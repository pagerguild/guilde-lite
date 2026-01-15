---
name: ms-agent-patterns
description: |
  Use when building multi-agent systems with Microsoft Agent Framework.
  Triggers: "microsoft agents", "agent framework", "semantic kernel", "autogen", "agent graph".
  NOT for: Simple single-agent scenarios or non-Microsoft frameworks.
---

# Microsoft Agent Patterns

Expert guidance for building multi-agent systems with Microsoft Agent Framework.

## Core Concepts

### What is Microsoft Agent Framework?

An open-source SDK that unifies:

- **AutoGen** - Research-grade orchestration patterns
- **Semantic Kernel** - Enterprise-ready foundations
- **MCP Support** - Model Context Protocol integration

### Four Pillars

1. **Open Standards & Interoperability**
   - Model Context Protocol (MCP)
   - Agent-to-Agent (A2A) communication
   - OpenAPI integration

2. **Extensible by Design**
   - Modular connectors
   - Declarative YAML/JSON config
   - Pluggable memory systems

3. **Production Ready**
   - OpenTelemetry observability
   - Azure Monitor integration
   - Entra ID security

4. **Research to Production**
   - Bleeding-edge patterns
   - Enterprise controls
   - Durable workflows

## Agent Design Patterns

### Pattern 1: Sequential Workflow

```python
from agent_framework import Graph, Node

graph = Graph()

# Define sequential flow
graph.add_node("researcher", ResearcherAgent())
graph.add_node("analyst", AnalystAgent())
graph.add_node("writer", WriterAgent())

graph.add_edge("researcher", "analyst")
graph.add_edge("analyst", "writer")

# Run
result = await graph.run("Research AI trends for 2025")
```

**Use when:** Tasks have clear dependencies, each step builds on previous.

### Pattern 2: Concurrent Fan-Out/Fan-In

```python
graph = Graph()

# Fan-out to parallel agents
graph.add_node("coordinator", CoordinatorAgent())
graph.add_node("web_searcher", WebSearchAgent())
graph.add_node("db_searcher", DatabaseSearchAgent())
graph.add_node("doc_searcher", DocumentSearchAgent())
graph.add_node("aggregator", AggregatorAgent())

# Fan-out
graph.add_edge("coordinator", ["web_searcher", "db_searcher", "doc_searcher"])

# Fan-in
graph.add_edge(["web_searcher", "db_searcher", "doc_searcher"], "aggregator")

result = await graph.run("Find all information about customer X")
```

**Use when:** Independent tasks can run in parallel.

### Pattern 3: Group Chat

```python
from agent_framework import GroupChat, GroupChatManager

# Create specialized agents
planner = PlannerAgent()
developer = DeveloperAgent()
tester = TesterAgent()
reviewer = ReviewerAgent()

# Create group chat
chat = GroupChat(
    agents=[planner, developer, tester, reviewer],
    max_rounds=15,
    speaker_selection="auto",  # AI selects next speaker
    allow_repeat_speaker=False
)

manager = GroupChatManager(chat)
result = await manager.run("Design and implement a REST API for user management")
```

**Use when:** Complex problems benefit from multi-perspective discussion.

### Pattern 4: Conditional Handoff

```python
graph = Graph()

graph.add_node("classifier", ClassifierAgent())
graph.add_node("billing", BillingAgent())
graph.add_node("technical", TechnicalAgent())
graph.add_node("general", GeneralAgent())

# Conditional routing
graph.add_edge("classifier", "billing", condition=lambda x: x.category == "billing")
graph.add_edge("classifier", "technical", condition=lambda x: x.category == "technical")
graph.add_edge("classifier", "general", condition=lambda x: x.category == "general")
```

**Use when:** Different inputs require different specialist agents.

### Pattern 5: Human-in-the-Loop

```python
from agent_framework import HumanApprovalNode

graph = Graph()

graph.add_node("drafter", DraftAgent())
graph.add_node("approval", HumanApprovalNode(
    prompt="Review and approve this draft?",
    timeout_minutes=60
))
graph.add_node("publisher", PublishAgent())

graph.add_edge("drafter", "approval")
graph.add_edge("approval", "publisher", condition=lambda x: x.approved)
graph.add_edge("approval", "drafter", condition=lambda x: not x.approved)
```

**Use when:** Critical decisions need human oversight.

### Pattern 6: Checkpointing & Recovery

```python
from agent_framework import Graph, CheckpointStore

# Enable checkpointing
store = CheckpointStore(backend="redis", url="redis://localhost")

graph = Graph(checkpoint_store=store)

# Long-running workflow
graph.add_node("step1", Step1Agent())
graph.add_node("step2", Step2Agent())
graph.add_node("step3", Step3Agent())

# If failure, resume from last checkpoint
result = await graph.run(
    input_data,
    resume_from_checkpoint=True
)
```

**Use when:** Long workflows need durability.

## Agent Implementation

### Basic Agent

```python
from agent_framework import Agent, tool

class MyAgent(Agent):
    """Agent description for the AI to understand its role."""

    system_prompt = """
    You are a helpful assistant specialized in {domain}.
    Always be accurate and cite sources.
    """

    model = "gpt-4"  # or "claude-3-opus", etc.

    @tool
    def search(self, query: str) -> str:
        """Search for information."""
        return search_implementation(query)

    @tool
    def calculate(self, expression: str) -> float:
        """Evaluate a mathematical expression."""
        return eval_safe(expression)
```

### Agent with Memory

```python
from agent_framework import Agent
from agent_framework.memory import ConversationMemory, VectorMemory

class MemoryAgent(Agent):
    system_prompt = "You are an assistant with memory."

    # Short-term conversation memory
    conversation_memory = ConversationMemory(max_turns=10)

    # Long-term vector memory
    vector_memory = VectorMemory(
        embedding_model="text-embedding-3-small",
        index_backend="qdrant"
    )

    async def on_message(self, message: str):
        # Retrieve relevant context
        context = await self.vector_memory.search(message, top_k=5)

        # Include in prompt
        return await super().on_message(message, context=context)
```

### Agent with MCP Tools

```python
from agent_framework import Agent
from agent_framework.mcp import MCPClient

class MCPAgent(Agent):
    system_prompt = "You are an assistant with external tools."

    async def setup(self):
        # Connect to MCP servers
        self.github = await MCPClient.connect("github-mcp")
        self.filesystem = await MCPClient.connect("filesystem-mcp")

    @tool
    async def create_pr(self, title: str, body: str) -> str:
        """Create a GitHub pull request."""
        return await self.github.call("create_pull_request", {
            "title": title,
            "body": body
        })
```

## Observability

### OpenTelemetry Integration

```python
from agent_framework import AgentRuntime
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# Configure tracing
tracer_provider = TracerProvider()
tracer_provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="localhost:4317"))
)
trace.set_tracer_provider(tracer_provider)

# Runtime automatically instruments
runtime = AgentRuntime(telemetry_enabled=True)
```

### Metrics

```python
# Built-in metrics
# - agent_invocations_total
# - agent_latency_seconds
# - tool_calls_total
# - token_usage_total
```

## Best Practices

### 1. Clear Agent Responsibilities

```python
# DO - Single responsibility
class DataFetcherAgent(Agent):
    """Fetches data from various sources."""

class DataAnalyzerAgent(Agent):
    """Analyzes data and generates insights."""

# DON'T - God agent
class DoEverythingAgent(Agent):
    """Fetches, analyzes, visualizes, reports..."""
```

### 2. Meaningful System Prompts

```python
# DO - Specific and actionable
system_prompt = """
You are a code reviewer specializing in Python.
Focus on: security, performance, readability.
Always provide specific line numbers.
Rate severity: critical, major, minor.
"""

# DON'T - Vague
system_prompt = "You review code."
```

### 3. Error Handling in Graphs

```python
graph = Graph()

# Add error handler
graph.on_error = lambda node, error: ErrorHandlerAgent().handle(node, error)

# Or per-node retry
graph.add_node("risky_op", RiskyAgent(), retry=3, retry_delay=1.0)
```

### 4. Test Agents

```python
import pytest
from agent_framework.testing import MockRuntime

@pytest.mark.asyncio
async def test_my_agent():
    runtime = MockRuntime()
    agent = MyAgent()

    # Mock tool responses
    runtime.mock_tool("search", return_value="mocked result")

    response = await runtime.run(agent, "test input")

    assert "expected" in response
    assert runtime.tool_called("search")
```

## Related

- `/ms-agents` - Command interface
- `agent-architect` agent - Design multi-agent systems
- [Microsoft Learn Docs](https://learn.microsoft.com/en-us/agent-framework/)
- [GitHub Repository](https://github.com/microsoft/agent-framework)
