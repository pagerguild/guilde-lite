# Code Review Pipeline

This document describes the multi-stage code review pipeline for guilde-lite.

## Overview

The review pipeline ensures code quality through three stages:

1. **Stage 1: Automated Checks** - Fast, automated validation
2. **Stage 2: Agent Reviews** - Parallel AI-powered code review
3. **Stage 3: Consensus** - Aggregate findings and prioritize

## Quick Start

```bash
# Run Stage 1 automated checks
task review:quick

# Run full review guidance
task review

# Use /review-all command for orchestrated multi-agent review
/review-all staged
```

## Stage 1: Automated Checks

Fast, automated validation that runs in seconds.

### Commands

```bash
# Via Task
task review:quick          # Stage 1 only
task lint                  # All linters
task test                  # All tests

# Via Script
bash scripts/review-pipeline.sh staged --quick
```

### Checks Performed

| Check | Go | Python | TypeScript |
|-------|-----|--------|------------|
| Linting | `go vet` | `ruff check` | `bun lint` |
| Testing | `go test` | `pytest` | `bun test` |
| Type Check | `go build` | `mypy` | `tsc --noEmit` |

### Quality Gates

- **Linting**: Zero errors required
- **Tests**: All must pass
- **Type Safety**: Strict mode enabled

## Stage 2: Agent Reviews

Launch parallel AI agents for comprehensive review.

### Review Agents

| Agent | Model | Focus Areas |
|-------|-------|-------------|
| `pr-review-toolkit:code-reviewer` | Opus | Bugs, logic errors, code quality, conventions |
| `full-stack-orchestration:security-auditor` | Opus | OWASP Top 10, auth, injection, credentials |
| `code-review-ai:architect-review` | Opus | Patterns, scalability, coupling, tech debt |

### When to Use Stage 2

Required for changes affecting:
- Security-sensitive code (auth, crypto, user data)
- Public APIs
- Architecture/design patterns
- More than 3 files
- Database schemas or migrations

### Invoking Agents

Via `/review-all` command:
```
/review-all staged    # Reviews staged changes
/review-all branch    # Reviews branch vs main
```

Or manually via Task tool:
```
Task tool:
  subagent_type: pr-review-toolkit:code-reviewer
  prompt: Review the following changes for bugs, security, and quality...
```

### Parallel Execution

For optimal performance, launch all Stage 2 agents in parallel:

```
[Parallel]
├── code-reviewer agent
├── security-auditor agent
└── architect-reviewer agent
```

## Stage 3: Consensus & Summary

Aggregate findings from all agents and prioritize.

### Issue Severity Levels

| Level | Description | Action Required |
|-------|-------------|-----------------|
| **CRITICAL** | Security vulnerabilities, data loss | Must fix before merge |
| **HIGH** | Bugs, major code issues | Should fix before merge |
| **MEDIUM** | Code quality, minor issues | Fix in follow-up |
| **LOW** | Style, suggestions | Optional |

### Consensus Rules

- **CRITICAL issues**: Block merge
- **HIGH issues**: Require explicit approval to proceed
- **Multiple agents flagging same issue**: Higher confidence
- **Conflicting opinions**: Escalate to human review

### Report Format

```
═══════════════════════════════════════════
REVIEW-ALL SUMMARY
═══════════════════════════════════════════

Files reviewed: 4
Lines changed: +127, -23

Issues Found:

CRITICAL (0)
  None

HIGH (1)
  [Security] Potential SQL injection in user_service.go:45
  - Found by: security-auditor
  - Recommendation: Use parameterized queries

MEDIUM (2)
  [Code Quality] Missing error handling in handler.go:78
  [Code Quality] Duplicate code in auth.go:120-135

Recommendation: FIX HIGH issues before merge
═══════════════════════════════════════════
```

## Integration with Workflow

### Pre-Commit

```bash
# Run before committing
task review:quick
# Or
bash scripts/review-pipeline.sh staged --quick
```

### Pre-Merge

```
# Run full review before merging
/review-all branch
```

### CI Integration

Add to CI pipeline:

```yaml
jobs:
  review:
    steps:
      - name: Stage 1 Checks
        run: task review:quick
```

## Hooks Integration

The review pipeline integrates with Claude Code hooks:

- **PostToolUse (Write/Edit)**: Tracks `code_change_no_review` event
- **PostToolUse (Task code-reviewer)**: Tracks `code_change_reviewed` event
- **PreToolUse (Write/Edit)**: Reminds to review before commit

## Metrics Tracking

Review events are tracked in `~/.local/share/multi-agent-metrics/`:

```bash
# Check review compliance
/multi-agent status
```

## Related Files

- `.claude/commands/review-all.md` - Command definition
- `.claude/rules/quality-gates.md` - Quality gate definitions
- `scripts/review-pipeline.sh` - Pipeline script
- `.claude/agents/code-reviewer.md` - Agent specification
- `.claude/agents/security-auditor.md` - Agent specification
- `.claude/agents/architect-reviewer.md` - Agent specification

## Task Commands

| Command | Description |
|---------|-------------|
| `task review` | Full review pipeline |
| `task review:quick` | Stage 1 only |
| `task review:staged` | Review staged changes |
| `task review:unstaged` | Review unstaged changes |
| `task review:branch` | Review branch vs main |
