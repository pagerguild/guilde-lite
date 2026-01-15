#!/bin/bash
# Multi-Agent Workflow Metrics Tracking
# Tracks compliance with multi-agent workflow requirements
#
# Usage:
#   bash scripts/multi-agent-metrics.sh track <event> [details]
#   bash scripts/multi-agent-metrics.sh report
#   bash scripts/multi-agent-metrics.sh reset
#
# Events:
#   code_change_no_review   - Code written without code-reviewer invoked
#   code_change_reviewed    - Code properly reviewed by agent
#   research_single_agent   - Research done with single agent
#   research_parallel       - Research done with parallel agents
#   validation_skipped      - Validation not performed
#   validation_complete     - Proper validation with agents
#   agent_invoked           - Any subagent invoked (track type)

set -euo pipefail

METRICS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/multi-agent-metrics"
METRICS_FILE="$METRICS_DIR/metrics.jsonl"
SESSION_FILE="$METRICS_DIR/session-$(date +%Y%m%d).json"

mkdir -p "$METRICS_DIR"

# Initialize metrics file if needed
if [[ ! -f "$METRICS_FILE" ]]; then
    echo '{"initialized":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}' > "$METRICS_FILE"
fi

# Session tracking for code changes without reviews
SESSION_CHANGES_FILE="$METRICS_DIR/.pending_changes"
touch "$SESSION_CHANGES_FILE"

track_event() {
    local event="$1"
    local details="${2:-}"

    # Validate event name against allowed events
    local valid_events="code_change_no_review code_change_reviewed research_single_agent research_parallel validation_skipped validation_complete agent_invoked"
    if ! echo "$valid_events" | grep -qw "$event"; then
        echo "Error: Unknown event '$event'" >&2
        echo "Valid events: $valid_events" >&2
        return 1
    fi

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Sanitize event and project to prevent JSON injection
    local project
    project=$(basename "$(pwd)" | tr -d '"\n\\' | cut -c1-100)
    event=$(printf '%s' "$event" | tr -d '"\n\\' | cut -c1-100)

    # Escape details for JSON (avoid command injection)
    if [[ -n "$details" ]]; then
        # Sanitize: remove quotes, newlines, backslashes
        details=$(printf '%s' "$details" | tr -d '"\n\\' | cut -c1-200)
    fi

    # Create JSON event using printf for safety
    local json
    if [[ -n "$details" ]]; then
        json=$(printf '{"ts":"%s","event":"%s","project":"%s","details":"%s"}' \
            "$timestamp" "$event" "$project" "$details")
    else
        json=$(printf '{"ts":"%s","event":"%s","project":"%s"}' \
            "$timestamp" "$event" "$project")
    fi

    echo "$json" >> "$METRICS_FILE"

    # Categorize event for display
    case "$event" in
        code_change_no_review|research_single_agent|validation_skipped)
            echo -e "\033[0;31m📊 Multi-agent violation: $event\033[0m" >&2
            ;;
        code_change_reviewed|research_parallel|validation_complete|agent_invoked)
            echo -e "\033[0;32m📊 Multi-agent compliant: $event\033[0m" >&2
            ;;
    esac

    # Track pending code changes
    case "$event" in
        code_change_no_review)
            echo "$timestamp" >> "$SESSION_CHANGES_FILE"
            ;;
        code_change_reviewed)
            # Clear pending changes when reviewed
            : > "$SESSION_CHANGES_FILE"
            ;;
    esac
}

check_pending_reviews() {
    # Check if there are code changes that haven't been reviewed
    if [[ -s "$SESSION_CHANGES_FILE" ]]; then
        local count
        count=$(wc -l < "$SESSION_CHANGES_FILE" | tr -d ' ')
        if [[ "$count" -gt 0 ]]; then
            echo -e "\033[0;33m⚠️  WARNING: $count code change(s) pending review\033[0m" >&2
            echo -e "\033[0;33m   Run code-reviewer agent before committing!\033[0m" >&2
            return 1
        fi
    fi
    return 0
}

generate_report() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "   Multi-Agent Workflow Compliance Report"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    if [[ ! -f "$METRICS_FILE" ]]; then
        echo "No metrics recorded yet."
        return 0
    fi

    # Count events (strip whitespace)
    local total
    total=$(wc -l < "$METRICS_FILE" | tr -d ' ')

    local no_review
    no_review=$(grep -c '"event":"code_change_no_review"' "$METRICS_FILE" 2>/dev/null || echo "0")
    no_review=$(echo "$no_review" | tr -d ' \n')
    [[ -z "$no_review" ]] && no_review=0

    local reviewed
    reviewed=$(grep -c '"event":"code_change_reviewed"' "$METRICS_FILE" 2>/dev/null || echo "0")
    reviewed=$(echo "$reviewed" | tr -d ' \n')
    [[ -z "$reviewed" ]] && reviewed=0

    local single_research
    single_research=$(grep -c '"event":"research_single_agent"' "$METRICS_FILE" 2>/dev/null || echo "0")
    single_research=$(echo "$single_research" | tr -d ' \n')
    [[ -z "$single_research" ]] && single_research=0

    local parallel_research
    parallel_research=$(grep -c '"event":"research_parallel"' "$METRICS_FILE" 2>/dev/null || echo "0")
    parallel_research=$(echo "$parallel_research" | tr -d ' \n')
    [[ -z "$parallel_research" ]] && parallel_research=0

    local validation_skip
    validation_skip=$(grep -c '"event":"validation_skipped"' "$METRICS_FILE" 2>/dev/null || echo "0")
    validation_skip=$(echo "$validation_skip" | tr -d ' \n')
    [[ -z "$validation_skip" ]] && validation_skip=0

    local validation_done
    validation_done=$(grep -c '"event":"validation_complete"' "$METRICS_FILE" 2>/dev/null || echo "0")
    validation_done=$(echo "$validation_done" | tr -d ' \n')
    [[ -z "$validation_done" ]] && validation_done=0

    local agents_invoked
    agents_invoked=$(grep -c '"event":"agent_invoked"' "$METRICS_FILE" 2>/dev/null || echo "0")
    agents_invoked=$(echo "$agents_invoked" | tr -d ' \n')
    [[ -z "$agents_invoked" ]] && agents_invoked=0

    # Calculate totals
    local total_violations=$((no_review + single_research + validation_skip))
    local total_compliant=$((reviewed + parallel_research + validation_done))

    echo "📈 Summary"
    echo "───────────────────────────────────────────────────────────────"
    printf "  Total events:        %d\n" "$((total - 1))"  # Exclude init line
    printf "  Agents invoked:      %d\n" "$agents_invoked"
    echo ""

    echo "❌ Violations (multi-agent workflow)"
    echo "───────────────────────────────────────────────────────────────"
    printf "  Code without review: %d\n" "$no_review"
    printf "  Single-agent research: %d\n" "$single_research"
    printf "  Validation skipped:  %d\n" "$validation_skip"
    printf "  ─────────────────────\n"
    printf "  Total violations:    %d\n" "$total_violations"
    echo ""

    echo "✅ Compliant Usage"
    echo "───────────────────────────────────────────────────────────────"
    printf "  Code reviewed:       %d\n" "$reviewed"
    printf "  Parallel research:   %d\n" "$parallel_research"
    printf "  Validation complete: %d\n" "$validation_done"
    printf "  ─────────────────────\n"
    printf "  Total compliant:     %d\n" "$total_compliant"
    echo ""

    # Calculate compliance rate
    local total_ops=$((total_violations + total_compliant))
    if [[ $total_ops -gt 0 ]]; then
        local compliance_rate=$((100 * total_compliant / total_ops))
        echo "📊 Compliance Rate"
        echo "───────────────────────────────────────────────────────────────"
        printf "  Multi-agent compliance: %d%%\n" "$compliance_rate"

        # Visual bar
        local filled=$((compliance_rate / 5))
        local empty=$((20 - filled))
        printf "  ["
        for ((i=0; i<filled; i++)); do printf '█'; done
        for ((i=0; i<empty; i++)); do printf '░'; done
        printf "] %d%%\n" "$compliance_rate"

        # Color-coded status
        if [[ $compliance_rate -ge 80 ]]; then
            echo -e "  Status: \033[0;32mExcellent\033[0m"
        elif [[ $compliance_rate -ge 60 ]]; then
            echo -e "  Status: \033[0;33mNeeds Improvement\033[0m"
        else
            echo -e "  Status: \033[0;31mPoor - Review Required\033[0m"
        fi
    fi
    echo ""

    # Pending reviews warning
    if [[ -s "$SESSION_CHANGES_FILE" ]]; then
        local pending
        pending=$(wc -l < "$SESSION_CHANGES_FILE" | tr -d ' ')
        if [[ "$pending" -gt 0 ]]; then
            echo "⚠️  PENDING REVIEWS"
            echo "───────────────────────────────────────────────────────────────"
            printf "  %d code change(s) awaiting review\n" "$pending"
            echo "  Run: code-reviewer agent before committing"
            echo ""
        fi
    fi

    # Recent events
    echo "📅 Recent Events (last 10)"
    echo "───────────────────────────────────────────────────────────────"
    tail -10 "$METRICS_FILE" | while read -r line; do
        local ts
        ts=$(echo "$line" | grep -o '"ts":"[^"]*"' | cut -d'"' -f4 | cut -d'T' -f1 || echo "")
        local event
        event=$(echo "$line" | grep -o '"event":"[^"]*"' | cut -d'"' -f4 || echo "")

        if [[ -n "$event" ]]; then
            case "$event" in
                *no_review*|*single*|*skipped*)
                    printf "  \033[0;31m%-12s\033[0m %s\n" "$ts" "$event"
                    ;;
                *)
                    printf "  \033[0;32m%-12s\033[0m %s\n" "$ts" "$event"
                    ;;
            esac
        fi
    done || true
    echo ""
}

reset_metrics() {
    if [[ -f "$METRICS_FILE" ]]; then
        local backup="$METRICS_DIR/metrics-backup-$(date +%Y%m%d%H%M%S).jsonl"
        mv "$METRICS_FILE" "$backup"
        echo "Backed up to: $backup"
    fi
    echo '{"initialized":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","reset":true}' > "$METRICS_FILE"
    : > "$SESSION_CHANGES_FILE"
    echo "Metrics reset."
}

export_json() {
    local no_review
    no_review=$(grep -c '"event":"code_change_no_review"' "$METRICS_FILE" 2>/dev/null || echo "0")
    no_review=$(echo "$no_review" | tr -d ' \n')
    [[ -z "$no_review" ]] && no_review=0

    local reviewed
    reviewed=$(grep -c '"event":"code_change_reviewed"' "$METRICS_FILE" 2>/dev/null || echo "0")
    reviewed=$(echo "$reviewed" | tr -d ' \n')
    [[ -z "$reviewed" ]] && reviewed=0

    local single_research
    single_research=$(grep -c '"event":"research_single_agent"' "$METRICS_FILE" 2>/dev/null || echo "0")
    single_research=$(echo "$single_research" | tr -d ' \n')
    [[ -z "$single_research" ]] && single_research=0

    local parallel_research
    parallel_research=$(grep -c '"event":"research_parallel"' "$METRICS_FILE" 2>/dev/null || echo "0")
    parallel_research=$(echo "$parallel_research" | tr -d ' \n')
    [[ -z "$parallel_research" ]] && parallel_research=0

    local validation_skip
    validation_skip=$(grep -c '"event":"validation_skipped"' "$METRICS_FILE" 2>/dev/null || echo "0")
    validation_skip=$(echo "$validation_skip" | tr -d ' \n')
    [[ -z "$validation_skip" ]] && validation_skip=0

    local validation_done
    validation_done=$(grep -c '"event":"validation_complete"' "$METRICS_FILE" 2>/dev/null || echo "0")
    validation_done=$(echo "$validation_done" | tr -d ' \n')
    [[ -z "$validation_done" ]] && validation_done=0

    local agents_invoked
    agents_invoked=$(grep -c '"event":"agent_invoked"' "$METRICS_FILE" 2>/dev/null || echo "0")
    agents_invoked=$(echo "$agents_invoked" | tr -d ' \n')
    [[ -z "$agents_invoked" ]] && agents_invoked=0

    local total_violations=$((no_review + single_research + validation_skip))
    local total_compliant=$((reviewed + parallel_research + validation_done))
    local total=$((total_violations + total_compliant))
    local compliance_rate=0
    if [[ $total -gt 0 ]]; then
        compliance_rate=$((100 * total_compliant / total))
    fi

    cat << EOF
{
  "generated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "violations": {
    "code_no_review": $no_review,
    "single_agent_research": $single_research,
    "validation_skipped": $validation_skip,
    "total": $total_violations
  },
  "compliant": {
    "code_reviewed": $reviewed,
    "parallel_research": $parallel_research,
    "validation_complete": $validation_done,
    "total": $total_compliant
  },
  "agents_invoked": $agents_invoked,
  "compliance_rate_percent": $compliance_rate
}
EOF
}

# Main dispatch
case "${1:-report}" in
    track)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 track <event> [details]"
            exit 1
        fi
        track_event "$2" "${3:-}"
        ;;
    check)
        check_pending_reviews
        ;;
    report)
        generate_report
        ;;
    json)
        export_json
        ;;
    reset)
        reset_metrics
        ;;
    *)
        echo "Usage: $0 {track|check|report|json|reset}"
        echo ""
        echo "Commands:"
        echo "  track <event> [details]  - Record a metric event"
        echo "  check                    - Check for pending reviews"
        echo "  report                   - Show compliance report"
        echo "  json                     - Export metrics as JSON"
        echo "  reset                    - Reset metrics (with backup)"
        echo ""
        echo "Events:"
        echo "  code_change_no_review    - Code written without review"
        echo "  code_change_reviewed     - Code properly reviewed"
        echo "  research_single_agent    - Single-agent research"
        echo "  research_parallel        - Parallel agent research"
        echo "  validation_skipped       - Validation not performed"
        echo "  validation_complete      - Proper validation done"
        echo "  agent_invoked            - Subagent invoked"
        exit 1
        ;;
esac
