---
name: ms-observability
description: |
  Use when implementing observability for Microsoft Agent Framework agents.
  Triggers: "agent observability", "OpenTelemetry agents", "agent metrics", "agent tracing", "Aspire dashboard".
  NOT for: Non-Microsoft agent frameworks or basic logging.
---

# Microsoft Agent Observability

Expert guidance for implementing comprehensive observability in agent systems.

## OpenTelemetry Integration

Microsoft Agent Framework provides built-in OpenTelemetry support for traces, metrics, and logs.

### Quick Setup

```python
from agent_framework import ChatAgent, AgentRuntime
from agent_framework.observability import TelemetryConfig

# Configure telemetry
config = TelemetryConfig(
    service_name="my-agent-service",
    exporter="otlp",
    endpoint="http://localhost:4317",
    enable_traces=True,
    enable_metrics=True,
    enable_logs=True
)

runtime = AgentRuntime(telemetry=config)
agent = ChatAgent()

# Run with telemetry
result = await runtime.run(agent, "Hello!")
```

### With Aspire Dashboard

```python
from agent_framework.observability import AspireConfig

# Configure for .NET Aspire Dashboard
config = AspireConfig(
    dashboard_url="http://localhost:18888",
    otlp_endpoint="http://localhost:4317"
)

runtime = AgentRuntime(telemetry=config)
```

## Traces

### Automatic Tracing

Agent Framework automatically creates spans for:

| Operation | Span Name | Attributes |
|-----------|-----------|------------|
| Agent invocation | `agent.invoke` | agent_name, model, input_tokens |
| Tool execution | `agent.tool` | tool_name, duration, success |
| LLM call | `llm.call` | model, prompt_tokens, completion_tokens |
| Workflow step | `workflow.step` | step_name, workflow_id |
| MCP tool call | `mcp.tool` | server, tool, latency |

### Custom Spans

```python
from agent_framework import ChatAgent
from agent_framework.observability import tracer

class TracedAgent(ChatAgent):

    @ai_function
    async def complex_operation(self, data: str) -> str:
        """Operation with custom tracing."""

        with tracer.start_as_current_span("custom_operation") as span:
            span.set_attribute("data.size", len(data))

            # Sub-operation 1
            with tracer.start_span("preprocess") as sub_span:
                processed = self.preprocess(data)
                sub_span.set_attribute("processed.size", len(processed))

            # Sub-operation 2
            with tracer.start_span("analyze") as sub_span:
                result = await self.analyze(processed)
                sub_span.set_attribute("result.type", type(result).__name__)

            span.set_attribute("success", True)
            return result
```

### Trace Context Propagation

```python
from agent_framework.observability import propagate_context

class DistributedAgent(ChatAgent):

    @ai_function
    async def call_external_service(self, request: dict) -> dict:
        """Call external service with trace propagation."""

        # Get headers with trace context
        headers = propagate_context()

        async with httpx.AsyncClient() as client:
            response = await client.post(
                "http://external-service/api",
                json=request,
                headers=headers
            )
            return response.json()
```

## Metrics

### Built-in Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `agent.invocations_total` | Counter | Total agent invocations |
| `agent.invocation_duration_seconds` | Histogram | Invocation latency |
| `agent.tool_calls_total` | Counter | Total tool calls |
| `agent.tool_duration_seconds` | Histogram | Tool execution time |
| `agent.tokens_total` | Counter | Total tokens used |
| `agent.errors_total` | Counter | Total errors |
| `workflow.steps_total` | Counter | Workflow steps executed |
| `workflow.duration_seconds` | Histogram | Workflow duration |

### Custom Metrics

```python
from agent_framework.observability import meter

# Create custom metrics
request_counter = meter.create_counter(
    "custom_requests_total",
    description="Total custom requests processed"
)

latency_histogram = meter.create_histogram(
    "custom_latency_seconds",
    description="Custom operation latency"
)

active_sessions = meter.create_up_down_counter(
    "active_sessions",
    description="Currently active sessions"
)

class MetricsAgent(ChatAgent):

    @ai_function
    async def process_request(self, request: str) -> str:
        """Process request with custom metrics."""
        import time

        start = time.time()
        active_sessions.add(1)

        try:
            result = await self.do_process(request)
            request_counter.add(1, {"status": "success"})
            return result
        except Exception as e:
            request_counter.add(1, {"status": "error"})
            raise
        finally:
            latency_histogram.record(time.time() - start)
            active_sessions.add(-1)
```

### Metric Attributes

```python
# Add context to metrics
request_counter.add(1, {
    "agent_name": self.name,
    "model": self.model,
    "tool": tool_name,
    "status": "success",
    "customer_tier": "premium"
})
```

## Logs

### Structured Logging

```python
from agent_framework.observability import logger

class LoggingAgent(ChatAgent):

    @ai_function
    async def process(self, data: str) -> str:
        """Operation with structured logging."""

        # Log with context
        logger.info(
            "Processing request",
            extra={
                "agent_name": self.name,
                "data_size": len(data),
                "request_id": self.context.request_id
            }
        )

        try:
            result = await self.do_process(data)
            logger.info(
                "Request processed successfully",
                extra={"result_size": len(result)}
            )
            return result
        except Exception as e:
            logger.error(
                "Request processing failed",
                extra={"error": str(e)},
                exc_info=True
            )
            raise
```

### Log Correlation

```python
from agent_framework.observability import get_trace_id, get_span_id

class CorrelatedAgent(ChatAgent):

    def log_with_trace(self, message: str, **kwargs):
        """Log with automatic trace correlation."""
        logger.info(
            message,
            extra={
                "trace_id": get_trace_id(),
                "span_id": get_span_id(),
                **kwargs
            }
        )
```

## Dashboard Integration

### Aspire Dashboard Setup

```bash
# Run Aspire Dashboard
docker run -d \
    -p 18888:18888 \
    -p 4317:18889 \
    mcr.microsoft.com/dotnet/aspire-dashboard:latest
```

```python
from agent_framework.observability import AspireConfig

config = AspireConfig(
    dashboard_url="http://localhost:18888",
    otlp_endpoint="http://localhost:4317"
)

# Now visit http://localhost:18888 for dashboard
```

### Grafana Integration

```python
from agent_framework.observability import TelemetryConfig

config = TelemetryConfig(
    service_name="my-agent",

    # Traces to Tempo
    trace_exporter="otlp",
    trace_endpoint="http://tempo:4317",

    # Metrics to Prometheus
    metrics_exporter="prometheus",
    metrics_port=9090,

    # Logs to Loki
    log_exporter="otlp",
    log_endpoint="http://loki:3100"
)
```

### Datadog Integration

```python
config = TelemetryConfig(
    service_name="my-agent",
    exporter="datadog",
    datadog_config={
        "api_key": "${DD_API_KEY}",
        "site": "datadoghq.com",
        "env": "production",
        "version": "1.0.0"
    }
)
```

## Alerting Patterns

### Define SLIs/SLOs

```python
from agent_framework.observability import SLO, SLI

# Define SLIs
latency_sli = SLI(
    name="agent_latency_p99",
    metric="agent.invocation_duration_seconds",
    aggregation="p99"
)

error_sli = SLI(
    name="agent_error_rate",
    metric="agent.errors_total / agent.invocations_total",
    aggregation="rate"
)

# Define SLOs
latency_slo = SLO(
    name="Agent Latency",
    sli=latency_sli,
    target=2.0,  # 2 seconds p99
    window="30d"
)

error_slo = SLO(
    name="Agent Error Rate",
    sli=error_sli,
    target=0.01,  # 1% error rate
    window="30d"
)
```

### Alert Rules

```yaml
# prometheus-rules.yml
groups:
  - name: agent-alerts
    rules:
      - alert: HighAgentLatency
        expr: histogram_quantile(0.99, agent_invocation_duration_seconds) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: Agent latency is high

      - alert: HighErrorRate
        expr: rate(agent_errors_total[5m]) / rate(agent_invocations_total[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: Agent error rate exceeds 5%
```

## Debugging Tools

### Request Tracing

```python
from agent_framework.observability import enable_debug_tracing

# Enable verbose tracing for debugging
enable_debug_tracing(
    log_prompts=True,
    log_responses=True,
    log_tool_args=True,
    log_tool_results=True
)
```

### Performance Profiling

```python
from agent_framework.observability import profile_agent

@profile_agent
async def run_agent(agent, input_data):
    """Profile agent execution."""
    return await agent.run(input_data)

# Generates flame graph and timing breakdown
```

## Best Practices

### 1. Semantic Conventions

```python
# Use OpenTelemetry semantic conventions
span.set_attribute("gen_ai.system", "openai")
span.set_attribute("gen_ai.request.model", "gpt-4o")
span.set_attribute("gen_ai.usage.prompt_tokens", 100)
span.set_attribute("gen_ai.usage.completion_tokens", 50)
```

### 2. Sampling Strategy

```python
from agent_framework.observability import TelemetryConfig
from opentelemetry.sdk.trace.sampling import TraceIdRatioBased

config = TelemetryConfig(
    # Sample 10% of requests in production
    sampler=TraceIdRatioBased(0.1),

    # But always sample errors
    error_sampling_rate=1.0
)
```

### 3. Cost Management

```python
config = TelemetryConfig(
    # Limit metric cardinality
    max_attribute_values=100,

    # Aggregate metrics before export
    metric_aggregation_interval=60,

    # Batch and compress
    batch_size=512,
    compression="gzip"
)
```

## Related

- `ms-agent-types` skill - Agent implementation
- `ms-hosting` skill - Production hosting
- `observability-expert` agent - Implement telemetry
- [Observability Docs](https://learn.microsoft.com/en-us/agent-framework/guides/observability)
