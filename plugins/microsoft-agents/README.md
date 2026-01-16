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
| `ms-agent-types` | "ChatAgent", "BaseAgent", "WorkflowAgent", "A2A agent" |
| `ms-workflows` | "workflow builder", "sequential workflow", "concurrent agents", "handoff", "group chat", "magentic" |
| `ms-ag-ui` | "AG-UI", "agent UI", "agent web interface", "SSE streaming" |
| `ms-mcp` | "MCP integration", "MCP tools", "MCP server", "Model Context Protocol" |
| `ms-observability` | "agent observability", "OpenTelemetry agents", "agent metrics", "agent tracing" |
| `ms-devui` | "DevUI", "agent testing", "local development", "agent debugging" |
| `ms-hosting` | "agent hosting", "deploy agent", "ASP.NET Core", "production deployment" |

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| `agent-architect` | opus | Designs multi-agent system architectures |
| `workflow-designer` | sonnet | Designs and implements workflow graphs |
| `observability-expert` | haiku | Implements observability infrastructure |

## What is Microsoft Agent Framework?

An open-source SDK unifying AutoGen and Semantic Kernel:

- **Graph-based workflows** - Sequential, concurrent, group chat, handoff, magentic
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

## Agent Types

| Type | Use Case |
|------|----------|
| ChatAgent | Conversational AI with tools |
| BaseAgent | Custom low-level control |
| WorkflowAgent | Multi-step orchestration |
| A2A Agent | Agent-to-agent communication |

## Workflow Patterns

| Pattern | Use Case |
|---------|----------|
| Sequential | Step-by-step workflows |
| Concurrent | Parallel independent tasks |
| Group Chat | Multi-agent discussions |
| Handoff | Conditional routing |
| Magentic | Dynamic adaptive orchestration |
| Human-in-the-Loop | Critical decision approval |

## Key Features

### AG-UI (Agent-User Interface)
- SSE streaming for real-time responses
- Tool execution visualization
- Human-in-the-loop approval flows
- React components available

### MCP Integration
- Connect to any MCP server
- Build custom MCP tools
- Resource subscriptions
- Multiple transport options

### Observability
- OpenTelemetry traces, metrics, logs
- Aspire Dashboard integration
- Grafana/Datadog support
- SLI/SLO management

### DevUI
- Interactive development interface
- Tool testing panel
- State inspection
- Request/response logging

### Hosting
- FastAPI integration
- ASP.NET Core support
- Kubernetes deployment
- Azure Container Apps

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
