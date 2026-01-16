# jj-tools

Jujutsu (jj) version control commands and workflow guidance.

## Commands

| Command | Description |
|---------|-------------|
| `/jj` | Jujutsu operations - status, log, diff, commit, rebase |
| `/jj status` | Show working copy status |
| `/jj log` | Show commit history |
| `/jj diff` | Show changes |
| `/jj commit` | Create a new commit |
| `/jj rebase` | Rebase commits |
| `/jj bookmark` | Manage bookmarks |
| `/jj git` | Git interoperability |

## Skills

| Skill | Triggers |
|-------|----------|
| `jj-expert` | "jj", "jujutsu", "revset", "bookmark", "rebase in jj" |

## Why jj?

Jujutsu is a Git-compatible VCS that's faster and simpler:

- **No staging area** - Working copy is always a commit
- **Edit any commit** - `jj edit <rev>` to modify history
- **Automatic rebasing** - Descendants update automatically
- **Conflict-free parallel work** - With QuantumDAG integration

## Quick Start

```bash
# Check status
/jj status

# View history
/jj log

# Make changes and commit
jj describe -m "my changes"
jj new

# Push to git remote
jj git push --bookmark main
```

## Installation

```bash
# Add marketplace (if needed)
claude plugin marketplace add ./marketplace

# Install plugin
claude plugin install jj-tools@guilde-plugins
```

## Related

- [JJ Integration Docs](../../docs/JJ-INTEGRATION.md)
- [Multi-Agent Patterns](../../docs/JJ-MULTI-AGENT-PATTERNS.md)
- `agentic-flow` plugin - Agent coordination with jj
