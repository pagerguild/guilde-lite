---
name: code-review-pipeline
description: |
  Multi-agent code review orchestration following 2024-2025 best practices. Use when:
  - Reviewing code changes before commit or merge
  - PR review with comprehensive analysis needed
  - Security audit of code changes
  - Architectural review of significant changes
  - AI-generated code needs validation
  - Team code quality enforcement

  Do NOT use for:
  - Simple typo fixes (direct review is faster)
  - Documentation-only changes
  - Single-line changes without logic
---

# Code Review Pipeline Skill

## Purpose

Orchestrates multi-agent code review using specialized agents that outperform single-agent review by 90%+ on complex changes (Anthropic research, 2025). Implements scatter-gather pattern with consensus aggregation.

## Core Pattern: Specialized Agent Review

```
┌─────────────────────────────────────────────────────────────────┐
│                    MULTI-AGENT REVIEW PIPELINE                   │
│                                                                   │
│  Stage 1: Automated Checks (5-30s)                               │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐        │
│  │  Linting  │ │  Testing  │ │Type Check │ │  Format   │        │
│  └─────┬─────┘ └─────┬─────┘ └─────┬─────┘ └─────┬─────┘        │
│        └─────────────┴───────┬─────┴─────────────┘              │
│                              ↓                                   │
│  Stage 2: Parallel Agent Reviews (30s-2min)                      │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐        │
│  │   Code    │ │ Security  │ │ Architect │ │   Test    │        │
│  │ Reviewer  │ │  Auditor  │ │ Reviewer  │ │ Analyzer  │        │
│  └─────┬─────┘ └─────┬─────┘ └─────┬─────┘ └─────┬─────┘        │
│        └─────────────┴───────┬─────┴─────────────┘              │
│                              ↓                                   │
│  Stage 3: Consensus & Report (10-30s)                            │
│  ┌─────────────────────────────────────────────────────┐        │
│  │  De-duplicate │ Prioritize │ Generate Report        │        │
│  └─────────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

## Agent Specializations

### Code Reviewer Agent
**Focus:** Logic, bugs, code quality
**Subagent:** `pr-review-toolkit:code-reviewer`

Checks:
- Logic errors and edge cases
- Error handling completeness
- Code clarity and maintainability
- Naming conventions
- Duplication detection

### Security Auditor Agent
**Focus:** Vulnerabilities, secrets, OWASP
**Subagent:** `full-stack-orchestration:security-auditor`

Checks:
- OWASP Top 10 vulnerabilities
- SQL injection, XSS, CSRF
- Authentication/authorization flaws
- Secrets exposure (API keys, passwords)
- Dependency vulnerabilities

### Architect Reviewer Agent
**Focus:** Design, patterns, scalability
**Subagent:** `code-review-ai:architect-review`

Checks:
- Architecture pattern compliance
- DDD principles adherence
- Coupling and cohesion
- Scalability implications
- Technical debt introduction

### Test Analyzer Agent
**Focus:** Coverage, edge cases, quality
**Subagent:** `pr-review-toolkit:pr-test-analyzer`

Checks:
- Test coverage gaps
- Missing edge case tests
- Test quality and maintainability
- Assertion completeness
- Mutation score impact

## Severity Classification

| Severity | Criteria | Action |
|----------|----------|--------|
| CRITICAL | Security vulnerability, data loss risk, production crash | Block merge |
| HIGH | Bug likely in production, significant logic error | Fix before merge |
| MEDIUM | Code quality issue, minor bug risk | Fix soon |
| LOW | Style issue, minor improvement | Nice to have |

## Consensus Mechanism

When multiple agents flag the same issue:
- **High confidence:** 2+ agents identify same problem
- **Cross-validation:** Security + Code reviewer both flag = priority increase
- **Conflict resolution:** Architect reviewer has tiebreaker on design questions

### De-duplication Rules

1. Same file + same line range = merge findings
2. Same category (security, logic, style) = group together
3. Different perspectives on same issue = note all viewpoints

## Review Modes

### Quick Review (Stage 1 only)
```
/review-all --quick
```
- Run automated checks only
- Fast feedback (<30s)
- Use for WIP commits

### Standard Review (Stages 1-3)
```
/review-all
```
- Full pipeline
- Parallel agent execution
- Comprehensive report

### Thorough Review (Extended)
```
/review-all --thorough
```
- Standard + additional agents:
  - Silent failure hunter
  - Comment analyzer
  - Type design analyzer

## Invocation Pattern

### Parallel Agent Launch

```
# Launch all review agents in parallel
Task tool (parallel):
  1. subagent_type: pr-review-toolkit:code-reviewer
     prompt: Review {diff} for bugs, logic errors, code quality

  2. subagent_type: full-stack-orchestration:security-auditor
     prompt: Security audit {diff} for vulnerabilities

  3. subagent_type: code-review-ai:architect-review
     prompt: Review {diff} for architectural integrity

  4. subagent_type: pr-review-toolkit:pr-test-analyzer
     prompt: Analyze test coverage for {diff}
```

### Result Aggregation

```
1. Collect all agent findings
2. Group by file and line range
3. De-duplicate similar findings
4. Assign severity based on:
   - Agent's assessment
   - Cross-validation boost
   - Category (security issues boost severity)
5. Generate unified report
```

## Report Format

```markdown
═══════════════════════════════════════════════════════════════════
CODE REVIEW SUMMARY
═══════════════════════════════════════════════════════════════════

Files Reviewed: X
Lines Changed: +Y, -Z
Agents Consulted: 4

CRITICAL (N)
────────────────────────────────────────────────────────────────────
[Security] SQL injection in user_handler.go:45
  Found by: security-auditor, code-reviewer
  Recommendation: Use parameterized queries

HIGH (N)
────────────────────────────────────────────────────────────────────
[Logic] Missing null check in processor.go:123
  Found by: code-reviewer
  Recommendation: Add nil guard before dereference

MEDIUM (N)
────────────────────────────────────────────────────────────────────
...

LOW (N)
────────────────────────────────────────────────────────────────────
...

═══════════════════════════════════════════════════════════════════
VERDICT: [APPROVE | APPROVE WITH COMMENTS | REQUEST CHANGES]
═══════════════════════════════════════════════════════════════════
```

## Integration Points

### Pre-Commit Hook
```bash
# Trigger quick review on pre-commit
/review-all --quick
```

### PR Review Automation
```yaml
# GitHub Actions integration
on: pull_request
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: AI Review
        run: claude "/review-all pr"
```

### Telemetry Tracking
```bash
# Track review metrics
bash scripts/multi-agent-metrics.sh track code_review_completed
```

## Quality Gates Enforced

From `.claude/rules/quality-gates.md`:
- No CRITICAL issues allowed
- HIGH issues must be addressed or acknowledged
- Test coverage must not decrease
- Security scan must pass

## Related Commands

- `/review-all` - Invoke this pipeline
- `/tdd` - TDD workflow (write tests first)
- `/conductor-checkpoint` - Checkpoint after review passes

## Reference Files

For detailed information, see:
- `reference/agent-prompts.md` - Detailed prompts for each agent
- `reference/severity-examples.md` - Issue severity classification examples
- `reference/integration-patterns.md` - CI/CD integration patterns
