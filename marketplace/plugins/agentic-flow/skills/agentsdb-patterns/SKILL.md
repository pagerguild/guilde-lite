---
name: agentsdb-patterns
description: |
  Use when implementing self-learning agent workflows.
  Triggers: "agent learning", "trajectory", "pattern recognition", "AgentDB", "self-learning agent".
  NOT for: Basic agent operations without learning requirements.
---

# AgentDB Patterns

Expert guidance for self-learning agent workflows using AgentDB.

## Core Concepts

### What is AgentDB?

AgentDB is a persistent knowledge base that:

- **Tracks operations** - Records every agent action with metadata
- **Recognizes patterns** - Identifies successful workflows
- **Provides suggestions** - Recommends actions based on history
- **Learns continuously** - Improves with each trajectory

### Trajectory System

A trajectory is a recorded sequence of operations:

```
┌─────────────────────────────────────────────────┐
│ Trajectory: "implement-auth-feature"            │
│                                                 │
│ Step 1: create_file src/auth.ts                │
│ Step 2: edit_file src/auth.ts (add login)      │
│ Step 3: create_file src/auth.test.ts           │
│ Step 4: run_tests (pass)                       │
│                                                 │
│ Score: 0.95  Status: Completed                 │
└─────────────────────────────────────────────────┘
```

## API Reference

### Starting a Trajectory

```javascript
const { JjWrapper } = require('agentic-jujutsu');

const jj = new JjWrapper();
await jj.enableAgentCoordination();

// Start tracking a workflow
const trajectoryId = await jj.startTrajectory('implement user authentication');
```

### Recording Operations

```javascript
// Add each significant operation
await jj.addToTrajectory(trajectoryId, {
  action: 'create_file',
  file: 'src/auth/login.ts',
  success: true,
  metadata: {
    lines: 45,
    imports: ['bcrypt', 'jwt']
  }
});

await jj.addToTrajectory(trajectoryId, {
  action: 'run_tests',
  success: true,
  metadata: {
    passed: 12,
    failed: 0,
    coverage: 0.85
  }
});
```

### Finalizing a Trajectory

```javascript
// Mark as complete with score and critique
await jj.finalizeTrajectory(
  trajectoryId,
  0.92,                              // Score (0-1)
  'Successfully implemented with good test coverage'
);
```

### Querying Past Trajectories

```javascript
// Find similar past workflows
const similar = await jj.queryTrajectories(
  'implement user registration',     // Task description
  5                                   // Max results
);

// Returns trajectories with similarity scores
// [{trajectoryId, task, score, similarity, operations}]
```

### Getting Suggestions

```javascript
// Get AI-powered suggestion for a task
const suggestion = await jj.getSuggestion('add password reset feature');

// Returns recommended approach based on learned patterns
// {
//   recommendedSteps: [...],
//   similarTrajectories: [...],
//   confidence: 0.85
// }
```

### Viewing Patterns

```javascript
// Get discovered patterns
const patterns = await jj.getPatterns();

// Returns common successful patterns
// [{pattern, frequency, avgScore, examples}]
```

### Learning Statistics

```javascript
const stats = await jj.getLearningStats();
// {
//   totalTrajectories: 156,
//   successfulTrajectories: 142,
//   successRate: 0.91,
//   topPatterns: [...],
//   recentLearnings: [...]
// }
```

## Learning Patterns

### Pattern 1: TDD Trajectory

```javascript
// Record TDD workflow
const id = await jj.startTrajectory('TDD: implement feature X');

// RED phase
await jj.addToTrajectory(id, {
  action: 'create_test',
  file: 'feature.test.ts',
  success: true,
  phase: 'red'
});

await jj.addToTrajectory(id, {
  action: 'run_tests',
  success: false,  // Expected to fail
  phase: 'red'
});

// GREEN phase
await jj.addToTrajectory(id, {
  action: 'implement',
  file: 'feature.ts',
  success: true,
  phase: 'green'
});

await jj.addToTrajectory(id, {
  action: 'run_tests',
  success: true,
  phase: 'green'
});

// REFACTOR phase
await jj.addToTrajectory(id, {
  action: 'refactor',
  file: 'feature.ts',
  success: true,
  phase: 'refactor'
});

await jj.finalizeTrajectory(id, 0.95, 'TDD cycle complete');
```

### Pattern 2: Code Review Learning

```javascript
// Track review outcomes
const id = await jj.startTrajectory('code-review: PR #123');

await jj.addToTrajectory(id, {
  action: 'review_security',
  findings: 2,
  severity: 'medium'
});

await jj.addToTrajectory(id, {
  action: 'review_quality',
  findings: 5,
  severity: 'low'
});

await jj.addToTrajectory(id, {
  action: 'fixes_applied',
  success: true
});

await jj.finalizeTrajectory(id, 0.88, 'Review complete, issues resolved');
```

### Pattern 3: Error Recovery Learning

```javascript
// Learn from errors
const id = await jj.startTrajectory('debug: authentication failure');

await jj.addToTrajectory(id, {
  action: 'investigate',
  finding: 'token_expired',
  success: true
});

await jj.addToTrajectory(id, {
  action: 'fix_applied',
  solution: 'refresh_token_logic',
  success: true
});

await jj.addToTrajectory(id, {
  action: 'verify_fix',
  tests_passed: true,
  success: true
});

await jj.finalizeTrajectory(id, 1.0, 'Bug fixed and verified');

// Next time similar error occurs:
const suggestion = await jj.getSuggestion('authentication failure');
// Will recommend checking token expiration
```

## Best Practices

### 1. Meaningful Task Names

```javascript
// DO
await jj.startTrajectory('implement: user password reset with email verification');

// DON'T
await jj.startTrajectory('task1');
```

### 2. Record All Significant Steps

```javascript
// DO - Record meaningful operations
await jj.addToTrajectory(id, { action: 'create_migration', ... });
await jj.addToTrajectory(id, { action: 'update_schema', ... });
await jj.addToTrajectory(id, { action: 'run_migration', ... });

// DON'T - Skip steps or over-record
await jj.addToTrajectory(id, { action: 'thinking', ... }); // Too granular
```

### 3. Accurate Scoring

```javascript
// Score based on outcome
await jj.finalizeTrajectory(id,
  testsPass && noRegressions ? 0.95 : 0.6,
  critique
);
```

### 4. Use Similarity Search

```javascript
// Before starting new work, check for similar past work
const similar = await jj.queryTrajectories(newTask, 3);
if (similar.length > 0 && similar[0].similarity > 0.8) {
  // Follow the successful pattern
  const pattern = similar[0].operations;
}
```

## Security

### Encrypted Trajectories

For sensitive workflows, enable encryption:

```javascript
await jj.enableEncryption();

// Trajectories are now encrypted with HQC-128
const id = await jj.startTrajectory('sensitive: handle PII data');
```

## Related

- `/agentic-flow learning` - View learning stats
- `agent-coordination` - Multi-agent coordination
- `quantum-signing` - Operation integrity
- `docs/JJ-INTEGRATION.md` - Full API reference
