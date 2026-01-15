# Telemetry Setup Guide

This guide covers the observability stack for monitoring Claude Code AI agent workflows.

## Overview

The telemetry system consists of:

1. **Grafana LGTM Stack** - Backend observability platform
   - **L**oki - Log aggregation
   - **G**rafana - Visualization dashboards
   - **T**empo - Distributed tracing
   - **M**imir - Metrics storage (Prometheus-compatible)

2. **Grafana Alloy** - OpenTelemetry collector (next-gen)

3. **Telemetry Hooks** - Claude Code integration for automatic metric collection

## Quick Start

### Option 1: Quick Start (Single Container)

For development/testing, use the all-in-one LGTM container:

```bash
# Start quick stack
task otel:up:quick

# Access Grafana at http://localhost:3000 (admin/admin)
```

### Option 2: Full Stack

For production-like setup with separate components:

```bash
# Start full observability stack
task otel:up

# Check status
task otel:status

# View service URLs
# Grafana:    http://localhost:3000
# Alloy UI:   http://localhost:12345
# OTLP gRPC:  localhost:4317
# OTLP HTTP:  localhost:4318
```

## Configuration

### Environment Variables

Source the telemetry configuration before running Claude Code:

```bash
source .env.telemetry
claude
```

Key variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector endpoint | `http://localhost:4317` |
| `OTEL_SERVICE_NAME` | Service identifier | `claude-code` |
| `OTEL_TRACES_SAMPLER_ARG` | Trace sampling rate (0-1) | `1.0` |
| `GUILDE_TELEMETRY_DEBUG` | Enable debug logging | `false` |

### Hooks Configuration

Telemetry hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/telemetry-hook.sh session-start"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/telemetry-hook.sh pre-compact"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/telemetry-hook.sh post-tool ..."
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/telemetry-hook.sh session-end"
          }
        ]
      }
    ]
  }
}
```

## Task Commands

| Command | Description |
|---------|-------------|
| `task otel:up` | Start full observability stack |
| `task otel:up:quick` | Start quick (single container) stack |
| `task otel:down` | Stop observability stack |
| `task otel:status` | Show stack status and URLs |
| `task otel:logs` | View Alloy collector logs |
| `task otel:reset` | Reset stack (delete all data) |
| `task telemetry:status` | Show telemetry hook status |
| `task telemetry:report` | Generate telemetry report |
| `task telemetry:session:start` | Manually start session |
| `task telemetry:session:end` | Manually end session |
| `task telemetry:emit` | Emit current metrics |
| `task telemetry:env` | Show environment config |

## Metrics Collected

### Session Metrics
- Session duration
- Tool invocations per session
- Context compaction count

### Tool Usage
- Tool call counts by type (Read, Write, Bash, Task, etc.)
- Success/failure rates
- Tool latency

### Agent/Subagent Activity
- Agent spawns by type (Explore, Plan, code-reviewer, etc.)
- Model tier distribution (haiku, sonnet, opus)
- Agent duration

### Skills & Commands
- Skill activation counts
- Command invocations

See `docker/observability/metrics-schema.md` for full schema.

## Grafana Dashboard

The pre-built dashboard provides:

1. **Session Overview**
   - Total sessions
   - Tool calls (24h)
   - Context compactions
   - Agent spawns
   - Success rate

2. **Tool Usage**
   - Tool usage rate over time
   - Tool distribution pie chart
   - Model tier distribution

3. **Agent Activity**
   - Agent invocations by type
   - Top agents table

4. **Context & Performance**
   - Context compaction events
   - Tool latency percentiles

5. **Skills & Commands**
   - Top skills table
   - Top commands table

Access at: `http://localhost:3000/d/claude-agent-workflow`

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Claude Code                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │SessionSt │ │PreCompact│ │PostTool  │ │Stop Hook │       │
│  │art Hook  │ │Hook      │ │Use Hook  │ │          │       │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘       │
│       │            │            │            │              │
│       └────────────┴────────────┴────────────┘              │
│                         │                                   │
│            ┌────────────▼────────────┐                      │
│            │ telemetry-hook.sh       │                      │
│            │ (local state tracking)  │                      │
│            └────────────┬────────────┘                      │
└─────────────────────────│───────────────────────────────────┘
                          │
                          ▼ OTLP (gRPC/HTTP)
┌─────────────────────────────────────────────────────────────┐
│                    Grafana Alloy                            │
│               (OpenTelemetry Collector)                     │
│                    localhost:4317/4318                      │
└───────────┬─────────────┬──────────────┬────────────────────┘
            │             │              │
            ▼             ▼              ▼
      ┌─────────┐   ┌─────────┐   ┌─────────┐
      │  Mimir  │   │  Tempo  │   │  Loki   │
      │(metrics)│   │(traces) │   │ (logs)  │
      └────┬────┘   └────┬────┘   └────┬────┘
           │             │              │
           └─────────────┴──────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │      Grafana        │
              │   localhost:3000    │
              └─────────────────────┘
```

## Troubleshooting

### Stack won't start

```bash
# Check for port conflicts
lsof -i :3000 -i :4317 -i :4318

# View container logs
docker compose -f docker/observability-compose.yml logs
```

### No metrics appearing

1. Check if OTEL collector is running:
   ```bash
   curl http://localhost:4318/v1/metrics
   ```

2. Verify telemetry hooks are enabled:
   ```bash
   task telemetry:status
   ```

3. Enable debug logging:
   ```bash
   export GUILDE_TELEMETRY_DEBUG=true
   ```

### Session data not persisting

Check state directory:
```bash
ls -la ~/.local/share/guilde-telemetry/
```

### High resource usage

Switch to quick start mode or reduce retention:
```bash
# Quick mode uses less resources
task otel:down
task otel:up:quick
```

## Advanced Configuration

### Custom Alloy Configuration

Edit `docker/observability/alloy-config.alloy` to:
- Add custom processors
- Configure additional exporters
- Modify batching settings

### Custom Grafana Dashboards

Add dashboards to `docker/observability/grafana/dashboards/`.

### Remote Backend

To send telemetry to a remote backend (e.g., Grafana Cloud):

1. Update `.env.telemetry`:
   ```bash
   OTEL_EXPORTER_OTLP_ENDPOINT=https://your-cloud-endpoint
   ```

2. Add authentication headers in `alloy-config.alloy`

## Validation Testing

The telemetry pipeline can be validated using the automated validation script.

### Automated Validation

```bash
# Run full validation suite
task telemetry:validate

# Or directly
bash scripts/validate-telemetry.sh
```

The validation script will:
1. Check backend connectivity (OTLP, Prometheus, Grafana)
2. Send test metrics and logs to the OTLP endpoint
3. Query backends to verify data was received
4. Export all telemetry data to JSON files for inspection

### Validation Commands

| Command | Description |
|---------|-------------|
| `task telemetry:validate` | Run full validation suite |
| `task telemetry:validate:send` | Send test data only |
| `task telemetry:validate:query` | Query backends only |
| `task telemetry:validate:export` | Export data to JSON |

### Manual Validation Steps

#### 1. Start the Quick Stack

```bash
docker compose -f docker/observability-compose.yml --profile quick up -d
```

#### 2. Verify OTEL Collector is Reachable

```bash
bash scripts/telemetry-hook.sh status
# Should show: ✓ OTEL Collector: http://localhost:4317 (reachable)
```

#### 3. Send Test Data and Query

```bash
# Send test metrics
bash scripts/validate-telemetry.sh send

# Query what was received
bash scripts/validate-telemetry.sh query
```

#### 4. Export Data for Analysis

```bash
# Export to /tmp/telemetry-validation/
bash scripts/validate-telemetry.sh export

# View exported metrics
cat /tmp/telemetry-validation/metric_names.json | jq '.data'
```

#### 5. Access Grafana Dashboard

Open http://localhost:3000 (admin/admin) and navigate to the Claude Agent Workflow dashboard.

### Validation Results (January 2026)

| Test | Result |
|------|--------|
| Quick stack starts | ✓ Pass |
| OTEL endpoint accepts metrics | ✓ Pass (HTTP 200) |
| Metrics appear in Prometheus | ✓ Pass (validation_test_counter visible) |
| Logs accepted by collector | ✓ Pass (records received) |
| Data export works | ✓ Pass (JSON files exported) |
| Session tracking works | ✓ Pass (archived to history) |
| Multi-agent workflow tracked | ✓ Pass (Explore agent, Task tool calls) |

### Querying OTLP Data

Data sent to the OTLP endpoint can be queried from the backends:

**Prometheus Metrics:**
```bash
# Query specific metric
curl -s "http://localhost:9090/api/v1/query?query=validation_test_counter_total" | jq '.'

# List all metrics
curl -s "http://localhost:9090/api/v1/label/__name__/values" | jq '.data'

# Query collector stats
curl -s "http://localhost:9090/api/v1/query?query=otelcol_receiver_accepted_metric_points_total" | jq '.'
```

**Example Response:**
```json
{
  "metric": {
    "__name__": "validation_test_counter_total",
    "service_name": "telemetry-validator"
  },
  "value": ["1736926931.964", "1"]
}
```

## Related Documentation

- [Metrics Schema](docker/observability/metrics-schema.md)
- [Multi-Agent Workflow](docs/MULTI-AGENT-WORKFLOW.md)
- [Conductor Restart Protocol](docs/CONDUCTOR-RESTART-PROTOCOL.md)
