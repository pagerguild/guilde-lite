---
name: conductor-implement
description: Work on implementing a track's current phase with guided workflow
arguments:
  - name: track_id
    description: "Track ID to work on (e.g., FEAT-001)"
    required: true
  - name: phase
    description: "Phase number to work on (default: current phase)"
    required: false
---

# /conductor-implement Command

Guides implementation of a track's current phase with task tracking, TDD enforcement, and checkpoint creation.

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONDUCTOR IMPLEMENT WORKFLOW                   │
│                                                                   │
│  1. Load Context                                                  │
│     ┌───────────┐ ┌───────────┐ ┌───────────┐                   │
│     │  spec.md  │ │  plan.md  │ │ tech-stack│                   │
│     └───────────┘ └───────────┘ └───────────┘                   │
│            ↓                                                      │
│  2. Phase Tasks                                                   │
│     ┌─────────────────────────────────────────────┐              │
│     │  [ ] Task 1 → [ ] Task 2 → [ ] Task 3       │              │
│     └─────────────────────────────────────────────┘              │
│            ↓                                                      │
│  3. TDD Loop (per task)                                          │
│     ┌──────────┐ ┌──────────┐ ┌──────────┐                      │
│     │   RED    │→│  GREEN   │→│ REFACTOR │                      │
│     └──────────┘ └──────────┘ └──────────┘                      │
│            ↓                                                      │
│  4. Quality Gates                                                 │
│     ┌───────────┐ ┌───────────┐ ┌───────────┐                   │
│     │   Tests   │ │   Lint    │ │  Review   │                   │
│     └───────────┘ └───────────┘ └───────────┘                   │
│            ↓                                                      │
│  5. Checkpoint                                                    │
│     ┌─────────────────────────────────────────────┐              │
│     │  git commit → update plan.md → next phase   │              │
│     └─────────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Usage

```
/conductor-implement FEAT-001        # Work on current phase
/conductor-implement FEAT-001 3      # Work on specific phase
```

## Actions

### Load Context

When invoked, automatically read and understand:

1. **Track specification:** `conductor/tracks/TRACK-ID/spec.md`
   - Requirements to implement
   - Acceptance criteria to meet
   - Constraints to respect

2. **Implementation plan:** `conductor/tracks/TRACK-ID/plan.md`
   - Current phase objectives
   - Tasks to complete
   - Quality gates to pass

3. **Technical context:** `conductor/tech-stack.md`
   - Technology decisions
   - Architecture patterns
   - Coding standards

### Phase Execution

For each task in the current phase:

1. **Announce task:**
   ```
   Working on: [Task description]
   Phase: X of Y
   Task: N of M
   ```

2. **TDD workflow:**
   - RED: Write failing test first
   - GREEN: Implement minimal code to pass
   - REFACTOR: Clean up without changing behavior

3. **Track progress:**
   - Use TodoWrite for visibility
   - Update plan.md as tasks complete
   - Report blockers immediately

### Quality Gates

Before completing a phase, verify:

1. **Tests pass:**
   ```bash
   task test
   ```

2. **Linting clean:**
   ```bash
   task lint
   ```

3. **Coverage adequate:**
   ```bash
   task test:coverage
   ```

4. **Review complete:**
   - Run `/review-all` for code review
   - Address CRITICAL and HIGH issues

### Checkpoint Creation

After phase completion:

1. **Stage changes:**
   ```bash
   git add -A
   ```

2. **Create checkpoint commit:**
   ```bash
   git commit -m "conductor(checkpoint): Complete Phase X - [Phase Name]

   Track: TRACK-ID
   Phase: X - [Phase Name]
   Tasks completed: N

   Changes:
   - [Summary of changes]

   Quality gates:
   - [x] Tests pass
   - [x] Lint clean
   - [x] Coverage adequate"
   ```

3. **Update plan.md:**
   - Add checkpoint hash to phase header
   - Mark tasks complete
   - Update progress summary

## Session Handoff

If session ends mid-phase, create handoff:

```markdown
# Session Handoff - TRACK-ID

## Current State
- Phase: X - [Name]
- Task: N of M - [Current task]
- TDD Phase: [RED/GREEN/REFACTOR]

## Progress
- [x] Completed tasks
- [ ] Remaining tasks

## Context
- Files modified: [list]
- Tests written: [list]
- Blockers: [any]

## Next Steps
1. [Next action]
2. [Following action]

## Resume Command
/conductor-implement TRACK-ID X
```

## Example Workflow

```
User: /conductor-implement MULTI-001

Claude: Loading track context...

        Track: MULTI-001 - Multi-Agent Workflow Architecture
        Current Phase: 9 - Conductor Commands

        ═══════════════════════════════════════════
        PHASE 9 OVERVIEW
        ═══════════════════════════════════════════

        Objectives:
        - Implement /conductor:* commands
        - Test command workflow
        - Document usage

        Tasks:
        [ ] Create conductor-setup.md
        [ ] Create conductor-new-track.md
        [ ] Create conductor-implement.md
        [ ] Create conductor-status.md
        [ ] Create conductor-checkpoint.md
        [ ] Create conductor-sync-docs.md
        [ ] Test full conductor workflow
        [ ] Document command usage

        Quality Gates:
        - All commands functional
        - Workflow completes end-to-end
        - Documentation complete

        ═══════════════════════════════════════════

        Starting implementation...

        [TodoWrite: Creating task list for Phase 9]

        Task 1 of 8: Create conductor-setup.md
        ────────────────────────────────────────────

        This command initializes the conductor infrastructure.
        Following TDD: Writing test/validation first...
```

## Parallel Agent Usage

For complex tasks, invoke specialized agents:

```
Task tool:
  subagent_type: feature-dev:code-architect
  prompt: Design the architecture for [feature]

Task tool:
  subagent_type: backend-development:backend-architect
  prompt: Implement the backend for [feature]

Task tool:
  subagent_type: tdd-workflows:tdd-orchestrator
  prompt: Guide TDD implementation of [feature]
```

## Progress Tracking

Throughout implementation:

1. **TodoWrite:** Track tasks visually
2. **plan.md:** Update completed tasks
3. **git:** Commit incrementally
4. **Telemetry:** Track metrics (if enabled)

## Related Commands

- `/conductor-setup` - Initialize conductor infrastructure
- `/conductor-new-track` - Create a new track
- `/conductor-status` - View all tracks and progress
- `/conductor-checkpoint` - Create checkpoint commits
- `/conductor-sync-docs` - Synchronize documentation
- `/tdd` - TDD workflow management
- `/review-all` - Run code review pipeline

## Related Files

- `conductor/tracks/TRACK-ID/spec.md` - Track specification
- `conductor/tracks/TRACK-ID/plan.md` - Implementation plan
- `conductor/tech-stack.md` - Technology decisions
- `.claude/rules/quality-gates.md` - Quality gate definitions
- `.claude/rules/tdd-requirements.md` - TDD requirements
