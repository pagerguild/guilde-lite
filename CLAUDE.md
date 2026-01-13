# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
task              # List all available commands
task setup        # Full environment bootstrap
task verify       # Verify all tools installed correctly
task lint         # Run all linters (Go, Python, TypeScript)
task test         # Run all tests
task ci:local     # Run full CI pipeline locally
```

### Database Management
```bash
task db:up        # Start PostgreSQL, Redis, MongoDB, Qdrant, ChromaDB
task db:down      # Stop all databases
task db:psql      # Connect to PostgreSQL
task db:redis     # Connect to Redis CLI
```

### Language-Specific Commands
```bash
# Go
go test -v ./...
go vet ./...

# Python (via uv)
uv sync           # Install dependencies
uv run pytest     # Run tests
uv run ruff check # Lint

# TypeScript/Bun
bun install       # Install dependencies
bun test          # Run tests
bun run lint      # Lint
```

## Architecture

This is a development environment automation repository ("Infrastructure as Code" for local machines).

```
Brewfile          # System dependencies (Homebrew manifest)
mise.toml         # Runtime versions (Go, Python, Rust, Bun, etc.)
Taskfile.yml      # Automation engine (Make replacement)
install.sh        # One-command bootstrap script

config/
├── ghostty.conf  # GPU-accelerated terminal settings
└── tmux.conf     # Session multiplexer with Vim integration

sandbox/          # AI agent isolation configurations
├── basic.sb      # macOS sandbox-exec profile
├── claude-settings.json  # Claude Code permission restrictions
└── Dockerfile.agent      # Container-based isolation

docker/
├── docker-compose.yml    # Database stack definition
└── init/postgres/        # PostgreSQL initialization (pgvector)

ci/
├── runner-local.sh       # Self-hosted GitHub runner (macOS)
└── runner-aws.yaml       # SkyPilot ephemeral runner (AWS)

.github/workflows/
└── ci.yml                # Multi-language CI pipeline
```

## Project Conventions

### Tool Preferences (Native Drop-in Replacements)
- **mise** over nvm/pyenv/goenv - Universal runtime manager
- **bun** over npm/yarn - Faster JS runtime and package manager
- **uv** over pip - 10-100x faster Python package management
- **OrbStack** over Docker Desktop - Lighter, faster on Apple Silicon
- **Task** over Make - Go-based, cross-platform task runner

### Security: AI Agent Sandboxing
This repo includes three isolation levels for running AI agents:
1. **Basic** (`sandbox:basic`) - macOS sandbox-exec file/network restrictions
2. **Container** (`sandbox:container`) - OrbStack container with dropped capabilities
3. **VM** (`sandbox:vm`) - Full OrbStack Linux VM isolation

When modifying sandbox configs, be conservative—block dangerous operations by default.

### Blocked Operations
The `sandbox/claude-settings.json` blocks:
- Destructive commands (`rm -rf /`, `mkfs`, etc.)
- Force pushes to main/master
- Package publishing without explicit approval
- System modification commands

### Database Stack
All databases run via OrbStack containers (not Docker Desktop):
- PostgreSQL 16 with **pgvector** extension for embeddings
- Redis Stack with **RediSearch** for vector similarity
- Qdrant for dedicated vector search
- ChromaDB for LLM embedding storage
