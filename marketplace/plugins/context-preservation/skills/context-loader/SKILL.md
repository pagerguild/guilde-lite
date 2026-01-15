---
name: context-loader
description: |
  Tiered context management for multi-agent workflows. Use when:
  - Starting a new session and need to load project context
  - Context window approaching capacity (>70% usage)
  - Switching between different parts of a codebase
  - Preparing context for subagent delegation
  - Recovering from session compaction
  - Handoff between agents needs structured context

  Do NOT use for:
  - Simple file reads (use Read tool directly)
  - Small projects that fit in context easily
  - Questions about specific files (just read them)
---

# Context Loader Skill

## Purpose

Implements tiered context management following modern multi-agent patterns (2024-2025). Ensures efficient context usage while maintaining project understanding across sessions and agent handoffs.

## Core Pattern: Progressive Context Loading

```
┌─────────────────────────────────────────────────────────────────┐
│                    TIERED CONTEXT LOADING                        │
│                                                                   │
│  Tier 1: Project Metadata (~500 tokens)                          │
│  ├── CLAUDE.md (project instructions)                            │
│  ├── conductor/product.md (vision, goals)                        │
│  └── conductor/tech-stack.md (technology decisions)              │
│                                                                   │
│  Tier 2: Active Work Context (~2k tokens)                        │
│  ├── Current track spec.md (requirements)                        │
│  ├── Current track plan.md (implementation state)                │
│  └── SESSION_HANDOFF.md (if resuming)                            │
│                                                                   │
│  Tier 3: On-Demand References (as needed)                        │
│  ├── Specific source files                                       │
│  ├── Test files                                                  │
│  └── Documentation                                               │
└─────────────────────────────────────────────────────────────────┘
```

## Context Budget Management

### Token Budget Guidelines

| Context Type | Budget | Priority |
|-------------|--------|----------|
| Project metadata | 10% | Always loaded |
| Active work | 20% | Phase-specific |
| Code under edit | 40% | Current task |
| Tool outputs | 20% | Strict limits |
| Conversation | 10% | Auto-compressed |

### Compression Strategies

When context exceeds 70% capacity, apply in order:

1. **Input Pruning:** Remove irrelevant context before processing
2. **Tool Output Limits:** Truncate long outputs, keep Head/Tail
3. **Observation Masking:** Hide older, less relevant observations
4. **LLM Summarization:** Compress when threshold reached

## Session Loading Protocol

### New Session Start

```markdown
1. Load Tier 1 (always):
   - Read CLAUDE.md
   - Read conductor/product.md
   - Read conductor/tech-stack.md

2. Load Tier 2 (if active track):
   - Identify current track from conductor/tracks.md
   - Read conductor/tracks/TRACK-ID/spec.md
   - Read conductor/tracks/TRACK-ID/plan.md
   - Find current phase and tasks

3. Check for handoff:
   - If SESSION_HANDOFF.md exists, read and apply
   - Resume from documented state
```

### Session Resume (from handoff)

```markdown
1. Read SESSION_HANDOFF.md
2. Parse current state:
   - Track and phase
   - Active task
   - TDD phase (RED/GREEN/REFACTOR)
   - Modified files list
3. Load relevant files from list
4. Continue from documented "Next Steps"
```

## Subagent Context Preparation

When delegating to subagents, prepare structured context:

### Context Package Format

```json
{
  "schemaVersion": "1.0",
  "trace_id": "<uuid>",
  "task": {
    "description": "Specific task for agent",
    "constraints": ["List of constraints"],
    "success_criteria": ["How to measure success"]
  },
  "context": {
    "project": "Brief project description",
    "tech_stack": ["Key technologies"],
    "conventions": ["Relevant coding standards"]
  },
  "files": {
    "required": ["paths to read"],
    "modified": ["paths being changed"],
    "tests": ["relevant test files"]
  },
  "state": {
    "tdd_phase": "RED|GREEN|REFACTOR",
    "previous_attempts": 0,
    "blockers": []
  }
}
```

### Agent-Specific Context

| Agent Type | Required Context |
|-----------|------------------|
| Researcher | Product.md, tech-stack.md, broad file list |
| Developer | Spec.md, plan.md, specific files to modify |
| Reviewer | Changed files, test files, coding standards |
| Security | All touched files, dependency info |

## Handoff Document Format

When creating SESSION_HANDOFF.md:

```markdown
# Session Handoff - [DATE]

## Current State
- **Track:** TRACK-ID - Title
- **Phase:** X - Phase Name
- **Task:** N of M - Task description
- **TDD Phase:** RED|GREEN|REFACTOR

## Progress
- [x] Completed items
- [ ] Remaining items

## Files Modified
- `path/to/file1.go` - Description of changes
- `path/to/file2_test.go` - Tests added

## Context Summary
[Brief summary of what was being worked on and why]

## Blockers
- [Any issues encountered]

## Next Steps
1. [Immediate next action]
2. [Following action]

## Resume Command
/conductor-implement TRACK-ID [phase]
```

## Quick Actions

### Load Full Project Context
```
1. Read CLAUDE.md
2. Read conductor/product.md
3. Read conductor/tech-stack.md
4. Read conductor/tracks.md
5. Identify active track
6. Read track spec.md and plan.md
```

### Prepare Subagent Context
```
1. Identify task scope
2. List required files
3. Extract relevant conventions
4. Create context package JSON
5. Set success criteria
```

### Create Session Handoff
```
1. Document current state
2. List all modified files
3. Summarize progress
4. Write next steps
5. Save to SESSION_HANDOFF.md
```

## Related Files

- `CLAUDE.md` - Project instructions
- `conductor/product.md` - Product definition
- `conductor/tech-stack.md` - Technology stack
- `conductor/tracks.md` - Track registry
- `SESSION_HANDOFF.md` - Session state (when exists)
- `docs/CONDUCTOR-RESTART-PROTOCOL.md` - Full restart protocol

## Reference Files

For detailed information, see:
- `reference/context-strategies.md` - Advanced compression strategies
- `reference/subagent-patterns.md` - Agent delegation patterns
- `reference/handoff-examples.md` - Example handoff documents
