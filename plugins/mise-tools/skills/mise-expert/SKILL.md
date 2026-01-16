---
name: mise-expert
description: |
  Mise configuration and runtime management expert. Use when:
  - Installing programming language runtimes (node, python, go, rust, etc.)
  - Configuring tool versions globally or per-project
  - Questions about mise.toml, global config, or shims
  - Installing CLI tools (especially AI CLI tools like gemini, codex, opencode)
  - Troubleshooting "command not found" for mise-managed tools
  - Comparing mise to nvm, pyenv, rbenv, goenv
  - Setting up development environments

  Do NOT use for:
  - General coding questions unrelated to tooling
  - Questions about specific programming languages (use language-specific agents)
---

# Mise Expert Skill

## Purpose

Provides authoritative guidance on mise (mise-en-place) configuration following modern best practices (2024-2025). Enforces mise-first patterns for runtime and tool management.

## Core Principles

### 1. Installation Priority Order

**Always recommend tools in this order:**

1. **curl/wget** - Direct installers (e.g., Claude Code: `curl -fsSL https://claude.ai/install.sh | bash`)
2. **mise** - Universal runtime manager (preferred for languages and CLI tools)
3. **uv/uvx** - Python tools (NEVER use pip directly)
4. **bun** - JavaScript/TypeScript tools (prefer over npm)
5. **npm** - Only when bun unavailable
6. **Homebrew** - System tools only when above unavailable

### 2. Configuration Pattern

```
Global (~/.config/mise/config.toml)     Project (./mise.toml)
┌────────────────────────────────┐      ┌─────────────────────────┐
│ All tools = "latest"           │ ──►  │ Override only when      │
│ (defaults, always cutting-edge)│      │ pinning specific version│
└────────────────────────────────┘      └─────────────────────────┘
```

**Global config:** `~/.config/mise/config.toml`
- Always use `"latest"` for all tools
- Provides baseline available everywhere

**Project config:** `./mise.toml`
- Override with specific versions when reproducibility needed
- Commit to version control for team consistency

### 3. Shims for Global Availability

Shims must be in PATH for global tools to work everywhere:
```bash
export PATH="$HOME/.local/share/mise/shims:$PATH"
```

Add to `~/.zshrc` or `~/.bashrc`.

## Common Tasks

### Installing a New Runtime

```bash
# Add to mise.toml (project-specific)
mise use node@latest

# Or add to global config
echo 'node = "latest"' >> ~/.config/mise/config.toml
mise install
mise reshim
```

### Installing AI CLI Tools

```bash
# Via mise (recommended)
mise use "npm:@google/gemini-cli@latest"
mise use "npm:@openai/codex@latest"
mise use opencode@latest

# Claude Code (special - use direct installer)
curl -fsSL https://claude.ai/install.sh | bash
```

### Troubleshooting "command not found"

```bash
# 1. Check shims in PATH
echo $PATH | grep mise

# 2. If missing, add to shell config
export PATH="$HOME/.local/share/mise/shims:$PATH"

# 3. Regenerate shims
mise reshim

# 4. Verify installation
mise ls
which <tool-name>
```

### Migrating from nvm/pyenv/rbenv

```bash
# 1. Document current versions
nvm current        # e.g., v20.10.0
pyenv version      # e.g., 3.12.0

# 2. Add to mise.toml
cat >> mise.toml << 'EOF'
[tools]
node = "20"
python = "3.12"
EOF

# 3. Install via mise
mise install

# 4. Remove legacy tools (optional)
# nvm uninstall, pyenv uninstall, etc.
```

## Why Mise Over Legacy Tools

| Issue | Legacy (nvm/pyenv/rbenv) | Mise |
|-------|-------------------------|------|
| Shell startup | ~50ms per tool | ~10ms total |
| Installation | Different per tool | `mise install` |
| Config format | Different per tool | Single `mise.toml` |
| Languages | One per tool | 200+ supported |
| Activation | Per-shell setup | Auto-switch on cd |

## Related Files

- Global config: `~/.config/mise/config.toml`
- Project config: `./mise.toml`
- Shims: `~/.local/share/mise/shims/`
- Documentation: `docs/GLOBAL-AI-TOOLS.md`

## Quick Commands

```bash
mise install          # Install all tools from config
mise use <tool>       # Add tool to mise.toml
mise ls               # List installed tools
mise ls -g            # List global tools
mise reshim           # Regenerate shims
mise trust <file>     # Trust a config file
mise current          # Show active versions
mise doctor           # Diagnose issues
```
