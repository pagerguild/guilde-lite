# Agent Selection Criteria

## Model Tier Strategy

| Tier | Cost | Speed | Use For |
|------|------|-------|---------|
| **haiku** | $ | Fast | Exploration, research, quick analysis |
| **sonnet** | $$ | Balanced | Implementation, testing, optimization |
| **opus** | $$$ | Thorough | Critical decisions, security, architecture |

## Agent Selection by Task Type

### Research & Exploration
```
Need to understand codebase? → context-explorer (haiku)
Need external docs/APIs?    → docs-researcher (haiku)
Need code quality analysis? → codebase-analyzer (haiku)
Need implementation plan?   → spec-builder (sonnet)
```

### Development
```
Building backend services?  → backend-architect (opus)
Building UI components?     → frontend-developer (sonnet)
Writing tests?              → test-automator (sonnet)
Optimizing database?        → database-optimizer (sonnet)
```

### Review & Quality
```
Code review (general)?      → code-reviewer (opus)
Security audit?             → security-auditor (opus)
Architecture review?        → architect-reviewer (opus)
TDD enforcement?            → tdd-orchestrator (sonnet)
```

## Decision Flow

```
Start
  │
  ├─ Is this exploration/research?
  │    YES → Use haiku tier agents
  │
  ├─ Is this implementation/testing?
  │    YES → Use sonnet tier agents
  │
  ├─ Is this a critical decision?
  │    (security, architecture, review)
  │    YES → Use opus tier agents
  │
  └─ Default → Use sonnet
```

## Parallel Agent Patterns

### Feature Development
1. **Parallel Research** (haiku):
   - context-explorer: Find existing patterns
   - docs-researcher: Check external dependencies
   - codebase-analyzer: Identify technical debt

2. **Sequential Implementation** (sonnet):
   - spec-builder → backend-architect → frontend-developer

3. **Parallel Review** (opus):
   - code-reviewer + security-auditor + architect-reviewer

### Bug Investigation
1. context-explorer (haiku) → codebase-analyzer (haiku)
2. code-reviewer (opus) for root cause

### Performance Optimization
1. codebase-analyzer (haiku) → database-optimizer (sonnet)
2. architect-reviewer (opus) for approval

## Invocation Examples

### Quick Exploration
```
Task tool:
  subagent_type: "Explore"
  model: "haiku"
  prompt: "Find all authentication-related files"
```

### Full Code Review
```
Task tool:
  subagent_type: "pr-review-toolkit:code-reviewer"
  model: "opus"
  prompt: "Review changes in PR #123 for bugs and security issues"
```

### Parallel Review (launch multiple)
```
# Launch all three in single message:
Task tool: subagent_type: "pr-review-toolkit:code-reviewer"
Task tool: subagent_type: "full-stack-orchestration:security-auditor"
Task tool: subagent_type: "code-review-ai:architect-review"
```

## Cost Optimization Tips

1. **Start with haiku** for exploration, upgrade if needed
2. **Batch parallel** research agents to reduce latency
3. **Reserve opus** for decisions that truly matter
4. **Use sonnet** as default for implementation work
5. **Cache exploration** results to avoid re-running
