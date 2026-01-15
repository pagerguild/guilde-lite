# Technology Stack

**Version:** 1.0.0
**Last Updated:** January 2026

---

## Overview

This document defines the technology choices for guilde-lite with rationale for each selection.

---

## Runtime Management

| Tool | Purpose | Why This Choice |
|------|---------|-----------------|
| **mise** | Universal runtime manager | Single tool for Go, Python, Rust, Node, etc. Replaces nvm/pyenv/goenv |
| **Homebrew** | System package manager | macOS standard, declarative via Brewfile |

### Version Constraints

```toml
# mise.toml
[tools]
go = "1.23"
python = "3.13"
rust = "1.83"
bun = "1.2"
```

---

## Languages

### Primary Languages

| Language | Use Case | Version | Rationale |
|----------|----------|---------|-----------|
| **Go** | CLI tools, performance-critical code | 1.23+ | Fast compilation, single binary, excellent concurrency |
| **Python** | AI/ML, scripting, automation | 3.13+ | AI ecosystem, uv for fast packages |
| **TypeScript** | Frontend, Node.js services | 5.x | Type safety, modern JS |
| **Rust** | System programming, WASM | 1.83+ | Memory safety, performance |

### Package Managers

| Language | Tool | Why |
|----------|------|-----|
| Go | go mod | Built-in |
| Python | **uv** | 10-100x faster than pip |
| TypeScript | **bun** | Faster than npm/yarn |
| Rust | cargo | Built-in |

---

## Databases

### Relational

| Database | Purpose | Configuration |
|----------|---------|---------------|
| **PostgreSQL 16** | Primary data store | pgvector extension for embeddings |

### Cache & Search

| Database | Purpose | Configuration |
|----------|---------|---------------|
| **Redis Stack** | Cache, sessions, pub/sub | RediSearch for full-text + vector similarity |

### Vector Databases

| Database | Purpose | When to Use |
|----------|---------|-------------|
| **pgvector** | Embeddings in PostgreSQL | When data is already in Postgres |
| **Qdrant** | Dedicated vector search | High-volume vector operations |
| **ChromaDB** | LLM embedding storage | Prototyping, simple use cases |

### Database Access Patterns

```yaml
# Preferred patterns
relational_queries: PostgreSQL via asyncpg/sqlx
caching: Redis with TTL
vector_search: pgvector for < 1M vectors, Qdrant for larger
full_text_search: RediSearch or PostgreSQL tsvector
```

---

## Containerization

| Tool | Purpose | Why |
|------|---------|-----|
| **OrbStack** | Container runtime | Faster, lighter than Docker Desktop on Apple Silicon |
| **Docker Compose** | Multi-container orchestration | Declarative database stack |

### Not Using

- **Docker Desktop** - Resource heavy, OrbStack is superior on macOS
- **Podman** - Less ecosystem support
- **Kubernetes** - Overkill for local development

---

## Task Automation

| Tool | Purpose | Why |
|------|---------|-----|
| **Task** (go-task) | Task runner | Go-based, cross-platform, YAML syntax |

### Not Using

- **Make** - Platform inconsistencies, arcane syntax
- **Just** - Less ecosystem adoption
- **npm scripts** - Language-specific

---

## AI & Agents

### AI Tools

| Tool | Purpose | Configuration |
|------|---------|---------------|
| **Claude Code** | AI coding assistant | .claude/ directory configuration |
| **Claude API** | Programmatic AI access | Anthropic SDK |

### Agent Orchestration

| Pattern | Implementation | Reference |
|---------|----------------|-----------|
| **Conductor** | conductor/ directory | Gemini CLI pattern adapted |
| **Subagents** | Task tool with specializations | Model tiering (Opus/Sonnet/Haiku) |
| **Consensus** | LLM Council pattern | Multi-agent agreement |

### Version Control for Agents

| Tool | Purpose | Why |
|------|---------|-----|
| **jj (Jujutsu)** | AI-friendly VCS | Lock-free concurrent operations, instant undo |
| **Git** | Fallback/compatibility | jj is Git-compatible |

---

## Testing

### Test Frameworks

| Language | Framework | Coverage Tool |
|----------|-----------|---------------|
| Go | go test | go cover |
| Python | pytest | coverage.py |
| TypeScript | bun test / vitest | c8 |
| Rust | cargo test | cargo tarpaulin |

### Test Requirements

```yaml
coverage_threshold: 80%
tdd_required: true
test_location: tests/ or *_test.go / test_*.py
```

---

## Linting & Formatting

| Language | Linter | Formatter |
|----------|--------|-----------|
| Go | golangci-lint | gofmt |
| Python | **ruff** | ruff format |
| TypeScript | eslint | prettier |
| Rust | clippy | rustfmt |

### Why Ruff for Python

- 10-100x faster than flake8 + isort + black combined
- Single tool for linting AND formatting
- Drop-in replacement

---

## Security

### AI Agent Sandboxing

| Level | Tool | Restrictions |
|-------|------|--------------|
| Basic | macOS sandbox-exec | File/network restrictions |
| Container | OrbStack | Dropped capabilities |
| VM | OrbStack Linux VM | Full isolation |

### Blocked Operations

```yaml
always_blocked:
  - rm -rf /
  - git push --force (to main/master)
  - package publishing without approval
  - system modification commands
```

---

## CI/CD

| Tool | Purpose | Configuration |
|------|---------|---------------|
| **GitHub Actions** | CI pipeline | .github/workflows/ci.yml |
| **Local Runner** | Self-hosted CI | ci/runner-local.sh |
| **SkyPilot** | Ephemeral cloud CI | ci/runner-aws.yaml |

---

## Terminal & Shell

| Tool | Purpose | Why |
|------|---------|-----|
| **Ghostty** | Terminal emulator | GPU-accelerated, fast |
| **tmux** | Session multiplexer | Vim integration, persistence |
| **zsh** | Shell | macOS default, plugins |

---

## Patterns & Conventions

### Code Style

- **Naming**: snake_case for Python, camelCase for JS/TS, PascalCase for Go exports
- **Comments**: Docstrings for public APIs, inline for complex logic
- **Error Handling**: Explicit errors, no silent failures

### Architecture Decisions

All significant decisions documented in:
- `CLAUDE.md` - Project-level
- `conductor/tech-stack.md` - Technology-level (this file)
- `docs/` - Detailed architecture

### Dependency Management

```yaml
principles:
  - Prefer standard library when possible
  - Minimize external dependencies
  - Pin versions in lockfiles
  - Regular security updates
```

---

## References

- [mise documentation](https://mise.jdx.dev/)
- [uv documentation](https://docs.astral.sh/uv/)
- [bun documentation](https://bun.sh/docs)
- [jj documentation](https://martinvonz.github.io/jj/latest/)
- [OrbStack](https://orbstack.dev/)
