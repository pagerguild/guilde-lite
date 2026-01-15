---
name: conductor-status
description: Display status of all tracks or a specific track with progress details
arguments:
  - name: track_id
    description: "Specific track ID to show (optional, shows all if omitted)"
    required: false
  - name: format
    description: "Output format: summary, detailed, json"
    required: false
    default: summary
---

# /conductor-status Command

Displays status of implementation tracks with progress metrics and phase details.

## Usage

```
/conductor-status                    # Summary of all tracks
/conductor-status FEAT-001           # Detailed status of specific track
/conductor-status --format=detailed  # Detailed view of all tracks
```

## Output Formats

### Summary Format (default)

```
═══════════════════════════════════════════════════════════════════
CONDUCTOR STATUS
═══════════════════════════════════════════════════════════════════

Active Tracks (1)
─────────────────────────────────────────────────────────────────

[~] MULTI-001: Multi-Agent Workflow Architecture
    Priority: P0 | Phase: 9 of 12 | Progress: 76%
    ████████████████████░░░░░ 86/113 tasks

Backlog Tracks (0)
─────────────────────────────────────────────────────────────────

No tracks in backlog

Completed Tracks (0)
─────────────────────────────────────────────────────────────────

No completed tracks

═══════════════════════════════════════════════════════════════════
Overall Progress: 76% | Active: 1 | Backlog: 0 | Completed: 0
═══════════════════════════════════════════════════════════════════
```

### Detailed Format

```
═══════════════════════════════════════════════════════════════════
TRACK: MULTI-001
═══════════════════════════════════════════════════════════════════

Title:    Multi-Agent Workflow Architecture
Status:   In Progress
Priority: P0 (Critical Path)
Created:  2026-01-14

Progress: 76% (86/113 tasks)
──────────────────────────────────────
████████████████████░░░░░

Phase Progress
──────────────────────────────────────
✓ Phase 1: Foundation [710fa35]        11/11 ████████████
✓ Phase 1.5: VCS Integration [453b1c6] 14/14 ████████████
✓ Phase 2: Agent Definitions [5389392] 15/15 ████████████
✓ Phase 3: Context Engineering [ed3c282] 7/7 ████████████
✓ Phase 4: TDD Integration [a56eeda]    9/9 ████████████
✓ Phase 5: Documentation [2d481b9]      7/7 ████████████
✓ Phase 6: Telemetry Setup [19d98ff]    7/7 ████████████
✓ Phase 7: Quality Assurance [48ffdcc]  6/6 ████████████
✓ Phase 8: Hookify Rules [b616234]    10/10 ████████████
→ Phase 9: Conductor Commands           0/8 ░░░░░░░░░░░░
○ Phase 10: Skill Packaging             0/6 ░░░░░░░░░░░░
○ Phase 11: Testing & Validation        0/7 ░░░░░░░░░░░░
○ Phase 12: Documentation & Release     0/6 ░░░░░░░░░░░░

Current Phase: 9 - Conductor Commands
──────────────────────────────────────
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
[ ] All commands functional
[ ] Workflow completes end-to-end
[ ] Documentation complete

Recent Activity
──────────────────────────────────────
2026-01-15 Phase 8 completed (b616234)
2026-01-14 Phase 7 completed (48ffdcc)
2026-01-14 Phase 6 completed (19d98ff)

Files
──────────────────────────────────────
Spec: conductor/tracks/MULTI-001/spec.md
Plan: conductor/tracks/MULTI-001/plan.md

═══════════════════════════════════════════════════════════════════
```

### JSON Format

```json
{
  "track_id": "MULTI-001",
  "title": "Multi-Agent Workflow Architecture",
  "status": "in_progress",
  "priority": "P0",
  "created": "2026-01-14",
  "progress": {
    "percentage": 76,
    "completed_tasks": 86,
    "total_tasks": 113
  },
  "current_phase": {
    "number": 9,
    "name": "Conductor Commands",
    "tasks": [
      {"name": "Create conductor-setup.md", "status": "pending"},
      {"name": "Create conductor-new-track.md", "status": "pending"}
    ]
  },
  "phases": [
    {"number": 1, "name": "Foundation", "checkpoint": "710fa35", "status": "complete"},
    {"number": 9, "name": "Conductor Commands", "checkpoint": null, "status": "in_progress"}
  ]
}
```

## Actions

### Read Track Data

1. **Read tracks.md:**
   - Parse Active Tracks table
   - Parse Backlog and Completed sections
   - Extract track metadata

2. **For each track, read plan.md:**
   - Parse phase sections
   - Count completed/total tasks
   - Extract checkpoint hashes
   - Identify current phase

3. **Calculate metrics:**
   - Overall progress percentage
   - Phase completion status
   - Velocity (if historical data available)

### Display Status

Format output based on requested format:
- `summary`: Compact overview of all tracks
- `detailed`: Full breakdown with phase tasks
- `json`: Machine-readable format

## Status Icons

| Icon | Meaning |
|------|---------|
| `✓` | Phase completed |
| `→` | Current phase (in progress) |
| `○` | Future phase (pending) |
| `!` | Blocked |
| `█` | Progress filled |
| `░` | Progress empty |

## Track Status Markers

| Marker | Meaning |
|--------|---------|
| `[ ]` | Not Started |
| `[~]` | In Progress |
| `[x]` | Completed |
| `[!]` | Blocked |
| `[-]` | Cancelled |

## Example Workflow

```
User: /conductor-status MULTI-001

Claude: Reading track data...

        ═══════════════════════════════════════════════════════════════════
        TRACK: MULTI-001
        ═══════════════════════════════════════════════════════════════════

        Title:    Multi-Agent Workflow Architecture
        Status:   In Progress
        Priority: P0 (Critical Path)

        Progress: 76% (86/113 tasks)
        ████████████████████░░░░░

        Current Phase: 9 - Conductor Commands
        ──────────────────────────────────────
        [ ] Create conductor-setup.md
        [ ] Create conductor-new-track.md
        ...

        Next action:
        Run /conductor-implement MULTI-001 to continue implementation
```

## Progress Visualization

Progress bars use block characters:

```
100%: ████████████████████████
 75%: ██████████████████░░░░░░
 50%: ████████████░░░░░░░░░░░░
 25%: ██████░░░░░░░░░░░░░░░░░░
  0%: ░░░░░░░░░░░░░░░░░░░░░░░░
```

## Related Commands

- `/conductor-setup` - Initialize conductor infrastructure
- `/conductor-new-track` - Create a new track
- `/conductor-implement` - Work on track implementation
- `/conductor-checkpoint` - Create checkpoint commits
- `/conductor-sync-docs` - Synchronize documentation

## Related Files

- `conductor/tracks.md` - Track registry
- `conductor/tracks/TRACK-ID/plan.md` - Track plans
- `conductor/tracks/TRACK-ID/spec.md` - Track specifications
