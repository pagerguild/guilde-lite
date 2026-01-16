---
name: ms-workflows
description: |
  Use when building multi-agent workflows with Microsoft Agent Framework.
  Triggers: "workflow builder", "sequential workflow", "concurrent agents", "handoff", "group chat", "magentic".
  NOT for: Single-agent scenarios or non-workflow coordination.
---

# Microsoft Agent Workflows

Expert guidance for building multi-agent workflows using workflow builders.

## Workflow Builders Overview

| Builder | Pattern | Use Case |
|---------|---------|----------|
| `SequentialBuilder` | A → B → C | Step-by-step processing |
| `ConcurrentBuilder` | A, B, C in parallel | Independent parallel tasks |
| `HandoffBuilder` | A → B or C (conditional) | Routing based on input |
| `GroupChatBuilder` | Round-robin/auto selection | Multi-agent discussion |
| `MagenticBuilder` | Dynamic orchestration | Complex adaptive workflows |

## Sequential Workflows

Step-by-step processing where each agent builds on the previous:

```python
from agent_framework.workflows import SequentialBuilder

# Define agents
researcher = ResearchAgent()
analyst = AnalystAgent()
writer = WriterAgent()
reviewer = ReviewerAgent()

# Build sequential workflow
workflow = (
    SequentialBuilder()
    .add_agent(researcher, name="research")
    .add_agent(analyst, name="analyze")
    .add_agent(writer, name="write")
    .add_agent(reviewer, name="review")
    .build()
)

# Run workflow
result = await workflow.run("Research AI trends for 2025 report")

# Access intermediate results
print(result.steps["research"].output)
print(result.steps["analyze"].output)
```

### With Transformations

```python
workflow = (
    SequentialBuilder()
    .add_agent(researcher)
    .transform(lambda x: {"summary": x[:500]})  # Transform between steps
    .add_agent(analyst)
    .add_agent(writer)
    .build()
)
```

### With Checkpointing

```python
from agent_framework.checkpoints import RedisCheckpointStore

store = RedisCheckpointStore("redis://localhost:6379")

workflow = (
    SequentialBuilder()
    .with_checkpointing(store)
    .add_agent(agent1)
    .add_agent(agent2)  # If fails here, can resume
    .add_agent(agent3)
    .build()
)

# Resume from checkpoint
result = await workflow.run(input_data, resume=True)
```

## Concurrent Workflows

Run independent agents in parallel:

```python
from agent_framework.workflows import ConcurrentBuilder

# Fan-out: Multiple agents process same input
workflow = (
    ConcurrentBuilder()
    .add_agent(web_searcher, name="web")
    .add_agent(db_searcher, name="database")
    .add_agent(doc_searcher, name="documents")
    .aggregate(aggregator_agent)  # Fan-in: Combine results
    .build()
)

result = await workflow.run("Find all information about customer X")
```

### With Timeout and Error Handling

```python
workflow = (
    ConcurrentBuilder()
    .add_agent(agent1, timeout=30)
    .add_agent(agent2, timeout=30)
    .add_agent(agent3, timeout=30)
    .on_timeout(lambda agent: {"status": "timeout", "agent": agent.name})
    .on_error(lambda agent, err: {"status": "error", "message": str(err)})
    .aggregate(aggregator)
    .build()
)
```

### Map-Reduce Pattern

```python
# Process multiple items in parallel
items = ["doc1.pdf", "doc2.pdf", "doc3.pdf"]

workflow = (
    ConcurrentBuilder()
    .map(document_processor, items)  # Process each item
    .reduce(summary_agent)           # Combine all results
    .build()
)

result = await workflow.run()
```

## Handoff Workflows

Route to different agents based on conditions:

```python
from agent_framework.workflows import HandoffBuilder

def route_by_category(input_data):
    """Determine which agent should handle the request."""
    if "billing" in input_data.lower():
        return "billing"
    elif "technical" in input_data.lower():
        return "technical"
    else:
        return "general"

workflow = (
    HandoffBuilder()
    .add_classifier(classifier_agent)  # Optional: LLM-based routing
    .add_route("billing", billing_agent)
    .add_route("technical", technical_agent)
    .add_route("general", general_agent)
    .with_router(route_by_category)    # Or function-based routing
    .build()
)

result = await workflow.run("I have a question about my invoice")
# Routes to billing_agent
```

### Multi-Level Handoff

```python
workflow = (
    HandoffBuilder()
    .add_route("billing", (
        HandoffBuilder()
        .add_route("payment", payment_agent)
        .add_route("invoice", invoice_agent)
        .add_route("refund", refund_agent)
        .build()
    ))
    .add_route("technical", technical_agent)
    .build()
)
```

### With Escalation

```python
workflow = (
    HandoffBuilder()
    .add_route("standard", standard_agent)
    .add_route("complex", senior_agent)
    .add_escalation(
        condition=lambda result: result.confidence < 0.8,
        target="complex"
    )
    .build()
)
```

## Group Chat Workflows

Multi-agent discussions with speaker selection:

```python
from agent_framework.workflows import GroupChatBuilder

workflow = (
    GroupChatBuilder()
    .add_agent(planner_agent, role="Planner")
    .add_agent(developer_agent, role="Developer")
    .add_agent(tester_agent, role="Tester")
    .add_agent(reviewer_agent, role="Reviewer")
    .with_max_rounds(15)
    .with_speaker_selection("auto")  # LLM selects next speaker
    .with_termination(lambda msg: "APPROVED" in msg)
    .build()
)

result = await workflow.run("Design and review a REST API for user management")
```

### Speaker Selection Modes

```python
# Round-robin: Each agent speaks in order
.with_speaker_selection("round_robin")

# Auto: LLM selects based on context
.with_speaker_selection("auto")

# Random: Random selection
.with_speaker_selection("random")

# Custom: Your own selection logic
.with_speaker_selection(
    lambda agents, history: select_best_agent(agents, history)
)
```

### With Moderator

```python
workflow = (
    GroupChatBuilder()
    .add_agent(expert1)
    .add_agent(expert2)
    .add_agent(expert3)
    .with_moderator(moderator_agent)  # Controls discussion flow
    .with_max_rounds(10)
    .build()
)
```

## Magentic Workflows

Dynamic orchestration with adaptive agent selection:

```python
from agent_framework.workflows import MagenticBuilder

workflow = (
    MagenticBuilder()
    .add_agent(researcher, capabilities=["search", "summarize"])
    .add_agent(analyst, capabilities=["analyze", "calculate"])
    .add_agent(writer, capabilities=["write", "format"])
    .add_agent(coder, capabilities=["code", "debug"])
    .with_orchestrator(orchestrator_agent)  # LLM decides agent flow
    .with_max_iterations(20)
    .build()
)

# Orchestrator dynamically decides which agents to invoke
result = await workflow.run(
    "Analyze sales data, identify trends, and create a report with visualizations"
)
```

### With Memory Sharing

```python
from agent_framework.memory import SharedMemory

shared = SharedMemory()

workflow = (
    MagenticBuilder()
    .add_agent(agent1)
    .add_agent(agent2)
    .with_shared_memory(shared)  # All agents can read/write
    .build()
)
```

## Human-in-the-Loop

Add human approval points in any workflow:

```python
from agent_framework.workflows import SequentialBuilder
from agent_framework.human import ApprovalGate, InputGate

workflow = (
    SequentialBuilder()
    .add_agent(drafter)
    .add_gate(ApprovalGate(
        prompt="Review this draft. Approve?",
        timeout_minutes=60,
        on_reject=lambda: "drafter"  # Loop back to drafter
    ))
    .add_agent(publisher)
    .build()
)

# Or request human input
workflow = (
    SequentialBuilder()
    .add_agent(data_collector)
    .add_gate(InputGate(
        prompt="Please provide additional context:",
        required=True
    ))
    .add_agent(processor)
    .build()
)
```

## Workflow Composition

Combine multiple workflows:

```python
# Sub-workflow for research
research_workflow = (
    ConcurrentBuilder()
    .add_agent(web_searcher)
    .add_agent(db_searcher)
    .aggregate(research_aggregator)
    .build()
)

# Sub-workflow for writing
writing_workflow = (
    SequentialBuilder()
    .add_agent(outliner)
    .add_agent(writer)
    .add_agent(editor)
    .build()
)

# Main workflow combining both
main_workflow = (
    SequentialBuilder()
    .add_workflow(research_workflow, name="research")
    .add_workflow(writing_workflow, name="writing")
    .add_agent(final_reviewer)
    .build()
)
```

## Error Handling

```python
from agent_framework.workflows import SequentialBuilder
from agent_framework.errors import RetryStrategy, FallbackStrategy

workflow = (
    SequentialBuilder()
    .add_agent(agent1)
    .add_agent(agent2)
    .with_error_handling(
        RetryStrategy(max_retries=3, backoff="exponential")
    )
    .with_fallback(
        FallbackStrategy(
            fallback_agent=fallback_agent,
            condition=lambda e: isinstance(e, TimeoutError)
        )
    )
    .build()
)
```

## Related

- `ms-agent-types` skill - Agent implementation patterns
- `ms-observability` skill - Workflow telemetry
- `workflow-designer` agent - Design complex workflows
- [Workflows Docs](https://learn.microsoft.com/en-us/agent-framework/concepts/workflows)
