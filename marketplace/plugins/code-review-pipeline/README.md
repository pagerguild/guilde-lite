# Code Review Pipeline

Multi-stage code review workflow with parallel agent reviews and test generation.

## Features

- **Multi-stage pipeline**: Automated checks, parallel agent reviews, and consensus aggregation
- **Parallel agent reviews**: Code reviewer, security auditor, and architect reviewer run simultaneously
- **Test generation workflow**: AI-driven test generation with property-based testing and mutation testing
- **Quality gates enforcement**: Automated severity classification and issue prioritization
- **CI/CD integration**: GitHub Actions compatible review automation

## Installation

```bash
claude plugin install code-review-pipeline@guilde-plugins
```

## Usage

### Commands

#### `/review-all`

Orchestrates a multi-stage code review pipeline:

```bash
/review-all                    # Review staged changes (default)
/review-all staged             # Review staged changes
/review-all unstaged           # Review unstaged changes
/review-all branch             # Review branch vs main
/review-all pr                 # Review pull request
/review-all file:path/to/file  # Review specific file
```

**Options:**
- `--parallel` - Run agents in parallel (default)
- `--sequential` - Run agents one at a time
- `--quick` - Stage 1 automated checks only
- `--thorough` - Extended review with additional agents

### Skills

#### `code-review-pipeline`

Auto-activates for:
- Reviewing code changes before commit or merge
- PR review with comprehensive analysis
- Security audit of code changes
- Architectural review of significant changes
- AI-generated code validation

#### `test-gen-workflow`

Auto-activates for:
- Comprehensive test coverage for new code
- Coverage gap identification
- TDD test scaffolding
- Test quality validation with mutation testing
- Edge case discovery

## Pipeline Stages

```
Stage 1: Fast Checks (Automated)
  - Linting, Tests, Type Checking

Stage 2: Parallel Agent Reviews
  - Code Reviewer (bugs, logic, quality)
  - Security Auditor (OWASP, vulnerabilities)
  - Architect Reviewer (patterns, scalability)

Stage 3: Consensus & Summary
  - De-duplicate findings
  - Prioritize by severity
  - Generate report
```

## Severity Classification

| Severity | Action |
|----------|--------|
| CRITICAL | Block merge (security, data loss) |
| HIGH | Fix before merge (bugs, major issues) |
| MEDIUM | Fix soon (code quality) |
| LOW | Nice to have (style, suggestions) |

## Configuration

Quality gates are configured in `.claude/rules/quality-gates.md`:
- Test coverage: 80% minimum
- Linting: Zero errors
- Type safety: Strict mode
- Security: No CRITICAL/HIGH issues
