# Conductor Restart Protocol

Guide for resuming work after a session ends or context is compacted.

---

## Quick Resume

When starting a new session after context loss:

```bash
# 1. Check current status
bash scripts/preserve-context.sh --status

# 2. Review handoff notes
cat .claude/SESSION_HANDOFF.md

# 3. Check current track
cat conductor/tracks.md

# 4. Resume from plan
cat conductor/tracks/MULTI-001/plan.md | grep -A20 "Current Phase"
```

---

## Session Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                     SESSION LIFECYCLE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  SessionStart                                               │
│       │                                                     │
│       ├── claude-health-check.sh (validate tools)           │
│       ├── session-startup.sh (show tracks)                  │
│       └── preserve-context.sh --status (show state)         │
│       │                                                     │
│       ▼                                                     │
│  Active Work                                                │
│       │                                                     │
│       ├── UserPromptSubmit hooks (enforce workflow)         │
│       └── Regular context saves                             │
│       │                                                     │
│       ▼                                                     │
│  PreCompact (context filling up)                            │
│       │                                                     │
│       ├── preserve-context.sh --save (auto-save)            │
│       └── Prompt to update SESSION_HANDOFF.md               │
│       │                                                     │
│       ▼                                                     │
│  Session End / Compaction                                   │
│       │                                                     │
│       └── Context preserved for next session                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Recovery Scenarios

### Scenario 1: Normal Resume

Session ended normally, context was preserved.

```bash
# Context status shows recent snapshot
bash scripts/preserve-context.sh --status

# If handoff file is current, just continue
# Session notes tell you where you left off
```

### Scenario 2: Unexpected Termination

Session crashed or was interrupted.

```bash
# Check if any context was saved
bash scripts/preserve-context.sh --list

# Restore most recent
bash scripts/preserve-context.sh --restore

# Check git status for work in progress
git status
git stash list

# Review recent commits
git log --oneline -10
```

### Scenario 3: Complete Context Loss

No saved context, starting fresh.

```bash
# Review project structure
task status    # or: cat Taskfile.yml | head -30

# Check current track
cat conductor/tracks.md

# Get current phase from plan
grep -A30 "Current Phase" conductor/tracks/MULTI-001/plan.md

# Check recent git history
git log --oneline -20

# Look for modified files
git status
```

---

## Context Files

| File | Purpose |
|------|---------|
| `.claude/SESSION_HANDOFF.md` | Human-readable session notes |
| `.claude/context/snapshot_*.json` | Machine-readable state dumps |
| `conductor/tracks.md` | Project tracking |
| `conductor/tracks/*/plan.md` | Detailed implementation plan |

---

## Best Practices

### Before Ending Session

1. **Update SESSION_HANDOFF.md** with current work
2. **Commit work in progress** (or stash)
3. **Note any blockers** in handoff
4. **Run context save** if PreCompact hasn't triggered

### When Resuming

1. **Read handoff file first**
2. **Check git status** for uncommitted work
3. **Review current phase** in plan
4. **Verify tools** are working (health check)

### During Long Sessions

1. **Commit frequently** with descriptive messages
2. **Update plan.md** as tasks complete
3. **Save context manually** periodically:
   ```bash
   bash scripts/preserve-context.sh --save
   ```

---

## Troubleshooting

### "No saved context found"

```bash
# Create initial context
mkdir -p .claude/context
bash scripts/preserve-context.sh --save
```

### "Handoff file out of date"

```bash
# Check last update
grep "Last Updated" .claude/SESSION_HANDOFF.md

# Update manually or regenerate
cat > .claude/SESSION_HANDOFF.md << 'EOF'
# Session Handoff
**Last Updated:** $(date)
## Active Work
<!-- Update this section -->
EOF
```

### "Can't determine current phase"

```bash
# Check plan directly
cat conductor/tracks/MULTI-001/plan.md | grep -B5 -A30 "pending"

# Or look at progress summary
tail -20 conductor/tracks/MULTI-001/plan.md
```

---

## Automation

The following is automated via hooks:

| Event | Action |
|-------|--------|
| SessionStart | Show status, validate tools |
| PreCompact | Save context, prompt for handoff |
| UserPromptSubmit | Enforce multi-agent workflow |

Manual commands:
```bash
bash scripts/preserve-context.sh --save    # Force save
bash scripts/preserve-context.sh --restore # View last context
bash scripts/preserve-context.sh --status  # Current state
bash scripts/preserve-context.sh --clean   # Remove old snapshots
```
