# Multi-Agent Workflow Onboarding Guide

Welcome to the guilde-lite multi-agent workflow system. This guide will help you get productive quickly.

## Prerequisites

Before starting, ensure you have:
- Claude Code installed and authenticated
- The guilde-lite repository cloned
- Basic familiarity with Claude Code commands

## Quick Start (5 minutes)

### 1. Verify Installation

```bash
# Run the validation script
bash scripts/validate-workflow.sh

# Expected: 66/66 validations passing
```

### 2. Check Current Status

```
/conductor-status
```

This shows the current implementation track and progress.

### 3. Your First Workflow

Start a new feature:

```
/conductor-new-track "Add user preferences API"
```

This creates:
- `conductor/tracks/FEAT-XXX/spec.md` - Requirements
- `conductor/tracks/FEAT-XXX/plan.md` - Implementation phases

## Core Concepts

### The Conductor Pattern

The conductor pattern breaks work into phases with checkpoints:

```
Phase 1: Research & Planning
    ↓ checkpoint
Phase 2: Implementation
    ↓ checkpoint
Phase 3: Testing
    ↓ checkpoint
Phase 4: Review & Release
```

Each phase has:
- **Objectives**: What to achieve
- **Tasks**: Specific work items
- **Quality Gates**: Must pass before checkpoint

### Agent Tiers

Agents are organized by cost/capability:

| Tier | Model | Use For |
|------|-------|---------|
| Research | haiku | Fast exploration, context gathering |
| Development | sonnet | Code writing, implementation |
| Review | opus | Critical analysis, architecture |

### TDD Workflow

All code follows Test-Driven Development:

```
RED    → Write failing test first
GREEN  → Minimal code to pass
REFACTOR → Improve without changing behavior
```

Check your phase:
```bash
bash scripts/tdd-enforcer.sh phase
```

## Daily Workflow

### Starting Work

1. **Load context**
   ```
   /conductor-status
   ```

2. **Start implementation**
   ```
   /conductor-implement
   ```

3. **Follow TDD**
   - Write test first (RED)
   - Implement minimally (GREEN)
   - Clean up (REFACTOR)

### Completing a Phase

1. **Verify all tasks complete**
   ```
   /conductor-status
   ```

2. **Run review pipeline**
   ```
   /review-all
   ```

3. **Create checkpoint**
   ```
   /conductor-checkpoint
   ```

### Handling Context Loss

If Claude loses context (session restart):

```
/conductor-status
```

This reloads the current track state automatically.

## Key Commands

| Command | Purpose |
|---------|---------|
| `/conductor-status` | View current progress |
| `/conductor-new-track` | Start new feature |
| `/conductor-implement` | Work on current phase |
| `/conductor-checkpoint` | Mark phase complete |
| `/conductor-sync-docs` | Update documentation |
| `/review-all` | Run full code review |

## Available Agents

### Research Agents (haiku - fast/cheap)

| Agent | When to Use |
|-------|-------------|
| `context-explorer` | Understanding codebase structure |
| `docs-researcher` | Finding relevant documentation |
| `codebase-analyzer` | Analyzing code patterns |

### Development Agents (sonnet - balanced)

| Agent | When to Use |
|-------|-------------|
| `spec-builder` | Creating specifications |
| `frontend-developer` | UI/UX implementation |
| `test-automator` | Writing tests |
| `database-optimizer` | Database queries/schemas |
| `tdd-orchestrator` | TDD workflow coordination |

### Review Agents (opus - thorough)

| Agent | When to Use |
|-------|-------------|
| `backend-architect` | API design, architecture |
| `code-reviewer` | Code quality, bugs |
| `security-auditor` | Security vulnerabilities |
| `architect-reviewer` | Design patterns, scalability |

## Skills Reference

Skills provide specialized workflows:

| Skill | Activation |
|-------|------------|
| `context-loader` | Session start, context overflow |
| `code-review-pipeline` | `/review-all`, pre-merge |
| `test-gen-workflow` | Test generation requests |
| `error-recovery` | Tool/agent failures |
| `tdd-red-phase` | Writing failing tests |
| `tdd-green-phase` | Minimal implementation |
| `tdd-refactor-phase` | Code cleanup |

## Hookify Rules (Automatic)

These rules trigger automatically:

| Rule | Trigger | Action |
|------|---------|--------|
| `block-destructive` | Dangerous bash commands | Block |
| `warn-secrets` | Editing sensitive files | Warn |
| `tdd-tests-first` | Writing impl before tests | Warn |
| `tdd-auto-test` | Code changes without tests | Warn |
| `doc-sync-reminder` | API/config changes | Warn |

## Telemetry (Optional)

Enable observability:

```bash
# Start Grafana stack
docker compose -f docker/observability-compose.yml up -d

# View dashboard
open http://localhost:3000
```

Metrics tracked:
- Agent invocations by tier
- Task completion times
- Error rates and recovery

## Troubleshooting

### "Context overflow" errors

The `context-loader` skill activates automatically. If manual intervention needed:

1. Save current state: `bash scripts/preserve-context.sh save`
2. Restart session
3. Run `/conductor-status` to reload

### Agent not responding

The `error-recovery` skill handles this:
1. Tier 1: Retry with backoff
2. Tier 2: Rephrase prompt
3. Tier 3: Try different agent
4. Tier 4: Escalate to user

### TDD phase confusion

```bash
# Check current phase
bash scripts/tdd-enforcer.sh phase

# Set phase manually
bash scripts/tdd-enforcer.sh phase green
```

## Best Practices

### Do

- Start with `/conductor-status` each session
- Follow TDD strictly (tests first)
- Use checkpoints frequently
- Let agents handle their specialties

### Don't

- Skip the review pipeline
- Ignore hookify warnings
- Work without an active track
- Use opus agents for simple tasks (cost)

## Next Steps

1. Read [MULTI-AGENT-WORKFLOW.md](MULTI-AGENT-WORKFLOW.md) for full details
2. Explore [CONDUCTOR-COMMANDS.md](CONDUCTOR-COMMANDS.md) for command reference
3. Review [SKILLS.md](SKILLS.md) for skill details
4. Check [HOOKIFY-RULES.md](HOOKIFY-RULES.md) for rule configuration

## Getting Help

- Run `/help` in Claude Code
- Check `docs/` directory for detailed guides
- Run `bash scripts/validate-workflow.sh` to diagnose issues
