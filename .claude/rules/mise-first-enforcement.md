# Mise-First Enforcement Rules

These hookify rules enforce mise-first patterns for tool and runtime management.

## Rule Categories

### 1. Block Rules (Hard Enforcement)

These rules BLOCK operations that violate mise-first patterns:

```yaml
- name: block-pip-install
  trigger: PreToolUse
  matcher: Bash
  condition: command contains "pip install" AND NOT "uv pip install"
  action: block
  message: |
    ❌ Direct pip install blocked.

    Use instead:
    • uv pip install <package>     # Install package
    • uvx <tool>                   # Run Python CLI tool
    • mise use pipx:<tool>@latest  # Install via mise

    Why: uv is 10-100x faster and manages virtual environments properly.

- name: block-npm-global-install
  trigger: PreToolUse
  matcher: Bash
  condition: command contains "npm install -g" OR "npm i -g"
  action: block
  message: |
    ❌ Global npm install blocked.

    Use instead:
    • mise use npm:<package>@latest  # Managed via mise
    • bun add -g <package>           # Via bun (faster)

    Why: mise-managed tools get shims and work everywhere.

- name: block-legacy-version-managers
  trigger: PreToolUse
  matcher: Bash
  condition: command starts with "nvm " OR "pyenv " OR "rbenv " OR "goenv "
  action: block
  message: |
    ❌ Legacy version manager detected.

    Migrate to mise:
    • mise use node@<version>     # Instead of nvm use
    • mise use python@<version>   # Instead of pyenv shell
    • mise use ruby@<version>     # Instead of rbenv local
    • mise use go@<version>       # Instead of goenv local

    Why: Single tool, faster shell startup, unified config.
```

### 2. Warn Rules (Soft Enforcement)

These rules WARN but allow the operation:

```yaml
- name: warn-brew-runtime-install
  trigger: PreToolUse
  matcher: Bash
  condition: command matches "brew install (node|python|go|rust|ruby)"
  action: warn
  message: |
    ⚠️ Consider using mise instead of Homebrew for runtimes:

    Current: brew install {runtime}
    Better:  mise use {runtime}@latest

    Why: mise allows per-project versions and auto-switching.

- name: warn-yarn-install
  trigger: PreToolUse
  matcher: Bash
  condition: command starts with "yarn " AND NOT project requires yarn
  action: warn
  message: |
    ⚠️ Consider using bun instead of yarn:

    Current: yarn install
    Better:  bun install

    Why: bun is faster and compatible with npm/yarn lockfiles.

- name: warn-manual-version-pin
  trigger: PostToolUse
  matcher: Write|Edit
  condition: file equals "mise.toml" AND contains hardcoded version
  action: notify
  message: |
    ℹ️ Consider using "latest" unless pinning is required:

    Pattern:
    • Global config: Always "latest"
    • Project config: "latest" unless reproducibility needed
```

### 3. Auto-Fix Rules (Automation)

These rules AUTOMATICALLY fix or validate:

```yaml
- name: validate-mise-toml
  trigger: PostToolUse
  matcher: Write|Edit
  condition: file equals "mise.toml"
  action: run
  command: mise install && mise doctor
  message: "Validating mise.toml configuration..."

- name: reshim-after-install
  trigger: PostToolUse
  matcher: Bash
  condition: command contains "mise install" OR "mise use"
  action: run
  command: mise reshim
  message: "Regenerating shims for new tools..."
```

## Installation Priority Reference

When Claude suggests installing tools, enforce this priority:

| Priority | Method | Use For | Example |
|----------|--------|---------|---------|
| 1 | curl/wget | Direct installers | `curl -fsSL https://claude.ai/install.sh \| bash` |
| 2 | mise | Languages, CLI tools | `mise use node@latest` |
| 3 | uv/uvx | Python packages/tools | `uvx ruff check` |
| 4 | bun | JS/TS packages | `bun add -g typescript` |
| 5 | npm | When bun unavailable | `npm install` |
| 6 | Homebrew | System tools only | `brew install git` |

## Configuration

These rules are enforced via:

1. **PreToolUse hook** in `.claude/settings.json` - Checks commands before execution
2. **mise-expert skill** in `.claude/skills/` - Provides guidance when activated
3. **CLAUDE.md** documentation - Reference for installation priority

## Exceptions

Some operations are **allowed** despite appearing to violate rules:

- `pip install` inside a Docker container or CI environment
- `npm install` for project dependencies (not global tools)
- `brew install` for system tools not available via mise
- Legacy commands when migrating existing projects

## Related Files

- `.claude/settings.json` - Hook configuration
- `.claude/skills/mise-expert/SKILL.md` - Auto-triggered guidance
- `~/.config/mise/config.toml` - Global mise configuration
- `./mise.toml` - Project mise configuration
- `docs/GLOBAL-AI-TOOLS.md` - Setup documentation
