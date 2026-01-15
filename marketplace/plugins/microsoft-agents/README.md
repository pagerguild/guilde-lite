# microsoft-agents

Microsoft Agent Framework for building AI agents with Python SDK.

## Commands

| Command | Description |
|---------|-------------|
| `/ms-agents` | Agent Framework operations |
| `/ms-agents init` | Initialize a new agent project |
| `/ms-agents create` | Create a new agent |
| `/ms-agents run` | Run an agent |
| `/ms-agents graph` | Design workflow graphs |
| `/ms-agents patterns` | Show orchestration patterns |

## Skills

| Skill | Triggers |
|-------|----------|
| `ms-agent-patterns` | "microsoft agents", "agent framework", "semantic kernel", "autogen" |

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| `agent-architect` | opus | Designs multi-agent systems |

## What is Microsoft Agent Framework?

An open-source SDK unifying AutoGen and Semantic Kernel:

- **Graph-based workflows** - Sequential, concurrent, group chat, handoff
- **MCP support** - Model Context Protocol integration
- **Production ready** - OpenTelemetry, Azure Monitor, Entra ID
- **Python SDK** - `pip install agent-framework --pre`

## Quick Start

```bash
# Install framework
uv pip install agent-framework --pre

# Create agent
cat > my_agent.py << 'EOF'
from agent_framework import Agent, tool

class MyAgent(Agent):
    system_prompt = "You are a helpful assistant."

    @tool
    def search(self, query: str) -> str:
        return f"Results for: {query}"
EOF

# Run agent
python -m agent_framework run my_agent:MyAgent --input "Hello"
```

## Orchestration Patterns

| Pattern | Use Case |
|---------|----------|
| Sequential | Step-by-step workflows |
| Concurrent | Parallel independent tasks |
| Group Chat | Multi-agent discussions |
| Handoff | Conditional routing |
| Human-in-the-Loop | Critical decision approval |

## Installation

```bash
# Add marketplace (if needed)
claude plugin marketplace add ./marketplace

# Install plugin
claude plugin install microsoft-agents@guilde-plugins
```

## Resources

- [Microsoft Learn Docs](https://learn.microsoft.com/en-us/agent-framework/)
- [GitHub Repository](https://github.com/microsoft/agent-framework)
- [Azure Blog Announcement](https://azure.microsoft.com/en-us/blog/introducing-microsoft-agent-framework/)
