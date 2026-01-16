# Plugin.json Gaps - Quick Summary

**Date:** 2026-01-15

---

## Current State

All 15 marketplace plugins use minimal schema:

```json
{
  "name": "plugin-name",
  "description": "...",
  "author": {"name": "pagerguild", "email": "team@pagerguild.dev"}
}
```

---

## Missing Fields

### Critical (P0)

| Field | Impact | Fix |
|-------|--------|-----|
| `version` | No update management | Add `"version": "1.0.0"` |
| `keywords` | Poor discoverability | Add 3-5 relevant keywords array |

### Important (P1)

| Field | Impact | Fix |
|-------|--------|-----|
| `homepage` | No docs link | Add GitHub plugin directory URL |
| `repository` | No source link | Add `"repository": "https://github.com/pagerguild/guilde-plugins"` |
| `license` | Legal ambiguity | Add `"license": "MIT"` (confirm) |

### Minor (P2)

| Field | Impact | Fix |
|-------|--------|-----|
| `author.url` | Nice to have | Add `"url": "https://github.com/pagerguild"` |

---

## Recommended Complete Schema

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief plugin description",
  "author": {
    "name": "pagerguild",
    "email": "team@pagerguild.dev",
    "url": "https://github.com/pagerguild"
  },
  "homepage": "https://github.com/pagerguild/guilde-plugins/tree/main/plugins/plugin-name",
  "repository": "https://github.com/pagerguild/guilde-plugins",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2", "keyword3"]
}
```

---

## Suggested Keywords by Plugin

| Plugin | Keywords |
|--------|----------|
| agentic-flow | `["multi-agent", "coordination", "jujutsu", "workflow"]` |
| code-review-pipeline | `["code-review", "quality", "testing", "workflow"]` |
| conductor-workflows | `["workflow", "orchestration", "project-management"]` |
| context-preservation | `["context", "error-recovery", "workflow"]` |
| diagram-generation | `["diagrams", "visualization", "mermaid", "c4"]` |
| docs-sync | `["documentation", "sync", "validation"]` |
| exploration-agents | `["exploration", "research", "agents"]` |
| implementation-agents | `["implementation", "development", "agents"]` |
| jj-tools | `["jujutsu", "version-control", "vcs"]` |
| microsoft-agents | `["microsoft", "agents", "python", "framework"]` |
| mise-tools | `["mise", "tools", "environment", "setup"]` |
| multi-agent-review | `["multi-agent", "review", "workflow"]` |
| release-research | `["releases", "research", "updates"]` |
| spec-agents | `["specification", "planning", "agents"]` |
| tdd-automation | `["tdd", "testing", "workflow", "automation"]` |

---

## Implementation Steps

1. **Decide on license** - MIT recommended
2. **Batch update all 15 plugins** - Add version, keywords, homepage, repository, license
3. **Update marketplace.json** - Sync with new plugin metadata
4. **Validate** - Run `jq . plugin.json` on all files

**Estimated time:** 1 hour for all 15 plugins

---

## Full Analysis

See [PLUGIN-JSON-SCHEMA-ANALYSIS.md](./PLUGIN-JSON-SCHEMA-ANALYSIS.md) for complete details.
