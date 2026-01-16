---
name: jj-expert
description: |
  Use when working with Jujutsu (jj) version control.
  Triggers: "jj", "jujutsu", "revset", "bookmark", "rebase in jj", "jj workflow".
  NOT for: Standard git operations (use git commands directly).
---

# Jujutsu Expert

Expert guidance for Jujutsu (jj) version control system.

## Core Concepts

### jj vs git Mental Model

| Git | jj | Key Difference |
|-----|-----|----------------|
| Branch | Bookmark | Bookmarks are just labels, not required |
| HEAD | `@` | Working copy is always a commit |
| Staging area | None | All changes are in working copy commit |
| Stash | Just use `jj new` | Create new commit, come back later |
| Checkout | `jj edit <rev>` | Edit any commit directly |

### The Working Copy is a Commit

In jj, your working copy IS a commit (called `@`). There's no staging area:

```bash
# See your current state
jj status

# Your changes are already "committed" to @
# To finalize, describe and create new:
jj describe -m "My changes"
jj new  # Creates fresh working copy
```

## Revset Patterns

### Common Revsets

```bash
# Current working copy
@

# Parent of working copy
@-

# Grandparent
@--

# All ancestors
ancestors(@)

# Range from A to B
A::B

# All heads
heads(all())

# Commits by author
author(name)

# Recent commits
@ | @- | @--
```

### Useful Queries

```bash
# Find all my uncommitted work
jj log -r 'heads(all()) ~ remote_bookmarks()'

# Find conflicts
jj log -r 'conflicts()'

# Find empty commits
jj log -r 'empty()'

# Commits not on main
jj log -r 'all() ~ ancestors(main)'
```

## Workflow Patterns

### 1. Simple Feature Work

```bash
# Start from main
jj new main -m "feat: add new feature"

# Work on changes (auto-saved to @)
# ...edit files...

# Finalize
jj describe -m "feat: completed feature"
jj bookmark create feature-branch
jj git push --bookmark feature-branch
```

### 2. Parallel Work (Multiple Features)

```bash
# Create multiple working copies
jj new main -m "feature A"
# ...work on A...

jj new main -m "feature B"
# Now @ is feature B, A still exists

# Switch back
jj edit <rev-of-A>
```

### 3. Amending Previous Commits

```bash
# Edit any commit directly
jj edit @-

# Make changes
# ...edit files...

# Return to where you were
jj new
```

### 4. Squashing Commits

```bash
# Squash @ into parent
jj squash

# Squash specific commit into its parent
jj squash -r <rev>

# Squash with custom message
jj squash -m "combined commit message"
```

## Conflict Resolution

### When Conflicts Occur

```bash
# Check for conflicts
jj status

# Resolve conflicts
jj resolve <file>

# Or edit files directly and mark resolved
jj restore --from @- <file>  # Take parent version
jj restore --from @+ <file>  # Take child version
```

### Avoiding Conflicts with QuantumDAG

When using multi-agent workflows:

```javascript
// Check before operations
const conflicts = await jj.checkAgentConflicts(opId, 'edit', files);
if (conflicts.length > 0) {
  // Handle conflicts before proceeding
}
```

## Git Interoperability

### Colocated Mode

jj can work alongside git in the same repo:

```bash
# Initialize jj in existing git repo
jj git init --colocate

# Changes sync automatically
jj git import  # Import git changes
jj git export  # Export jj changes to git
```

### Pushing to Git

```bash
# Create bookmark for the branch
jj bookmark create my-feature

# Push to remote
jj git push --bookmark my-feature

# Push all bookmarks
jj git push --all
```

## Performance Tips

| Operation | jj Time | git Time |
|-----------|---------|----------|
| Status | 3ms | 8ms |
| Commit | 18ms | 45ms |
| Rebase (10) | 65ms | 150ms |

jj is optimized for:
- Large monorepos
- Frequent rebasing
- Multi-agent workflows (with QuantumDAG)

## Common Issues

### "Working copy is dirty"

This is normal - your working copy IS a commit with changes.

### "Bookmark already exists"

```bash
# Move existing bookmark
jj bookmark set <name>

# Or delete and recreate
jj bookmark delete <name>
jj bookmark create <name>
```

### "Cannot rebase: conflicts"

```bash
# Check what conflicts
jj log -r 'conflicts()'

# Resolve or abandon
jj resolve
# or
jj abandon @
```

## Related Resources

- `/jj` command - Quick operations
- `/agentic-flow` - Multi-agent coordination
- `docs/JJ-INTEGRATION.md` - Full documentation
- `docs/JJ-MULTI-AGENT-PATTERNS.md` - Workflow patterns
