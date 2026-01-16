---
description: Microsoft Agent Framework - create, run, and manage AI agents
argument-hint: "[init|create|run|graph|patterns|help]"
allowed-tools: ["Bash", "Read", "Write", "Glob"]
---

# /ms-agents Command

Microsoft Agent Framework for building AI agents with Python.

## Quick Reference

| Subcommand | Description |
|------------|-------------|
| `init` | Initialize a new agent project |
| `create` | Create a new agent |
| `run` | Run an agent |
| `graph` | Design agent workflow graph |
| `patterns` | Show orchestration patterns |
| `help` | Show this help |

## Actions

### `/ms-agents init`

Initialize a new Microsoft Agent Framework project:

```bash
# Create project directory
mkdir my-agent-project && cd my-agent-project

# Create virtual environment
uv venv
source .venv/bin/activate

# Install framework
uv pip install agent-framework --pre

# Create basic structure
mkdir -p src/agents src/tools
```

Creates:
- `pyproject.toml` - Project configuration
- `src/agents/` - Agent definitions
- `src/tools/` - Custom tools
- `.env.example` - Environment template

### `/ms-agents create`

Create a new agent:

```python
# src/agents/my_agent.py
from agent_framework import Agent, tool

class MyAgent(Agent):
    """A simple agent that answers questions."""

    system_prompt = """
    You are a helpful assistant. Answer questions clearly and concisely.
    """

    @tool
    def search_knowledge(self, query: str) -> str:
        """Search the knowledge base for information."""
        # Implementation here
        return f"Results for: {query}"
```

### `/ms-agents run`

Run an agent:

```python
# run_agent.py
import asyncio
from agent_framework import AgentRuntime
from src.agents.my_agent import MyAgent

async def main():
    runtime = AgentRuntime()
    agent = MyAgent()

    response = await runtime.run(
        agent,
        "What is the capital of France?"
    )
    print(response)

asyncio.run(main())
```

Or from CLI:

```bash
python -m agent_framework run src.agents.my_agent:MyAgent \
    --input "What is the capital of France?"
```

### `/ms-agents graph`

Design workflow graphs for multi-agent systems:

```python
from agent_framework import Graph, Node

# Create workflow graph
graph = Graph()

# Add agent nodes
graph.add_node("researcher", ResearcherAgent())
graph.add_node("writer", WriterAgent())
graph.add_node("reviewer", ReviewerAgent())

# Define edges (data flow)
graph.add_edge("researcher", "writer")
graph.add_edge("writer", "reviewer")
graph.add_edge("reviewer", "writer", condition=needs_revision)

# Run graph
result = await graph.run(initial_input)
```

### `/ms-agents patterns`

Show orchestration patterns:

#### Sequential Pattern

```python
graph = Graph()
graph.add_edge("agent_a", "agent_b")
graph.add_edge("agent_b", "agent_c")
# A → B → C
```

#### Concurrent Pattern

```python
graph = Graph()
graph.add_edge("start", ["agent_a", "agent_b", "agent_c"])
graph.add_edge(["agent_a", "agent_b", "agent_c"], "end")
# A, B, C run in parallel
```

#### Group Chat Pattern

```python
from agent_framework import GroupChat

chat = GroupChat(
    agents=[agent_a, agent_b, agent_c],
    max_rounds=10,
    speaker_selection="round_robin"  # or "auto"
)
result = await chat.run("Discuss the project plan")
```

#### Handoff Pattern

```python
graph = Graph()
graph.add_edge("agent_a", "agent_b", condition=handoff_to_b)
graph.add_edge("agent_a", "agent_c", condition=handoff_to_c)
# Conditional routing based on output
```

## Framework Features

### Four Core Pillars

1. **Open Standards** - MCP support, A2A communication, OpenAPI
2. **Extensible** - Connectors, plugins, declarative YAML/JSON
3. **Production Ready** - OpenTelemetry, Azure Monitor, Entra ID
4. **Research to Production** - AutoGen patterns with enterprise controls

### MCP Integration

```python
from agent_framework import Agent
from agent_framework.mcp import MCPToolProvider

class MyAgent(Agent):
    tools = [
        MCPToolProvider("github"),      # GitHub MCP server
        MCPToolProvider("filesystem"),  # Filesystem MCP server
    ]
```

### Observability

```python
from agent_framework import AgentRuntime
from opentelemetry import trace

runtime = AgentRuntime(
    telemetry={
        "enabled": True,
        "exporter": "otlp",
        "endpoint": "http://localhost:4317"
    }
)
```

## Related

- [Microsoft Agent Framework Docs](https://learn.microsoft.com/en-us/agent-framework/)
- [GitHub Repository](https://github.com/microsoft/agent-framework)
- `ms-agent-patterns` skill - Detailed orchestration patterns
- `agent-architect` agent - Design multi-agent systems
