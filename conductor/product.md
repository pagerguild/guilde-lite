# Product Definition

**Version:** 1.0.0
**Last Updated:** January 2026

---

## Product Vision

**guilde-lite** is a development environment automation system ("Infrastructure as Code" for local machines) that enables rapid, reproducible developer setup with integrated AI agent orchestration.

### One-Line Summary

> Automate local development environments with AI-first tooling and multi-agent workflow orchestration.

---

## Target Users

### Primary Users

| User | Description | Pain Points |
|------|-------------|-------------|
| **Developer** | Individual developer setting up new machine | Manual setup takes hours, inconsistent environments |
| **Team Lead** | Standardizing team development environments | "Works on my machine" syndrome, onboarding friction |
| **AI Engineer** | Building with Claude Code / AI agents | Context loss, no workflow orchestration, merge conflicts |

### Secondary Users

| User | Description |
|------|-------------|
| **DevOps Engineer** | CI/CD pipeline configuration |
| **Open Source Maintainer** | Contributor onboarding |

---

## Product Goals

### Must Have (P0)

1. **One-command setup** - `./install.sh` bootstraps entire environment
2. **Reproducible environments** - Same tools, same versions, same config
3. **AI agent sandboxing** - Safe execution boundaries for AI tools
4. **Multi-agent orchestration** - Conductor pattern for parallel AI work

### Should Have (P1)

1. **Database stack** - PostgreSQL, Redis, vector databases ready to use
2. **Task automation** - Common workflows via `task` commands
3. **Session continuity** - AI agents can resume across sessions

### Could Have (P2)

1. **Telemetry** - Track AI agent usage and costs
2. **CI/CD integration** - Local runner, cloud ephemeral runners
3. **Team sync** - Shared configuration via git

---

## Non-Goals

These are explicitly **out of scope**:

1. **Production deployment** - This is for local development only
2. **Multi-user collaboration** - Single developer focus
3. **Cloud infrastructure provisioning** - Local machines only
4. **IDE configuration** - Tool-agnostic (works with any editor)
5. **Custom model fine-tuning** - Uses existing AI models

---

## Key Features

### 1. Environment Bootstrap

```bash
./install.sh
```

Installs and configures:
- Homebrew packages (Brewfile)
- Runtime versions (mise.toml)
- Task automation (Taskfile.yml)
- Database stack (docker-compose)
- AI agent configuration (.claude/)

### 2. AI Agent Sandboxing

Three isolation levels:
- **Basic** - macOS sandbox-exec restrictions
- **Container** - OrbStack with dropped capabilities
- **VM** - Full Linux VM isolation

### 3. Multi-Agent Workflow (Conductor)

```
conductor/
├── product.md        # This file
├── tech-stack.md     # Technology choices
├── workflow.md       # Execution protocol
├── tracks.md         # Work tracking
└── tracks/*/         # Feature/bug tracks
```

### 4. Database Stack

Pre-configured databases:
- PostgreSQL 16 + pgvector
- Redis Stack + RediSearch
- Qdrant (vector search)
- ChromaDB (embeddings)

---

## Success Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Setup time (new machine) | < 30 minutes | - |
| Tool consistency | 100% reproducible | - |
| AI agent safety | Zero unauthorized actions | - |
| Session resume success | 100% context preserved | - |

---

## Competitive Landscape

| Tool | Focus | Guilde-lite Advantage |
|------|-------|----------------------|
| **dotfiles repos** | Shell config | Full stack automation |
| **Nix/Home Manager** | Reproducibility | Simpler, AI-focused |
| **Dev containers** | Container dev | Native performance |
| **Cursor/Windsurf** | AI IDE | Tool-agnostic, CLI-first |

---

## Roadmap

### Phase 1: Foundation (Current)
- Conductor directory structure
- Multi-agent workflow documentation
- Context engineering

### Phase 2-4: Agent Definitions & TDD
- Subagent specializations
- TDD enforcement hooks
- Ralph loop integration

### Phase 5-8: Automation
- Documentation automation
- Telemetry setup
- Quality assurance pipeline
- Hookify rules

### Phase 9-12: Polish
- Conductor commands
- Skill packaging
- Testing & release

---

## References

- [MULTI-AGENT-WORKFLOW.md](../docs/MULTI-AGENT-WORKFLOW.md)
- [Gemini CLI Conductor](https://github.com/gemini-cli-extensions/conductor)
- [conductor_cc](https://github.com/pilotparpikhodjaev/conductor_cc)
