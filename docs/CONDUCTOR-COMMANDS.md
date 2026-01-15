# Conductor Commands

The conductor pattern provides a set of commands for orchestrating multi-phase implementations with proper tracking, checkpoints, and documentation synchronization.

## Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONDUCTOR WORKFLOW                            │
│                                                                   │
│  /conductor-setup      Initialize infrastructure                 │
│         ↓                                                        │
│  /conductor-new-track  Create implementation track               │
│         ↓                                                        │
│  /conductor-implement  Work on current phase                     │
│         ↓                                                        │
│  /conductor-checkpoint Mark phase complete                       │
│         ↓                                                        │
│  /conductor-sync-docs  Update documentation                      │
│         ↓                                                        │
│  /conductor-status     View progress                             │
└─────────────────────────────────────────────────────────────────┘
```

## Commands

### /conductor-setup

Initialize or verify conductor infrastructure in a repository.

**Usage:**
```
/conductor-setup           # Initialize conductor directories and templates
/conductor-setup verify    # Verify infrastructure is properly set up
/conductor-setup reset     # Reset to fresh templates (preserves data)
```

**Creates:**
```
conductor/
├── tracks.md         # Track registry
├── product.md        # Product definition
├── tech-stack.md     # Technology decisions
├── workflow.md       # Workflow conventions
└── tracks/           # Track directories
```

---

### /conductor-new-track

Create a new implementation track with specification and plan templates.

**Usage:**
```
/conductor-new-track FEAT-001 "User Authentication"       # Default P1
/conductor-new-track BUG-042 "Fix memory leak" P0         # Critical
/conductor-new-track INFRA-003 "K8s migration" P2         # Medium priority
```

**Track ID Prefixes:**
| Prefix | Type |
|--------|------|
| FEAT | New feature |
| BUG | Bug fix |
| INFRA | Infrastructure |
| REFAC | Refactoring |
| DOCS | Documentation |
| PERF | Performance |
| SEC | Security |
| MULTI | Multi-component |

**Creates:**
```
conductor/tracks/TRACK-ID/
├── spec.md    # Requirements and acceptance criteria
└── plan.md    # Implementation phases and tasks
```

---

### /conductor-implement

Work on implementing a track's current phase with guided workflow.

**Usage:**
```
/conductor-implement FEAT-001       # Work on current phase
/conductor-implement FEAT-001 3     # Work on specific phase
```

**Workflow:**
1. Loads context (spec.md, plan.md, tech-stack.md)
2. Lists phase tasks
3. Guides TDD implementation (RED → GREEN → REFACTOR)
4. Tracks progress via TodoWrite
5. Verifies quality gates
6. Prepares for checkpoint

---

### /conductor-status

Display status of all tracks or a specific track.

**Usage:**
```
/conductor-status                        # Summary of all tracks
/conductor-status FEAT-001               # Detailed status of specific track
/conductor-status --format=detailed      # Full breakdown
/conductor-status --format=json          # Machine-readable
```

**Output includes:**
- Track progress percentage
- Phase completion status
- Task breakdown
- Quality gate status
- Recent activity

---

### /conductor-checkpoint

Create a checkpoint commit marking phase completion.

**Usage:**
```
/conductor-checkpoint FEAT-001        # Checkpoint current phase
/conductor-checkpoint FEAT-001 3      # Checkpoint specific phase
```

**Actions:**
1. Verifies all phase tasks complete
2. Verifies quality gates passed
3. Updates plan.md with completion status
4. Creates checkpoint commit with hash
5. Updates plan.md with checkpoint reference

**Commit format:**
```
conductor(checkpoint): Complete Phase X - [Phase Name]

Track: TRACK-ID
Phase: X - [Phase Name]

Completed tasks:
- Task 1
- Task 2

Quality gates passed:
- [x] Tests pass
- [x] Lint clean
```

---

### /conductor-sync-docs

Synchronize documentation with implementation state.

**Usage:**
```
/conductor-sync-docs                     # Sync all documentation
/conductor-sync-docs track:MULTI-001     # Sync specific track
/conductor-sync-docs --check             # Dry run (report only)
/conductor-sync-docs --generate          # Create missing docs
```

**Syncs:**
- README files
- API documentation
- Architecture diagrams
- Track documentation
- Changelog entries

---

## Workflow Example

### 1. Initialize

```
/conductor-setup

✓ conductor/ directory created
✓ Template files created
✓ CLAUDE.md updated
```

### 2. Create Track

```
/conductor-new-track AUTH-001 "OAuth2 Integration" P0

✓ conductor/tracks/AUTH-001/ created
✓ spec.md template created
✓ plan.md template created
✓ tracks.md updated
```

### 3. Define Requirements

Edit `conductor/tracks/AUTH-001/spec.md`:
- Add requirements
- Define acceptance criteria
- Document constraints

Edit `conductor/tracks/AUTH-001/plan.md`:
- Define implementation phases
- Break down tasks
- Set quality gates

### 4. Implement

```
/conductor-implement AUTH-001

Loading track context...
Phase 1: Foundation
Tasks: 5 remaining

Working on: Set up OAuth2 client configuration
[TDD: RED phase - writing test first]
```

### 5. Checkpoint

```
/conductor-checkpoint AUTH-001

✓ All tasks complete (5/5)
✓ Quality gates passed
✓ Checkpoint created: abc1234

Phase 1 complete. Next: Phase 2 - Provider Integration
```

### 6. Continue

```
/conductor-implement AUTH-001

Phase 2: Provider Integration
Tasks: 4 remaining
...
```

### 7. Track Progress

```
/conductor-status AUTH-001

Track: AUTH-001 - OAuth2 Integration
Progress: 45% (9/20 tasks)

Phase Progress:
✓ Phase 1: Foundation [abc1234]
→ Phase 2: Provider Integration (in progress)
○ Phase 3: Session Management
○ Phase 4: Testing & Release
```

### 8. Sync Docs

```
/conductor-sync-docs track:AUTH-001

✓ spec.md updated with implementation notes
✓ plan.md progress synced
✓ README.md authentication section updated
✓ API docs regenerated
```

---

## Best Practices

### Track Organization

1. **One track per feature/initiative**
   - Keep tracks focused
   - Avoid scope creep

2. **3-7 phases per track**
   - Small enough to complete
   - Large enough to be meaningful

3. **5-15 tasks per phase**
   - Manageable chunks
   - Clear progress visibility

### Checkpoints

1. **Checkpoint after each phase**
   - Creates recovery point
   - Documents progress

2. **Include quality gates**
   - Tests must pass
   - Lint must be clean

3. **Reference in plan.md**
   - Easy to find later
   - Enables recovery

### Documentation

1. **Sync regularly**
   - After each checkpoint
   - Before major reviews

2. **Use --check first**
   - See what needs updating
   - Avoid surprises

3. **Generate missing docs**
   - Use --generate flag
   - Customize templates

---

## Related Documentation

- [Multi-Agent Workflow](MULTI-AGENT-WORKFLOW.md) - Agent orchestration
- [TDD Requirements](.claude/rules/tdd-requirements.md) - TDD guidelines
- [Quality Gates](.claude/rules/quality-gates.md) - Quality requirements
- [Conductor Restart Protocol](CONDUCTOR-RESTART-PROTOCOL.md) - Session recovery

---

## Command Files

All conductor commands are defined in:
```
.claude/commands/
├── conductor-setup.md
├── conductor-new-track.md
├── conductor-implement.md
├── conductor-status.md
├── conductor-checkpoint.md
└── conductor-sync-docs.md
```
