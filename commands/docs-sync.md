---
description: Documentation synchronization - check, scan, and validate documentation
argument-hint: "[status|scan|validate|check|report|mappings|help]"
allowed-tools: ["Read", "Write", "Glob", "Grep", "Task"]
---

# /docs-sync Command

Documentation synchronization and validation.

## Overview

Ensures documentation stays in sync with code changes through:
- **Mapping-based tracking**: Code files → related documentation
- **Timestamp checking**: Detect potentially stale docs
- **Structure validation**: Verify required docs exist

## Actions

### `/docs-sync` or `/docs-sync status`

Show documentation sync status:

```bash
bash scripts/doc-sync-check.sh status
```

Displays:
- Total markdown files
- Active mappings count
- Uncommitted doc changes

### `/docs-sync scan`

Scan all modified files for documentation impact:

```bash
bash scripts/doc-sync-check.sh scan
```

Checks:
- All files modified in git
- Related documentation for each file
- Timestamp comparison (code vs docs)

### `/docs-sync validate`

Validate documentation structure:

```bash
bash scripts/doc-sync-check.sh validate
```

Verifies:
- CLAUDE.md exists
- conductor/tracks.md exists
- Active track has plan.md
- Required docs exist (MULTI-AGENT-WORKFLOW.md, workflow.md)
- Context freshness

### `/docs-sync check <file>`

Check if a specific file needs documentation updates:

```bash
bash scripts/doc-sync-check.sh check src/api/handler.go
```

### `/docs-sync report`

Generate full documentation report:

```bash
bash scripts/doc-sync-check.sh report
```

Includes:
- Documentation overview
- Key files status
- History of doc checks
- Recent documentation commits

### `/docs-sync mappings`

Show code-to-documentation mappings:

```bash
bash scripts/doc-sync-check.sh mappings
```

Displays all configured mappings that link code files to their related documentation.

### `/docs-sync help`

Show this help information.

## Code-to-Documentation Mappings

The doc-sync system uses mappings to know which docs are related to which code:

| Code Pattern | Related Documentation |
|--------------|----------------------|
| `conductor/*` | MULTI-AGENT-WORKFLOW.md, workflow.md |
| `scripts/*.sh` | README.md, CLAUDE.md |
| `.claude/settings.json` | MULTI-AGENT-WORKFLOW.md, CLAUDE.md |
| `.claude/agents/*` | MULTI-AGENT-WORKFLOW.md, AGENT-SELECTION.md |
| `.claude/skills/*` | MULTI-AGENT-WORKFLOW.md |
| `.claude/commands/*` | CLAUDE.md |
| `Taskfile.yml` | README.md, CLAUDE.md |
| `mise.toml` | README.md, tech-stack.md |

Custom mappings can be added at:
`~/.local/share/doc-sync/mappings.json`

## Workflow Integration

### Pre-Commit Check
Before committing, run:
```bash
/docs-sync scan
```

If documentation may need updates, review and update before committing.

### Post-Change Reminder
The PostToolUse hooks automatically remind you to check doc-sync when:
- Writing new files
- Editing existing code

### CI Integration
Add to CI pipeline:
```yaml
- name: Validate Documentation
  run: |
    bash scripts/doc-sync-check.sh validate
    bash scripts/doc-sync-check.sh scan
```

## Related Commands

- `task docs:validate` - Validate documentation
- `task docs:sync` - Run doc-sync check
- `/mermaid` - Generate Mermaid diagrams
- `/c4` - Generate C4 architecture diagrams
