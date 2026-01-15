# Coordination Manager Agent

**Model Tier:** sonnet (balanced quality and speed)
**Invocation:** `Task tool with subagent_type="agentic-flow:coordination-manager"`

## Purpose

Manages multi-agent workflows using QuantumDAG coordination, ensuring conflict-free parallel operations and optimal resource utilization.

## Capabilities

- Register and track multiple agents
- Detect and prevent file conflicts
- Coordinate parallel operations
- Monitor agent health and performance
- Suggest workflow optimizations
- Track learning trajectories

## When to Use

- **Launching parallel agents** - Ensure conflict-free file access
- **Complex multi-step workflows** - Coordinate handoffs between agents
- **Debugging coordination issues** - Diagnose conflicts or deadlocks
- **Optimizing agent efficiency** - Analyze and improve coordination

## Example Invocation

```
Use Task tool:
  subagent_type: "agentic-flow:coordination-manager"
  prompt: "Coordinate a parallel code review with 3 agents reviewing different parts of the codebase"
```

## Input Format

Provide:
1. **Goal** - What coordination is needed
2. **Agents** - Which agents to coordinate (optional)
3. **Files** - Which files are involved (optional)
4. **Constraints** - Any timing or ordering requirements

Example:

```
Coordinate parallel implementation of:
- Agent A: Backend API (src/api/)
- Agent B: Frontend components (src/components/)
- Agent C: Tests (src/tests/)

Ensure no conflicts and proper sequencing.
```

## Output Format

The agent will provide:

1. **Coordination Plan** - How agents will be orchestrated
2. **Conflict Analysis** - Potential conflicts and mitigations
3. **Execution Order** - Recommended sequence or parallelism
4. **Monitoring Points** - What to watch during execution
5. **Recovery Plan** - How to handle failures

## Coordination Patterns

### Pattern 1: Parallel Non-Overlapping

```
Agent A: src/auth/
Agent B: src/user/
Agent C: src/api/

→ Full parallel execution (no file overlap)
```

### Pattern 2: Sequential with Handoff

```
Agent A: Create schema
   ↓
Agent B: Implement API
   ↓
Agent C: Write tests

→ Each waits for predecessor
```

### Pattern 3: Parallel with Sync Points

```
Agent A: Backend ─────┬─→ Integration
Agent B: Frontend ────┘

→ Parallel until sync point
```

## Integration

Works with:
- `agent-coordination` skill - For implementation details
- `agentsdb-patterns` skill - For learning from coordination
- `multi-agent-review` plugin - For review coordination
- `conductor-workflows` plugin - For track-based orchestration

## Limitations

- Cannot directly execute jj commands (use `/jj` command)
- Provides coordination guidance, not enforcement
- Requires agents to follow coordination protocol

## Related

- `/agentic-flow` - Coordination status and management
- `agent-coordination` skill - QuantumDAG patterns
- `docs/JJ-MULTI-AGENT-PATTERNS.md` - Workflow patterns
