#!/bin/bash
# Telemetry Hook Script
# Collects and emits telemetry for Claude Code sessions
#
# Usage:
#   bash scripts/telemetry-hook.sh session-start     - Initialize session tracking
#   bash scripts/telemetry-hook.sh session-end       - Finalize session metrics
#   bash scripts/telemetry-hook.sh pre-tool <json>   - Track tool invocation start
#   bash scripts/telemetry-hook.sh post-tool <json>  - Track tool completion
#   bash scripts/telemetry-hook.sh pre-compact       - Track context compaction
#   bash scripts/telemetry-hook.sh emit-metrics      - Send metrics to OTEL
#   bash scripts/telemetry-hook.sh status            - Show current session stats
#   bash scripts/telemetry-hook.sh report            - Generate session report
#
# Environment:
#   OTEL_EXPORTER_OTLP_ENDPOINT - OTEL collector endpoint (default: http://localhost:4317)
#   GUILDE_TELEMETRY_DEBUG      - Enable debug output (default: false)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
STATE_DIR="${GUILDE_TELEMETRY_STATE_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/guilde-telemetry}"
SESSION_FILE="$STATE_DIR/current_session.json"
HISTORY_DIR="$STATE_DIR/history"
OTEL_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4317}"
DEBUG="${GUILDE_TELEMETRY_DEBUG:-false}"

mkdir -p "$STATE_DIR" "$HISTORY_DIR"
LOCK_FILE="$STATE_DIR/.lock"
ERROR_LOG="$STATE_DIR/errors.log"

# Atomic write - prevents race conditions with temp file + mv
atomic_write() {
    local file="$1"
    local content="$2"
    local tmp_file="${file}.tmp.$$"
    echo "$content" > "$tmp_file" && mv "$tmp_file" "$file"
}

# Safe JSON update with file locking
safe_json_update() {
    local jq_filter="$1"
    shift
    local jq_args=("$@")

    (
        flock -x 200 2>/dev/null || true  # Graceful fallback if flock unavailable
        if [[ -f "$SESSION_FILE" ]]; then
            local updated
            updated=$(jq "${jq_args[@]}" "$jq_filter" "$SESSION_FILE" 2>>"$ERROR_LOG")
            if [[ -n "$updated" ]]; then
                atomic_write "$SESSION_FILE" "$updated"
            fi
        fi
    ) 200>"$LOCK_FILE"
}

# Debug logging
debug_log() {
    if [[ "$DEBUG" == "true" ]]; then
        echo -e "${CYAN}[telemetry-debug]${NC} $*" >&2
    fi
}

# Generate unique session ID
generate_session_id() {
    echo "session-$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 4)"
}

# Get current timestamp in milliseconds
timestamp_ms() {
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS: use perl for milliseconds
        perl -MTime::HiRes=time -e 'printf "%.0f\n", time * 1000'
    else
        date +%s%3N
    fi
}

# Initialize session tracking
session_start() {
    local session_id
    session_id=$(generate_session_id)
    local start_time
    start_time=$(timestamp_ms)

    # Create session state
    jq -n \
        --arg id "$session_id" \
        --arg start "$start_time" \
        --arg cwd "$(pwd)" \
        '{
            session_id: $id,
            start_time: ($start | tonumber),
            working_directory: $cwd,
            metrics: {
                tool_calls: {},
                skills_invoked: [],
                compaction_count: 0,
                total_tool_calls: 0,
                successful_tool_calls: 0,
                failed_tool_calls: 0,
                agents_spawned: []
            },
            timeline: []
        }' > "$SESSION_FILE"

    debug_log "Session started: $session_id"

    # Emit session start event
    emit_event "session_start" "{\"session_id\":\"$session_id\"}"

    echo -e "${GREEN}Telemetry session started:${NC} $session_id"
}

# End session and archive
session_end() {
    if [[ ! -f "$SESSION_FILE" ]]; then
        echo -e "${YELLOW}No active session to end${NC}"
        return 0
    fi

    local session_id end_time duration
    session_id=$(jq -r '.session_id' "$SESSION_FILE")
    end_time=$(timestamp_ms)
    local start_time
    start_time=$(jq -r '.start_time' "$SESSION_FILE")
    duration=$((end_time - start_time))

    # Update session with end time (atomic)
    (
        flock -x 200 2>/dev/null || true
        local updated
        updated=$(jq \
            --arg end "$end_time" \
            --arg dur "$duration" \
            '. + {end_time: ($end | tonumber), duration_ms: ($dur | tonumber)}' \
            "$SESSION_FILE")
        atomic_write "$SESSION_FILE" "$updated"
    ) 200>"$LOCK_FILE"

    # Emit final metrics
    emit_metrics

    # Archive session
    local archive_file="$HISTORY_DIR/${session_id}.json"
    cp "$SESSION_FILE" "$archive_file"

    # Emit session end event
    emit_event "session_end" "{\"session_id\":\"$session_id\",\"duration_ms\":$duration}"

    echo -e "${GREEN}Session ended:${NC} $session_id"
    echo -e "Duration: $((duration / 1000))s"
    echo -e "Archived to: $archive_file"

    # Clean up current session
    rm -f "$SESSION_FILE"
}

# Track tool invocation (PreToolUse)
pre_tool() {
    local tool_data="${1:-}"

    if [[ ! -f "$SESSION_FILE" ]]; then
        debug_log "No active session, skipping pre_tool"
        return 0
    fi

    local tool_name timestamp
    tool_name=$(echo "$tool_data" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
    timestamp=$(timestamp_ms)

    # Record tool start in timeline (atomic)
    safe_json_update \
        '.timeline += [{
            event: "tool_start",
            tool: $tool,
            timestamp: ($ts | tonumber)
        }]' \
        --arg tool "$tool_name" \
        --arg ts "$timestamp"

    debug_log "Tool started: $tool_name"
}

# Track tool completion (PostToolUse)
post_tool() {
    local tool_data="${1:-}"

    if [[ ! -f "$SESSION_FILE" ]]; then
        debug_log "No active session, skipping post_tool"
        return 0
    fi

    local tool_name status timestamp
    tool_name=$(echo "$tool_data" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
    status=$(echo "$tool_data" | jq -r '.status // "success"' 2>/dev/null || echo "success")
    timestamp=$(timestamp_ms)

    # Update metrics (atomic)
    safe_json_update \
        '
        .metrics.total_tool_calls += 1 |
        .metrics.tool_calls[$tool] = ((.metrics.tool_calls[$tool] // 0) + 1) |
        (if $status == "success" then .metrics.successful_tool_calls += 1 else .metrics.failed_tool_calls += 1 end) |
        .timeline += [{
            event: "tool_end",
            tool: $tool,
            status: $status,
            timestamp: ($ts | tonumber)
        }]
        ' \
        --arg tool "$tool_name" \
        --arg status "$status" \
        --arg ts "$timestamp"

    # Check if this was a Task tool (agent spawn)
    if [[ "$tool_name" == "Task" ]]; then
        local subagent_type
        subagent_type=$(echo "$tool_data" | jq -r '.subagent_type // "unknown"' 2>/dev/null || echo "unknown")
        safe_json_update '.metrics.agents_spawned += [$agent]' --arg agent "$subagent_type"
    fi

    debug_log "Tool completed: $tool_name ($status)"
}

# Track context compaction (PreCompact)
pre_compact() {
    if [[ ! -f "$SESSION_FILE" ]]; then
        debug_log "No active session, skipping pre_compact"
        return 0
    fi

    local timestamp
    timestamp=$(timestamp_ms)

    # Update compaction count (atomic)
    safe_json_update \
        '
        .metrics.compaction_count += 1 |
        .timeline += [{
            event: "context_compaction",
            count: .metrics.compaction_count,
            timestamp: ($ts | tonumber)
        }]
        ' \
        --arg ts "$timestamp"

    # Emit compaction metric immediately
    emit_metric "claude_context_compaction_total" "1" "session_id=$(jq -r '.session_id // \"unknown\"' "$SESSION_FILE" 2>/dev/null)"

    debug_log "Context compacted (count: $(jq '.metrics.compaction_count' "$SESSION_FILE" 2>/dev/null))"
}

# Track skill/command invocation
track_skill() {
    local skill_name="${1:-unknown}"

    if [[ ! -f "$SESSION_FILE" ]]; then
        return 0
    fi

    local timestamp
    timestamp=$(timestamp_ms)

    # Update skills (atomic)
    safe_json_update \
        '
        .metrics.skills_invoked += [$skill] |
        .timeline += [{
            event: "skill_invoked",
            skill: $skill,
            timestamp: ($ts | tonumber)
        }]
        ' \
        --arg skill "$skill_name" \
        --arg ts "$timestamp"

    debug_log "Skill invoked: $skill_name"
}

# Get HTTP endpoint from gRPC endpoint
get_http_endpoint() {
    local http_endpoint="${OTEL_ENDPOINT%:4317}:4318"
    # Handle case where endpoint already uses HTTP port
    if [[ "$OTEL_ENDPOINT" == *":4318"* ]]; then
        http_endpoint="$OTEL_ENDPOINT"
    fi
    echo "$http_endpoint"
}

# Emit a single metric to OTEL (via OTLP/HTTP)
emit_metric() {
    local name="$1"
    local value="$2"
    local labels="${3:-}"

    local http_endpoint
    http_endpoint=$(get_http_endpoint)
    local timestamp_ns
    timestamp_ns=$(( $(timestamp_ms) * 1000000 ))

    # Build OTLP metric JSON payload
    local payload
    payload=$(jq -n \
        --arg name "$name" \
        --arg value "$value" \
        --argjson ts "$timestamp_ns" \
        --arg svc "${OTEL_SERVICE_NAME:-claude-code}" \
        '{
            resourceMetrics: [{
                resource: {
                    attributes: [{
                        key: "service.name",
                        value: { stringValue: $svc }
                    }]
                },
                scopeMetrics: [{
                    scope: { name: "guilde-telemetry" },
                    metrics: [{
                        name: $name,
                        sum: {
                            dataPoints: [{
                                asInt: ($value | tonumber),
                                timeUnixNano: $ts,
                                startTimeUnixNano: $ts
                            }],
                            aggregationTemporality: 2,
                            isMonotonic: true
                        }
                    }]
                }]
            }]
        }')

    # Send to OTEL collector (non-blocking, fire-and-forget)
    curl -s --connect-timeout 1 --max-time 2 \
        -X POST "$http_endpoint/v1/metrics" \
        -H "Content-Type: application/json" \
        -d "$payload" > /dev/null 2>&1 &

    debug_log "Emitting metric: $name=$value to $http_endpoint"
}

# Emit event/log to OTEL
emit_event() {
    local event_name="$1"
    local event_data="$2"

    local http_endpoint
    http_endpoint=$(get_http_endpoint)
    local timestamp_ns
    timestamp_ns=$(( $(timestamp_ms) * 1000000 ))

    # Build OTLP log payload
    local payload
    payload=$(jq -n \
        --arg name "$event_name" \
        --arg body "$event_data" \
        --argjson ts "$timestamp_ns" \
        --arg svc "${OTEL_SERVICE_NAME:-claude-code}" \
        '{
            resourceLogs: [{
                resource: {
                    attributes: [{
                        key: "service.name",
                        value: { stringValue: $svc }
                    }]
                },
                scopeLogs: [{
                    scope: { name: "guilde-telemetry" },
                    logRecords: [{
                        timeUnixNano: $ts,
                        severityNumber: 9,
                        severityText: "INFO",
                        body: { stringValue: $body },
                        attributes: [{
                            key: "event.name",
                            value: { stringValue: $name }
                        }]
                    }]
                }]
            }]
        }')

    # Send to OTEL collector (non-blocking, fire-and-forget)
    curl -s --connect-timeout 1 --max-time 2 \
        -X POST "$http_endpoint/v1/logs" \
        -H "Content-Type: application/json" \
        -d "$payload" > /dev/null 2>&1 &

    debug_log "Event: $event_name - $event_data"
}

# Emit all session metrics to OTEL
emit_metrics() {
    if [[ ! -f "$SESSION_FILE" ]]; then
        echo -e "${YELLOW}No active session${NC}"
        return 0
    fi

    local session_id
    session_id=$(jq -r '.session_id' "$SESSION_FILE")

    echo -e "${BLUE}Emitting metrics for session:${NC} $session_id"

    # Read metrics
    local total_calls successful_calls failed_calls compaction_count
    total_calls=$(jq '.metrics.total_tool_calls' "$SESSION_FILE")
    successful_calls=$(jq '.metrics.successful_tool_calls' "$SESSION_FILE")
    failed_calls=$(jq '.metrics.failed_tool_calls' "$SESSION_FILE")
    compaction_count=$(jq '.metrics.compaction_count' "$SESSION_FILE")

    echo "  Total tool calls: $total_calls"
    echo "  Successful: $successful_calls"
    echo "  Failed: $failed_calls"
    echo "  Context compactions: $compaction_count"

    # Per-tool metrics
    echo -e "\n${CYAN}Tool usage:${NC}"
    jq -r '.metrics.tool_calls | to_entries | .[] | "  \(.key): \(.value)"' "$SESSION_FILE"

    # Agents spawned
    local agents_count
    agents_count=$(jq '.metrics.agents_spawned | length' "$SESSION_FILE")
    if [[ "$agents_count" -gt 0 ]]; then
        echo -e "\n${CYAN}Agents spawned ($agents_count):${NC}"
        jq -r '.metrics.agents_spawned | unique | .[]' "$SESSION_FILE" | while read -r agent; do
            local count
            count=$(jq --arg a "$agent" '[.metrics.agents_spawned[] | select(. == $a)] | length' "$SESSION_FILE")
            echo "  $agent: $count"
        done
    fi

    # Skills invoked
    local skills_count
    skills_count=$(jq '.metrics.skills_invoked | length' "$SESSION_FILE")
    if [[ "$skills_count" -gt 0 ]]; then
        echo -e "\n${CYAN}Skills invoked:${NC}"
        jq -r '.metrics.skills_invoked | unique | .[]' "$SESSION_FILE" | while read -r skill; do
            local count
            count=$(jq --arg s "$skill" '[.metrics.skills_invoked[] | select(. == $s)] | length' "$SESSION_FILE")
            echo "  $skill: $count"
        done
    fi
}

# Show current session status
show_status() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Telemetry Status${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Check OTEL endpoint
    local http_endpoint="${OTEL_ENDPOINT%:4317}:4318"
    if curl -s --connect-timeout 2 "$http_endpoint" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ OTEL Collector:${NC} $OTEL_ENDPOINT (reachable)"
    else
        echo -e "${YELLOW}⚠ OTEL Collector:${NC} $OTEL_ENDPOINT (not reachable)"
    fi

    echo ""

    # Current session
    if [[ -f "$SESSION_FILE" ]]; then
        local session_id start_time duration_sec
        session_id=$(jq -r '.session_id' "$SESSION_FILE")
        start_time=$(jq -r '.start_time' "$SESSION_FILE")
        local now
        now=$(timestamp_ms)
        duration_sec=$(( (now - start_time) / 1000 ))

        echo -e "${GREEN}Active session:${NC} $session_id"
        echo -e "  Duration: ${duration_sec}s"
        echo -e "  Tool calls: $(jq '.metrics.total_tool_calls' "$SESSION_FILE")"
        echo -e "  Compactions: $(jq '.metrics.compaction_count' "$SESSION_FILE")"
    else
        echo -e "${YELLOW}No active session${NC}"
    fi

    echo ""

    # History stats
    local history_count
    history_count=$(find "$HISTORY_DIR" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "${CYAN}Session history:${NC} $history_count archived sessions"

    if [[ "$history_count" -gt 0 ]]; then
        echo -e "\n${CYAN}Recent sessions:${NC}"
        # shellcheck disable=SC2012
        ls -t "$HISTORY_DIR"/*.json 2>/dev/null | head -5 | while read -r file; do
            local sid duration tools
            sid=$(jq -r '.session_id' "$file" 2>/dev/null)
            duration=$(jq -r '.duration_ms // 0' "$file" 2>/dev/null)
            tools=$(jq -r '.metrics.total_tool_calls // 0' "$file" 2>/dev/null)
            echo "  $sid: $((duration / 1000))s, $tools tool calls"
        done
    fi
}

# Generate detailed session report
generate_report() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Telemetry Report${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    if [[ -f "$SESSION_FILE" ]]; then
        echo -e "${CYAN}Current Session${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        emit_metrics
        echo ""
    fi

    # Aggregate stats from history
    local history_count
    history_count=$(find "$HISTORY_DIR" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$history_count" -gt 0 ]]; then
        echo -e "${CYAN}Historical Analysis ($history_count sessions)${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        # Aggregate metrics
        local total_duration=0 total_tools=0 total_compactions=0

        for file in "$HISTORY_DIR"/*.json; do
            if [[ -f "$file" ]]; then
                local dur tools comp
                dur=$(jq -r '.duration_ms // 0' "$file" 2>/dev/null)
                tools=$(jq -r '.metrics.total_tool_calls // 0' "$file" 2>/dev/null)
                comp=$(jq -r '.metrics.compaction_count // 0' "$file" 2>/dev/null)
                total_duration=$((total_duration + dur))
                total_tools=$((total_tools + tools))
                total_compactions=$((total_compactions + comp))
            fi
        done

        echo "Total session time: $((total_duration / 1000 / 60)) minutes"
        echo "Total tool calls: $total_tools"
        echo "Total compactions: $total_compactions"
        echo "Average tools/session: $((total_tools / history_count))"

        # Most used tools across all sessions
        echo -e "\n${CYAN}Most Used Tools (all sessions):${NC}"
        cat "$HISTORY_DIR"/*.json 2>/dev/null | \
            jq -s '[.[].metrics.tool_calls | to_entries[]] | group_by(.key) | map({tool: .[0].key, count: ([.[].value] | add)}) | sort_by(-.count) | .[:10][] | "\(.tool): \(.count)"' 2>/dev/null | \
            while read -r line; do echo "  $line"; done
    fi
}

# Main dispatch
case "${1:-status}" in
    session-start|start)
        session_start
        ;;
    session-end|end)
        session_end
        ;;
    pre-tool)
        pre_tool "${2:-}"
        ;;
    post-tool)
        post_tool "${2:-}"
        ;;
    pre-compact|compact)
        pre_compact
        ;;
    skill)
        track_skill "${2:-}"
        ;;
    emit|emit-metrics)
        emit_metrics
        ;;
    status)
        show_status
        ;;
    report)
        generate_report
        ;;
    *)
        echo "Telemetry Hook Script"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  session-start      Initialize session tracking"
        echo "  session-end        Finalize and archive session"
        echo "  pre-tool <json>    Track tool invocation start"
        echo "  post-tool <json>   Track tool completion"
        echo "  pre-compact        Track context compaction"
        echo "  skill <name>       Track skill/command invocation"
        echo "  emit-metrics       Emit all metrics to OTEL"
        echo "  status             Show telemetry status"
        echo "  report             Generate detailed report"
        exit 1
        ;;
esac
