# Docs Sync

Documentation synchronization to keep docs aligned with code changes.

## Features

- **Mapping-based tracking**: Automatic code-to-documentation relationship tracking
- **Timestamp checking**: Detect potentially stale documentation
- **Structure validation**: Verify required documentation exists
- **Pre-commit integration**: Check documentation before committing
- **CI/CD compatible**: Integrate documentation validation into pipelines

## Installation

```bash
claude plugin install docs-sync@guilde-plugins
```

## Usage

### Commands

#### `/docs-sync`

Documentation synchronization and validation:

```bash
/docs-sync              # Show sync status (default)
/docs-sync status       # Show documentation sync status
/docs-sync scan         # Scan modified files for doc impact
/docs-sync validate     # Validate documentation structure
/docs-sync check <file> # Check if file needs doc updates
/docs-sync report       # Generate full documentation report
/docs-sync mappings     # Show code-to-doc mappings
/docs-sync help         # Show help information
```

## Code-to-Documentation Mappings

The doc-sync system tracks which documentation is related to which code:

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

## Validation Checks

The `validate` action verifies:
- CLAUDE.md exists
- conductor/tracks.md exists
- Active track has plan.md
- Required docs exist (MULTI-AGENT-WORKFLOW.md, workflow.md)
- Context freshness

## Workflow Integration

### Pre-Commit Check

```bash
/docs-sync scan
```

Review and update documentation if flagged.

### CI Integration

```yaml
- name: Validate Documentation
  run: |
    bash scripts/doc-sync-check.sh validate
    bash scripts/doc-sync-check.sh scan
```

## Configuration

Custom mappings can be added at:
`~/.local/share/doc-sync/mappings.json`
