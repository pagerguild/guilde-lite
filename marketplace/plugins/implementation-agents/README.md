# implementation-agents

Development and implementation agents for building features.

## Agents

| Agent | Model | Focus |
|-------|-------|-------|
| `backend-architect` | opus | API design, microservices, backend patterns |
| `frontend-developer` | sonnet | React, UI components, client-side state |
| `database-optimizer` | sonnet | Query optimization, schema design, indexing |
| `test-automator` | sonnet | Test generation, coverage, CI/CD integration |
| `tdd-orchestrator` | sonnet | TDD workflow coordination and enforcement |

## Usage

```
# Backend implementation
Task tool: subagent_type="implementation-agents:backend-architect"
prompt: "Design API endpoints for user management"

# Frontend implementation
Task tool: subagent_type="implementation-agents:frontend-developer"
prompt: "Create a dashboard component with charts"

# Database optimization
Task tool: subagent_type="implementation-agents:database-optimizer"
prompt: "Optimize the slow queries in the analytics module"

# Test automation
Task tool: subagent_type="implementation-agents:test-automator"
prompt: "Generate test suite for the payment service"
```

## Installation

```bash
claude plugin marketplace add ./marketplace
claude plugin install implementation-agents@guilde-plugins
```
