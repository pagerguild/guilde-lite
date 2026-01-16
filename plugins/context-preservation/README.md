# Context Preservation

Session state management and error recovery for long-running development workflows.

## Features

- **Tiered context loading**: Progressive context management across sessions
- **Subagent context preparation**: Structured context packages for agent delegation
- **Session handoff documents**: Preserve state between sessions
- **Cascading error recovery**: Multi-tier retry strategies with graceful degradation
- **Circuit breaker pattern**: Prevent cascading failures in multi-agent workflows

## Installation

```bash
claude plugin install context-preservation@guilde-plugins
```

## Usage

### Skills

#### `context-loader`

Auto-activates for:
- Starting a new session and need to load project context
- Context window approaching capacity (>70% usage)
- Switching between different parts of a codebase
- Preparing context for subagent delegation
- Recovering from session compaction
- Handoff between agents

**Tiered Loading Strategy:**
```
Tier 1: Project Metadata (~500 tokens)
  - CLAUDE.md, product.md, tech-stack.md

Tier 2: Active Work Context (~2k tokens)
  - Current track spec.md and plan.md
  - SESSION_HANDOFF.md (if resuming)

Tier 3: On-Demand References (as needed)
  - Specific source files, tests, documentation
```

#### `error-recovery`

Auto-activates for:
- Agent task fails and needs retry strategy
- Tool call returns error
- Build or test failures need diagnosis
- Rate limiting encountered
- Context window overflow
- Subagent produces invalid output

**Recovery Tiers:**
```
Tier 1: Immediate Retry (Transient Errors)
  - Exponential backoff with jitter
  - Max 3 attempts

Tier 2: Semantic Fallback (Output Issues)
  - Rephrase prompt
  - Add explicit constraints

Tier 3: Agent Substitution (Capability Issues)
  - Route to backup agent
  - Simplify task scope

Tier 4: Human Escalation (Unrecoverable)
  - Document failure state
  - Request user intervention
```

## Session Handoff Format

Create `SESSION_HANDOFF.md` for preserving state:

```markdown
# Session Handoff - [DATE]

## Current State
- **Track:** TRACK-ID - Title
- **Phase:** X - Phase Name
- **TDD Phase:** RED|GREEN|REFACTOR

## Files Modified
- `path/to/file.go` - Description

## Next Steps
1. Immediate next action
2. Following action
```

## Configuration

Token budget guidelines:
| Context Type | Budget | Priority |
|-------------|--------|----------|
| Project metadata | 10% | Always loaded |
| Active work | 20% | Phase-specific |
| Code under edit | 40% | Current task |
| Tool outputs | 20% | Strict limits |
| Conversation | 10% | Auto-compressed |
