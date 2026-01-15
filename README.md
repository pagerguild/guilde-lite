# Guilde Lite - Modern Dev Environment

Reproducible, automated development environment for AI/Agent development.

## Quick Start

```bash
# Clone the repo
git clone https://github.com/YOUR_ORG/guilde-lite.git ~/guilde-lite
cd ~/guilde-lite

# Run bootstrap (choose one)
./install.sh              # Default: all Homebrew + runtimes + configs
./install.sh minimal      # Core + CLI + runtimes only
./install.sh developer    # Minimal + terminal + containers
./install.sh full         # Everything including AI and databases
```

## Staged Installation

Install incrementally to test each step:

```bash
# Run stages individually
task stage:1              # Core (git, jj, just, mise, task)
task stage:2              # CLI tools (ripgrep, fd, bat, etc.)
task stage:3              # Terminal (Ghostty, tmux, fonts)
task stage:4              # Containers (OrbStack, kubectl, helm)
task stage:5              # Database clients (psql, redis-cli)
task stage:6              # Cloud/AWS (awscli, granted)
task stage:7              # AI tools (Cursor)
task stage:8              # Security (age, sops, trivy)
task stage:9              # Build tools (cmake, ninja)
task stage:runtimes       # Languages (Go, Python, Rust, Bun)
task stage:configs        # Config files (shell, git, tmux)
task stage:databases      # Start database containers
task stage:ai-tools       # Claude Code

# Verify any stage
task stage:1:verify
task stage:2:verify
# etc.

# See all stages
task help:stages
```

### Preset Bundles

| Bundle | What's Included |
|--------|-----------------|
| `setup:minimal` | Core + CLI + runtimes |
| `setup:developer` | Minimal + terminal + containers + build |
| `setup:full` | Everything including AI and databases |

## What's Included

### Modern Tooling (Native Drop-in Replacements)

| Legacy | Modern | Purpose |
|--------|--------|---------|
| nvm/pyenv/goenv | **mise** | Universal runtime version manager |
| npm/yarn | **bun** | JS runtime + package manager |
| pip/pip-tools | **uv** | Fast Python package manager |
| Docker Desktop | **OrbStack** | Lightweight container engine |
| grep | **ripgrep** | Fast search |
| find | **fd** | Fast file finder |
| cat | **bat** | Syntax-highlighted file viewer |
| ls | **eza** | Modern file listing |
| make | **Task** | Go-based task runner |

### Languages & Runtimes

- **Go 1.24** - Orchestration, CLI tools, agents
- **Rust** - Systems programming, performance-critical code
- **Python 3.12** - AI/ML, scripting, data processing
- **Bun** - JavaScript/TypeScript runtime
- **Deno** - Secure JS/TS runtime

### AI Coding Tools

- **Claude Code** - Anthropic's CLI assistant
- **Cursor** - AI-native editor
- Additional tools via mise

### Databases (with Vector Extensions)

- **PostgreSQL 16 + pgvector** - Relational + vector similarity
- **Redis Stack** - Cache + RediSearch + vector search
- **MongoDB** - Document store
- **Qdrant** - Purpose-built vector DB
- **ChromaDB** - Embedding database

## Commands

```bash
task              # List all commands
task setup        # Full environment setup
task verify       # Verify installation
task db:up        # Start databases
task db:down      # Stop databases
task lint         # Run all linters
task test         # Run all tests
```

### AI Agent Sandboxing

Three levels of isolation to prevent AI agents from doing anything nefarious:

```bash
# Level 1: Basic (file/network restrictions)
task sandbox:basic -- claude

# Level 2: Container isolation
task sandbox:container -- claude

# Level 3: Full VM isolation
task sandbox:vm -- claude
```

### CI/CD

```bash
# Run CI locally
task ci:local

# Setup self-hosted runner (local Mac)
task ci:runner:local

# Launch ephemeral runner on AWS
task ci:runner:aws
```

## Directory Structure

```
guilde-lite/
├── Brewfile              # System dependencies (Homebrew)
├── mise.toml             # Runtime versions
├── Taskfile.yml          # Automation engine
├── install.sh            # Bootstrap script
├── config/
│   ├── ghostty.conf      # Terminal config
│   └── tmux.conf         # tmux config
├── sandbox/
│   ├── basic.sb          # macOS sandbox profile
│   ├── claude-settings.json  # Claude Code restrictions
│   └── Dockerfile.agent  # Container sandbox
├── docker/
│   └── docker-compose.yml    # Database stack
├── ci/
│   ├── runner-local.sh   # Self-hosted runner (Mac)
│   └── runner-aws.yaml   # SkyPilot runner (AWS)
└── .github/
    └── workflows/
        └── ci.yml        # GitHub Actions workflow
```

## Configuration

### Ghostty

Copy config to Ghostty's config directory:
```bash
task config:ghostty
```

### tmux

Prefix key: `Ctrl+Space`

Key bindings:
- `Prefix + |` - Split vertical
- `Prefix + -` - Split horizontal
- `Prefix + t` - Floating terminal
- `Prefix + g` - Lazygit popup
- `Prefix + d` - Lazydocker popup
- `Ctrl+h/j/k/l` - Navigate panes

### AWS

```bash
# Login via Granted (modern aws-vault replacement)
task aws:login

# Connect to EC2 via SSM (no SSH keys needed)
task aws:ssm -- i-instanceid
```

## Security Considerations

### AI Agent Restrictions

The `sandbox/claude-settings.json` file blocks dangerous commands:
- Destructive operations (`rm -rf`, `mkfs`, etc.)
- System modifications (`launchctl`, `networksetup`)
- Credential/secret access
- Force pushes to main/master
- Package publishing

### Allowed Network Domains

AI agents can only access:
- API endpoints (anthropic, openai, github)
- Package registries (npm, pypi, crates.io, pkg.go.dev)

### Audit Logging

All tool uses are logged to `/tmp/claude-audit.log`

## Customization

### Adding New Runtimes

Edit `mise.toml`:
```toml
[tools]
java = "21"
ruby = "3.3"
```

### Adding System Tools

Edit `Brewfile`:
```ruby
brew "new-tool"
cask "new-app"
```

Then run:
```bash
task brew
```

## Troubleshooting

### mise not found after install

```bash
source ~/.zshrc
# or restart terminal
```

### Docker/OrbStack not responding

```bash
orb restart
```

### Databases not starting

```bash
task db:reset  # Warning: destroys data
```

### Claude Code Plugin Issues

If plugins fail to load or `/doctor` reports errors:

```bash
# Check plugin structure
ls -la ~/.claude/plugins/cache/<marketplace>/<plugin>/

# View debug logs
tail -100 ~/.claude/debug/*.txt | grep "<plugin-name>"
```

**Known Issues**:
- **business-analytics plugin**: Upstream missing required files. See [PLUGIN-FIX-SUMMARY.md](docs/PLUGIN-FIX-SUMMARY.md) for fix.

For detailed plugin troubleshooting, see [docs/PLUGIN-FIX-BUSINESS-ANALYTICS.md](docs/PLUGIN-FIX-BUSINESS-ANALYTICS.md).

## Contributing

1. Fork the repository
2. Create a feature branch
3. Run tests: `task ci:local`
4. Submit a pull request

## License

MIT
