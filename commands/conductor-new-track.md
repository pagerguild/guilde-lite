---
description: Create a new implementation track with spec and plan files
argument-hint: "TRACK-ID \"Track Title\" [P0|P1|P2|P3]"
allowed-tools: ["Read", "Write", "Bash", "AskUserQuestion", "TodoWrite"]
---

# /conductor-new-track Command

Creates a new implementation track with specification and plan templates.

## Track Structure

```
conductor/tracks/TRACK-ID/
├── spec.md    # What to build (requirements, acceptance criteria)
└── plan.md    # How to build it (phases, tasks, checkpoints)
```

## Usage

```
/conductor-new-track FEAT-001 "User Authentication System"
/conductor-new-track BUG-042 "Fix memory leak in cache" P0
/conductor-new-track INFRA-003 "Kubernetes migration" P2
```

## Actions

### Create Track

When invoked, this command will:

1. **Validate Track ID:**
   - Format: PREFIX-NNN (e.g., FEAT-001, BUG-042, INFRA-001)
   - Check for duplicates in tracks.md

2. **Create Directory:**
   ```bash
   mkdir -p conductor/tracks/TRACK-ID
   ```

3. **Create spec.md:**
   - Track metadata (ID, title, priority, type)
   - Requirements section
   - Acceptance criteria template
   - Dependencies and constraints

4. **Create plan.md:**
   - Implementation phases
   - Task breakdown template
   - Quality gates
   - Progress tracking

5. **Update tracks.md:**
   - Add entry to Active Tracks table
   - Add track detail section

## spec.md Template

```markdown
# TRACK-ID: [Title]

**Status:** Not Started
**Priority:** [P0/P1/P2/P3]
**Type:** [Feature/Bug/Infrastructure/Refactor]
**Created:** [Date]

---

## Overview

*High-level description of what this track delivers*

## Objectives

1. **Primary:** [Main goal]
2. **Secondary:** [Supporting goals]

## Requirements

### Functional Requirements

- [ ] FR-1: [Description]
- [ ] FR-2: [Description]

### Non-Functional Requirements

- [ ] NFR-1: Performance - [Criteria]
- [ ] NFR-2: Security - [Criteria]
- [ ] NFR-3: Scalability - [Criteria]

## Acceptance Criteria

Given [context]
When [action]
Then [expected outcome]

## Dependencies

| Dependency | Type | Status |
|------------|------|--------|
| - | - | - |

## Constraints

- Technical: [Constraints]
- Timeline: [Constraints]
- Resource: [Constraints]

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| - | - | - |

## Out of Scope

- [Items explicitly not included]
```

## plan.md Template

```markdown
# TRACK-ID: Implementation Plan

**Track:** [Title]
**Status:** Not Started
**Current Phase:** Phase 1

---

## Phase 1: [Name] [checkpoint: pending]

### Objectives
- [Objective 1]
- [Objective 2]

### Tasks

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

### Quality Gates
- [ ] Gate 1
- [ ] Gate 2
- [ ] Git committed with checkpoint

---

## Phase 2: [Name] [checkpoint: pending]

### Objectives
- [Objective 1]

### Tasks

- [ ] Task 1
- [ ] Task 2

### Quality Gates
- [ ] Gate 1
- [ ] Git committed with checkpoint

---

## Progress Summary

| Phase | Status | Tasks Done | Tasks Total |
|-------|--------|------------|-------------|
| 1. [Name] | [ ] Pending | 0 | 3 |
| 2. [Name] | [ ] Pending | 0 | 2 |

**Overall Progress:** 0 / 5 tasks (0%)
```

## tracks.md Update

Add to Active Tracks table:

```markdown
| TRACK-ID | [Title] | [ ] Not Started | P[X] | Phase 1 |
```

Add Track Details section:

```markdown
### [ ] TRACK-ID: [Title]

**Priority:** P[X]
**Type:** [Type]
**Created:** [Date]
**Estimated Effort:** TBD

**Summary:** [Brief description]

**Spec:** [conductor/tracks/TRACK-ID/spec.md](tracks/TRACK-ID/spec.md)
**Plan:** [conductor/tracks/TRACK-ID/plan.md](tracks/TRACK-ID/plan.md)
```

## Example Workflow

```
User: /conductor-new-track AUTH-001 "OAuth2 Integration" P0

Claude: Creating new track AUTH-001...

        Validating:
        ✓ Track ID format valid (AUTH-001)
        ✓ Track ID not duplicate

        Creating files:
        ✓ conductor/tracks/AUTH-001/
        ✓ conductor/tracks/AUTH-001/spec.md
        ✓ conductor/tracks/AUTH-001/plan.md

        Updating registry:
        ✓ conductor/tracks.md updated

        ═══════════════════════════════════════════
        TRACK AUTH-001 CREATED
        ═══════════════════════════════════════════

        Title: OAuth2 Integration
        Priority: P0 (Critical Path)
        Type: Feature (inferred from AUTH prefix)

        Files created:
        - conductor/tracks/AUTH-001/spec.md
        - conductor/tracks/AUTH-001/plan.md

        Next steps:
        1. Edit spec.md with detailed requirements
        2. Edit plan.md to define implementation phases
        3. Run /conductor-implement AUTH-001 to begin work

        Quick edit:
        - Read spec.md to add requirements
        - Read plan.md to define phases
```

## Track ID Conventions

| Prefix | Type | Example |
|--------|------|---------|
| FEAT | New feature | FEAT-001 |
| BUG | Bug fix | BUG-042 |
| INFRA | Infrastructure | INFRA-003 |
| REFAC | Refactoring | REFAC-007 |
| DOCS | Documentation | DOCS-015 |
| PERF | Performance | PERF-002 |
| SEC | Security | SEC-001 |
| MULTI | Multi-component | MULTI-001 |

## Priority Levels

| Priority | Meaning | SLA |
|----------|---------|-----|
| P0 | Critical Path | Immediate |
| P1 | High Priority | This sprint |
| P2 | Medium Priority | This quarter |
| P3 | Low Priority | Backlog |

## Related Commands

- `/conductor-setup` - Initialize conductor infrastructure
- `/conductor-status` - View all tracks and progress
- `/conductor-implement` - Work on track implementation
- `/conductor-checkpoint` - Create checkpoint commits

## Related Files

- `conductor/tracks.md` - Track registry
- `conductor/tracks/TRACK-ID/spec.md` - Track specification
- `conductor/tracks/TRACK-ID/plan.md` - Implementation plan
