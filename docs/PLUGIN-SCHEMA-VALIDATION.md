# Plugin & Marketplace Schema Validation

**Last Updated:** 2026-01-15
**Status:** Reference Documentation

---

## Schema Documentation Sources

### Official Documentation

| Schema | Documentation URL |
|--------|-------------------|
| Plugin Manifest | https://code.claude.com/docs/en/plugins-reference#plugin-manifest-schema |
| Complete Plugin Schema | https://code.claude.com/docs/en/plugins-reference#complete-schema |
| Marketplace Schema | https://code.claude.com/docs/en/plugin-marketplaces#marketplace-schema |

### Reference Implementations

| Type | Location |
|------|----------|
| Official Marketplace | https://github.com/anthropics/claude-plugins-official/blob/main/.claude-plugin/marketplace.json |
| Official Plugins | https://github.com/anthropics/claude-code/tree/main/plugins |

---

## Schema URL Issue (IMPORTANT)

### The `$schema` Reference

Our `marketplace.json` and the official marketplace both use:

```json
"$schema": "https://anthropic.com/claude-code/marketplace.schema.json"
```

### Finding: URL Returns 404

**Date Discovered:** 2026-01-15

The schema URL `https://anthropic.com/claude-code/marketplace.schema.json` returns a 404 "Not Found" response. This means:

1. **External JSON Schema validation is NOT working** - The `$schema` reference is decorative
2. **No downloadable JSON Schema file exists** at that URL
3. **Cannot use standard JSON Schema validators** (ajv, jsonschema, etc.) against this URL

### What DOES Work

The `claude plugin validate` CLI command has **internal validation** that enforces the schema:

```bash
# This works - uses built-in validation rules
claude plugin validate ./marketplace
claude plugin validate ./marketplace/plugins/plugin-name
```

The CLI validates:
- Required fields: `name`, `owner`, `plugins` (marketplace), `name` (plugin)
- Field types (string, object, array)
- Plugin entry structure within marketplace
- Rejects unknown fields

---

## Validation Methods

### Method 1: CLI Validation (Recommended)

```bash
# Validate marketplace
claude plugin validate ./marketplace

# Validate individual plugin
claude plugin validate ./marketplace/plugins/plugin-name

# Validate all plugins
for plugin in marketplace/plugins/*/; do
  claude plugin validate "$plugin"
done
```

### Method 2: SDK Load Testing

```python
from claude_agent_sdk import query, ClaudeAgentOptions, SystemMessage

options = ClaudeAgentOptions(
    plugins=[{"type": "local", "path": "./marketplace/plugins/plugin-name"}]
)

async for message in query(prompt="test", options=options):
    if isinstance(message, SystemMessage) and message.subtype == "init":
        # Verify plugins loaded
        print(message.data.get("plugins"))
        print(message.data.get("slash_commands"))
```

### Method 3: Manual Schema Validation (If Schema Available)

If a local schema file is created:

```bash
# Using ajv-cli
ajv validate -s schema/marketplace.schema.json -d marketplace/.claude-plugin/marketplace.json

# Using Python jsonschema
python -c "
import json
from jsonschema import validate
schema = json.load(open('schema/marketplace.schema.json'))
data = json.load(open('marketplace/.claude-plugin/marketplace.json'))
validate(data, schema)
"
```

---

## Marketplace Schema (Derived)

Based on CLI validation behavior and documentation:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["name", "owner", "plugins"],
  "properties": {
    "$schema": {
      "type": "string",
      "description": "Schema URL (currently non-functional)"
    },
    "name": {
      "type": "string",
      "description": "Marketplace identifier"
    },
    "description": {
      "type": "string",
      "description": "Marketplace description"
    },
    "owner": {
      "type": "object",
      "required": ["name", "email"],
      "properties": {
        "name": { "type": "string" },
        "email": { "type": "string", "format": "email" }
      }
    },
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$",
      "description": "Semver version"
    },
    "plugins": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["name", "source"],
        "properties": {
          "name": { "type": "string" },
          "description": { "type": "string" },
          "version": { "type": "string" },
          "author": {
            "type": "object",
            "properties": {
              "name": { "type": "string" },
              "email": { "type": "string" }
            }
          },
          "source": {
            "oneOf": [
              { "type": "string" },
              {
                "type": "object",
                "properties": {
                  "type": { "enum": ["url"] },
                  "url": { "type": "string", "format": "uri" }
                }
              }
            ]
          },
          "category": { "type": "string" },
          "tags": { "type": "array", "items": { "type": "string" } },
          "homepage": { "type": "string", "format": "uri" },
          "strict": { "type": "boolean" }
        }
      }
    }
  },
  "additionalProperties": false
}
```

---

## Plugin Schema (Derived)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["name"],
  "properties": {
    "name": {
      "type": "string",
      "description": "Plugin identifier"
    },
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$",
      "description": "Semver version (recommended)"
    },
    "description": {
      "type": "string",
      "description": "Plugin description (recommended)"
    },
    "author": {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "email": { "type": "string", "format": "email" }
      },
      "description": "Author info (recommended)"
    },
    "commands": { "type": "string", "description": "Path to commands directory" },
    "agents": { "type": "string", "description": "Path to agents directory" },
    "skills": { "type": "string", "description": "Path to skills directory" },
    "hooks": { "type": "string", "description": "Path to hooks file/directory" },
    "mcpServers": { "type": "string", "description": "Path to MCP config" }
  },
  "additionalProperties": false
}
```

---

## Directory Structure

### Marketplace Structure

```
marketplace/
├── .claude-plugin/
│   └── marketplace.json      # Required: marketplace manifest
└── plugins/
    ├── plugin-one/
    │   ├── .claude-plugin/
    │   │   └── plugin.json   # Required: plugin manifest
    │   ├── commands/         # Optional: slash commands
    │   ├── agents/           # Optional: subagent definitions
    │   ├── skills/           # Optional: auto-triggered skills
    │   ├── hooks/            # Optional: event handlers
    │   └── .mcp.json         # Optional: MCP servers
    └── plugin-two/
        └── ...
```

### Plugin Component Structure

| Component | Location | File Pattern |
|-----------|----------|--------------|
| Commands | `commands/` | `*.md` |
| Agents | `agents/` | `*.md` |
| Skills | `skills/{name}/` | `SKILL.md` |
| Hooks | `hooks/` | `hooks.json` or `*.json` |
| MCP Servers | `.mcp.json` | JSON config |

---

## Validation Test Results (2026-01-15)

### Summary

| Test | Status | Details |
|------|--------|---------|
| Marketplace Manifest | ⚠️ Pass | 1 warning (metadata.description) |
| Root Plugin | ✅ Pass | No issues |
| 15 Marketplace Plugins | ⚠️ Pass | 15 warnings (missing version) |
| SDK Plugin Loading | ✅ Pass | 15/15 loaded |
| Component Discovery | ✅ Pass | 38 slash commands |

### Component Inventory

| Type | Count |
|------|-------|
| Plugins | 15 |
| Commands | 15 |
| Skills | 23 |
| Agents | 16 |
| **Total** | **54 components** |

### Warnings to Address

1. All 15 plugins missing `version` field in individual `plugin.json`
2. Marketplace has `metadata.description` warning (likely CLI validation quirk)

---

## Recommendations

### Short-term

1. **Add `version` field** to all plugin.json files (fixes warnings)
2. **Use CLI validation** as primary validation method
3. **Run SDK load test** to verify runtime behavior

### Long-term

1. **Create local schema files** for JSON Schema validation in CI
2. **File issue** with Anthropic about non-functional `$schema` URL
3. **Add validation to CI/CD** pipeline

---

## Official Plugin-Dev Patterns (Research: 2026-01-15)

Research source: https://github.com/anthropics/claude-plugins-official/tree/main/plugins/plugin-dev

### Plugin.json (Minimal Required)

The official plugin-dev plugin uses a minimal plugin.json:

```json
{
  "name": "plugin-name",
  "description": "Brief description",
  "author": {
    "name": "Author Name"
  }
}
```

**Required:** `name`
**Recommended:** `description`, `author`
**Optional:** `version`, `keywords`, `homepage`, `repository`, `license`

### Component Frontmatter Patterns

#### Skills (SKILL.md)

```yaml
---
name: skill-name
description: When and how to use this skill
version: 1.0.0
---
```

**Structure:**
- Main file: `skills/{skill-name}/SKILL.md` (~1500-2000 words)
- Additional content: `skills/{skill-name}/references/*.md`
- Progressive disclosure: SKILL.md contains essential info, references/ has deep details

#### Commands (*.md)

```yaml
---
description: What this command does
argument-hint: <subcommand> [options]
allowed-tools: ["Bash", "Read", "Write"]
model: sonnet
---
```

**Fields:**
- `description`: Brief purpose (required)
- `argument-hint`: Usage pattern for arguments
- `allowed-tools`: Tools the command can use
- `model`: Preferred model tier (haiku/sonnet/opus)

#### Agents (*.md)

```yaml
---
name: agent-name
description: Agent purpose and capabilities
model: sonnet
color: blue
tools: ["Read", "Grep", "Glob"]
---
```

**Fields:**
- `name`: Agent identifier (required)
- `description`: When to use this agent (required)
- `model`: Model tier (haiku/sonnet/opus)
- `color`: UI display color
- `tools`: Available tools list

### Auto-Discovery Mechanism

Components are auto-discovered by directory structure:

| Component | Discovery Pattern |
|-----------|-------------------|
| Commands | `commands/*.md` |
| Skills | `skills/*/SKILL.md` |
| Agents | `agents/*.md` |
| Hooks | `hooks/hooks.json` or `hooks/*.json` |

### Portable Paths

Use `${CLAUDE_PLUGIN_ROOT}` for paths that work regardless of installation location:

```yaml
allowed-tools:
  - name: Read
    paths:
      - "${CLAUDE_PLUGIN_ROOT}/references/**/*.md"
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Plugin directories | kebab-case | `my-plugin` |
| Skill directories | kebab-case | `skill-name` |
| Command files | kebab-case | `my-command.md` |
| Agent files | kebab-case | `my-agent.md` |

### Gaps in Our Marketplace

Based on plugin-dev patterns, our 15 plugins are missing:

| Field | Status | Action |
|-------|--------|--------|
| `version` | Missing in all | Add `"version": "1.0.0"` |
| `keywords` | Missing in all | Add relevant tags |
| `homepage` | Missing in all | Optional |
| `repository` | Missing in all | Optional |
| `license` | Missing in all | Optional |

### Validation Using plugin-dev

The plugin-dev plugin includes a `plugin-validator` agent:

```bash
# Use the plugin-validator agent
Task tool with subagent_type: "plugin-dev:plugin-validator"
prompt: "Validate the marketplace/plugins/my-plugin plugin"
```

This agent checks:
- Plugin.json structure and required fields
- Component frontmatter validity
- Directory structure compliance
- Naming conventions

---

## Related Documentation

- [MULTI-AGENT-WORKFLOW.md](./MULTI-AGENT-WORKFLOW.md) - Workflow architecture
- [conductor/workflow.md](../conductor/workflow.md) - Development workflow
- [.claude/rules/quality-gates.md](../.claude/rules/quality-gates.md) - Quality gates
- [plugin-dev official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/plugin-dev) - Official patterns
