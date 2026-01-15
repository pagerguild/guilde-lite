# exploration-agents

Codebase exploration and analysis agents for understanding unfamiliar code.

## Agents

| Agent | Model | Focus |
|-------|-------|-------|
| `context-explorer` | haiku | Fast codebase navigation and file discovery |
| `codebase-analyzer` | sonnet | Deep architecture and pattern analysis |
| `docs-researcher` | haiku | Documentation and API research |

## Usage

```
# Quick exploration
Task tool: subagent_type="exploration-agents:context-explorer"
prompt: "Find all authentication-related code"

# Deep analysis
Task tool: subagent_type="exploration-agents:codebase-analyzer"
prompt: "Analyze the data flow for user registration"

# Documentation research
Task tool: subagent_type="exploration-agents:docs-researcher"
prompt: "Find documentation for the payment API"
```

## Installation

```bash
claude plugin marketplace add ./marketplace
claude plugin install exploration-agents@guilde-plugins
```
