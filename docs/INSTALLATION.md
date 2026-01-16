# Development Environment Installation Guide

Welcome to the hands-on installation tutorial for this modern development environment. This guide will walk you through setting up a production-ready workspace optimized for AI/Agent development on macOS.

## What You'll Learn

By the end of this tutorial, you'll have:
- A fully automated, reproducible development environment
- Modern CLI tools that replace legacy Unix utilities
- Language runtimes (Go, Python, Rust, Bun) managed with mise
- Containerized databases (PostgreSQL, Redis, MongoDB, Qdrant, ChromaDB)
- GPU-accelerated terminal (Ghostty) with tmux integration
- Git configuration optimized for modern workflows
- AI coding tools (Cursor, Claude Code)

**Time Estimate:** 30-60 minutes (depending on internet speed and chosen installation type)

## Mise-First Policy

This setup prefers mise for runtimes and CLI tools, and uses Homebrew only for system apps (GUI tools, fonts, container runtime). If a tool exists in both, mise is the default; Homebrew is fallback when mise doesn’t support it.

## Prerequisites

### Required

- **macOS** (Apple Silicon recommended, Intel supported)
- **macOS 13.0 or later** (for best compatibility)
- **10GB free disk space** (minimum)
- **Admin/sudo access** on your Mac
- **Internet connection** (stable, for downloading packages)

### Recommended

- Basic familiarity with terminal/command line
- Understanding of shell environments (zsh is default on modern macOS)

### Not Required

You don't need these pre-installed (the setup handles them):
- Homebrew
- Git
- Docker Desktop
- Any language runtimes

## Quick Start

**For experienced developers who want to get going fast:**

```bash
# Clone the repository (or use your existing checkout)
git clone <repository-url>
cd guilde-lite

# Run one-command installation
./install.sh

# Wait for completion (15-30 minutes)
# Restart your terminal when done

# Verify everything works
task verify
```

That's it! Skip to [Post-Installation Setup](#post-installation-setup) if this works.

**If you encounter issues or want more control, continue with the Staged Installation Guide below.**

---

## Staged Installation Guide

The staged approach lets you install components incrementally, verify each step, and troubleshoot issues as they arise. This is the **recommended approach for first-time setup**.

### Pre-Flight Checks

Before starting, let's verify your system meets the requirements.

#### Step 1: Check macOS Version

```bash
sw_vers
```

**Expected output:**
```
ProductName:        macOS
ProductVersion:     14.x.x (or higher)
BuildVersion:       23xxx
```

**Troubleshooting:**
- If version is below 13.0, some tools may not work correctly
- Consider updating macOS before proceeding

#### Step 2: Check Architecture

```bash
uname -m
```

**Expected output:**
- `arm64` - Apple Silicon (M1/M2/M3) - Optimal
- `x86_64` - Intel Mac - Supported but slower

#### Step 3: Install Xcode Command Line Tools

```bash
xcode-select --install
```

**What this does:** Installs essential build tools (git, make, clang) required by Homebrew.

**If already installed:**
```bash
xcode-select -p
# Output: /Library/Developer/CommandLineTools
```

**Common Issues:**
- **"command line tools are already installed"** - This is fine, continue
- **Installation window doesn't appear** - Run `sudo rm -rf /Library/Developer/CommandLineTools` then retry
- **Installation fails** - Update macOS first, then retry

**Verification:**
```bash
# These commands should work without errors
git --version
clang --version
```

---

### Stage 0: Bootstrap (Homebrew + Task)

This stage installs the foundation: Homebrew (package manager) and Task (automation runner).

#### Install with Script

```bash
./install.sh stage 1
```

**Or manually:**

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to your PATH (for Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Verify Homebrew
brew --version
```

**What gets installed:**
- Homebrew (package manager)
- Task (task runner)
- git, git-lfs, gh (GitHub CLI)
- mise (universal runtime manager)

**Expected output:**
```
=== Stage 1: Installing core tools ===
==> Downloading and installing Homebrew...
[...]
=== Verifying Stage 1 ===
git version 2.43.0
mise 2025.1.0
go-task version: v3.34.1
✓ Stage 1 complete
```

**Verification:**
```bash
# All these commands should work
command -v brew && brew --version
command -v task && task --version
command -v mise && mise --version
command -v git && git --version
command -v gh && gh --version
```

**Troubleshooting:**

| Problem | Solution |
|---------|----------|
| `brew: command not found` | Run: `eval "$(/opt/homebrew/bin/brew shellenv)"` |
| Permission errors | Don't use `sudo` with brew commands |
| Slow download | Be patient; first-time setup downloads ~2GB |
| `task: command not found` | Restart terminal or run `brew install go-task/tap/task` |

**Rollback:**
```bash
# Remove Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

---

### Stage 1: Core Tools

Essential version control and runtime management tools.

```bash
task stage:1
```

**What gets installed:**
- ✓ git - Version control
- ✓ git-lfs - Large file storage
- ✓ gh - GitHub CLI
- ✓ jj - Jujutsu VCS (Git-compatible with better UX)
- ✓ just - Simple command runner
- ✓ mise - Universal runtime manager
- ✓ task - Task runner (Go-based Make replacement)

**Time:** ~2 minutes

**Verification:**
```bash
task stage:1:verify
```

**Manual verification:**
```bash
git --version              # Should show 2.40+
gh --version               # Should show 2.40+
jj --version               # Should show 0.35+
just --version             # Should show 1.40+
mise --version             # Should show 2024.12+
task --version             # Should show v3.30+
```

**Common Issues:**

**Issue:** `mise: command not found` after installation
```bash
# Solution: Activate mise in your shell
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**Issue:** Task commands fail with "Taskfile.yml not found"
```bash
# Solution: Make sure you're in the project root
cd /path/to/guilde-lite
task stage:1
```

---

### Stage 2: Modern CLI Tools

Rust/Go replacements for traditional Unix tools - faster, more user-friendly, with better defaults.

```bash
task stage:2
```

**What gets installed:**

| Tool | Replaces | Purpose | Why Better |
|------|----------|---------|------------|
| `rg` (ripgrep) | `grep` | Search files | 5-10x faster, ignores .gitignore |
| `fd` | `find` | Find files | Simpler syntax, faster |
| `bat` | `cat` | View files | Syntax highlighting, line numbers |
| `eza` | `ls` | List files | Color-coded, git integration |
| `delta` | `diff` | Git diffs | Side-by-side, syntax highlighting |
| `jq` | - | JSON processing | Parse/transform JSON |
| `yq` | - | YAML processing | Parse/transform YAML |
| `starship` | - | Shell prompt | Fast, customizable |
| `zoxide` | `cd` | Directory jumping | Smart, learns your habits |
| `fzf` | - | Fuzzy finder | Interactive file/command search |
| `dust` | `du` | Disk usage | Prettier output |
| `duf` | `df` | Filesystem info | Modern UI |
| `procs` | `ps` | Process list | Better formatting |
| `bottom` | `top`/`htop` | System monitor | Modern TUI |
| `hyperfine` | `time` | Benchmarking | Statistical analysis |
| `xh` | `curl` | HTTP client | Simpler syntax |

**Time:** ~5 minutes

**Verification:**
```bash
task stage:2:verify
```

**Try them out:**
```bash
# Search for text in files
rg "function" --type rust

# Find files by name
fd README

# View a file with syntax highlighting
bat Taskfile.yml

# Better ls
eza -la

# Interactive directory jump (after using cd a few times)
z dev

# Fuzzy find files
fzf

# Check disk usage
dust

# System monitor
btm
```

**Before vs After Example:**

**Before (traditional):**
```bash
find . -name "*.go" -type f | xargs grep "func main"
```

**After (modern):**
```bash
rg "func main" -g "*.go"
```

**Common Issues:**

**Issue:** Commands not found after installation
```bash
# Solution: Restart terminal or reload shell
source ~/.zshrc
```

**Issue:** `starship` prompt doesn't appear
```bash
# Solution: Add to shell config
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
source ~/.zshrc
```

---

### Stage 3: Terminal & Multiplexer

GPU-accelerated terminal and session management.

```bash
task stage:3
```

**What gets installed:**
- Ghostty - Modern GPU-accelerated terminal
- JetBrainsMono Nerd Font - Programming font with icons
- Fira Code Nerd Font - Alternative programming font
- tmux - Terminal multiplexer
- zellij - Modern tmux alternative

**Time:** ~3 minutes

**Why Ghostty?**
- **Fast:** GPU-accelerated rendering, 60fps+
- **Native:** Built for macOS, uses Metal
- **Modern:** True color, ligatures, image support
- **Lightweight:** ~30MB RAM vs iTerm2's 200MB+
- **AI-Ready:** Semantic prompt zones for Claude Code

**Verification:**
```bash
task stage:3:verify

# Check if Ghostty installed
ls /Applications/Ghostty.app

# Check tmux
tmux -V
```

**Post-Installation:**

After Stage 3, you should:

1. **Launch Ghostty** (from Applications folder)
2. **Set as default terminal** (optional but recommended)
3. **Try tmux:**
   ```bash
   tmux new -s dev
   # Press Ctrl+B then D to detach
   tmux attach -t dev
   ```

**Common Issues:**

**Issue:** Ghostty doesn't appear in Applications
```bash
# Solution: Install manually
brew install --cask ghostty

# Verify
ls /Applications/Ghostty.app
```

**Issue:** Fonts don't show up in Ghostty
```bash
# Solution: Restart Ghostty after font installation
# Then check Settings > Appearance > Font
```

**Issue:** tmux key bindings don't work
```bash
# Default prefix is Ctrl+B
# Try: Ctrl+B then ? for help
```

---

### Stage 4: Containers & Orchestration

OrbStack (Docker alternative) and Kubernetes tools.

```bash
task stage:4
```

**What gets installed:**
- OrbStack - Docker Desktop replacement (~4GB RAM saved)
- kubectl - Kubernetes CLI
- kubectx - Context/namespace switching
- helm - Kubernetes package manager
- k9s - Kubernetes TUI
- lazydocker - Docker TUI

**Time:** ~5 minutes (OrbStack is large)

**Why OrbStack vs Docker Desktop?**

| Feature | OrbStack | Docker Desktop |
|---------|----------|----------------|
| RAM Usage | ~500MB | ~4GB |
| CPU Usage | ~1-2% idle | ~5-10% idle |
| Startup Time | <2s | ~30s |
| Integration | Native macOS | VM-based |
| License | Free for personal | Paid for business |

**Verification:**
```bash
task stage:4:verify

# Check OrbStack
ls /Applications/OrbStack.app

# Start OrbStack (first time)
open /Applications/OrbStack.app

# Wait 10 seconds for it to start, then:
docker ps
kubectl version --client
```

**Post-Installation:**

1. **Launch OrbStack** (first time)
   ```bash
   open /Applications/OrbStack.app
   ```

2. **Wait for it to start** (~10 seconds)

3. **Verify Docker works:**
   ```bash
   docker run hello-world
   ```

**Expected output:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

**Try the TUIs:**
```bash
# Docker TUI
lazydocker

# Kubernetes TUI (if you have a cluster)
k9s
```

**Common Issues:**

**Issue:** `docker: command not found`
```bash
# Solution: Start OrbStack first
open /Applications/OrbStack.app
# Wait 10 seconds
docker ps
```

**Issue:** `Cannot connect to Docker daemon`
```bash
# Solution: Make sure OrbStack is running
ps aux | grep -i orbstack

# If not running, start it:
open /Applications/OrbStack.app
```

**Issue:** Kubernetes not enabled
```bash
# Solution: Open OrbStack settings
# Enable Kubernetes in Settings > Kubernetes
```

**Rollback:**
```bash
# Uninstall OrbStack
brew uninstall --cask orbstack
rm -rf ~/.orbstack
```

---

### Stage 5: Database Clients

CLI clients for PostgreSQL and Redis.

```bash
task stage:5
```

**What gets installed:**
- postgresql@16 - PostgreSQL client (`psql`)
- libpq - PostgreSQL C library
- redis - Redis client (`redis-cli`)

**Time:** ~3 minutes

**Note:** This installs **clients only**, not database servers. Servers run in Docker containers (see Stage D: Databases).

**Verification:**
```bash
task stage:5:verify

# Check versions
psql --version
redis-cli --version
```

**Try connecting (after databases are running):**
```bash
# PostgreSQL
psql -h localhost -U dev -d dev
# Password: dev

# Redis
redis-cli -h localhost -p 6379 -a dev
```

**Common Issues:**

**Issue:** `psql: command not found`
```bash
# Solution: Add to PATH
echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Issue:** Cannot connect to database
```bash
# Solution: Start databases first (see Stage D below)
task db:up
task db:wait
```

---

### Stage 6: Cloud & AWS Tools

AWS CLI and modern authentication tools.

```bash
task stage:6
```

**What gets installed:**
- awscli - AWS command line interface
- granted - Fast AWS SSO/role switching
- session-manager-plugin - SSH via AWS SSM (no keys needed)

**Time:** ~2 minutes

**Why Granted?**
- **Fast:** Role switching in <1s vs ~10s with `aws configure`
- **SSO-native:** Built for AWS IAM Identity Center
- **Secure:** No long-lived credentials
- **UX:** Interactive profile selection

**Verification:**
```bash
task stage:6:verify

aws --version
granted --version
```

**Post-Installation:**

Configure AWS credentials:

```bash
# Traditional AWS CLI
aws configure

# Modern way with Granted
assume
# Interactive profile selector will appear
```

**Common Issues:**

**Issue:** `assume: command not found`
```bash
# Solution: Restart terminal
# Granted installs shell integration on first run
```

**Issue:** AWS SSO login fails
```bash
# Solution: Make sure you have AWS SSO configured
aws configure sso
```

---

### Stage 7: AI Coding Tools

AI-assisted development tools.

```bash
task stage:7
```

**What gets installed:**
- Cursor - AI-native code editor (VSCode fork)

**Time:** ~3 minutes

**Note:** CLI AI tools are installed separately via mise (see Stage AI below).

**Verification:**
```bash
task stage:7:verify

# Check Cursor
ls /Applications/Cursor.app

# Launch Cursor
open /Applications/Cursor.app
```

**Post-Installation:**

1. **Launch Cursor**
2. **Sign in** with GitHub/Google
3. **Install extensions** (Cursor will suggest these):
   - Cursor AI
   - GitLens
   - Prettier
   - ESLint

**Common Issues:**

**Issue:** Cursor doesn't open from terminal
```bash
# Solution: Install shell command
# Open Cursor > Command Palette (Cmd+Shift+P)
# Type: "Install 'cursor' command in PATH"
```

---

### Stage 8: Security Tools

Encryption, secrets management, and security scanning.

```bash
task stage:8
```

**What gets installed:**

| Tool | Purpose |
|------|---------|
| age | Modern file encryption (GPG alternative) |
| sops | Secrets in Git (encrypts values, not files) |
| cosign | Container signing and verification |
| trivy | Security scanner (containers, IaC, code) |

**Time:** ~2 minutes

**Verification:**
```bash
task stage:8:verify

age --version
sops --version
trivy --version
```

**Try them out:**

```bash
# Encrypt a file with age
echo "secret data" | age -p > secret.age
# Enter passphrase when prompted

# Decrypt
age -d secret.age
# Enter passphrase

# Scan for vulnerabilities
trivy image node:18
```

---

### Stage 9: Build Tools

Compilers, linters, and build systems.

```bash
task stage:9
```

**What gets installed:**
- cmake - Cross-platform build system
- ninja - Fast build system (Make replacement)
- ccache - Compiler cache (faster rebuilds)
- golangci-lint - Go linter aggregator

**Time:** ~2 minutes

**Verification:**
```bash
task stage:9:verify

cmake --version
ninja --version
golangci-lint --version
```

**Common Issues:**

**Issue:** `cmake: command not found`
```bash
# Solution: Restart terminal
source ~/.zshrc
```

---

### Stage R: Language Runtimes

Install programming language runtimes via mise.

```bash
task stage:runtimes
```

**What gets installed:**

| Language | Version | Tools |
|----------|---------|-------|
| Go | latest | `go`, `gofmt`, `goimports` |
| Rust | latest | `rustc`, `cargo`, `rustup` |
| Python | latest | `python`, `pip`, `uv` |
| Node.js | latest | `node`, `npm` |
| Bun | latest | `bun` (npm alternative) |
| Deno | latest | `deno` |
| Terraform | latest | `terraform` |

**Plus Python tools:**
- mypy - Type checker
- ruff - Linter + formatter
- skypilot - Cloud compute orchestration

**AI CLIs:** Installed in Stage AI (Claude via curl; Codex/Gemini/OpenCode via mise)

**Time:** ~10 minutes (downloads and compiles)

**What mise does:**
- Downloads and installs runtimes
- Manages multiple versions per language
- Automatically switches versions based on project
- Handles PATH configuration

**Verification:**
```bash
task stage:runtimes:verify

# Check installed runtimes
mise current

# Manual checks
go version
rustc --version
python --version
bun --version
uv --version
```

**Expected output:**
```
Tool   Version          Config Source
bun    latest           ~/dev/guilde-lite/mise.toml
go     latest           ~/dev/guilde-lite/mise.toml
node   latest           ~/dev/guilde-lite/mise.toml
python latest           ~/dev/guilde-lite/mise.toml
rust   latest           ~/dev/guilde-lite/mise.toml
```

**Try them out:**
```bash
# Go
go version
echo 'package main; import "fmt"; func main() { fmt.Println("Hello, Go!") }' > hello.go
go run hello.go

# Python with uv (fast package manager)
uv venv
source .venv/bin/activate
uv pip install requests
python -c "import requests; print(requests.__version__)"

# Bun (fast Node.js alternative)
echo 'console.log("Hello, Bun!")' > hello.js
bun run hello.js

# Rust
echo 'fn main() { println!("Hello, Rust!"); }' > hello.rs
rustc hello.rs && ./hello
```

**Common Issues:**

**Issue:** `mise: command not found`
```bash
# Solution: Activate mise in shell
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**Issue:** Runtimes not in PATH
```bash
# Solution: Restart terminal or reload shell
source ~/.zshrc

# Verify mise is active
echo $PATH | grep mise
```

**Issue:** Slow installation
```bash
# This is normal - mise compiles from source
# Go: ~2 minutes
# Rust: ~5 minutes
# Python: ~3 minutes

# Be patient, it only happens once
```

**Issue:** Python version conflicts
```bash
# Solution: Check which python is active
which python
python --version

# Make sure mise's python is first in PATH
mise reshim
```

**Rollback:**
```bash
# Uninstall specific runtime
mise uninstall go@<version>

# Uninstall all
mise prune --all
```

---

### Stage C: Configurations

Apply shell, git, tmux, and Ghostty configurations.

```bash
task stage:configs
```

**What gets configured:**

**1. Shell (zsh):**
- mise activation
- starship prompt
- zoxide (smart cd)

**2. Git:**
- Default branch: `main`
- Rebase on pull
- Auto-prune branches
- Delta for diffs
- Better diff algorithm (histogram)

**3. Tmux:**
- Modern key bindings
- Mouse support
- Better colors
- Plugin manager (TPM)

**4. Ghostty:**
- JetBrainsMono Nerd Font
- Catppuccin Mocha theme
- Shell integration
- Optimized performance

**Time:** ~1 minute

**Verification:**
```bash
# Check shell config
grep mise ~/.zshrc
grep starship ~/.zshrc

# Check git config
git config --global --list | grep -E 'init.defaultBranch|pull.rebase|core.pager'

# Check tmux config
cat ~/.tmux.conf | head -10

# Check Ghostty config
cat ~/.config/ghostty/config | head -10
```

**Post-Configuration:**

**Restart your terminal** to apply shell changes.

**Try the new configurations:**

```bash
# New shell prompt (starship)
# Should show: directory, git branch, language versions

# Smart cd (zoxide)
cd ~/dev/some-project
cd ~/
z some  # Jumps back to ~/dev/some-project

# Better git diffs (delta)
git diff HEAD~1

# Tmux with new config
tmux new -s test
# Try Ctrl+Space (new prefix) instead of Ctrl+B
```

**Common Issues:**

**Issue:** Shell changes don't take effect
```bash
# Solution: Restart terminal (not just new tab)
# Cmd+Q, then reopen
```

**Issue:** Git still uses old defaults
```bash
# Solution: Check global config
git config --global --list

# Re-run config
task config:git
```

---

### Stage D: Databases

Start containerized databases.

```bash
task stage:databases
```

**What gets started:**

| Database | Port | Purpose | Memory |
|----------|------|---------|--------|
| PostgreSQL + pgvector | 5432 | Relational + vector search | 2GB |
| Redis Stack | 6379, 8001 | Cache + vector search | 1GB |
| MongoDB | 27017 | Document database | 1GB |
| Qdrant | 6333, 6334 | Purpose-built vector DB | 1GB |
| ChromaDB | 8000 | Embedding database | 512MB |

**Credentials (dev only):**
- PostgreSQL: `dev` / `dev`
- Redis: password `dev`
- MongoDB: `dev` / `dev`

**Time:** ~2 minutes (first start downloads images)

**What happens:**
1. Starts Docker containers via compose
2. Waits for databases to be ready
3. Verifies health checks pass

**Verification:**
```bash
# Check status
task db:status

# Should show all containers as "Up" and "healthy"
docker compose -f docker/docker-compose.yml ps
```

**Expected output:**
```
NAME           STATUS        PORTS
dev-chromadb   Up (healthy)  0.0.0.0:8000->8000/tcp
dev-mongodb    Up (healthy)  0.0.0.0:27017->27017/tcp
dev-postgres   Up (healthy)  0.0.0.0:5432->5432/tcp
dev-qdrant     Up (healthy)  0.0.0.0:6333-6334->6333-6334/tcp
dev-redis      Up (healthy)  0.0.0.0:6379->6379/tcp, 0.0.0.0:8001->8001/tcp
```

**Try connecting:**

```bash
# PostgreSQL
task db:psql
# Or manually:
psql -h localhost -U dev -d dev

# Redis
task db:redis
# Or manually:
redis-cli -h localhost -p 6379 -a dev

# Check vector capabilities in PostgreSQL
task db:psql
# Then in psql:
SELECT * FROM pg_extension WHERE extname = 'vector';
```

**Common Issues:**

**Issue:** `Cannot connect to Docker daemon`
```bash
# Solution: Start OrbStack
open /Applications/OrbStack.app
# Wait 10 seconds
docker ps
```

**Issue:** Port already in use (e.g., 5432)
```bash
# Solution: Stop conflicting service
# For PostgreSQL:
brew services stop postgresql

# Or change port in docker/docker-compose.yml
```

**Issue:** Database timeout during startup
```bash
# Solution: Databases are still starting
# Wait 30 seconds and try again:
task db:wait
```

**Issue:** Out of memory
```bash
# Solution: Stop unused containers
docker ps -a
docker stop <container>

# Or increase Docker memory limit in OrbStack settings
```

**Stop databases:**
```bash
task db:down
```

**Reset databases (deletes all data):**
```bash
task db:reset
```

---

### Stage AI: AI Coding Tools

Install Claude Code and other AI development tools.

```bash
task stage:ai-tools
```

**What gets installed:**
- Claude Code - Claude CLI coding assistant (curl installer)
- npm:@openai/codex - OpenAI Codex CLI
- npm:@google/gemini-cli - Gemini CLI
- opencode - OpenCode CLI

**Time:** ~2 minutes

**Note:** Requires Node.js or Bun (installed in Stage R).

**Optional (global install):** Make AI CLIs available in any directory:
```bash
task mise:global:setup
```
See `docs/GLOBAL-AI-TOOLS.md` for details.

**Verification:**
```bash
command -v claude && claude --version
command -v codex && codex --version
command -v gemini && gemini --version
command -v opencode && opencode --version
```

See `docs/TOOLS.md` for the full AI tools reference.

**Post-Installation:**

Configure Claude Code:

```bash
# First run will prompt for API key
claude config

# Test it
claude "explain this command: git rebase -i HEAD~3"
```

**Common Issues:**

**Issue:** `npm: command not found`
```bash
# Solution: Install runtimes first
task stage:runtimes
source ~/.zshrc
```

**Issue:** `claude: command not found`
```bash
# Solution: Restart terminal
# Or re-run the installer:
curl -fsSL https://claude.ai/install.sh | bash
```

---

## Installation Bundles

Instead of running stages individually, use these preset bundles:

### Minimal Setup

Core tools + CLI + runtimes only (~15 minutes)

```bash
./install.sh minimal
```

**Includes:**
- Stage 1: Core tools
- Stage 2: CLI tools
- Stage R: Language runtimes
- Shell + Git configuration

**Use when:**
- You want a lightweight setup
- You already have Docker/editors
- You're on a resource-constrained machine

### Developer Setup

Minimal + terminal + containers + build tools (~25 minutes)

```bash
./install.sh developer
```

**Includes:**
- Everything from Minimal
- Stage 3: Terminal (Ghostty, tmux)
- Stage 4: Containers (OrbStack)
- Stage 9: Build tools
- All configurations

**Use when:**
- You're doing serious development
- You need containers for testing
- You want the full terminal experience

### Full Setup

Everything including AI and databases (~40 minutes)

```bash
./install.sh full
```

**Includes:**
- Everything from Developer
- Stage 5: Database clients
- Stage 6: Cloud/AWS tools
- Stage 7: AI editors (Cursor)
- Stage 8: Security tools
- Stage AI: AI CLIs (Claude, Codex, Gemini, OpenCode)
- claude-flow (global bun install)
- Stage D: Database containers

**Use when:**
- First-time complete setup
- You want all features
- Disk space and time aren't constraints

---

## Post-Installation Setup

After installation completes, follow these steps to finalize your environment.

### 1. Restart Terminal

**Critical:** Many tools require a fresh shell session.

```bash
# Quit terminal completely (Cmd+Q)
# Then reopen

# Or reload config (less reliable)
source ~/.zshrc
```

### 2. Verify Installation

Run the comprehensive verification:

```bash
task verify
```

**Expected output:**
```
=== Full Environment Verification ===
=== Verifying Stage 1 ===
git version 2.43.0
mise 2025.1.0
go-task version: v3.34.1
✓ Stage 1 complete
=== Verifying Stage 2 ===
ripgrep 14.1.0
fd 9.0.0
bat 0.24.0
[...]
=== All verifications passed ===
```

**If any verification fails:**
```bash
# Re-run that specific stage
task stage:N

# Example: If Stage 2 failed
task stage:2
```

### 2a. Maintenance Updates

Keep Homebrew and mise tools up to date:

```bash
task update:all
```

Get a consolidated tool status summary:

```bash
task tools:status
```

List all available project commands:

```bash
task -l
```

This includes claude-flow wrappers (`claude-flow:*`) for bun-based usage.

Claude Flow (bunx wrapper, pinned to `claude-flow@3.0.0-alpha.79`):

```bash
task claude-flow:init
task claude-flow:install
task claude-flow:version
task claude-flow:doctor
task claude-flow:mcp:start
task claude-flow:run -- --help
```

### 3. Configure Shell

Your shell should now have:

**Check prompt:**
```bash
# Should show starship prompt with:
# - Current directory
# - Git branch (if in repo)
# - Language versions (go, python, etc.)
```

**Check PATH:**
```bash
echo $PATH | tr ':' '\n' | grep -E 'mise|homebrew'
```

**Should include:**
- `/opt/homebrew/bin` (Homebrew)
- `.local/share/mise/shims` (mise)

**Test smart cd:**
```bash
# Jump to a directory you've visited
z dev
# Or use interactive selector
zi
```

### 4. Configure Terminal (Ghostty)

If you installed Stage 3, configure Ghostty:

**Launch Ghostty:**
```bash
open /Applications/Ghostty.app
```

**Verify configuration:**
1. Open Settings (Cmd+,)
2. Check Font: "JetBrainsMono Nerd Font"
3. Check Theme: "Catppuccin Mocha"
4. Check Font Size: 14

**Test features:**
```bash
# Color and icons (needs Nerd Font)
eza -la --icons

# Syntax highlighting
bat Taskfile.yml

# Split panes
# Cmd+D for vertical split
# Cmd+Shift+D for horizontal split
```

### 5. Configure Git

Your git should now have modern defaults:

**Verify configuration:**
```bash
git config --global --list
```

**Key settings:**
- `init.defaultBranch=main`
- `pull.rebase=true`
- `core.pager=delta`
- `diff.algorithm=histogram`

**Test delta (better diffs):**
```bash
cd /path/to/any/git/repo
git diff HEAD~1
# Should show side-by-side diff with syntax highlighting
```

**Configure your identity (if not already set):**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 6. Start Databases

If you installed Stage D or Full Setup:

**Start all databases:**
```bash
task db:up
task db:wait
```

**Verify they're running:**
```bash
task db:status
```

**Test connections:**
```bash
# PostgreSQL
task db:psql
# Type \l to list databases
# Type \q to quit

# Redis
task db:redis
# Type PING
# Should respond: PONG
# Type exit
```

**Configure auto-start (optional):**
```bash
# Add to ~/.zshrc to start databases automatically
echo 'task db:up 2>/dev/null || true' >> ~/.zshrc
```

### 7. Configure AWS (if applicable)

If you installed Stage 6:

**Traditional AWS CLI:**
```bash
aws configure
# Enter your access key, secret key, region, output format
```

**Modern SSO with Granted:**
```bash
# Configure SSO
aws configure sso

# Use granted for fast switching
assume
# Interactive profile selector will appear
```

**Test AWS access:**
```bash
aws sts get-caller-identity
```

### 8. Configure AI Tools

If you installed Stage 7 or AI:

**Claude Code:**
```bash
# First run configuration
claude config
# Enter API key when prompted
# Get key from: https://console.anthropic.com/

# Test it
claude "what is the Taskfile?"
```

**Codex/Gemini/OpenCode:**
```bash
codex --help
gemini --help
opencode --help
```

**Cursor:**
```bash
# Open Cursor
open /Applications/Cursor.app

# Sign in with GitHub/Google
# Configure API keys in Settings > Features > AI
```

---

## Verification Checklist

Use this checklist to confirm everything is working:

### Core Tools
- [ ] `git --version` shows 2.40+
- [ ] `gh --version` works
- [ ] `task --version` works
- [ ] `mise --version` works

### CLI Tools
- [ ] `rg --version` works
- [ ] `fd --version` works
- [ ] `bat --version` works
- [ ] `eza -la` shows colorized output
- [ ] `starship --version` works
- [ ] Prompt shows starship theme

### Terminal
- [ ] Ghostty is installed: `ls /Applications/Ghostty.app`
- [ ] Ghostty launches without errors
- [ ] Font is JetBrainsMono Nerd Font
- [ ] Icons show up in `eza -la --icons`
- [ ] `tmux -V` works

### Containers
- [ ] OrbStack is installed: `ls /Applications/OrbStack.app`
- [ ] `docker ps` works
- [ ] `kubectl version --client` works
- [ ] `lazydocker` launches

### Runtimes
- [ ] `go version` works
- [ ] `python --version` works
- [ ] `rustc --version` works
- [ ] `bun --version` works
- [ ] `uv --version` works
- [ ] `mise current` shows all runtimes

### Databases
- [ ] `task db:status` shows all containers healthy
- [ ] `task db:psql` connects to PostgreSQL
- [ ] `task db:redis` connects to Redis

### Configurations
- [ ] `~/.zshrc` contains mise, starship, zoxide
- [ ] `~/.gitconfig` contains delta, histogram
- [ ] `~/.tmux.conf` exists
- [ ] `~/.config/ghostty/config` exists

### Optional (if installed)
- [ ] `aws --version` works
- [ ] `claude --version` works
- [ ] Cursor launches: `open /Applications/Cursor.app`
- [ ] `trivy --version` works

---

## Troubleshooting

### General Issues

#### Commands Not Found After Installation

**Symptom:** Newly installed tools don't work in terminal

**Solution:**
```bash
# 1. Restart terminal completely (Cmd+Q)
# 2. Or reload shell config
source ~/.zshrc

# 3. Check PATH
echo $PATH

# 4. Verify Homebrew in PATH
which brew

# 5. Re-add Homebrew to PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
```

#### Slow Installation

**Symptom:** Homebrew or mise taking a long time

**This is normal:**
- First-time Homebrew setup: ~5-10 minutes
- Language runtime compilation: ~10-15 minutes
- Container image downloads: ~5 minutes

**Speed it up:**
```bash
# Use faster DNS
# Add to /etc/hosts:
echo '1.1.1.1' | sudo tee -a /etc/hosts

# Or use Cloudflare DNS in System Settings
```

#### Permission Errors

**Symptom:** "Permission denied" errors

**Solution:**
```bash
# Never use sudo with brew
# If you accidentally did:
sudo chown -R $(whoami) /opt/homebrew

# For mise:
chmod -R u+w ~/.local/share/mise
```

#### Disk Space Issues

**Symptom:** "No space left on device"

**Solution:**
```bash
# Check disk space
df -h

# Clean Homebrew cache
brew cleanup -s

# Clean Docker
docker system prune -a

# Clean mise cache
rm -rf ~/.local/share/mise/installs/*/cache
```

---

### Stage-Specific Issues

#### Stage 1: Core Tools

**Issue:** `mise: command not found`

**Solution:**
```bash
# Install mise
brew install mise

# Activate in shell
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**Issue:** `task: command not found`

**Solution:**
```bash
brew install go-task/tap/task
```

#### Stage 2: CLI Tools

**Issue:** Tools work but prompt doesn't change

**Solution:**
```bash
# Add starship to shell
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**Issue:** `zoxide` not working

**Solution:**
```bash
# Need to use it first
cd ~/dev
cd ~/Documents
cd ~/
z dev  # Now it should work
```

#### Stage 3: Terminal

**Issue:** Ghostty won't launch

**Solution:**
```bash
# Check installation
ls -la /Applications/Ghostty.app

# Reinstall if missing
brew reinstall --cask ghostty

# Check console for errors
open /Applications/Utilities/Console.app
# Filter for "Ghostty"
```

**Issue:** Fonts don't show up

**Solution:**
```bash
# Verify font installation
ls ~/Library/Fonts | grep -i nerd

# Reinstall fonts
brew reinstall font-jetbrains-mono-nerd-font

# Restart Ghostty (Cmd+Q, reopen)
```

**Issue:** tmux colors look wrong

**Solution:**
```bash
# Make sure TERM is set correctly
echo $TERM
# Should be: xterm-256color or screen-256color

# In ~/.zshrc:
export TERM=xterm-256color

# Restart terminal
```

#### Stage 4: Containers

**Issue:** OrbStack won't start

**Solution:**
```bash
# Check if running
ps aux | grep -i orbstack

# Kill and restart
pkill -9 OrbStack
open /Applications/OrbStack.app

# Check logs
tail -f ~/.orbstack/logs/app.log
```

**Issue:** Docker commands fail

**Solution:**
```bash
# Make sure OrbStack is running
docker context ls

# Switch to OrbStack context
docker context use orbstack

# Or set DOCKER_HOST locally
export DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock
```

**Issue:** Port conflicts

**Solution:**
```bash
# Find what's using the port
sudo lsof -i :5432

# Kill the process
kill -9 <PID>

# Or change port in docker-compose.yml
```

#### Stage R: Runtimes

**Issue:** Runtime installation fails

**Solution:**
```bash
# Check mise status
mise doctor

# Reinstall specific runtime
mise uninstall go@<version>
mise install go@<version>

# Check logs
mise debug install go@<version>
```

**Issue:** Wrong runtime version active

**Solution:**
```bash
# Check current versions
mise current

# Check which version is in PATH
which python
python --version

# Reshim mise (refresh PATH)
mise reshim

# Make sure mise.toml is in current directory
ls mise.toml
```

**Issue:** Python/pip not found

**Solution:**
```bash
# Check mise python
mise which python

# Reshim
mise reshim

# Add to PATH manually (if needed)
export PATH="$HOME/.local/share/mise/installs/python/<version>/bin:$PATH"
```

#### Stage D: Databases

**Issue:** Containers won't start

**Solution:**
```bash
# Check Docker
docker ps

# Check compose file
docker compose -f docker/docker-compose.yml config

# View logs
docker compose -f docker/docker-compose.yml logs

# Restart containers
task db:down
task db:up
```

**Issue:** Database connection refused

**Solution:**
```bash
# Check if container is running
docker ps | grep postgres

# Check if port is listening
nc -zv localhost 5432

# Wait for database to be ready
task db:wait

# Check container logs
docker logs dev-postgres
```

**Issue:** Out of memory

**Solution:**
```bash
# Check Docker memory usage
docker stats

# Stop unused containers
docker ps -a
docker stop <container-name>

# Increase OrbStack memory limit
# Settings > Resources > Memory > 8GB
```

---

### Recovery Commands

If something goes wrong, use these to recover:

#### Reset Homebrew
```bash
# Uninstall Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Reinstall
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Restore packages
task stage:1
task stage:2
# ... continue with stages
```

#### Reset mise
```bash
# Backup mise.toml
cp mise.toml mise.toml.backup

# Remove mise
rm -rf ~/.local/share/mise

# Reinstall
brew reinstall mise

# Restore runtimes
mise install --yes
```

#### Reset Shell Configuration
```bash
# Backup
cp ~/.zshrc ~/.zshrc.backup

# Remove custom configs
sed -i.bak '/mise activate/d' ~/.zshrc
sed -i.bak '/starship init/d' ~/.zshrc
sed -i.bak '/zoxide init/d' ~/.zshrc

# Re-apply
task config:shell
source ~/.zshrc
```

#### Reset Docker/OrbStack
```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all volumes
docker volume prune -f

# Remove all images
docker rmi $(docker images -q)

# Or reset OrbStack completely
rm -rf ~/.orbstack
brew reinstall --cask orbstack
```

#### Reset Git Configuration
```bash
# Backup
cp ~/.gitconfig ~/.gitconfig.backup

# Remove custom configs
git config --global --unset-all init.defaultBranch
git config --global --unset-all pull.rebase
git config --global --unset-all core.pager

# Re-apply
task config:git
```

#### Nuclear Option (Complete Reset)
```bash
# ⚠️ WARNING: This removes EVERYTHING
# Backup important files first!

# Remove all tools
brew remove --cask ghostty orbstack cursor
brew remove --force $(brew list)
brew cleanup -s

# Remove Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Remove mise
rm -rf ~/.local/share/mise

# Remove configs
rm -rf ~/.config/ghostty
rm ~/.tmux.conf
cp ~/.zshrc ~/.zshrc.backup
rm ~/.zshrc

# Start fresh
git clone <repository-url>
cd guilde-lite
./install.sh
```

---

## Next Steps

### Learn the Tools

After installation, learn your new tools:

```bash
# View all available tasks
task --list

# Get help on staged installation
task help:stages

# Learn modern CLI tools
rg --help
fd --help
bat --help

# Learn tmux
tmux new -s learning
# Press Ctrl+B then ? for help

# Learn Ghostty key bindings
# Cmd+K - clear screen
# Cmd+D - split vertical
# Cmd+Shift+D - split horizontal
```

### Configure for Your Workflow

Customize the environment:

**1. Update mise.toml for your languages:**
```toml
[tools]
go = "latest"         # Your preferred version (pin if needed)
python = "latest"
ruby = "3.3"          # Add languages you need
java = "21"
```

**2. Customize shell prompt:**
```bash
# Edit ~/.config/starship.toml
mkdir -p ~/.config
starship preset bracketed-segments > ~/.config/starship.toml
```

**3. Add shell aliases:**
```bash
# Add to ~/.zshrc
alias dc='docker compose'
alias k='kubectl'
alias g='git'
alias t='task'
```

**4. Customize Ghostty:**
```bash
# Edit ~/.config/ghostty/config
# Try different themes:
# - catppuccin-mocha (default)
# - tokyonight
# - dracula
# - nord
```

### Integrate with Your Projects

Use this environment with your projects:

**1. Copy mise.toml to project:**
```bash
cp mise.toml ~/your-project/
cd ~/your-project
mise install  # Installs project-specific runtimes
```

**2. Copy Taskfile template:**
```bash
# Create project-specific tasks
cd ~/your-project
cat > Taskfile.yml <<'EOF'
version: '3'

tasks:
  dev:
    desc: "Start development server"
    cmds:
      - go run main.go

  test:
    desc: "Run tests"
    cmds:
      - go test ./...
EOF

task --list
```

**3. Use Docker compose for project:**
```bash
# Copy database setup
cp docker/docker-compose.yml ~/your-project/
cd ~/your-project
docker compose up -d
```

### Join the Community

- Star this repository
- Report issues
- Contribute improvements
- Share your setup

---

## Summary

Congratulations! You now have a modern, reproducible development environment with:

- ✅ Modern CLI tools (ripgrep, fd, bat, eza, etc.)
- ✅ Language runtimes managed by mise
- ✅ GPU-accelerated terminal (Ghostty)
- ✅ Lightweight containers (OrbStack)
- ✅ Containerized databases
- ✅ Git with modern defaults
- ✅ AI coding tools
- ✅ Task automation

**Key commands to remember:**
```bash
task --list              # View all tasks
task stage:N             # Run specific stage
task verify              # Verify installation
task db:up               # Start databases
task db:status           # Check database status
mise current             # Show active runtimes
z <directory>            # Smart cd
rg <pattern>             # Fast search
fd <name>                # Find files
```

**Documentation:**
- README.md - Project overview
- Taskfile.yml - All available tasks
- mise.toml - Runtime configuration
- docker/docker-compose.yml - Database setup

**Need help?**
- Check troubleshooting section above
- Run `task help:stages`
- Open an issue on GitHub

Happy coding!
