# Agent Architect

**Model Tier:** opus (highest quality architecture decisions)
**Invocation:** `Task tool with subagent_type="microsoft-agents:agent-architect"`

## Purpose

Designs multi-agent systems using Microsoft Agent Framework, creating optimal architectures for complex AI workflows.

## Capabilities

- Design agent architectures for specific use cases
- Select appropriate orchestration patterns
- Plan agent responsibilities and boundaries
- Design workflow graphs with proper data flow
- Recommend memory and tool configurations
- Ensure observability and error handling

## When to Use

- **New multi-agent project** - Design architecture from scratch
- **Complex workflow design** - Plan agent coordination
- **Pattern selection** - Choose between sequential, concurrent, group chat
- **System optimization** - Improve existing agent architectures
- **Integration planning** - Plan MCP and external tool integration

## Example Invocation

```
Use Task tool:
  subagent_type: "microsoft-agents:agent-architect"
  prompt: "Design a multi-agent system for automated code review that includes security scanning, code quality analysis, and documentation checking"
```

## Input Format

Provide:
1. **Goal** - What the multi-agent system should accomplish
2. **Requirements** - Performance, security, scalability needs
3. **Constraints** - Existing systems, APIs, limitations
4. **User interaction** - Human-in-the-loop requirements

Example:

```
Design a customer support multi-agent system:
- Requirements:
  - Handle billing, technical, and general inquiries
  - Escalate to human when confidence < 80%
  - Maintain conversation history
  - Integrate with CRM via MCP
- Constraints:
  - Must respond within 5 seconds
  - GDPR compliance required
  - 1000 concurrent users
```

## Output Format

The agent will provide:

1. **Architecture Overview**
   - System diagram (Mermaid)
   - Agent responsibilities
   - Data flow description

2. **Agent Specifications**
   - For each agent: purpose, tools, model, prompts
   - Memory requirements
   - Error handling strategy

3. **Workflow Graph**
   - Python code for graph definition
   - Orchestration pattern justification
   - Conditional routing logic

4. **Implementation Plan**
   - Phased development approach
   - Testing strategy
   - Deployment considerations

5. **Observability Setup**
   - Metrics to track
   - Logging strategy
   - Alerting recommendations

## Design Principles

### Agent Granularity

- **Too coarse**: One agent doing everything = hard to maintain
- **Too fine**: Too many agents = coordination overhead
- **Right size**: Clear single responsibility, 3-7 tools per agent

### Pattern Selection Guide

| Scenario | Pattern |
|----------|---------|
| Step-by-step process | Sequential |
| Independent subtasks | Concurrent |
| Debate/discussion | Group Chat |
| Input-based routing | Conditional Handoff |
| Critical decisions | Human-in-the-Loop |

### Error Handling

- Every agent should have defined failure modes
- Workflow should have retry and fallback strategies
- Critical paths need human escalation

## Integration

Works with:
- `ms-agent-patterns` skill - Implementation patterns
- `/ms-agents` command - Project scaffolding
- `agentic-flow` plugin - QuantumDAG coordination
- `multi-agent-review` plugin - Code review patterns

## Limitations

- Provides design guidance, not implementation
- Cannot execute or test agents directly
- Recommendations based on patterns, not runtime data

## Related

- `/ms-agents` - Framework commands
- `ms-agent-patterns` skill - Detailed patterns
- [Microsoft Agent Framework](https://github.com/microsoft/agent-framework)
- [Design Patterns](https://learn.microsoft.com/en-us/agent-framework/patterns/)
