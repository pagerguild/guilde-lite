---
description: Multi-stage code review pipeline - runs parallel review agents for comprehensive QA
argument-hint: "[staged|unstaged|branch|pr|file:path] [--parallel|--quick|--thorough]"
allowed-tools: ["Read", "Bash", "Task", "Glob", "Grep", "TodoWrite"]
---

# /review-all Command

Orchestrates a multi-stage code review pipeline using parallel agents for comprehensive quality assurance.

## Review Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                     REVIEW-ALL PIPELINE                          │
│                                                                  │
│  Stage 1: Fast Checks (Automated)                               │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐                  │
│  │  Linting   │ │   Tests    │ │ Type Check │                  │
│  └────────────┘ └────────────┘ └────────────┘                  │
│         ↓              ↓              ↓                         │
│  Stage 2: Parallel Agent Reviews                                │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐                  │
│  │   Code     │ │ Security   │ │ Architect  │                  │
│  │  Reviewer  │ │  Auditor   │ │  Reviewer  │                  │
│  └────────────┘ └────────────┘ └────────────┘                  │
│         ↓              ↓              ↓                         │
│  Stage 3: Consensus & Summary                                   │
│  ┌─────────────────────────────────────────────┐               │
│  │         Aggregate Findings                   │               │
│  │         Prioritize Issues                    │               │
│  │         Generate Report                      │               │
│  └─────────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

## Actions

### `/review-all` or `/review-all staged`

Review staged changes (default):

1. Run Stage 1 automated checks
2. Launch parallel review agents on staged diff
3. Aggregate and report findings

### `/review-all unstaged`

Review all unstaged changes:

```bash
# Get unstaged diff for review
git diff
```

### `/review-all branch`

Review all changes on current branch vs main:

```bash
# Get branch diff
git diff main...HEAD
```

### `/review-all pr`

Review changes in a pull request (requires PR number in context).

### `/review-all file:<path>`

Review a specific file:

```bash
# Review specific file
/review-all file:src/auth/handler.go
```

## Options

### `--parallel` (default)

Run all Stage 2 agents in parallel for faster results.

### `--sequential`

Run Stage 2 agents one at a time (useful for debugging or rate limiting).

### `--quick`

Skip Stage 2, only run Stage 1 automated checks.

### `--thorough`

Add additional reviewers:
- Silent failure hunter
- Comment analyzer
- Type design analyzer

## Stage 1: Automated Checks

Run via Task commands or directly:

```bash
# Linting
task lint              # All linters
go vet ./...           # Go
uv run ruff check      # Python
bun run lint           # TypeScript

# Testing
task test              # All tests
go test -v ./...       # Go
uv run pytest          # Python
bun test               # TypeScript

# Type checking
go build ./...         # Go type check
uv run mypy            # Python (if configured)
bun run typecheck      # TypeScript
```

## Stage 2: Parallel Agent Reviews

Launch these agents in parallel:

### Code Reviewer (Opus)

```
Task tool:
  subagent_type: pr-review-toolkit:code-reviewer
  prompt: Review the following code changes for bugs, logic errors,
          security vulnerabilities, code quality issues, and adherence
          to project conventions.
```

Focus areas:
- Bug detection and logic errors
- Security vulnerabilities
- Code quality and maintainability
- Convention adherence (see .claude/rules/coding-standards.md)

### Security Auditor (Opus)

```
Task tool:
  subagent_type: full-stack-orchestration:security-auditor
  prompt: Perform security audit on the following code changes.
          Check for OWASP Top 10, auth/authz issues, injection
          vulnerabilities, and credential exposure.
```

Focus areas:
- OWASP Top 10 vulnerabilities
- Authentication/authorization issues
- SQL injection, XSS, CSRF
- Credential and secret detection
- Compliance considerations (GDPR, HIPAA if applicable)

### Architect Reviewer (Opus)

```
Task tool:
  subagent_type: code-review-ai:architect-review
  prompt: Review the following changes for architectural integrity.
          Check pattern compliance, scalability, coupling/cohesion,
          and technical debt implications.
```

Focus areas:
- Architecture pattern compliance
- DDD principles adherence
- Scalability implications
- Coupling and cohesion analysis
- Technical debt assessment

## Stage 3: Consensus & Summary

After all agents complete, aggregate findings:

1. **Categorize by severity:**
   - CRITICAL: Must fix before merge (security, data loss)
   - HIGH: Should fix before merge (bugs, major issues)
   - MEDIUM: Fix soon (code quality, minor issues)
   - LOW: Nice to have (style, suggestions)

2. **De-duplicate findings:**
   - Merge similar issues from different reviewers
   - Note when multiple reviewers flag same issue (higher confidence)

3. **Generate report:**
   - Summary of changes reviewed
   - Issues by severity
   - Recommendations
   - Approval/rejection recommendation

## Example Workflow

```
User: /review-all staged

Claude: Running Stage 1 automated checks...
        ✓ Linting passed
        ✓ Tests passed (47/47)
        ✓ Type check passed

        Running Stage 2 parallel reviews...
        [Launching code-reviewer agent]
        [Launching security-auditor agent]
        [Launching architect-reviewer agent]

        Waiting for agents to complete...
        ✓ Code Reviewer: 2 issues found
        ✓ Security Auditor: 1 issue found
        ✓ Architect Reviewer: 0 issues found

        Stage 3: Aggregating findings...

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
          - Found by: code-reviewer

          [Code Quality] Duplicate code in auth.go:120-135
          - Found by: code-reviewer

        LOW (0)
          None

        Recommendation: FIX HIGH issues before merge
        ═══════════════════════════════════════════
```

## Quality Gates Integration

The review pipeline enforces quality gates from `.claude/rules/quality-gates.md`:

- Test coverage: 80% minimum
- Linting: Zero errors
- Type safety: Strict mode
- Security: No CRITICAL/HIGH issues
- Architecture: Pattern compliance

## Metrics Tracking

Review events are tracked via multi-agent-metrics.sh:

```bash
# Track review completion
bash scripts/multi-agent-metrics.sh track code_change_reviewed
```

## Related Commands

- `/tdd` - TDD workflow management
- `/multi-agent status` - Multi-agent compliance
- `/docs-sync` - Documentation synchronization
- `task lint` - Run all linters
- `task test` - Run all tests

## Related Files

- `.claude/rules/quality-gates.md` - Quality gate definitions
- `.claude/rules/coding-standards.md` - Coding conventions
- `.claude/agents/code-reviewer.md` - Code reviewer spec
- `.claude/agents/security-auditor.md` - Security auditor spec
- `.claude/agents/architect-reviewer.md` - Architect reviewer spec
