---
description: AI agent coordination - status, conflicts, learning, and management
argument-hint: "[status|agents|conflicts|learning|tips|help]"
allowed-tools: ["Bash", "Read", "Glob", "Task"]
---

# /agentic-flow Command

AI agent coordination using agentic-jujutsu infrastructure.

## Quick Reference

| Subcommand | Description |
|------------|-------------|
| `status` | Show coordination system status |
| `agents` | List registered agents |
| `conflicts` | Check for potential conflicts |
| `learning` | Show AgentDB learning stats |
| `tips` | Get coordination tips (DAG tips) |
| `help` | Show this help |

## Actions

### `/agentic-flow` or `/agentic-flow status`

Show coordination system status:

```javascript
const jj = new JjWrapper();
await jj.enableAgentCoordination();
const stats = await jj.getCoordinationStats();
console.log(stats);
```

Displays:
- Coordination enabled/disabled
- Total registered agents
- Active operations
- Conflict count
- Learning statistics

### `/agentic-flow agents`

List all registered agents:

```javascript
const agents = await jj.listAgents();
// Returns: [{agentId, agentType, registeredAt, operationCount}]
```

To register a new agent:

```javascript
await jj.registerAgent('agent-001', 'code-reviewer');
```

### `/agentic-flow conflicts`

Check for potential conflicts before operations:

```javascript
const conflicts = await jj.checkAgentConflicts(
  'op-123',           // Operation ID
  'edit',             // Operation type
  ['src/main.ts']     // Files involved
);

if (conflicts.length > 0) {
  console.log('Conflicts detected:', conflicts);
}
```

### `/agentic-flow learning`

Show AgentDB learning statistics:

```javascript
const stats = await jj.getLearningStats();
// Returns: {
//   totalTrajectories: number,
//   successRate: number,
//   patterns: string[],
//   recentLearnings: Trajectory[]
// }
```

View discovered patterns:

```javascript
const patterns = await jj.getPatterns();
```

Get suggestions for a task:

```javascript
const suggestion = await jj.getSuggestion('implement auth endpoint');
```

### `/agentic-flow tips`

Get current DAG tips (latest coordination states):

```javascript
const tips = await jj.getCoordinationTips();
// Returns latest states for conflict resolution
```

## QuantumDAG Overview

QuantumDAG is a conflict-free data structure for multi-agent operations:

```
Performance vs Git (8-10 agents):
┌────────────────────────────────┐
│ Operation        jj    git     │
│ ─────────────────────────────  │
│ Status check     3ms   8ms     │
│ Commit           18ms  45ms    │
│ Rebase (10)      65ms  150ms   │
│ Coordination     1.5ms N/A     │
└────────────────────────────────┘
```

## Agent Registration

Before agents can coordinate, they must register:

```javascript
// In agent initialization
const jj = new JjWrapper();
await jj.enableAgentCoordination();
await jj.registerAgent(process.env.AGENT_ID, 'my-agent-type');

// Track operations
await jj.registerAgentOperation(
  process.env.AGENT_ID,
  'op-' + Date.now(),
  ['file1.ts', 'file2.ts']
);
```

## Self-Learning Workflow

Track successful workflows for future suggestions:

```javascript
// Start tracking
const trajectoryId = await jj.startTrajectory('implement feature X');

// Add operations as you go
await jj.addToTrajectory(trajectoryId, {
  action: 'create_file',
  file: 'src/feature.ts',
  success: true
});

// Finalize with score
await jj.finalizeTrajectory(trajectoryId, 0.95, 'Completed successfully');

// Later, query similar tasks
const similar = await jj.queryTrajectories('implement feature Y', 5);
```

## Related

- `/jj` - Basic jj operations
- `agent-coordination` skill - QuantumDAG patterns
- `agentsdb-patterns` skill - Learning patterns
- `quantum-signing` skill - Cryptographic signing
- `docs/JJ-INTEGRATION.md` - Full documentation
