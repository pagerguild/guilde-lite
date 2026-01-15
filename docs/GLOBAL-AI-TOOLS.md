# Global AI CLI Tools Setup

Guide for installing AI CLI tools globally so they're available in any directory.

---

## Quick Setup

```bash
bash scripts/setup-global-ai-tools.sh
```

This script:
1. Creates `~/.config/mise/config.toml` with global tools
2. Installs all AI CLI tools via mise
3. Adds mise shims to PATH
4. Verifies installation

---

## The Problem

By default, mise manages tools **per-project** via `mise.toml`. Tools are only available when you're in that project directory:

```bash
# In project with mise.toml containing gemini
~/project $ which gemini
/Users/you/.local/share/mise/shims/gemini  ✓

# In different directory
~/other $ which gemini
gemini not found  ✗
```

## The Solution

Two-part fix:

### 1. Global Mise Config

Create `~/.config/mise/config.toml`:

```toml
# Pattern: Global uses "latest" for everything.
# Projects can override with specific versions when needed.

[tools]
"npm:@google/gemini-cli" = "latest"
"npm:@openai/codex" = "latest"
opencode = "latest"
node = "latest"
bun = "latest"
uv = "latest"
python = "latest"
jj = "latest"
```

**Important**: Always use `"latest"` in global config. Projects can pin specific versions in their `mise.toml` when needed.

### 2. Shims in PATH

Add to `~/.zshrc` (or `~/.bashrc`):

```bash
export PATH="$HOME/.local/share/mise/shims:$PATH"
```

---

## Manual Setup

If you prefer manual setup:

```bash
# 1. Create global config directory
mkdir -p ~/.config/mise

# 2. Create global config (use "latest" for everything)
cat > ~/.config/mise/config.toml << 'EOF'
[tools]
"npm:@google/gemini-cli" = "latest"
"npm:@openai/codex" = "latest"
opencode = "latest"
node = "latest"
python = "latest"
bun = "latest"
uv = "latest"
jj = "latest"
EOF

# 3. Trust and install
mise trust ~/.config/mise/config.toml
mise install

# 4. Regenerate shims
mise reshim

# 5. Add shims to PATH (add to ~/.zshrc)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# 6. Reload shell
source ~/.zshrc
```

---

## AI CLI Tools

| Tool | Command | Purpose |
|------|---------|---------|
| Claude Code | `claude` | Anthropic's AI coding assistant |
| Gemini CLI | `gemini` | Google's Gemini AI |
| OpenAI Codex | `codex` | OpenAI's code assistant |
| OpenCode | `opencode` | AI code generation tool |

---

## How It Works

```
~/.config/mise/config.toml    ← Global tool definitions
         ↓
    mise install              ← Downloads tools
         ↓
~/.local/share/mise/shims/    ← Creates shim binaries
         ↓
    PATH includes shims       ← Tools available everywhere
```

**Shims** are small wrapper binaries that:
1. Look up the correct tool version
2. Execute the actual binary
3. Work from any directory

---

## Troubleshooting

### "command not found"

```bash
# Check if shims are in PATH
echo $PATH | grep mise

# If not, add to ~/.zshrc:
export PATH="$HOME/.local/share/mise/shims:$PATH"
source ~/.zshrc
```

### "too many levels of symbolic links"

```bash
# Regenerate shims
mise reshim
```

### Tool version not found

```bash
# Install tools from global config
mise install

# Or install specific tool
mise install node@lts
```

### Shims exist but tool doesn't work

```bash
# Check tool is installed
mise ls -g

# Check shim points to mise
ls -la ~/.local/share/mise/shims/gemini
# Should show: -> /opt/homebrew/bin/mise
```

---

## Verification

```bash
# From any directory
cd /tmp
which gemini    # Should show shims path
which codex     # Should show shims path
which opencode  # Should show shims path

# Test tools
gemini --version
codex --version
opencode --version
```

---

## Project vs Global Tools

| Scope | Config Location | When Available |
|-------|-----------------|----------------|
| Project | `./mise.toml` | Only in that directory |
| Global | `~/.config/mise/config.toml` | Everywhere (via shims) |

### The Pattern

1. **Global config**: Always use `"latest"` for all tools
2. **Project config**: Override only when you need a specific version

```
Global (~/.config/mise/config.toml)     Project (./mise.toml)
┌────────────────────────────────┐      ┌─────────────────────────┐
│ node = "latest"                │ ──►  │ node = "22"  # override │
│ python = "latest"              │      │ # inherits python       │
│ bun = "latest"                 │      │ go = "latest"  # add    │
└────────────────────────────────┘      └─────────────────────────┘
```

Project configs **override** global configs for the same tool, so you can pin specific versions per-project while global defaults stay at latest.
