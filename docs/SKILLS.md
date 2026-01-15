# Skills Reference

Skills are specialized knowledge packages that Claude Code activates based on task context. They follow progressive disclosure patterns to minimize context usage while providing deep expertise when needed.

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    SKILL ARCHITECTURE                            │
│                                                                   │
│  Level 1: Metadata (~100 tokens)                                 │
│  ├── Skill name and description                                  │
│  ├── Activation triggers                                         │
│  └── Loaded at session start for intent matching                 │
│                                                                   │
│  Level 2: Core SKILL.md (<5k tokens)                             │
│  ├── Full instructions and patterns                              │
│  ├── Decision logic and workflows                                │
│  └── Loaded when skill is activated                              │
│                                                                   │
│  Level 3: Reference Files (unlimited)                            │
│  ├── Detailed documentation                                      │
│  ├── Code templates and examples                                 │
│  └── Loaded on-demand via filesystem                             │
└─────────────────────────────────────────────────────────────────┘
```

## Available Skills

### Workflow Skills

| Skill | Purpose | Key Patterns |
|-------|---------|--------------|
| `context-loader` | Tiered context management | Progressive loading, handoffs |
| `code-review-pipeline` | Multi-agent code review | Scatter-gather, consensus |
| `test-gen-workflow` | AI-driven test generation | Property-based, mutation testing |
| `error-recovery` | Cascading failure recovery | Retry, fallback, escalation |

### TDD Skills

| Skill | Purpose | TDD Phase |
|-------|---------|-----------|
| `tdd-red-phase` | Write failing tests | RED |
| `tdd-green-phase` | Minimal implementation | GREEN |
| `tdd-refactor-phase` | Clean up code | REFACTOR |

### Tool Skills

| Skill | Purpose | Domain |
|-------|---------|--------|
| `mise-expert` | Runtime management | Dev environment |
| `mermaid-generator` | Diagram generation | Documentation |
| `c4-generator` | Architecture diagrams | Documentation |

---

## Context Loader

**Location:** `.claude/skills/context-loader/SKILL.md`

Manages context efficiently across sessions and agent handoffs.

### Key Patterns

- **Tiered Loading:** Project metadata → Active work → On-demand references
- **Token Budgeting:** Strict limits by context type
- **Compression Strategies:** Pruning, summarization, masking
- **Handoff Protocol:** Structured state transfer between sessions

### When Activated

- Session start
- Context approaching capacity (>70%)
- Agent delegation
- Session recovery

### Quick Reference

```markdown
Tier 1 (Always): CLAUDE.md, product.md, tech-stack.md
Tier 2 (Active): spec.md, plan.md, SESSION_HANDOFF.md
Tier 3 (On-demand): Source files, test files, docs
```

---

## Code Review Pipeline

**Location:** `.claude/skills/code-review-pipeline/SKILL.md`

Orchestrates multi-agent code review with specialized agents.

### Key Patterns

- **Parallel Agent Review:** 4 specialized agents run concurrently
- **Scatter-Gather:** Distribute to agents, aggregate results
- **Consensus Mechanism:** Cross-validation increases confidence
- **Severity Classification:** CRITICAL, HIGH, MEDIUM, LOW

### Agents Used

| Agent | Focus | Model |
|-------|-------|-------|
| Code Reviewer | Logic, bugs | Opus |
| Security Auditor | Vulnerabilities | Opus |
| Architect Reviewer | Design, patterns | Opus |
| Test Analyzer | Coverage, quality | Sonnet |

### When Activated

- `/review-all` command
- Pre-merge review
- Security audit request
- Architecture review

### Quick Reference

```markdown
Quick: Stage 1 only (automated checks)
Standard: All 3 stages (parallel agents)
Thorough: + Silent failure, comment, type analyzers
```

---

## Test Generation Workflow

**Location:** `.claude/skills/test-gen-workflow/SKILL.md`

AI-driven test generation with property-based testing (50x more effective) and mutation testing validation.

### Key Patterns

- **Test Quality Pyramid:** Unit → Property-based → Mutation validation
- **Coverage-Driven:** Target specific coverage gaps
- **Property Categories:** Exception, inclusion, type, idempotency, round-trip
- **Mutation Validation:** Verify tests catch real bugs

### Effectiveness Data

| Property Type | Effectiveness vs Unit Tests |
|--------------|----------------------------|
| Exception checking | 19x |
| Collection inclusion | 19x |
| Type checking | 19x |

### When Activated

- Test generation requests
- Coverage improvement tasks
- TDD test scaffolding
- Refactoring safety net

### Quick Reference

```bash
# Property-based testing tools
Go:     gopter
Python: hypothesis
TS:     fast-check

# Mutation testing tools
Go:     go-mutesting
Python: mutmut
TS:     stryker
```

---

## Error Recovery

**Location:** `.claude/skills/error-recovery/SKILL.md`

Cascading error recovery for multi-agent workflows.

### Key Patterns

- **Tiered Recovery:** Retry → Semantic fallback → Agent substitution → Human escalation
- **Circuit Breaker:** Prevent cascading failures
- **Error Classification:** Transient, output, capability, blocking
- **Exponential Backoff:** With jitter to prevent thundering herd

### Recovery Tiers

| Tier | Strategy | When |
|------|----------|------|
| 1 | Exponential backoff | Rate limits, timeouts |
| 2 | Semantic fallback | Invalid output |
| 3 | Agent substitution | Capability issues |
| 4 | Human escalation | Blocking issues |

### When Activated

- Tool call errors
- Agent failures
- Build/test failures
- Context overflow

### Quick Reference

```yaml
circuit_breaker:
  failure_threshold: 3
  recovery_timeout: 60s

retry_delays: [1s, 2s, 4s, 8s, 16s]
```

---

## TDD Skills

### TDD Red Phase

**Location:** `.claude/skills/tdd-red-phase/SKILL.md`

Guides writing failing tests before implementation.

**Key Actions:**
1. Write test that expresses expected behavior
2. Run test to confirm it fails
3. Verify failure message is meaningful

### TDD Green Phase

**Location:** `.claude/skills/tdd-green-phase/SKILL.md`

Guides minimal implementation to pass tests.

**Key Actions:**
1. Write minimal code to pass test
2. Don't optimize or add features
3. Confirm all tests pass

### TDD Refactor Phase

**Location:** `.claude/skills/tdd-refactor-phase/SKILL.md`

Guides code improvement without changing behavior.

**Key Actions:**
1. Improve code quality
2. Remove duplication
3. Verify tests still pass

---

## Tool Skills

### Mise Expert

**Location:** `.claude/skills/mise-expert/SKILL.md`

Runtime and tool management using mise.

**Key Topics:**
- Installing language runtimes
- Global vs project configuration
- Shims and PATH management
- Migration from nvm/pyenv/rbenv

### Mermaid Generator

**Location:** `.claude/skills/mermaid-generator/SKILL.md`

Generate Mermaid diagrams for documentation.

**Diagram Types:**
- Flowcharts
- Sequence diagrams
- Class diagrams
- State diagrams
- Entity relationship diagrams

### C4 Generator

**Location:** `.claude/skills/c4-generator/SKILL.md`

Generate C4 architecture diagrams.

**C4 Levels:**
1. Context - System in environment
2. Container - High-level technology
3. Component - Major structural blocks
4. Code - Implementation details

---

## Creating New Skills

### Directory Structure

```
.claude/skills/<skill-name>/
├── SKILL.md              # Level 2: Core instructions
└── reference/            # Level 3: Detailed docs
    ├── patterns.md
    ├── examples.md
    └── troubleshooting.md
```

### SKILL.md Template

```yaml
---
name: skill-name
description: |
  Brief description. Use when:
  - Trigger condition 1
  - Trigger condition 2

  Do NOT use for:
  - Exception 1
  - Exception 2
---

# Skill Name

## Purpose
[What this skill does]

## Core Patterns
[Key patterns and workflows]

## Quick Actions
[Common tasks]

## Related Files
[Links to related files]

## Reference Files
[Links to Level 3 references]
```

---

## Plugin Integration

Skills are registered in `.claude-plugin/plugin.json`:

```json
{
  "components": {
    "skills": [
      "context-loader",
      "code-review-pipeline",
      "test-gen-workflow",
      "error-recovery"
    ]
  }
}
```

---

## Related Documentation

- [Multi-Agent Workflow](MULTI-AGENT-WORKFLOW.md) - Agent orchestration
- [Conductor Commands](CONDUCTOR-COMMANDS.md) - Workflow orchestration
- [TDD Requirements](.claude/rules/tdd-requirements.md) - TDD guidelines
- [Quality Gates](.claude/rules/quality-gates.md) - Quality requirements
