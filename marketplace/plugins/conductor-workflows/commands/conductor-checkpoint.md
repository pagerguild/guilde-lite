---
description: Create a checkpoint commit marking phase completion with plan updates
argument-hint: "TRACK-ID [phase-number]"
allowed-tools: ["Read", "Edit", "Bash(git:*)"]
---

# /conductor-checkpoint Command

Creates a checkpoint commit marking the completion of a track phase, updating the plan with the commit hash.

## Checkpoint Purpose

Checkpoints serve as:
1. **Recovery points:** Can restore to any completed phase
2. **Progress markers:** Track implementation history
3. **Context anchors:** Reference point for session handoffs
4. **Audit trail:** Document what was completed when

## Usage

```
/conductor-checkpoint MULTI-001        # Checkpoint current phase
/conductor-checkpoint MULTI-001 9      # Checkpoint specific phase
```

## Checkpoint Process

```
┌─────────────────────────────────────────────────────────────────┐
│                    CHECKPOINT PROCESS                            │
│                                                                   │
│  1. Verify Ready                                                  │
│     ┌───────────┐ ┌───────────┐ ┌───────────┐                   │
│     │  Tasks    │ │  Quality  │ │   Tests   │                   │
│     │ Complete  │ │   Gates   │ │   Pass    │                   │
│     └───────────┘ └───────────┘ └───────────┘                   │
│            ↓                                                      │
│  2. Update Plan                                                   │
│     ┌─────────────────────────────────────────────┐              │
│     │  Mark tasks [x] complete                     │              │
│     │  Update progress summary                     │              │
│     │  Set current phase to next                  │              │
│     └─────────────────────────────────────────────┘              │
│            ↓                                                      │
│  3. Create Commit                                                 │
│     ┌─────────────────────────────────────────────┐              │
│     │  git add -A                                  │              │
│     │  git commit -m "conductor(checkpoint):..."   │              │
│     └─────────────────────────────────────────────┘              │
│            ↓                                                      │
│  4. Record Checkpoint                                             │
│     ┌─────────────────────────────────────────────┐              │
│     │  Update plan.md with commit hash            │              │
│     │  Update tracks.md status                    │              │
│     └─────────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Actions

### 1. Verify Readiness

Before creating checkpoint, verify:

1. **Tasks complete:**
   - All tasks in phase marked `[x]`
   - No pending items

2. **Quality gates pass:**
   - All quality gates in phase marked `[x]`
   - Tests passing
   - Lint clean

3. **Changes staged:**
   - All relevant changes in staging area
   - No unintended files

### 2. Update Plan

Edit `conductor/tracks/TRACK-ID/plan.md`:

1. **Mark tasks complete:**
   ```markdown
   - [x] Task 1
   - [x] Task 2
   - [x] Task 3
   ```

2. **Mark quality gates:**
   ```markdown
   ### Quality Gates
   - [x] Gate 1
   - [x] Gate 2
   - [x] Git committed with checkpoint
   ```

3. **Update progress summary:**
   ```markdown
   | 9. Conductor Commands | [x] Complete | 8 | 8 |
   ```

4. **Update current phase header:**
   ```markdown
   **Current Phase:** Phase 10 - Skill Packaging
   ```

### 3. Create Commit

Stage all changes and create checkpoint commit:

```bash
git add -A
git commit -m "$(cat <<'EOF'
conductor(checkpoint): Complete Phase X - [Phase Name]

Track: TRACK-ID
Phase: X - [Phase Name]

Completed tasks:
- Task 1
- Task 2
- Task 3

Quality gates passed:
- [x] Gate 1
- [x] Gate 2

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

### 4. Record Checkpoint

Get commit hash and update plan:

1. **Get hash:**
   ```bash
   git rev-parse --short HEAD
   ```

2. **Update phase header in plan.md:**
   ```markdown
   ## Phase X: [Name] [checkpoint: abc1234]
   ```

3. **Update tracks.md if needed:**
   - Update phase column
   - Update status if track complete

## Commit Message Format

```
conductor(checkpoint): Complete Phase X - [Phase Name]

Track: TRACK-ID
Phase: X - [Phase Name]

Completed tasks:
- [List of completed tasks]

Quality gates passed:
- [x] [Gate descriptions]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Example Workflow

```
User: /conductor-checkpoint MULTI-001 9

Claude: Creating checkpoint for MULTI-001 Phase 9...

        Verifying readiness:
        ✓ All tasks complete (8/8)
        ✓ Quality gates passed
        ✓ Tests passing
        ✓ Lint clean

        Updating plan.md:
        ✓ Tasks marked complete
        ✓ Quality gates marked complete
        ✓ Progress summary updated
        ✓ Current phase advanced to 10

        Creating checkpoint commit:
        ✓ Changes staged
        ✓ Commit created

        Recording checkpoint:
        ✓ Commit hash: def4567
        ✓ Plan.md updated with checkpoint

        ═══════════════════════════════════════════════════════════════════
        CHECKPOINT CREATED
        ═══════════════════════════════════════════════════════════════════

        Track:      MULTI-001
        Phase:      9 - Conductor Commands
        Checkpoint: def4567

        Progress:   94/113 tasks (83%)
        Next Phase: 10 - Skill Packaging

        ═══════════════════════════════════════════════════════════════════

        Next steps:
        - Run /conductor-implement MULTI-001 to start Phase 10
        - Run /conductor-status MULTI-001 to view progress
```

## Incomplete Phase Handling

If phase is not ready for checkpoint:

```
User: /conductor-checkpoint MULTI-001 9

Claude: Cannot create checkpoint - phase not complete.

        Incomplete tasks:
        [ ] Task 5: Create conductor-checkpoint.md
        [ ] Task 6: Create conductor-sync-docs.md

        Failing quality gates:
        [ ] All commands functional

        To complete this phase:
        1. Run /conductor-implement MULTI-001 9 to continue
        2. Complete remaining tasks
        3. Run /conductor-checkpoint again
```

## Recovery from Checkpoint

To restore to a checkpoint:

```bash
# View checkpoint history
git log --oneline --grep="conductor(checkpoint)"

# Restore to specific checkpoint
git checkout <checkpoint-hash>

# Create branch from checkpoint
git checkout -b recovery-phase-9 <checkpoint-hash>
```

## Related Commands

- `/conductor-setup` - Initialize conductor infrastructure
- `/conductor-new-track` - Create a new track
- `/conductor-implement` - Work on track implementation
- `/conductor-status` - View all tracks and progress
- `/conductor-sync-docs` - Synchronize documentation
- `/commit` - Standard git commit (non-checkpoint)

## Related Files

- `conductor/tracks/TRACK-ID/plan.md` - Implementation plan
- `conductor/tracks.md` - Track registry
- `.claude/rules/quality-gates.md` - Quality gate definitions
