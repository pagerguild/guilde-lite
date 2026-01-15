#!/bin/bash
# Mise Adoption Metrics Tracking
# Tracks mise-first pattern adoption and violations
#
# Usage:
#   bash scripts/mise-metrics.sh track <event> [details]
#   bash scripts/mise-metrics.sh report
#   bash scripts/mise-metrics.sh reset
#
# Events:
#   pip_violation     - Direct pip install detected
#   npm_violation     - Global npm install detected
#   legacy_violation  - Legacy tool (nvm/pyenv/rbenv) usage
#   mise_install      - Tool installed via mise
#   mise_use          - Tool added via mise use
#   uv_usage          - uv/uvx used (good)
#   bun_usage         - bun used (good)

set -euo pipefail

METRICS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/mise-metrics"
METRICS_FILE="$METRICS_DIR/metrics.jsonl"
DAILY_SUMMARY="$METRICS_DIR/daily-$(date +%Y-%m-%d).json"

mkdir -p "$METRICS_DIR"

# Initialize metrics file if needed
if [[ ! -f "$METRICS_FILE" ]]; then
    echo '{"initialized":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > "$METRICS_FILE"
fi

track_event() {
    local event="$1"
    local details="${2:-}"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local project=$(basename "$(pwd)")

    # Create JSON event
    local json="{\"ts\":\"$timestamp\",\"event\":\"$event\",\"project\":\"$project\""
    if [[ -n "$details" ]]; then
        # Escape details for JSON
        details=$(echo "$details" | sed 's/"/\\"/g' | tr '\n' ' ')
        json="$json,\"details\":\"$details\""
    fi
    json="$json}"

    echo "$json" >> "$METRICS_FILE"

    # Categorize event
    case "$event" in
        pip_violation|npm_violation|legacy_violation)
            echo -e "\033[0;33m📊 Mise metric: $event recorded\033[0m" >&2
            ;;
        mise_install|mise_use|uv_usage|bun_usage)
            echo -e "\033[0;32m📊 Mise metric: $event recorded\033[0m" >&2
            ;;
    esac
}

generate_report() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "   Mise Adoption Metrics Report"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    if [[ ! -f "$METRICS_FILE" ]]; then
        echo "No metrics recorded yet."
        return 0
    fi

    # Count events (use tr to strip whitespace/newlines)
    local total=$(wc -l < "$METRICS_FILE" | tr -d ' \n')
    local pip_violations=$(grep -c '"event":"pip_violation"' "$METRICS_FILE" 2>/dev/null | tr -d ' \n' || echo 0)
    local npm_violations=$(grep -c '"event":"npm_violation"' "$METRICS_FILE" 2>/dev/null | tr -d ' \n' || echo 0)
    local legacy_violations=$(grep -c '"event":"legacy_violation"' "$METRICS_FILE" 2>/dev/null | tr -d ' \n' || echo 0)
    local mise_installs=$(grep -c '"event":"mise_install"' "$METRICS_FILE" 2>/dev/null | tr -d ' \n' || echo 0)
    local mise_uses=$(grep -c '"event":"mise_use"' "$METRICS_FILE" 2>/dev/null | tr -d ' \n' || echo 0)
    local uv_uses=$(grep -c '"event":"uv_usage"' "$METRICS_FILE" 2>/dev/null | tr -d ' \n' || echo 0)
    local bun_uses=$(grep -c '"event":"bun_usage"' "$METRICS_FILE" 2>/dev/null | tr -d ' \n' || echo 0)

    # Default to 0 if empty
    [[ -z "$pip_violations" ]] && pip_violations=0
    [[ -z "$npm_violations" ]] && npm_violations=0
    [[ -z "$legacy_violations" ]] && legacy_violations=0
    [[ -z "$mise_installs" ]] && mise_installs=0
    [[ -z "$mise_uses" ]] && mise_uses=0
    [[ -z "$uv_uses" ]] && uv_uses=0
    [[ -z "$bun_uses" ]] && bun_uses=0

    # Calculate totals
    local total_violations=$((pip_violations + npm_violations + legacy_violations))
    local total_compliant=$((mise_installs + mise_uses + uv_uses + bun_uses))

    echo "📈 Summary"
    echo "───────────────────────────────────────────────────────────────"
    printf "  Total events:      %d\n" "$((total - 1))"  # Exclude init line
    echo ""

    echo "❌ Violations (mise-first pattern)"
    echo "───────────────────────────────────────────────────────────────"
    printf "  pip install:       %d\n" "$pip_violations"
    printf "  npm -g install:    %d\n" "$npm_violations"
    printf "  legacy tools:      %d\n" "$legacy_violations"
    printf "  ─────────────────────\n"
    printf "  Total violations:  %d\n" "$total_violations"
    echo ""

    echo "✅ Compliant Usage"
    echo "───────────────────────────────────────────────────────────────"
    printf "  mise install:      %d\n" "$mise_installs"
    printf "  mise use:          %d\n" "$mise_uses"
    printf "  uv/uvx:            %d\n" "$uv_uses"
    printf "  bun:               %d\n" "$bun_uses"
    printf "  ─────────────────────\n"
    printf "  Total compliant:   %d\n" "$total_compliant"
    echo ""

    # Calculate adoption rate
    local total_tool_ops=$((total_violations + total_compliant))
    if [[ $total_tool_ops -gt 0 ]]; then
        local adoption_rate=$((100 * total_compliant / total_tool_ops))
        echo "📊 Adoption Rate"
        echo "───────────────────────────────────────────────────────────────"
        printf "  Mise-first adoption: %d%%\n" "$adoption_rate"

        # Visual bar
        local filled=$((adoption_rate / 5))
        local empty=$((20 - filled))
        printf "  ["
        for ((i=0; i<filled; i++)); do printf '█'; done
        for ((i=0; i<empty; i++)); do printf '░'; done
        printf "] %d%%\n" "$adoption_rate"
    fi
    echo ""

    # Recent events
    echo "📅 Recent Events (last 10)"
    echo "───────────────────────────────────────────────────────────────"
    tail -10 "$METRICS_FILE" | while read -r line; do
        local ts=$(echo "$line" | grep -o '"ts":"[^"]*"' | cut -d'"' -f4 | cut -d'T' -f1)
        local event=$(echo "$line" | grep -o '"event":"[^"]*"' | cut -d'"' -f4)
        local project=$(echo "$line" | grep -o '"project":"[^"]*"' | cut -d'"' -f4)

        if [[ -n "$event" ]]; then
            case "$event" in
                *violation*) printf "  \033[0;31m%-12s\033[0m %-20s %s\n" "$ts" "$event" "$project" ;;
                *)           printf "  \033[0;32m%-12s\033[0m %-20s %s\n" "$ts" "$event" "$project" ;;
            esac
        fi
    done
    echo ""
}

reset_metrics() {
    if [[ -f "$METRICS_FILE" ]]; then
        local backup="$METRICS_DIR/metrics-backup-$(date +%Y%m%d%H%M%S).jsonl"
        mv "$METRICS_FILE" "$backup"
        echo "Backed up to: $backup"
    fi
    echo '{"initialized":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","reset":true}' > "$METRICS_FILE"
    echo "Metrics reset."
}

export_json() {
    # Export as JSON summary
    local pip_violations=$(grep -c '"event":"pip_violation"' "$METRICS_FILE" 2>/dev/null || echo 0)
    local npm_violations=$(grep -c '"event":"npm_violation"' "$METRICS_FILE" 2>/dev/null || echo 0)
    local legacy_violations=$(grep -c '"event":"legacy_violation"' "$METRICS_FILE" 2>/dev/null || echo 0)
    local mise_installs=$(grep -c '"event":"mise_install"' "$METRICS_FILE" 2>/dev/null || echo 0)
    local mise_uses=$(grep -c '"event":"mise_use"' "$METRICS_FILE" 2>/dev/null || echo 0)
    local uv_uses=$(grep -c '"event":"uv_usage"' "$METRICS_FILE" 2>/dev/null || echo 0)
    local bun_uses=$(grep -c '"event":"bun_usage"' "$METRICS_FILE" 2>/dev/null || echo 0)

    local total_violations=$((pip_violations + npm_violations + legacy_violations))
    local total_compliant=$((mise_installs + mise_uses + uv_uses + bun_uses))
    local total=$((total_violations + total_compliant))
    local adoption_rate=0
    if [[ $total -gt 0 ]]; then
        adoption_rate=$((100 * total_compliant / total))
    fi

    cat << EOF
{
  "generated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "violations": {
    "pip": $pip_violations,
    "npm_global": $npm_violations,
    "legacy_tools": $legacy_violations,
    "total": $total_violations
  },
  "compliant": {
    "mise_install": $mise_installs,
    "mise_use": $mise_uses,
    "uv": $uv_uses,
    "bun": $bun_uses,
    "total": $total_compliant
  },
  "adoption_rate_percent": $adoption_rate
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
        echo "Usage: $0 {track|report|json|reset}"
        echo ""
        echo "Commands:"
        echo "  track <event> [details]  - Record a metric event"
        echo "  report                   - Show adoption report"
        echo "  json                     - Export metrics as JSON"
        echo "  reset                    - Reset metrics (with backup)"
        echo ""
        echo "Events:"
        echo "  pip_violation     - Direct pip install"
        echo "  npm_violation     - Global npm install"
        echo "  legacy_violation  - nvm/pyenv/rbenv usage"
        echo "  mise_install      - mise install"
        echo "  mise_use          - mise use"
        echo "  uv_usage          - uv/uvx usage"
        echo "  bun_usage         - bun usage"
        exit 1
        ;;
esac
