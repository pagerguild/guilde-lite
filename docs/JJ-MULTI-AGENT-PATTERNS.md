# Jujutsu (jj) for Multi-Agent AI Workflows

**Version:** 1.0.0
**Last Updated:** January 2026
**Status:** Research Complete

---

## Table of Contents

1. [Why Jujutsu for AI Agents](#why-jujutsu-for-ai-agents)
2. [Key Concepts](#key-concepts)
3. [Workflow Patterns](#workflow-patterns)
4. [Safety Strategies](#safety-strategies)
5. [Command Reference](#command-reference)
6. [Integration with Claude Code](#integration-with-claude-code)
7. [Resources](#resources)

---

## Why Jujutsu for AI Agents

Jujutsu (jj) solves the two primary causes of AI agent failure in Git:

| Problem | Git Behavior | Jujutsu Solution |
|---------|--------------|------------------|
| **Lock Contention** | Agents fight over `index.lock` | Lock-free concurrent operations |
| **Destructive State** | Agents leave repo in broken merge state | Conflicts as data, not blockers |
| **Lost Work** | Agent crashes lose uncommitted work | Working copy IS a commit |
| **Merge Conflicts** | Block operations until resolved | First-class conflicts, deferred resolution |

### Performance Gains (Real-World Data)

From research on multiple Gemini CLIs with Jujutsu:

- **Setup Time**: 90% reduction
- **Conflict Resolution**: 95% faster (1x vs Git's 3x)
- **Overall Efficiency**: 1000% improvement
- **Concurrent Agents**: 8+ agents without locks

---

## Key Concepts

### 1. Working Copy IS a Commit

In Git, you must `git add` before committing. In jj, **every edit is automatically part of a revision**.

```bash
# Git workflow (error-prone for agents)
git add file.py
git commit -m "changes"

# jj workflow (agent-safe)
# Just edit files - they're automatically tracked
jj describe -m "changes"  # Optional: add message
```

**Agent Benefit**: If an agent crashes, work is already saved as a revision.

### 2. Conflicts as Data

When conflicts occur, jj records them **inside the file** rather than aborting:

```
<<<<<<< Conflict 1 of 1
+++++++ Contents of side #1
def hello():
    print("Hello from Agent 1")
------- Contents of base
def hello():
    print("Hello")
+++++++ Contents of side #2
def hello():
    print("Hello from Agent 2")
>>>>>>> Conflict 1 of 1 ends
```

**Agent Benefit**: Pipeline continues; a separate "Resolver Agent" can fix conflicts later.

### 3. Anonymous Branches

jj uses **revisions** instead of named branches:

```bash
jj new                        # Create anonymous working revision
jj new -m "Agent task"        # With description
jj new rev1 rev2 rev3         # Merge multiple revisions
```

**Agent Benefit**: No branch name collisions, no cleanup needed for abandoned work.

### 4. Operation Log (Time Machine)

Every jj command is logged with full repository snapshots:

```bash
jj op log                     # View all operations
jj undo                       # Revert last operation
jj op revert <op-id>          # Revert specific operation
jj op restore <op-id>         # Restore entire repo state
```

**Agent Benefit**: Any agent mistake can be instantly reversed.

---

## Workflow Patterns

### Pattern A: Intent & Squash (Human-in-the-Loop)

Best for daily work with Claude Code, Cursor, or Aider.

```bash
# 1. Capture Intent
echo "Implement user authentication with OAuth2" > INTENT.md

# 2. Start agent work
jj new -m "Agent: implement OAuth2 auth"

# 3. Agent executes (files auto-tracked)

# 4. Review
# Success:
jj squash                     # Merge into history

# Failure:
jj undo                       # Instant revert
```

**Key Insight**: INTENT.md creates permanent link between "what you asked" and "what agent wrote".

### Pattern B: Parallel Swarm (Autonomous Multi-Agent)

Best for multi-agent systems solving complex tasks.

```bash
# 1. Spawn workspaces for each agent
jj workspace add ./agents/backend --rev main
jj workspace add ./agents/frontend --rev main
jj workspace add ./agents/testing --rev main

# 2. Agents work in parallel (no locks!)
# Agent A in ./agents/backend
# Agent B in ./agents/frontend
# Agent C in ./agents/testing

# 3. Manager Agent merges results
jj new @backend_change @frontend_change @testing_change -m "Merge all features"
```

### Pattern C: Single Directory Multi-Revision

Lightweight approach without filesystem overhead:

```bash
# 1. Each agent creates a revision
jj new -m "Agent-1: backend API"
jj new -m "Agent-2: frontend UI"
jj new -m "Agent-3: test suite"

# 2. View all concurrent work
jj log --all

# 3. Switch between agent contexts
jj edit <revision_id>

# 4. Integrate work
jj new agent1-rev agent2-rev agent3-rev -m "integrate"
```

### Pattern D: Conductor-Orchestrated Workflow

Integration with conductor pattern for Claude Code:

```bash
# 1. Conductor reads track plan
cat conductor/tracks/MULTI-001/plan.md

# 2. Spawn agent revisions per task
jj new -m "Agent-Backend: Task 1 - Create API endpoint"
jj new -m "Agent-Test: Task 1 - Write API tests"

# 3. Agents work in parallel

# 4. Coordinator merges when tasks complete
jj new @backend @test -m "Phase 1 complete"

# 5. Update plan.md with commit reference
# Mark tasks [x] with revision ID
```

---

## Safety Strategies

### Three Layers of Defense

| Layer | Feature | Implementation |
|-------|---------|----------------|
| **1. Hard Stop** | Immutable Heads | Forbid rewriting `main` at binary level |
| **2. Time Machine** | Operation Log | `jj op log` + `jj undo` for instant recovery |
| **3. Sandbox** | Anonymous Branches | `jj new` creates isolated workspace |

### Configuration for Immutable Main

```toml
# .jj/repo/config.toml
[revset-aliases]
"immutable_heads()" = "main"
```

If an agent tries to force-push or delete history on main, jj rejects the command.

### Recovery Commands

```bash
# View what happened
jj op log

# Undo last operation
jj undo

# Revert specific operation (keep later changes)
jj op revert <op-id>

# Full restore to earlier state
jj op restore <op-id>

# Abandon failed agent work
jj abandon <revision>
```

---

## Command Reference

### Essential Commands for AI Agents

| Command | Purpose | Agent Use Case |
|---------|---------|----------------|
| `jj new` | Create revision | Start isolated agent task |
| `jj new A B C` | Merge revisions | Combine multiple agents' work |
| `jj edit <rev>` | Switch revision | Change agent context |
| `jj describe -m` | Add message | Document agent intent |
| `jj squash` | Consolidate | Clean up agent iterations |
| `jj undo` | Revert last op | Quick mistake recovery |
| `jj op log` | View history | Audit agent actions |
| `jj op revert` | Revert specific | Rollback failed work |
| `jj log` | View revisions | See all agent work |
| `jj diff` | Show changes | Review agent output |
| `jj resolve` | Fix conflicts | Interactive resolution |
| `jj fix` | Auto-resolve | Formatting/lint conflicts |
| `jj workspace add` | Create workspace | Filesystem isolation |
| `jj abandon` | Drop revision | Discard failed attempts |

### Revset Queries for Agent Work

```bash
# Find all agent commits
jj log -r 'description("Agent-")'

# Find work by specific agent
jj log -r 'description("Agent-Backend")'

# Find all unmerged work
jj log -r 'heads(all())'

# Find conflicts
jj log -r 'conflicts()'
```

---

## Integration with Claude Code

### System Prompt Addition

Add to CLAUDE.md or agent system prompt:

```markdown
## Version Control: Jujutsu (jj)

You are using Jujutsu (jj), not Git.

**Key Rules:**
1. **No Staging** - Do NOT run `git add`. All file edits are auto-tracked.
2. **New Tasks** - Run `jj new -m "task description"` to start fresh workspace.
3. **Save Work** - Run `jj describe -m "summary"` to name your work.
4. **Undo** - If you make a mistake, run `jj undo`.
5. **Conflicts** - Conflicts are stored inside files. Read them, fix them, continue.

**Workflow:**
1. `jj new -m "Agent: {task}"` - Start task
2. Make changes (auto-tracked)
3. `jj log` - Verify work
4. `jj squash` - Finalize OR `jj undo` - Revert
```

### Hook Integration

```json
// .claude/settings.json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "scripts/jj-safety-check.sh"
      }]
    }],
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "jj status 2>/dev/null || true"
      }]
    }]
  }
}
```

### Conductor Workflow Update

```markdown
## Task Execution Protocol (with jj)

1. **Select Task** - Choose next `[ ]` from plan.md
2. **Create Revision** - `jj new -m "Agent: {task}"`
3. **Mark In Progress** - Change `[ ]` to `[~]`
4. **TDD: RED** - Write failing tests
5. **TDD: GREEN** - Implement to pass
6. **TDD: REFACTOR** - Clean up
7. **Squash or Undo** - `jj squash` if good, `jj undo` if bad
8. **Update Plan** - Mark `[x]` with revision ID
```

---

## Tools & Projects

### mcp-jujutsu

MCP server for Jujutsu integration with Claude Desktop, Cursor, etc.

- Allows AI to natively "speak" jj
- Read repo graph, apply changes safely
- No hallucinated invalid Git commands

### agentic-jujutsu

Rust/WASM library for custom AI CLI tools.

- 10-100x faster than standard Git shells
- High-performance concurrent operations
- Structured conflict API for programmatic resolution

### Colocated Repos (Git Compatibility)

For tools that only support Git:

```bash
jj git init --colocate
```

Creates standard `.git` folder that tools can use while you manage with jj.

---

## Resources

### Documentation
- [Jujutsu GitHub](https://github.com/jj-vcs/jj)
- [Steve Klabnik's Jujutsu Tutorial](https://steveklabnik.github.io/jujutsu-tutorial/)
- [Chris Krycho: Deferred Conflict Resolution](https://v5.chriskrycho.com/journal/deferred-conflict-resolution-in-jujutsu/)

### AI Agent Integration
- [agentic-jujutsu NPM](https://www.npmjs.com/package/agentic-jujutsu)
- [Parallel Claude Code with Jujutsu](https://slavakurilyak.com/posts/parallel-claude-code-with-jujutsu)
- [Ian Bull: AI-Native Development Workflow](https://eclipsesource.com/blogs/2024/01/ai-native-jujutsu/)

### Presentations
- [The Madness of Multiple Gemini CLIs with Jujutsu](https://speakerdeck.com/gunta/the-madness-of-multiple-gemini-clis-developing-simultaneously-with-jujutsu)

### Videos
- [Jujutsu Tutorial by Matthew Sanabria](https://www.youtube.com/watch?v=jj-tutorial)

---

## Quick Start

```bash
# Initialize jj in existing Git repo
jj git init --colocate

# Or fresh repo
jj init

# Create agent workspace
jj new -m "Agent-1: implement feature X"

# Work normally (auto-tracked)
# Edit files...

# View status
jj status
jj log

# Success - squash into history
jj squash

# Failure - instant revert
jj undo
```

---

**Document Metadata**
- **Author**: Guilde Engineering
- **Version**: 1.0.0
- **Date**: January 14, 2026
- **Status**: Research Complete - Ready for Implementation
