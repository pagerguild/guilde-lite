# CLAUDE.md

## Project State (Read First)

**Active Track:** MULTI-001 - Multi-Agent Workflow Architecture
**Priority:** P0 (Critical Path)
**Phase:** 2 - Agent Definitions
**Status:** Phase 1 complete (11/11), Phase 2 starting (0/15)

**Next Task:** Create `.claude/agents/` directory structure

```
Quick Status:
  conductor/tracks.md        → Master track list
  conductor/tracks/MULTI-001/plan.md → Current implementation plan
  conductor/workflow.md      → Task execution protocol
```

---

## Contents

1. [Project State](#project-state-read-first)
2. [Critical Rules](#critical-rules)
3. [Quick Commands](#quick-commands)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Documentation](#detailed-documentation)

---

## Critical Rules

### Workflow Discipline
1. **Read Plan First** - Check `conductor/tracks/MULTI-001/plan.md` before any work
2. **TDD Required** - Write tests BEFORE implementation (RED → GREEN → REFACTOR)
3. **Update Plan** - Mark tasks `[~]` when starting, `[x]` when complete
4. **Sync Docs** - Keep documentation in sync with code changes

### Confirmation Required
- **NEVER guess** - If requirements are unclear, ASK FIRST
- **Confirm Phases** - AWAIT explicit user "yes" before marking phase complete
- Architectural decisions with multiple valid approaches
- Any destructive operation (delete, force push, drop)
- Database schema or API contract changes

### Multi-Agent Consensus
For high-impact decisions, use consensus patterns:
- Launch parallel subagents for diverse perspectives
- Use LLM Council pattern for architecture decisions
- See `docs/MULTI-AGENT-CONSENSUS-PATTERNS.md` for details

---

## Quick Commands

```bash
# Development
task              # List all available commands
task setup        # Full environment bootstrap
task verify       # Verify all tools installed correctly
task lint         # Run all linters
task test         # Run all tests
task ci:local     # Run full CI pipeline locally

# Database
task db:up        # Start all databases
task db:down      # Stop all databases
```

<details>
<summary>Language-Specific Commands</summary>

```bash
# Go
go test -v ./...
go vet ./...

# Python (via uv)
uv sync && uv run pytest

# TypeScript/Bun
bun install && bun test
```
</details>

---

## Architecture Overview

Development environment automation ("Infrastructure as Code" for local machines).

```
Key Files:
  Brewfile          # System dependencies (Homebrew)
  mise.toml         # Runtime versions (Go, Python, Rust, Bun)
  Taskfile.yml      # Task automation

Directories:
  conductor/        # Workflow orchestration (tracks, plans, specs)
  docs/             # Architecture documentation
  .claude/          # Claude Code configuration (hooks, skills, agents)
  sandbox/          # AI agent isolation configs
  docker/           # Database stack (PostgreSQL, Redis, Qdrant)
```

### Tool Preferences (Mise-First)

**ENFORCED via hooks** - See `.claude/rules/mise-first-enforcement.md`

| Instead of | Use | Why |
|------------|-----|-----|
| nvm/pyenv/rbenv | **mise** | Single tool, faster startup |
| pip install | **uv pip** or **uvx** | 10-100x faster |
| npm/yarn | **bun** | Faster, compatible |
| Docker Desktop | **OrbStack** | Lighter on Apple Silicon |
| Make | **Task** | Go-based, readable YAML |

### Installation Priority Order (ENFORCED)

```
Priority  Method      Use For              Example
───────────────────────────────────────────────────────────────
1         curl/wget   Direct installers    curl -fsSL url | bash
2         mise        Languages, CLI tools mise use node@latest
3         uv/uvx      Python tools         uvx ruff check
4         bun         JS/TS packages       bun add typescript
5         npm         When bun unavailable npm install
6         Homebrew    System tools only    brew install git
```

**Python Package Rule:** NEVER use `pip install`. ALWAYS use `uv pip install` or `uvx`.

**Mise Configuration Pattern:**
- Global (`~/.config/mise/config.toml`): All tools = `"latest"`
- Project (`./mise.toml`): Override only when pinning specific version

---

## Detailed Documentation

| Document | Purpose |
|----------|---------|
| [Multi-Agent Workflow](docs/MULTI-AGENT-WORKFLOW.md) | Full architecture spec |
| [Consensus Patterns](docs/MULTI-AGENT-CONSENSUS-PATTERNS.md) | How agents reach agreement |
| [Workflow Protocol](conductor/workflow.md) | Task execution steps |
| [Track Plan](conductor/tracks/MULTI-001/plan.md) | Current implementation tasks |
| [Track Spec](conductor/tracks/MULTI-001/spec.md) | Requirements & acceptance criteria |
| [Global AI Tools](docs/GLOBAL-AI-TOOLS.md) | Mise global tools setup |
| [Mise-First Rules](.claude/rules/mise-first-enforcement.md) | Hookify enforcement patterns |

---

## Session Startup Protocol

When starting a new session:

1. **Check Active Track**
   ```bash
   cat conductor/tracks.md | head -20
   ```

2. **Find Next Task**
   ```bash
   grep -A 5 "^\- \[ \]" conductor/tracks/MULTI-001/plan.md | head -10
   ```

3. **Review Recent Changes**
   ```bash
   git log --oneline -5
   git status
   ```

4. **Load Context** (if resuming complex work)
   ```bash
   cat SESSION_HANDOFF.md 2>/dev/null || echo "No handoff file"
   ```

---

## Memory Hierarchy

Context is loaded in this priority order:

1. **CLAUDE.md** (this file) - Project rules and state
2. **conductor/tracks.md** - Active work summary
3. **conductor/tracks/*/plan.md** - Current task details
4. **SESSION_HANDOFF.md** - Session-specific context (if present)
5. **.claude/rules/*.md** - Modular instruction sets

### Token Optimization
- Use subagents for exploration (isolates context)
- Compact with `/compact focus on {topic}` at logical breakpoints
- Summarize findings, don't dump raw output

---

## Import Context

@conductor/tracks.md
@conductor/workflow.md
