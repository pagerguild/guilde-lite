# agentic-flow

AI agent coordination with QuantumDAG, AgentDB learning, and quantum-resistant signing.

## Commands

| Command | Description |
|---------|-------------|
| `/agentic-flow` | Agent coordination status and management |
| `/agentic-flow status` | Show coordination system status |
| `/agentic-flow agents` | List registered agents |
| `/agentic-flow conflicts` | Check for potential conflicts |
| `/agentic-flow learning` | Show AgentDB learning stats |
| `/agentic-flow tips` | Get coordination tips |

## Skills

| Skill | Triggers |
|-------|----------|
| `agent-coordination` | "multi-agent", "parallel agents", "QuantumDAG" |
| `agentsdb-patterns` | "agent learning", "trajectory", "pattern recognition" |
| `quantum-signing` | "quantum signing", "ML-DSA", "post-quantum" |

## Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| `coordination-manager` | sonnet | Manages multi-agent workflows |

## Features

### QuantumDAG

Conflict-free coordination for parallel agents:

- **23x faster** than Git for 8-10 agents
- **Automatic conflict detection**
- **No locks required**

### AgentDB Learning

Self-improving agent workflows:

- **Trajectory tracking** - Record successful workflows
- **Pattern recognition** - Learn from past operations
- **Smart suggestions** - AI-powered recommendations

### Quantum Signing

Post-quantum cryptographic integrity:

- **ML-DSA-65** - NIST FIPS 204 Level 3
- **SHA3-512 fingerprints** - Fast integrity checks
- **HQC-128 encryption** - Optional data encryption

## Quick Start

```javascript
const { JjWrapper } = require('agentic-jujutsu');

const jj = new JjWrapper();
await jj.enableAgentCoordination();

// Register agent
await jj.registerAgent('my-agent', 'code-reviewer');

// Check conflicts before operating
const conflicts = await jj.checkAgentConflicts('op-1', 'edit', ['file.ts']);

// Track learning
const id = await jj.startTrajectory('implement feature');
await jj.addToTrajectory(id, { action: 'create', file: 'feature.ts' });
await jj.finalizeTrajectory(id, 0.95, 'Success');
```

## Installation

```bash
# Add marketplace (if needed)
claude plugin marketplace add ./marketplace

# Install plugin
claude plugin install agentic-flow@guilde-plugins
```

## Related

- [JJ Integration Docs](../../docs/JJ-INTEGRATION.md)
- [Multi-Agent Patterns](../../docs/JJ-MULTI-AGENT-PATTERNS.md)
- `jj-tools` plugin - Basic jj operations
- `multi-agent-review` plugin - Code review coordination
