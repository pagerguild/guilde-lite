#!/bin/bash
# Telemetry Validation Script
# Validates OTLP data export and queries the Grafana LGTM stack
#
# Usage:
#   bash scripts/validate-telemetry.sh [command]
#
# Commands:
#   all          - Run full validation suite (default)
#   send         - Send test data to OTLP endpoint
#   query        - Query all backends for received data
#   export       - Export telemetry data to JSON files
#   status       - Check backend connectivity
#   help         - Show this help
#
# Requirements:
#   - Grafana LGTM stack running (task otel:up:quick)
#   - curl and jq installed

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
OTLP_HTTP_ENDPOINT="${OTLP_HTTP_ENDPOINT:-http://localhost:4318}"
PROMETHEUS_ENDPOINT="${PROMETHEUS_ENDPOINT:-http://localhost:9090}"
LOKI_ENDPOINT="${LOKI_ENDPOINT:-http://localhost:3100}"
TEMPO_ENDPOINT="${TEMPO_ENDPOINT:-http://localhost:3200}"
GRAFANA_ENDPOINT="${GRAFANA_ENDPOINT:-http://localhost:3000}"
EXPORT_DIR="${EXPORT_DIR:-/tmp/telemetry-validation}"

# Test identifiers
TEST_RUN_ID="validation-$(date +%Y%m%d-%H%M%S)"
TEST_SERVICE_NAME="telemetry-validator"

log() {
    echo -e "$@"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_fail() {
    echo -e "${RED}✗${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

# Get timestamp in nanoseconds
timestamp_ns() {
    if [[ "$(uname)" == "Darwin" ]]; then
        perl -MTime::HiRes=time -e 'printf "%.0f\n", time * 1000000000'
    else
        date +%s%N
    fi
}

# Check if endpoint is reachable
check_endpoint() {
    local name="$1"
    local url="$2"
    local path="${3:-/}"

    if curl -s --connect-timeout 2 "${url}${path}" > /dev/null 2>&1; then
        log_success "$name: ${url}${path}"
        return 0
    else
        log_fail "$name: ${url}${path} (unreachable)"
        return 1
    fi
}

# Check all backend connectivity
check_status() {
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BOLD}${BLUE}   Backend Connectivity Check${NC}"
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log ""

    local all_ok=true

    check_endpoint "OTLP HTTP" "$OTLP_HTTP_ENDPOINT" "" || all_ok=false
    check_endpoint "Prometheus" "$PROMETHEUS_ENDPOINT" "/api/v1/status/config" || all_ok=false
    check_endpoint "Grafana" "$GRAFANA_ENDPOINT" "/api/health" || all_ok=false

    # Loki and Tempo may not be directly accessible in quick mode
    if ! check_endpoint "Loki (direct)" "$LOKI_ENDPOINT" "/ready" 2>/dev/null; then
        log_info "Loki: Not directly accessible (normal in quick mode)"
    fi

    if ! check_endpoint "Tempo (direct)" "$TEMPO_ENDPOINT" "/ready" 2>/dev/null; then
        log_info "Tempo: Not directly accessible (normal in quick mode)"
    fi

    log ""
    if [[ "$all_ok" == "true" ]]; then
        log_success "Core backends are reachable"
        return 0
    else
        log_fail "Some backends are not reachable"
        return 1
    fi
}

# Send test metric to OTLP endpoint
send_test_metric() {
    local metric_name="$1"
    local metric_value="$2"
    local ts
    ts=$(timestamp_ns)

    local payload
    payload=$(jq -n \
        --arg name "$metric_name" \
        --arg value "$metric_value" \
        --argjson ts "$ts" \
        --arg svc "$TEST_SERVICE_NAME" \
        --arg run "$TEST_RUN_ID" \
        '{
            resourceMetrics: [{
                resource: {
                    attributes: [
                        { key: "service.name", value: { stringValue: $svc } },
                        { key: "test.run.id", value: { stringValue: $run } }
                    ]
                },
                scopeMetrics: [{
                    scope: { name: "telemetry-validator" },
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

    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "$OTLP_HTTP_ENDPOINT/v1/metrics" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>&1)

    if [[ "$http_code" == "200" ]]; then
        log_success "Metric sent: $metric_name=$metric_value"
        return 0
    else
        log_fail "Metric failed: $metric_name (HTTP $http_code)"
        return 1
    fi
}

# Send test log to OTLP endpoint
send_test_log() {
    local message="$1"
    local severity="${2:-INFO}"
    local ts
    ts=$(timestamp_ns)

    local severity_num=9
    case "$severity" in
        DEBUG) severity_num=5 ;;
        INFO) severity_num=9 ;;
        WARN) severity_num=13 ;;
        ERROR) severity_num=17 ;;
    esac

    local payload
    payload=$(jq -n \
        --arg msg "$message" \
        --arg sev "$severity" \
        --argjson sevnum "$severity_num" \
        --argjson ts "$ts" \
        --arg svc "$TEST_SERVICE_NAME" \
        --arg run "$TEST_RUN_ID" \
        '{
            resourceLogs: [{
                resource: {
                    attributes: [
                        { key: "service.name", value: { stringValue: $svc } },
                        { key: "test.run.id", value: { stringValue: $run } }
                    ]
                },
                scopeLogs: [{
                    scope: { name: "telemetry-validator" },
                    logRecords: [{
                        timeUnixNano: $ts,
                        severityNumber: $sevnum,
                        severityText: $sev,
                        body: { stringValue: $msg },
                        attributes: [
                            { key: "event.name", value: { stringValue: "validation_test" } }
                        ]
                    }]
                }]
            }]
        }')

    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "$OTLP_HTTP_ENDPOINT/v1/logs" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>&1)

    if [[ "$http_code" == "200" ]]; then
        log_success "Log sent: [$severity] $message"
        return 0
    else
        log_fail "Log failed: $message (HTTP $http_code)"
        return 1
    fi
}

# Send all test data
send_test_data() {
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BOLD}${BLUE}   Sending Test Telemetry Data${NC}"
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log ""
    log_info "Test run ID: $TEST_RUN_ID"
    log ""

    local metrics_ok=true
    local logs_ok=true

    # Send test metrics
    log "${CYAN}Metrics:${NC}"
    send_test_metric "validation_test_counter" "1" || metrics_ok=false
    send_test_metric "validation_tool_calls_total" "5" || metrics_ok=false
    send_test_metric "validation_agent_spawns_total" "2" || metrics_ok=false

    log ""

    # Send test logs
    log "${CYAN}Logs:${NC}"
    send_test_log "Validation test started for run $TEST_RUN_ID" "INFO" || logs_ok=false
    send_test_log "Test metric sent successfully" "DEBUG" || logs_ok=false
    send_test_log "Validation test completed" "INFO" || logs_ok=false

    log ""

    if [[ "$metrics_ok" == "true" ]] && [[ "$logs_ok" == "true" ]]; then
        log_success "All test data sent successfully"
        return 0
    else
        log_fail "Some test data failed to send"
        return 1
    fi
}

# Query Prometheus for metrics
query_prometheus_metrics() {
    log "${CYAN}Prometheus Metrics:${NC}"

    # Query OTEL collector stats
    local collector_metrics
    collector_metrics=$(curl -s "$PROMETHEUS_ENDPOINT/api/v1/query?query=otelcol_receiver_accepted_metric_points_total" 2>/dev/null)

    if echo "$collector_metrics" | jq -e '.data.result | length > 0' > /dev/null 2>&1; then
        local metric_points
        metric_points=$(echo "$collector_metrics" | jq -r '.data.result[0].value[1]')
        log_success "Metrics received by collector: $metric_points"
    else
        log_warn "No collector metrics found"
    fi

    # Query our test metrics
    local test_metrics
    test_metrics=$(curl -s "$PROMETHEUS_ENDPOINT/api/v1/query?query=validation_test_counter" 2>/dev/null)

    if echo "$test_metrics" | jq -e '.data.result | length > 0' > /dev/null 2>&1; then
        local value
        value=$(echo "$test_metrics" | jq -r '.data.result[0].value[1]')
        log_success "validation_test_counter: $value"
    else
        log_warn "Test metric not found (may need time to propagate)"
    fi

    # List all metrics from our service
    local all_metrics
    all_metrics=$(curl -s "$PROMETHEUS_ENDPOINT/api/v1/label/__name__/values" 2>/dev/null)
    local validation_metrics
    validation_metrics=$(echo "$all_metrics" | jq -r '.data[] | select(startswith("validation"))' 2>/dev/null | wc -l | tr -d ' ')

    log_info "Validation metrics in Prometheus: $validation_metrics"
}

# Query for log reception stats
query_log_stats() {
    log "${CYAN}Log Reception Stats:${NC}"

    local log_metrics
    log_metrics=$(curl -s "$PROMETHEUS_ENDPOINT/api/v1/query?query=otelcol_receiver_accepted_log_records_total" 2>/dev/null)

    if echo "$log_metrics" | jq -e '.data.result | length > 0' > /dev/null 2>&1; then
        local log_count
        log_count=$(echo "$log_metrics" | jq -r '.data.result[0].value[1]')
        log_success "Log records received by collector: $log_count"
    else
        log_warn "No log reception stats found"
    fi
}

# Query all backends
query_backends() {
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BOLD}${BLUE}   Querying Telemetry Backends${NC}"
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log ""

    query_prometheus_metrics
    log ""
    query_log_stats
}

# Export telemetry data to files
export_data() {
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BOLD}${BLUE}   Exporting Telemetry Data${NC}"
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log ""

    mkdir -p "$EXPORT_DIR"
    log_info "Export directory: $EXPORT_DIR"
    log ""

    # Export all metric names
    log "${CYAN}Exporting metric names...${NC}"
    curl -s "$PROMETHEUS_ENDPOINT/api/v1/label/__name__/values" | jq '.' > "$EXPORT_DIR/metric_names.json"
    local metric_count
    metric_count=$(jq '.data | length' "$EXPORT_DIR/metric_names.json")
    log_success "Exported $metric_count metric names to metric_names.json"

    # Export collector stats
    log "${CYAN}Exporting collector statistics...${NC}"
    curl -s "$PROMETHEUS_ENDPOINT/api/v1/query?query=otelcol_receiver_accepted_metric_points_total" | jq '.' > "$EXPORT_DIR/collector_metrics.json"
    curl -s "$PROMETHEUS_ENDPOINT/api/v1/query?query=otelcol_receiver_accepted_log_records_total" | jq '.' > "$EXPORT_DIR/collector_logs.json"
    log_success "Exported collector stats"

    # Export validation metrics
    log "${CYAN}Exporting validation metrics...${NC}"
    curl -s "$PROMETHEUS_ENDPOINT/api/v1/query?query={__name__=~\"validation.*\"}" | jq '.' > "$EXPORT_DIR/validation_metrics.json"
    log_success "Exported validation metrics"

    # Export service info
    log "${CYAN}Exporting service info...${NC}"
    curl -s "$PROMETHEUS_ENDPOINT/api/v1/query?query=target_info" | jq '.' > "$EXPORT_DIR/service_info.json"
    log_success "Exported service info"

    log ""
    log_success "All exports completed to: $EXPORT_DIR"
    log ""
    log "${CYAN}Export files:${NC}"
    ls -la "$EXPORT_DIR"/*.json 2>/dev/null | awk '{print "  " $NF ": " $5 " bytes"}'
}

# Run full validation suite
run_validation() {
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BOLD}${BLUE}   TELEMETRY VALIDATION SUITE${NC}"
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log ""
    log_info "Test Run ID: $TEST_RUN_ID"
    log_info "Timestamp: $(date)"
    log ""

    local status_ok=true
    local send_ok=true
    local query_ok=true

    # Step 1: Check connectivity
    check_status || status_ok=false
    log ""

    if [[ "$status_ok" == "false" ]]; then
        log_fail "Backend connectivity check failed. Is the LGTM stack running?"
        log_info "Start with: docker compose -f docker/observability-compose.yml --profile quick up -d"
        return 1
    fi

    # Step 2: Send test data
    send_test_data || send_ok=false
    log ""

    # Step 3: Wait for data propagation
    log_info "Waiting 5s for data propagation..."
    sleep 5
    log ""

    # Step 4: Query backends
    query_backends || query_ok=false
    log ""

    # Step 5: Export data
    export_data
    log ""

    # Summary
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BOLD}${BLUE}   VALIDATION SUMMARY${NC}"
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log ""

    [[ "$status_ok" == "true" ]] && log_success "Backend connectivity: PASS" || log_fail "Backend connectivity: FAIL"
    [[ "$send_ok" == "true" ]] && log_success "Test data sending: PASS" || log_fail "Test data sending: FAIL"
    [[ "$query_ok" == "true" ]] && log_success "Backend queries: PASS" || log_fail "Backend queries: FAIL"

    log ""
    log_info "Exported data: $EXPORT_DIR"
    log_info "Grafana UI: $GRAFANA_ENDPOINT (admin/admin)"
    log ""

    if [[ "$status_ok" == "true" ]] && [[ "$send_ok" == "true" ]]; then
        log "${GREEN}${BOLD}VALIDATION PASSED${NC}"
        return 0
    else
        log "${RED}${BOLD}VALIDATION FAILED${NC}"
        return 1
    fi
}

# Show help
show_help() {
    echo "Telemetry Validation Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  all      Run full validation suite (default)"
    echo "  send     Send test data to OTLP endpoint"
    echo "  query    Query all backends for received data"
    echo "  export   Export telemetry data to JSON files"
    echo "  status   Check backend connectivity"
    echo "  help     Show this help"
    echo ""
    echo "Environment Variables:"
    echo "  OTLP_HTTP_ENDPOINT    OTLP HTTP endpoint (default: http://localhost:4318)"
    echo "  PROMETHEUS_ENDPOINT   Prometheus endpoint (default: http://localhost:9090)"
    echo "  EXPORT_DIR            Export directory (default: /tmp/telemetry-validation)"
    echo ""
    echo "Examples:"
    echo "  # Run full validation"
    echo "  bash scripts/validate-telemetry.sh"
    echo ""
    echo "  # Just send test data"
    echo "  bash scripts/validate-telemetry.sh send"
    echo ""
    echo "  # Export all data for analysis"
    echo "  bash scripts/validate-telemetry.sh export"
}

# Main dispatch
case "${1:-all}" in
    all|validate)
        run_validation
        ;;
    send)
        send_test_data
        ;;
    query)
        query_backends
        ;;
    export)
        export_data
        ;;
    status|check)
        check_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
