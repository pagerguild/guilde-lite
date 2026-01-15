---
description: Jujutsu version control operations - status, log, diff, commit, rebase
argument-hint: "[status|log|diff|commit|rebase|bookmark|git|help]"
allowed-tools: ["Bash", "Read", "Glob"]
---

# /jj Command

Jujutsu (jj) version control operations via jj-mcp-server.

## Quick Reference

| Subcommand | Description |
|------------|-------------|
| `status` | Show working copy status |
| `log` | Show commit history |
| `diff` | Show changes |
| `commit` | Create a new commit |
| `rebase` | Rebase commits |
| `bookmark` | Manage bookmarks (branches) |
| `git` | Git interoperability |
| `help` | Show this help |

## Actions

### `/jj` or `/jj status`

Show working copy status:

```bash
jj status
```

Shows:
- Working copy changes
- Parent commit(s)
- Conflict status

### `/jj log`

Show commit history:

```bash
# Default log (recent commits)
jj log

# Show specific revisions
jj log -r 'heads(all())'

# Show with diff
jj log -p
```

### `/jj diff`

Show changes in working copy:

```bash
# All changes
jj diff

# Specific file
jj diff <file>

# Between revisions
jj diff --from @- --to @
```

### `/jj commit`

Create a new commit:

```bash
# Describe current working copy and create new
jj describe -m "commit message"
jj new

# Or in one step
jj commit -m "commit message"
```

### `/jj rebase`

Rebase commits:

```bash
# Rebase current onto main
jj rebase -d main

# Rebase specific revision
jj rebase -r <rev> -d <destination>

# Rebase branch
jj rebase -b <branch> -d <destination>
```

### `/jj bookmark`

Manage bookmarks (jj's equivalent to git branches):

```bash
# List bookmarks
jj bookmark list

# Create bookmark
jj bookmark create <name>

# Move bookmark to current
jj bookmark set <name>

# Delete bookmark
jj bookmark delete <name>
```

### `/jj git`

Git interoperability:

```bash
# Fetch from git remote
jj git fetch

# Push to git remote
jj git push

# Import git refs
jj git import

# Export to git refs
jj git export
```

## Revsets

Jujutsu uses revsets for selecting commits:

| Revset | Description |
|--------|-------------|
| `@` | Current working copy |
| `@-` | Parent of working copy |
| `root()` | Root commit |
| `heads(all())` | All head commits |
| `main` | The main bookmark |
| `ancestors(@)` | All ancestors of @ |
| `@::main` | Path from @ to main |

## MCP Tools Available

This command uses jj-mcp-server which provides 30+ MCP tools:

**Core:** status, log, diff, show, commit, new, abandon, rebase, revert
**Bookmarks:** bookmark-create, bookmark-delete, bookmark-list, bookmark-move, etc.
**Git:** git-clone, git-fetch, git-push, git-import, git-export, etc.

## Related

- `docs/JJ-INTEGRATION.md` - Full integration documentation
- `docs/JJ-MULTI-AGENT-PATTERNS.md` - Multi-agent workflow patterns
- `/agentic-flow` - Agent coordination with jj
