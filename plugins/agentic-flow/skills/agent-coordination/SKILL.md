---
name: agent-coordination
description: |
  Use when coordinating multiple AI agents for parallel work.
  Triggers: "multi-agent", "parallel agents", "agent coordination", "QuantumDAG", "conflict-free".
  NOT for: Single-agent operations or basic jj commands.
---

# Agent Coordination

Expert guidance for multi-agent coordination using QuantumDAG.

## Core Concepts

### QuantumDAG

A Directed Acyclic Graph structure for tracking agent operations without conflicts:

- **Conflict-free** - Multiple agents can work simultaneously
- **Automatic detection** - Conflicts detected before they occur
- **23x faster** - Than Git for 8-10 agent scenarios
- **Quantum fingerprints** - SHA3-512 for integrity verification

### Agent Lifecycle

```
┌─────────────────────────────────────────────┐
│                                             │
│   Register → Check Conflicts → Operate →    │
│      ↑                              │       │
│      └──────── Report ←─────────────┘       │
│                                             │
└─────────────────────────────────────────────┘
```

## Coordination API

### Setup

```javascript
const { JjWrapper } = require('agentic-jujutsu');

const jj = new JjWrapper();
await jj.enableAgentCoordination();
```

### Register Agent

```javascript
// Each agent must register before coordinating
await jj.registerAgent('agent-001', 'code-reviewer');
await jj.registerAgent('agent-002', 'test-automator');
await jj.registerAgent('agent-003', 'security-auditor');
```

### Check Conflicts Before Operating

```javascript
// ALWAYS check before modifying files
const conflicts = await jj.checkAgentConflicts(
  'operation-id',
  'edit',              // Operation type: 'edit', 'create', 'delete'
  ['src/auth.ts']      // Files you plan to touch
);

if (conflicts.length > 0) {
  // Another agent is working on these files
  console.log('Wait for:', conflicts.map(c => c.agentId));
  return;
}

// Safe to proceed
await jj.registerAgentOperation('agent-001', 'operation-id', ['src/auth.ts']);
```

### Get Coordination Stats

```javascript
const stats = await jj.getCoordinationStats();
// {
//   totalAgents: 3,
//   activeOperations: 2,
//   conflictsDetected: 0,
//   averageResolutionTime: 45
// }
```

## Workflow Patterns

### Pattern 1: Parallel Code Review

```javascript
// Launch 3 reviewers in parallel
const reviewers = ['code-reviewer', 'security-auditor', 'architect-reviewer'];

for (const type of reviewers) {
  await jj.registerAgent(`${type}-${Date.now()}`, type);
}

// Each reviewer checks conflicts before reading
// No conflicts for read-only operations
```

### Pattern 2: Parallel File Editing

```javascript
// Agent A wants to edit auth.ts
const conflictsA = await jj.checkAgentConflicts('op-A', 'edit', ['auth.ts']);

// Agent B wants to edit user.ts (different file - no conflict)
const conflictsB = await jj.checkAgentConflicts('op-B', 'edit', ['user.ts']);

// Both can proceed in parallel
```

### Pattern 3: Sequential with Handoff

```javascript
// Agent A completes work
await jj.registerAgentOperation('agent-A', 'op-1', ['shared.ts']);
// ... do work ...
// Operation complete - automatically released

// Agent B can now work on same file
const conflicts = await jj.checkAgentConflicts('op-2', 'edit', ['shared.ts']);
// conflicts = [] (empty, A is done)
```

## Best Practices

### 1. Always Register First

```javascript
// DO
await jj.enableAgentCoordination();
await jj.registerAgent(agentId, agentType);

// DON'T
// Skip registration and hope for the best
```

### 2. Check Before Write

```javascript
// DO
const conflicts = await jj.checkAgentConflicts(opId, 'edit', files);
if (conflicts.length === 0) {
  // Safe to edit
}

// DON'T
// Edit files without checking
```

### 3. Use Specific File Lists

```javascript
// DO
await jj.checkAgentConflicts(opId, 'edit', ['src/auth.ts', 'src/user.ts']);

// DON'T
await jj.checkAgentConflicts(opId, 'edit', ['src/']); // Too broad
```

### 4. Handle Conflicts Gracefully

```javascript
if (conflicts.length > 0) {
  // Option 1: Wait
  await sleep(1000);
  return retry();

  // Option 2: Work on different files
  const safeFiles = files.filter(f => !conflicts.some(c => c.files.includes(f)));

  // Option 3: Report to orchestrator
  throw new ConflictError(conflicts);
}
```

## Performance Characteristics

| Agents | QuantumDAG | Git | Speedup |
|--------|------------|-----|---------|
| 2 | 5ms | 12ms | 2.4x |
| 4 | 8ms | 35ms | 4.4x |
| 8 | 15ms | 180ms | 12x |
| 10 | 20ms | 450ms | 23x |

## Troubleshooting

### "Coordination not enabled"

```javascript
// Always enable before using coordination features
await jj.enableAgentCoordination();
```

### "Agent not registered"

```javascript
// Register before operations
await jj.registerAgent(agentId, agentType);
```

### "Stale conflict data"

```javascript
// Get fresh tips
const tips = await jj.getCoordinationTips();
```

## Related

- `/agentic-flow` - Command interface
- `agentsdb-patterns` - Learning from operations
- `quantum-signing` - Operation integrity
- `docs/JJ-INTEGRATION.md` - Full API reference
