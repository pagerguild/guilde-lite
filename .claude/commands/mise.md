---
name: mise
description: Show mise status, validate configuration, and assist with migrations
arguments:
  - name: action
    description: Action to perform (status, validate, migrate, doctor, help)
    required: false
    default: status
---

# /mise Command

Comprehensive mise management command for status, validation, and migrations.

## Actions

### `/mise` or `/mise status`

Show current mise configuration status:

1. **Run the validation script** to get comprehensive status:
   ```bash
   bash scripts/validate-mise-first.sh
   ```

2. **Show current tool versions**:
   ```bash
   mise current
   ```

3. **Show installed tools**:
   ```bash
   mise ls
   ```

4. **Report summary** to user including:
   - Global config status
   - Project config status
   - Legacy tool warnings
   - AI CLI tools availability

### `/mise validate`

Run full validation with detailed checks:

```bash
bash scripts/validate-mise-first.sh --ci
```

Report any errors or warnings found.

### `/mise fix`

Auto-fix mise configuration issues:

```bash
bash scripts/validate-mise-first.sh --fix
```

This will:
- Install missing tools
- Regenerate shims
- Trust config files

### `/mise migrate`

Help user migrate from legacy version managers:

1. **Detect legacy tools**:
   ```bash
   # Check for nvm
   ls -la ~/.nvm 2>/dev/null && echo "nvm detected"

   # Check for pyenv
   ls -la ~/.pyenv 2>/dev/null && echo "pyenv detected"

   # Check for rbenv
   ls -la ~/.rbenv 2>/dev/null && echo "rbenv detected"
   ```

2. **Get current versions from legacy tools** (if found):
   ```bash
   # From nvm
   nvm current 2>/dev/null || true

   # From pyenv
   pyenv version 2>/dev/null || true

   # From rbenv
   rbenv version 2>/dev/null || true
   ```

3. **Generate migration commands**:
   - For each detected legacy tool, provide:
     - `mise use <tool>@<version>` command
     - Instructions to remove legacy tool from shell config
     - Safe removal instructions

4. **Offer to perform migration** (with user confirmation):
   - Add tools to mise.toml
   - Verify tools work via mise
   - Provide shell config cleanup instructions

### `/mise doctor`

Run mise diagnostics:

```bash
mise doctor
```

Also check:
- Shims are in PATH
- Global config uses "latest" pattern
- No conflicting version managers

### `/mise help`

Show this help information and link to documentation:

- `docs/GLOBAL-AI-TOOLS.md` - Global tools setup
- `.claude/rules/mise-first-enforcement.md` - Enforcement rules
- `.claude/skills/mise-expert/SKILL.md` - Mise expert guidance

## Usage Examples

```
/mise              # Show status
/mise status       # Show status (explicit)
/mise validate     # Run validation
/mise fix          # Auto-fix issues
/mise migrate      # Help migrate from legacy tools
/mise doctor       # Run diagnostics
/mise help         # Show help
```

## Related Commands

- `mise install` - Install tools from mise.toml
- `mise use <tool>@<version>` - Add tool to mise.toml
- `mise ls` - List installed tools
- `mise current` - Show active versions
- `mise reshim` - Regenerate shims
- `mise trust` - Trust config file
