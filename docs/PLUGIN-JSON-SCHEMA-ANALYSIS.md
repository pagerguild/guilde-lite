# Plugin.json Schema Analysis

**Date:** 2026-01-15
**Purpose:** Document official Claude Code plugin.json schema and identify gaps in marketplace plugins

---

## Executive Summary

Analysis of the official Claude Code plugin.json schema reveals several missing fields in our marketplace plugins. All 15 plugins in `marketplace/plugins/` currently use a minimal schema with only `name`, `description`, and `author` fields. The official schema supports additional metadata and configuration options that would improve plugin discoverability and functionality.

**Key Findings:**
- **Missing:** `version`, `homepage`, `repository`, `license`, `keywords` fields in all plugins
- **Incomplete:** `author` object missing optional `url` property
- **Opportunity:** Component path customization not utilized
- **Compliant:** Author field correctly uses object format (not string)

---

## Official Plugin.json Schema

### Source Documentation

- [Plugins Reference - Claude Code Docs](https://code.claude.com/docs/en/plugins-reference)
- [Plugin Structure Skill](https://claude-plugins.dev/skills/@anthropics/claude-plugins-official/plugin-structure)

### Required Fields

| Field | Type | Format | Example |
|-------|------|--------|---------|
| `name` | string | kebab-case, no spaces | `"deployment-tools"` |

**Note:** While documentation lists only `name` as strictly required, `description` is effectively required for plugin discovery and user experience.

### Core Metadata Fields (Optional but Recommended)

| Field | Type | Format | Purpose | Example |
|-------|------|--------|---------|---------|
| `version` | string | Semantic versioning (MAJOR.MINOR.PATCH) | Track releases, manage updates | `"1.2.0"` |
| `description` | string | Brief explanation | Plugin manager display | `"Multi-stage code review workflow"` |
| `author` | object | See Author Object section | Attribution, contact | `{"name": "...", "email": "..."}` |
| `homepage` | string | URL | Documentation link | `"https://docs.example.com"` |
| `repository` | string | URL | Source code link | `"https://github.com/user/repo"` |
| `license` | string | SPDX identifier | Legal clarity | `"MIT"`, `"Apache-2.0"` |
| `keywords` | array | String array | Discovery, categorization | `["tdd", "testing", "workflow"]` |

### Author Object Structure

```json
{
  "name": "Author Name",          // Optional but recommended
  "email": "author@example.com",  // Optional
  "url": "https://github.com/author"  // Optional
}
```

**Current Usage in Marketplace:**
```json
{
  "name": "pagerguild",
  "email": "team@pagerguild.dev"
  // Missing: "url" property
}
```

### Component Path Fields (Optional)

| Field | Type | Format | Purpose |
|-------|------|--------|---------|
| `commands` | string\|array | Relative paths starting with `./` | Additional command files beyond `commands/` |
| `agents` | string\|array | Relative paths starting with `./` | Additional agent files beyond `agents/` |
| `skills` | string\|array | Relative paths starting with `./` | Additional skill directories beyond `skills/` |
| `hooks` | string\|object | Path or inline config | Hook configuration |
| `mcpServers` | string\|object | Path or inline config | MCP server configuration |
| `outputStyles` | string\|array | Relative paths | Custom output styles |
| `lspServers` | string\|object | Path or inline config | Language Server Protocol config |

**Key Behavior:** Custom paths **supplement** (not replace) default directories.

### Environment Variables

| Variable | Purpose | Example Usage |
|----------|---------|---------------|
| `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin directory | Used in hooks, MCP servers for correct paths |

---

## Current Marketplace Plugin Analysis

### Sample Plugin.json Files

All 15 plugins follow this minimal structure:

```json
{
  "name": "plugin-name",
  "description": "Brief description...",
  "author": {
    "name": "pagerguild",
    "email": "team@pagerguild.dev"
  }
}
```

**Plugins Analyzed:**
1. agentic-flow
2. code-review-pipeline
3. conductor-workflows
4. context-preservation
5. diagram-generation
6. docs-sync
7. exploration-agents
8. implementation-agents
9. jj-tools
10. microsoft-agents
11. mise-tools
12. multi-agent-review
13. release-research
14. spec-agents
15. tdd-automation

### Gap Analysis

| Field | Status | Impact | Priority |
|-------|--------|--------|----------|
| `version` | ❌ Missing | **HIGH** - No version tracking, update management broken | P0 |
| `homepage` | ❌ Missing | **MEDIUM** - No documentation links | P1 |
| `repository` | ❌ Missing | **MEDIUM** - No source code links | P1 |
| `license` | ❌ Missing | **MEDIUM** - Legal ambiguity | P1 |
| `keywords` | ❌ Missing | **HIGH** - Poor discoverability | P0 |
| `author.url` | ❌ Missing | **LOW** - Nice to have | P2 |
| Component paths | ❌ Not used | **LOW** - Not needed yet | P3 |

---

## Impact Assessment

### Critical Gaps (P0)

#### 1. Missing Version Field

**Problem:**
- No version tracking in plugin.json files
- Cannot manage plugin updates
- No way to communicate breaking changes
- Marketplace cannot enforce version compatibility

**Impact:**
- Users cannot track which version they have installed
- No semantic versioning for backward compatibility
- Difficult to coordinate updates across plugins

**Recommendation:**
```json
{
  "name": "plugin-name",
  "version": "1.0.0",  // Add this
  ...
}
```

**Version Strategy:**
- Start at `1.0.0` for all existing plugins (they're production-ready)
- Use semantic versioning: MAJOR.MINOR.PATCH
- Document version in plugin README.md

#### 2. Missing Keywords

**Problem:**
- Plugins not discoverable by topic
- No categorization in marketplace
- Users can't find plugins by use case

**Impact:**
- Reduced plugin adoption
- Poor user experience in marketplace browsing
- Difficult to find related plugins

**Recommendation:**

```json
{
  "name": "code-review-pipeline",
  "keywords": ["code-review", "quality", "testing", "workflow"],
  ...
}
```

**Keyword Strategy by Plugin:**

| Plugin | Suggested Keywords |
|--------|-------------------|
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

### Important Gaps (P1)

#### 3. Missing Homepage

**Problem:**
- No link to documentation
- Users must search for docs manually

**Recommendation:**
```json
{
  "homepage": "https://github.com/pagerguild/guilde-plugins/tree/main/plugins/plugin-name",
  ...
}
```

#### 4. Missing Repository

**Problem:**
- No link to source code
- Cannot easily report issues or contribute

**Recommendation:**
```json
{
  "repository": "https://github.com/pagerguild/guilde-plugins",
  ...
}
```

#### 5. Missing License

**Problem:**
- Legal ambiguity
- Users unsure if they can use/modify
- Cannot determine compatibility with their projects

**Recommendation:**
```json
{
  "license": "MIT",  // Or Apache-2.0, BSD-3-Clause, etc.
  ...
}
```

**License Decision:** Need to determine which license pagerguild uses for these plugins.

### Minor Gaps (P2)

#### 6. Incomplete Author Object

**Current:**
```json
{
  "author": {
    "name": "pagerguild",
    "email": "team@pagerguild.dev"
  }
}
```

**Enhanced:**
```json
{
  "author": {
    "name": "pagerguild",
    "email": "team@pagerguild.dev",
    "url": "https://github.com/pagerguild"
  }
}
```

---

## Recommended Complete Schema

### Template for All Plugins

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief plugin description focusing on value proposition",
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

### Example: code-review-pipeline

```json
{
  "name": "code-review-pipeline",
  "version": "1.0.0",
  "description": "Multi-stage code review workflow with parallel agent reviews and test generation.",
  "author": {
    "name": "pagerguild",
    "email": "team@pagerguild.dev",
    "url": "https://github.com/pagerguild"
  },
  "homepage": "https://github.com/pagerguild/guilde-plugins/tree/main/plugins/code-review-pipeline",
  "repository": "https://github.com/pagerguild/guilde-plugins",
  "license": "MIT",
  "keywords": ["code-review", "quality", "testing", "workflow", "agents"]
}
```

### Example: tdd-automation

```json
{
  "name": "tdd-automation",
  "version": "1.0.0",
  "description": "TDD workflow management with phase tracking, test validation, and coverage reporting.",
  "author": {
    "name": "pagerguild",
    "email": "team@pagerguild.dev",
    "url": "https://github.com/pagerguild"
  },
  "homepage": "https://github.com/pagerguild/guilde-plugins/tree/main/plugins/tdd-automation",
  "repository": "https://github.com/pagerguild/guilde-plugins",
  "license": "MIT",
  "keywords": ["tdd", "testing", "workflow", "automation", "coverage"]
}
```

---

## Versioning Strategy

### Semantic Versioning Rules

| Version Component | When to Increment | Examples |
|------------------|-------------------|----------|
| **MAJOR** (X.0.0) | Breaking changes, incompatible API changes | Rename command, remove agent, change skill API |
| **MINOR** (0.X.0) | New features, backward-compatible additions | Add new agent, add new command, enhance skill |
| **PATCH** (0.0.X) | Bug fixes, documentation updates | Fix command bug, update docs, fix typo |

### Initial Version Assignment

All existing plugins should start at `1.0.0` because:
1. They are production-ready (in use)
2. They have complete functionality
3. They are being released to marketplace
4. Starting at 1.0.0 signals stability

**Pre-release versions** (0.x.x) should only be used for:
- Experimental plugins
- Incomplete implementations
- Prototypes not ready for production

### Version Synchronization

**Question:** Should all plugins share the same version number or version independently?

**Option A: Independent Versioning** (Recommended)
- Each plugin has its own version
- Plugins evolve at different rates
- Clear which plugins have updates

**Option B: Synchronized Versioning**
- All plugins share marketplace version
- Simpler mental model
- May result in unnecessary version bumps

**Recommendation:** Use independent versioning. Each plugin should track its own changes.

---

## Implementation Plan

### Phase 1: Add Critical Fields (P0)

**Target:** All 15 plugins
**Timeline:** Immediate

For each plugin:
1. Add `version: "1.0.0"`
2. Add appropriate `keywords` array (3-5 keywords)

**Estimated effort:** 30 minutes (batch operation)

### Phase 2: Add Important Fields (P1)

**Target:** All 15 plugins
**Timeline:** Same session as Phase 1

For each plugin:
1. Add `homepage` pointing to GitHub plugin directory
2. Add `repository` pointing to guilde-plugins repo
3. Add `license` (need to confirm which license to use)

**Estimated effort:** 15 minutes (batch operation)

### Phase 3: Enhance Author Field (P2)

**Target:** All 15 plugins
**Timeline:** Optional, can be deferred

For each plugin:
1. Add `url: "https://github.com/pagerguild"` to author object

**Estimated effort:** 5 minutes (batch operation)

### Phase 4: Update Marketplace Validation

**Target:** marketplace.json and validation scripts
**Timeline:** After plugin updates

1. Update marketplace.json with new plugin metadata
2. Add schema validation for required fields
3. Document versioning policy

**Estimated effort:** 1 hour

---

## Validation Checklist

Use this checklist when creating or updating plugin.json files:

### Required Fields
- [ ] `name` - kebab-case, no spaces, unique
- [ ] `description` - Clear, concise value proposition

### Recommended Fields
- [ ] `version` - Semantic version (X.Y.Z)
- [ ] `author.name` - Organization or person name
- [ ] `author.email` - Contact email
- [ ] `author.url` - GitHub profile or website
- [ ] `homepage` - Link to documentation
- [ ] `repository` - Link to source code
- [ ] `license` - SPDX license identifier
- [ ] `keywords` - 3-5 relevant keywords for discovery

### Format Validation
- [ ] JSON is valid (use `jq . plugin.json`)
- [ ] All paths (if present) start with `./`
- [ ] Author is object, not string
- [ ] Version is string, not number
- [ ] Keywords is array, not string

### Content Quality
- [ ] Description is user-focused (value, not implementation)
- [ ] Keywords match plugin functionality
- [ ] Version follows semantic versioning
- [ ] License matches repository license

---

## References

### Official Documentation
- [Plugins Reference - Claude Code Docs](https://code.claude.com/docs/en/plugins-reference)
- [Plugin Structure Skill](https://claude-plugins.dev/skills/@anthropics/claude-plugins-official/plugin-structure)
- [Discover Plugins - Claude Code Docs](https://code.claude.com/docs/en/discover-plugins)

### Related Repositories
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
- [anthropics/claude-code](https://github.com/anthropics/claude-code)

### Internal Documentation
- `marketplace/.claude-plugin/marketplace.json` - Marketplace manifest
- `marketplace/plugins/*/README.md` - Individual plugin documentation

---

## Appendix A: Complete Field Reference

### Official Schema Fields (Comprehensive)

```typescript
interface PluginManifest {
  // Required
  name: string;                    // kebab-case identifier

  // Core metadata (highly recommended)
  version?: string;                // Semantic version
  description?: string;            // Brief explanation
  author?: {                       // Author information
    name?: string;
    email?: string;
    url?: string;
  };
  homepage?: string;               // Documentation URL
  repository?: string;             // Source code URL
  license?: string;                // SPDX identifier
  keywords?: string[];             // Discovery tags

  // Component paths (optional, supplement defaults)
  commands?: string | string[];    // Additional command files
  agents?: string | string[];      // Additional agent files
  skills?: string | string[];      // Additional skill directories
  hooks?: string | HooksConfig;    // Hook configuration
  mcpServers?: string | McpConfig; // MCP server configuration
  outputStyles?: string | string[]; // Custom output styles
  lspServers?: string | LspConfig; // LSP configuration
}
```

### Type Constraints

| Field | Allowed Types | Notes |
|-------|---------------|-------|
| name | string | Must be kebab-case |
| version | string | Must follow semver (not number) |
| description | string | User-facing explanation |
| author | object | Not string (common mistake) |
| keywords | array | Not comma-separated string |
| Component paths | string \| array | Must start with `./` |

---

## Appendix B: Keywords Taxonomy

### Category-Based Keywords

**Workflow & Orchestration:**
- workflow, orchestration, automation, coordination

**Development & Testing:**
- tdd, testing, code-review, quality, debugging

**Documentation:**
- documentation, docs, diagrams, visualization

**Version Control:**
- git, jujutsu, vcs, version-control

**Agent Systems:**
- agents, multi-agent, ai, automation

**Tools & Environment:**
- tools, setup, environment, configuration

**Architecture & Planning:**
- architecture, planning, specification, design

**Integration:**
- integration, mcp, framework, api

### Usage Guidelines

1. **Use 3-5 keywords per plugin** - Balance discoverability with focus
2. **Prioritize specificity** - "tdd" over "development"
3. **Include use case** - What problem does it solve?
4. **Include technology** - What tools/frameworks does it work with?
5. **Avoid redundancy** - Don't repeat plugin name in keywords

---

## Appendix C: License Options

### Common Open Source Licenses

| License | Permissions | Conditions | Limitations |
|---------|-------------|------------|-------------|
| MIT | Commercial use, Modification, Distribution | License and copyright notice | Liability, Warranty |
| Apache-2.0 | Commercial use, Modification, Distribution, Patent use | License and copyright notice, State changes | Trademark use, Liability, Warranty |
| BSD-3-Clause | Commercial use, Modification, Distribution | License and copyright notice | Liability, Warranty |

**Recommendation for pagerguild plugins:** MIT (simplest, most permissive, widely understood)

---

## Document Metadata

**Created:** 2026-01-15
**Author:** Claude Code (Sonnet 4.5)
**Version:** 1.0.0
**Status:** Complete - Ready for Implementation
**Related Files:**
- `marketplace/plugins/*/. claude-plugin/plugin.json` (15 files to update)
- `marketplace/.claude-plugin/marketplace.json` (marketplace manifest)
- `docs/MARKETPLACE-VALIDATION.md` (validation documentation)
