# Brewfile - System Manifest for Reproducible Dev Environment
# 2026 Modern Best Practices - Native drop-in replacements preferred

# =============================================================================
# TAPS
# =============================================================================
tap "homebrew/bundle"
tap "go-task/tap"           # Task runner (Make replacement)
tap "common-fate/granted"   # Modern AWS SSO
tap "oven-sh/bun"           # Bun runtime
tap "jdx/mise"              # Runtime version manager

# =============================================================================
# 1. CORE INFRASTRUCTURE
# =============================================================================
cask "ghostty"              # GPU-accelerated terminal (primary)
cask "orbstack"             # Container engine (Docker Desktop replacement, ~4GB RAM saved)
brew "git"
brew "git-lfs"
brew "gh"                   # GitHub CLI

# =============================================================================
# 2. RUNTIME & VERSION MANAGEMENT
# =============================================================================
brew "mise"                 # Universal version manager (replaces nvm, pyenv, goenv, rbenv)

# =============================================================================
# 3. MODERN CLI TOOLS (Native Rust/Go replacements)
# =============================================================================
brew "starship"             # Cross-shell prompt
brew "zoxide"               # Smart cd replacement (z/autojump replacement)
brew "fzf"                  # Fuzzy finder
brew "ripgrep"              # grep replacement (rg)
brew "fd"                   # find replacement
brew "bat"                  # cat replacement with syntax highlighting
brew "eza"                  # ls replacement (exa successor)
brew "delta"                # git diff viewer
brew "sd"                   # sed replacement
brew "dust"                 # du replacement
brew "duf"                  # df replacement
brew "procs"                # ps replacement
brew "bottom"               # top/htop replacement (btm)
brew "hyperfine"            # Benchmarking tool
brew "tokei"                # Code statistics
brew "jq"                   # JSON processor
brew "yq"                   # YAML processor
brew "xh"                   # curl replacement (httpie-like)

# =============================================================================
# 4. SESSION & MULTIPLEXING
# =============================================================================
brew "tmux"
brew "zellij"               # Modern tmux alternative (optional)

# =============================================================================
# 5. AI CODING TOOLS
# =============================================================================
cask "cursor"               # AI-native editor
# Claude Code, OpenCode, Codex installed via mise (npm packages)

# =============================================================================
# 6. AWS & CLOUD TOOLS
# =============================================================================
brew "awscli"
brew "granted"              # Fast AWS role switching (aws-vault replacement)
brew "session-manager-plugin"  # SSH via SSM (no keys/VPN needed)
# SkyPilot installed via uv/pip for better version control

# =============================================================================
# 7. CONTAINER & ORCHESTRATION
# =============================================================================
brew "kubectl"
brew "kubectx"              # Context/namespace switching
brew "helm"
brew "k9s"                  # Kubernetes TUI
brew "lazydocker"           # Docker TUI

# =============================================================================
# 8. DATABASE CLIENTS
# =============================================================================
brew "postgresql@16"        # psql client
brew "libpq"                # PostgreSQL C library
brew "redis"                # redis-cli
cask "pgadmin4"             # PostgreSQL GUI (optional)

# =============================================================================
# 9. SECURITY & SECRETS
# =============================================================================
brew "age"                  # Modern encryption (GPG alternative)
brew "sops"                 # Secrets management
brew "cosign"               # Container signing
brew "trivy"                # Security scanner

# =============================================================================
# 10. BUILD TOOLS
# =============================================================================
brew "task"                 # Task runner (Make replacement)
brew "cmake"
brew "ninja"
brew "ccache"               # Compiler cache
brew "mold"                 # Fast linker (Linux, available on macOS for cross-compile)

# =============================================================================
# 11. FONTS
# =============================================================================
cask "font-jetbrains-mono-nerd-font"
cask "font-fira-code-nerd-font"
cask "font-monaspace-nerd-font"   # GitHub's variable-width coding font

# =============================================================================
# 12. OPTIONAL GUI APPS
# =============================================================================
# cask "raycast"            # Spotlight replacement
# cask "rectangle"          # Window management
# cask "bruno"              # API client (Postman replacement)
