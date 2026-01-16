# Mise Tools

Mise-first development environment management with version control and tool installation.

## Features

- **Mise status and validation**: Check configuration health and diagnose issues
- **Legacy tool migration**: Migrate from nvm, pyenv, rbenv to mise
- **Auto-fix capabilities**: Automatically resolve common configuration issues
- **Installation priority guidance**: Recommended tool installation order
- **AI CLI tool management**: Install and manage AI CLI tools via mise

## Installation

```bash
claude plugin install mise-tools@guilde-plugins
```

## Usage

### Commands

#### `/mise`

Comprehensive mise management:

```bash
/mise              # Show status (default)
/mise status       # Show configuration status
/mise validate     # Run full validation
/mise fix          # Auto-fix configuration issues
/mise migrate      # Migrate from legacy tools
/mise doctor       # Run diagnostics
/mise help         # Show help information
```

### Skills

#### `mise-expert`

Auto-activates for:
- Installing programming language runtimes (node, python, go, rust, etc.)
- Configuring tool versions globally or per-project
- Questions about mise.toml, global config, or shims
- Installing CLI tools (especially AI CLI tools like gemini, codex, opencode)
- Troubleshooting "command not found" for mise-managed tools
- Comparing mise to nvm, pyenv, rbenv, goenv
- Setting up development environments

## Installation Priority Order

Always recommend tools in this order:

| Priority | Method | Use For |
|----------|--------|---------|
| 1 | curl/wget | Direct installers |
| 2 | mise | Languages, CLI tools |
| 3 | uv/uvx | Python tools (NEVER pip) |
| 4 | bun | JavaScript/TypeScript |
| 5 | npm | When bun unavailable |
| 6 | Homebrew | System tools only |

## Configuration Pattern

```
Global (~/.config/mise/config.toml)
  - All tools = "latest"
  - Provides baseline available everywhere

Project (./mise.toml)
  - Override with specific versions when needed
  - Commit for team consistency
```

## Common Tasks

### Install a Runtime
```bash
mise use node@latest      # Add to mise.toml
mise install              # Install all tools
mise reshim               # Regenerate shims
```

### Install AI CLI Tools
```bash
mise use "npm:@google/gemini-cli@latest"
mise use "npm:@openai/codex@latest"
mise use opencode@latest
```

### Troubleshoot "command not found"
```bash
echo $PATH | grep mise    # Check shims in PATH
mise reshim               # Regenerate shims
mise ls                   # Verify installation
```

## Why Mise Over Legacy Tools

| Aspect | Legacy (nvm/pyenv/rbenv) | Mise |
|--------|-------------------------|------|
| Shell startup | ~50ms per tool | ~10ms total |
| Installation | Different per tool | `mise install` |
| Config format | Different per tool | Single `mise.toml` |
| Languages | One per tool | 200+ supported |

## Configuration

Shims must be in PATH for global tools:
```bash
export PATH="$HOME/.local/share/mise/shims:$PATH"
```

Add to `~/.zshrc` or `~/.bashrc`.
