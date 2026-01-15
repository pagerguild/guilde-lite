# Claude Code Telemetry Metrics Schema

This document defines the custom metrics and spans for AI agent workflow observability.

## Metrics

### Session Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `claude_session_duration_seconds` | Histogram | `session_id` | Duration of Claude Code sessions |
| `claude_session_tool_calls_total` | Counter | `session_id`, `tool_name`, `status` | Total tool invocations per session |
| `claude_session_compaction_total` | Counter | `session_id` | Context compaction events per session |

### Tool Usage Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `claude_tool_calls_total` | Counter | `tool_name`, `status` | Total tool invocations |
| `claude_tool_latency_seconds` | Histogram | `tool_name` | Tool execution latency |
| `claude_tool_errors_total` | Counter | `tool_name`, `error_type` | Tool execution errors |

### Agent/Subagent Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `claude_agent_invocations_total` | Counter | `agent_type`, `model_tier` | Agent spawns by type and model |
| `claude_agent_duration_seconds` | Histogram | `agent_type` | Agent execution duration |
| `claude_agent_handoffs_total` | Counter | `from_agent`, `to_agent` | Agent-to-agent handoffs |

### Skill/Command Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `claude_skill_invocations_total` | Counter | `skill_name` | Skill/command activations |
| `claude_command_invocations_total` | Counter | `command_name` | Slash command usage |

### Context Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `claude_context_tokens_total` | Counter | `session_id` | Tokens in context window |
| `claude_context_compaction_total` | Counter | `session_id` | Compaction event count |
| `claude_context_utilization_ratio` | Gauge | `session_id` | Context window utilization (0-1) |

### TDD Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `claude_tdd_phase_transitions_total` | Counter | `from_phase`, `to_phase` | TDD phase changes |
| `claude_tdd_tests_written_total` | Counter | `session_id` | Tests written in RED phase |
| `claude_tdd_implementations_total` | Counter | `session_id` | Implementations in GREEN phase |

### Documentation Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `claude_doc_sync_checks_total` | Counter | `result` | Doc-sync check results |
| `claude_doc_updates_total` | Counter | `doc_type` | Documentation updates |

## Spans (Traces)

### Session Span
```
claude.session
├── session.id: string
├── session.working_directory: string
├── session.start_time: timestamp
└── session.end_time: timestamp
```

### Tool Span
```
claude.tool
├── tool.name: string (Read, Write, Edit, Bash, Task, etc.)
├── tool.input_size: int
├── tool.output_size: int
├── tool.duration_ms: int
└── tool.status: string (success, error)
```

### Agent Span
```
claude.agent
├── agent.type: string (Explore, Plan, code-reviewer, etc.)
├── agent.model_tier: string (haiku, sonnet, opus)
├── agent.parent_session_id: string
├── agent.task_description: string
└── agent.duration_ms: int
```

### Context Span
```
claude.context
├── context.token_count: int
├── context.compaction_count: int
├── context.preserved: boolean
└── context.files_read: int
```

## Labels (Attributes)

### Standard Labels

| Label | Type | Example | Description |
|-------|------|---------|-------------|
| `session_id` | string | `session-20250115-143022-a1b2c3d4` | Unique session identifier |
| `tool_name` | string | `Read`, `Write`, `Bash`, `Task` | Tool being used |
| `agent_type` | string | `Explore`, `code-reviewer` | Agent/subagent type |
| `model_tier` | string | `haiku`, `sonnet`, `opus` | Model tier used |
| `skill_name` | string | `mermaid-generator`, `c4-generator` | Skill name |
| `status` | string | `success`, `error`, `blocked` | Operation result |

### Custom Labels for guilde-lite

| Label | Type | Example | Description |
|-------|------|---------|-------------|
| `tdd_phase` | string | `red`, `green`, `refactor` | Current TDD phase |
| `track_id` | string | `MULTI-001` | Active conductor track |
| `mise_compliant` | boolean | `true`, `false` | Command follows mise-first |
| `doc_sync_required` | boolean | `true`, `false` | Doc update needed |

## Cardinality Guidelines

To avoid high-cardinality issues:

1. **Bounded Labels**: Only use labels with bounded cardinality
   - `tool_name`: ~20 distinct values
   - `agent_type`: ~50 distinct values
   - `status`: 3-5 values
   - `model_tier`: 3 values

2. **Session IDs**: Use only for aggregation queries, not real-time dashboards
   - Archive after session ends
   - Roll up to daily aggregates

3. **Avoid**: File paths, commit SHAs, or user-generated content as labels

## Exemplar Links

For traces-to-metrics correlation:

```yaml
# Metric with exemplar
claude_tool_latency_seconds{tool="Write"} 0.234
  # exemplar: {trace_id="abc123", span_id="def456"}
```

This enables clicking from a metric spike directly to the corresponding trace in Tempo.

## Dashboard Queries

### Top Tools by Usage
```promql
topk(10, sum by (tool_name) (rate(claude_tool_calls_total[1h])))
```

### Session Duration Distribution
```promql
histogram_quantile(0.95, sum by (le) (rate(claude_session_duration_seconds_bucket[1d])))
```

### Context Compaction Rate
```promql
sum(rate(claude_context_compaction_total[1h])) by (session_id)
```

### Agent Model Distribution
```promql
sum by (model_tier) (rate(claude_agent_invocations_total[1d]))
```

### TDD Phase Time
```promql
sum by (tdd_phase) (increase(claude_tdd_phase_transitions_total[1d]))
```
