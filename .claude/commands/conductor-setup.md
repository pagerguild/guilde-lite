---
name: conductor-setup
description: Initialize conductor infrastructure in a repository - creates directories, templates, and configuration
arguments:
  - name: action
    description: "Action to perform: init, verify, reset"
    required: false
    default: init
---

# /conductor-setup Command

Sets up the conductor pattern infrastructure for orchestrating multi-phase implementations.

## Directory Structure Created

```
conductor/
├── tracks.md            # Master track registry
├── product.md           # Product definition (goals, users, features)
├── tech-stack.md        # Technology decisions and rationale
├── workflow.md          # Workflow template and conventions
└── tracks/              # Individual track directories
    └── TRACK-XXX/
        ├── spec.md      # Track specification
        └── plan.md      # Implementation plan
```

## Actions

### `/conductor-setup` or `/conductor-setup init`

Initialize conductor infrastructure:

1. **Check prerequisites:**
   - Git repository initialized
   - CLAUDE.md exists (or create minimal one)

2. **Create directories:**
   ```bash
   mkdir -p conductor/tracks
   ```

3. **Create template files:**
   - `conductor/tracks.md` - Track registry template
   - `conductor/product.md` - Product definition template
   - `conductor/tech-stack.md` - Tech stack template
   - `conductor/workflow.md` - Workflow conventions

4. **Update CLAUDE.md:**
   - Add conductor section if not present
   - Reference conductor files for context

### `/conductor-setup verify`

Verify conductor infrastructure:

1. Check all required directories exist
2. Validate file format (YAML frontmatter where required)
3. Check for orphaned tracks
4. Report status

### `/conductor-setup reset`

Reset conductor infrastructure (use with caution):

1. Backup existing conductor/ directory
2. Re-create from templates
3. Preserve track data in backup

## Template Contents

### tracks.md Template

```markdown
# Project Tracks

**Last Updated:** [DATE]

## Active Tracks

| Track ID | Title | Status | Priority | Phase |
|----------|-------|--------|----------|-------|
| - | - | - | - | - |

## Track Details

*No active tracks*

---

## Backlog Tracks

| Track ID | Title | Type | Priority |
|----------|-------|------|----------|
| - | - | - | - |

---

## Completed Tracks

| Track ID | Title | Completed | Checkpoint |
|----------|-------|-----------|------------|
| - | - | - | - |

---

## Track Status Legend

| Marker | Meaning |
|--------|---------|
| `[ ]` | Not Started |
| `[~]` | In Progress |
| `[x]` | Completed |
| `[!]` | Blocked |
| `[-]` | Cancelled |
```

### product.md Template

```markdown
# Product Definition

## Vision

*What is the long-term vision for this product?*

## Goals

1. **Primary Goal:** [Description]
2. **Secondary Goal:** [Description]

## Target Users

| User Type | Description | Primary Needs |
|-----------|-------------|---------------|
| Developer | Primary user | Productivity, reliability |

## Key Features

| Feature | Status | Priority |
|---------|--------|----------|
| Feature 1 | Planned | P0 |

## Success Metrics

- [Metric 1]: [Target]
- [Metric 2]: [Target]
```

### tech-stack.md Template

```markdown
# Technology Stack

## Languages

| Language | Version | Purpose |
|----------|---------|---------|
| Go | 1.24+ | Backend services |

## Frameworks

| Framework | Version | Purpose |
|-----------|---------|---------|
| - | - | - |

## Tools

| Tool | Version | Purpose |
|------|---------|---------|
| mise | latest | Runtime management |
| Task | 3.0+ | Build automation |

## Architecture Decisions

### ADR-001: [Title]

**Status:** Accepted
**Context:** [Why this decision was needed]
**Decision:** [What was decided]
**Consequences:** [What happens as a result]
```

## Verification Checks

When running `/conductor-setup verify`:

1. **Structure Check:**
   - conductor/ directory exists
   - tracks.md exists and valid
   - product.md exists
   - tech-stack.md exists

2. **Track Integrity:**
   - All tracks in tracks.md have corresponding directories
   - All track directories have spec.md and plan.md
   - No orphaned track directories

3. **Format Validation:**
   - Markdown files parse correctly
   - Required sections present
   - Links valid

## Example Workflow

```
User: /conductor-setup

Claude: Initializing conductor infrastructure...

        Checking prerequisites:
        ✓ Git repository found
        ✓ CLAUDE.md exists

        Creating directories:
        ✓ conductor/
        ✓ conductor/tracks/

        Creating template files:
        ✓ conductor/tracks.md
        ✓ conductor/product.md
        ✓ conductor/tech-stack.md
        ✓ conductor/workflow.md

        Updating CLAUDE.md:
        ✓ Added conductor section

        ═══════════════════════════════════════════
        CONDUCTOR SETUP COMPLETE
        ═══════════════════════════════════════════

        Next steps:
        1. Edit conductor/product.md with your product vision
        2. Edit conductor/tech-stack.md with your technology choices
        3. Run /conductor-new-track to create your first track

        Commands available:
        - /conductor-new-track - Create a new implementation track
        - /conductor-status - View all tracks and progress
        - /conductor-setup verify - Verify infrastructure
```

## Related Commands

- `/conductor-new-track` - Create a new track
- `/conductor-status` - View track status
- `/conductor-implement` - Work on track implementation
- `/conductor-checkpoint` - Create checkpoint commits

## Related Files

- `conductor/tracks.md` - Track registry
- `conductor/product.md` - Product definition
- `conductor/tech-stack.md` - Technology stack
- `CLAUDE.md` - Project instructions
