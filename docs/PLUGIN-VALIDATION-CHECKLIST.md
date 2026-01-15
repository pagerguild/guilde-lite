# Claude Code Plugin Validation Checklist

Quick reference for validating plugin structure before enabling or troubleshooting plugin issues.

---

## Pre-Installation Validation

Before enabling a new plugin, verify structure in marketplace directory:

```bash
MARKETPLACE="claude-code-workflows"  # or "claude-plugins-official"
PLUGIN="plugin-name"

# Check marketplace location
ls -la ~/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN/
```

### Required Files Checklist

- [ ] `.claude-plugin/plugin.json` - Plugin manifest (REQUIRED)
- [ ] `README.md` - Documentation (REQUIRED)
- [ ] At least one of: `agents/`, `skills/`, `commands/`, `hooks/`

### Optional But Recommended

- [ ] `.gitignore` - Development hygiene
- [ ] `LICENSE` - License information
- [ ] Examples or documentation subdirectory

---

## Validation Commands

### 1. Check Plugin Manifest

```bash
# Verify plugin.json exists and is valid JSON
cat ~/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN/.claude-plugin/plugin.json | python3 -m json.tool

# Expected fields:
# - name (string)
# - version (string, semver)
# - description (string)
# - author (object with name, email, url)
```

### 2. Check README

```bash
# Verify README exists and has content
test -f ~/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN/README.md && \
  wc -l ~/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN/README.md

# Should be > 10 lines for meaningful documentation
```

### 3. Check Component Directories

```bash
# List all directories
find ~/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN -type d -maxdepth 1

# Check specific components
test -d ~/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN/commands && echo "✓ Commands found"
test -d ~/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN/agents && echo "✓ Agents found"
test -d ~/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN/skills && echo "✓ Skills found"
```

---

## Post-Installation Validation

After enabling a plugin, verify it loaded correctly:

### 1. Check Cache Directory

```bash
# Plugin should be copied to versioned cache
VERSION=$(cat ~/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN/.claude-plugin/plugin.json | grep '"version"' | cut -d'"' -f4)
ls -la ~/.claude/plugins/cache/$MARKETPLACE/$PLUGIN/$VERSION/
```

### 2. Check Debug Logs

```bash
# View recent plugin loading logs
tail -200 ~/.claude/debug/*.txt | grep -A 3 "Loading plugin $PLUGIN"

# Success indicators:
# [DEBUG] Copied local plugin $PLUGIN to versioned cache
# [DEBUG] Loaded N skills from plugin $PLUGIN
# [DEBUG] Loaded N agents from plugin $PLUGIN

# Failure indicators:
# [ERROR] Plugin $PLUGIN has an invalid manifest
# [ERROR] Failed to load plugin $PLUGIN
```

### 3. Test Plugin Components

Within Claude Code CLI:

```bash
# Test commands (if plugin has them)
/<plugin-name>:<command-name>

# Test skills by asking relevant questions
"[Question that should trigger skill]"

# Check if plugin appears in help
/help  # Look for plugin in list
```

### 4. Run Doctor (if available)

```bash
# Within Claude Code
/doctor

# Or if there's a CLI command
claude doctor
```

---

## Common Issues & Fixes

### Issue: Plugin enabled but not loading

**Symptoms**:
- Plugin listed in `.claude/settings.json`
- No commands/skills/agents available
- Debug logs show copy success but no component loading

**Diagnosis**:
```bash
# Compare marketplace vs cache
diff -r ~/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN \
        ~/.claude/plugins/cache/$MARKETPLACE/$PLUGIN/$VERSION/
```

**Common Causes**:
1. Missing `plugin.json` manifest
2. Missing `README.md`
3. Empty component directories
4. Invalid JSON in `plugin.json`

**Fix**:
- See [PLUGIN-FIX-BUSINESS-ANALYTICS.md](./PLUGIN-FIX-BUSINESS-ANALYTICS.md) for detailed fix procedure
- Create missing files in cache directory (not marketplace)

### Issue: Plugin validation errors

**Symptoms**:
- `[ERROR] Plugin X has an invalid manifest file`
- Validation errors in debug logs

**Fix**:
```bash
# Check JSON syntax
cat ~/.claude/plugins/cache/$MARKETPLACE/$PLUGIN/$VERSION/.claude-plugin/plugin.json | python3 -m json.tool

# Common JSON errors:
# - Trailing commas
# - Unquoted keys
# - Invalid escape sequences
# - Unrecognized fields (check Claude Code schema)
```

### Issue: Commands not appearing

**Symptoms**:
- Plugin loads successfully
- Skills/agents work
- Commands missing from palette

**Diagnosis**:
```bash
# Check commands directory
ls -la ~/.claude/plugins/cache/$MARKETPLACE/$PLUGIN/$VERSION/commands/

# Each command should be a .md file with YAML frontmatter
```

**Fix**:
- Ensure command files have `.md` extension
- Verify YAML frontmatter has `name:` field
- Check `allowed-tools:` array is valid

---

## Automated Validation Script

Save as `validate-plugin.sh`:

```bash
#!/bin/bash
set -euo pipefail

MARKETPLACE="${1:-claude-code-workflows}"
PLUGIN="${2:?Usage: $0 <marketplace> <plugin-name>}"

MARKETPLACE_DIR="$HOME/.claude/plugins/marketplaces/$MARKETPLACE/plugins/$PLUGIN"
PLUGIN_JSON="$MARKETPLACE_DIR/.claude-plugin/plugin.json"
README="$MARKETPLACE_DIR/README.md"

echo "=== Validating Plugin: $PLUGIN @ $MARKETPLACE ==="
echo

# Check marketplace directory exists
if [[ ! -d "$MARKETPLACE_DIR" ]]; then
  echo "❌ Marketplace directory not found: $MARKETPLACE_DIR"
  exit 1
fi
echo "✓ Marketplace directory exists"

# Check plugin.json
if [[ ! -f "$PLUGIN_JSON" ]]; then
  echo "❌ Missing plugin.json: $PLUGIN_JSON"
  exit 1
fi
echo "✓ plugin.json exists"

# Validate JSON
if ! python3 -m json.tool "$PLUGIN_JSON" > /dev/null 2>&1; then
  echo "❌ Invalid JSON in plugin.json"
  exit 1
fi
echo "✓ plugin.json is valid JSON"

# Check required fields
for field in name version description; do
  if ! grep -q "\"$field\"" "$PLUGIN_JSON"; then
    echo "❌ Missing required field: $field"
    exit 1
  fi
done
echo "✓ plugin.json has required fields"

# Check README
if [[ ! -f "$README" ]]; then
  echo "❌ Missing README.md"
  exit 1
fi
echo "✓ README.md exists"

# Check README has content
if [[ $(wc -l < "$README") -lt 10 ]]; then
  echo "⚠️  README.md is suspiciously short (< 10 lines)"
else
  echo "✓ README.md has content"
fi

# Check for at least one component
HAS_COMPONENTS=false
for component in agents skills commands hooks; do
  if [[ -d "$MARKETPLACE_DIR/$component" ]]; then
    echo "✓ Has $component directory"
    HAS_COMPONENTS=true
  fi
done

if [[ "$HAS_COMPONENTS" == false ]]; then
  echo "⚠️  No component directories found (agents/skills/commands/hooks)"
fi

echo
echo "=== Validation Complete ==="
echo "Plugin $PLUGIN appears to be valid for installation."
```

Usage:
```bash
chmod +x validate-plugin.sh
./validate-plugin.sh claude-code-workflows business-analytics
```

---

## Plugin Structure Reference

### Minimal Valid Plugin

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Required: metadata
├── README.md                 # Required: documentation
└── [agents|skills|commands|hooks]/  # At least one required
    └── [component-file].md
```

### Full Featured Plugin

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json
├── README.md
├── LICENSE
├── .gitignore
├── agents/
│   ├── agent-1.md
│   └── agent-2.md
├── skills/
│   ├── skill-1/
│   │   └── skill-1.md
│   └── skill-2/
│       └── skill-2.md
├── commands/
│   ├── command-1.md
│   └── command-2.md
├── hooks/
│   ├── PreToolUse.md
│   └── PostToolUse.md
└── docs/
    └── examples.md
```

---

## When to Report Upstream

Report to plugin maintainer if:
- [ ] Missing required `plugin.json`
- [ ] Missing `README.md`
- [ ] Invalid JSON in manifest
- [ ] Component directories empty when README claims they exist
- [ ] Commands defined in README but files missing

**Template**: See [PLUGIN-FIX-BUSINESS-ANALYTICS.md](./PLUGIN-FIX-BUSINESS-ANALYTICS.md#reporting-to-maintainer) for issue report template.

---

## Resources

- **Detailed Fix Guide**: [PLUGIN-FIX-BUSINESS-ANALYTICS.md](./PLUGIN-FIX-BUSINESS-ANALYTICS.md)
- **Quick Summary**: [PLUGIN-FIX-SUMMARY.md](./PLUGIN-FIX-SUMMARY.md)
- **Claude Code Docs**: https://docs.anthropic.com/claude/code (if available)
- **Plugin Development**: Check marketplace repository for guidelines

---

**Last Updated**: 2026-01-14
**Maintained By**: guilde-lite project
