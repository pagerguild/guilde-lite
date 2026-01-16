---
name: release-researcher
description: |
  Research latest releases from GitHub repositories relevant to guilde-lite.
  Use when:
  - User asks to check for updates
  - Starting a new development phase
  - Periodic maintenance review
  - Investigating compatibility issues
  - User runs /research-releases command

  Do NOT use for:
  - General GitHub searches unrelated to this project
  - Searching for new libraries/tools (use web search)
  - Code review or security audits
---

# Release Researcher Skill

## Purpose

Systematically research and analyze releases from repositories that impact the guilde-lite multi-agent workflow system. Provides actionable update recommendations.

## Tracked Repositories

### Tier 1: Critical (Check Weekly)

| Repository | What to Watch | Impact Area |
|------------|---------------|-------------|
| `anthropics/claude-code` | Tags, releases | Core CLI functionality |
| `anthropics/claude-plugins-official` | Plugin updates | Plugin patterns, hooks |
| `gemini-cli-extensions/conductor` | Releases | Conductor pattern |

### Tier 2: Important (Check Monthly)

| Repository | What to Watch | Impact Area |
|------------|---------------|-------------|
| `anthropics/skills` | New skills, patterns | Skill packaging |
| `anthropics/anthropic-cookbook` | Multi-agent examples | Agent patterns |
| `modelcontextprotocol/servers` | MCP updates | Tool integrations |

### Tier 3: Reference (Check Quarterly)

| Repository | What to Watch | Impact Area |
|------------|---------------|-------------|
| `jj-vcs/jj` | Releases | VCS integration |
| `mise-plugins/*` | Plugin updates | Runtime management |

## Research Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    RELEASE RESEARCH WORKFLOW                     │
│                                                                   │
│  Step 1: Fetch Current State                                     │
│  ├── Read conductor/tech-stack.md for tracked versions           │
│  ├── Read .claude-plugin/plugin.json for compatibility           │
│  └── Note last research date if tracked                          │
│                                                                   │
│  Step 2: Query Repositories                                      │
│  ├── Use GitHub MCP tools for release data                       │
│  ├── Fallback to WebFetch for release pages                      │
│  └── Extract version, date, changelog highlights                 │
│                                                                   │
│  Step 3: Analyze Changes                                         │
│  ├── Compare versions (current vs latest)                        │
│  ├── Identify breaking changes from changelogs                   │
│  ├── Flag deprecations affecting our patterns                    │
│  └── Note new features we could adopt                            │
│                                                                   │
│  Step 4: Generate Recommendations                                │
│  ├── Prioritize by impact (critical/high/medium/low)             │
│  ├── Map changes to affected components                          │
│  ├── Estimate update effort                                      │
│  └── Create actionable update tasks                              │
│                                                                   │
│  Step 5: Output Report                                           │
│  ├── Summary with key findings                                   │
│  ├── Detailed per-repository analysis                            │
│  ├── Impact matrix                                               │
│  └── Recommended next steps                                      │
└─────────────────────────────────────────────────────────────────┘
```

## GitHub API Patterns

### Using MCP Tools (Preferred)

```typescript
// Get latest release
mcp__plugin_github_github__get_latest_release({
  owner: "anthropics",
  repo: "claude-code"
})

// List recent releases
mcp__plugin_github_github__list_releases({
  owner: "gemini-cli-extensions",
  repo: "conductor",
  perPage: 5
})

// List tags (for repos without releases)
mcp__plugin_github_github__list_tags({
  owner: "anthropics",
  repo: "claude-code",
  perPage: 10
})

// Get specific tag details
mcp__plugin_github_github__get_tag({
  owner: "anthropics",
  repo: "skills",
  tag: "v1.2.0"
})
```

### Fallback: WebFetch

```typescript
// Fetch release page
WebFetch({
  url: "https://github.com/anthropics/claude-code/releases",
  prompt: "Extract the latest 3 releases with version numbers, dates, and key changes"
})
```

## Version Comparison

### Semantic Versioning Analysis

```
Current: v1.2.3
Latest:  v2.0.0
         ^ Major bump = Breaking changes likely

Current: v1.2.3
Latest:  v1.3.0
           ^ Minor bump = New features, backward compatible

Current: v1.2.3
Latest:  v1.2.5
             ^ Patch bump = Bug fixes only
```

### Priority Matrix

| Version Jump | Breaking Changes | Priority |
|--------------|------------------|----------|
| Major (X.0.0) | Likely | Critical |
| Minor (0.X.0) | Possible | High |
| Patch (0.0.X) | Unlikely | Medium |
| Pre-release | Unknown | Low |

## Impact Mapping

### Component Impact Table

| Change Type | Affected Files |
|-------------|----------------|
| Hook API changes | `.claude/settings.json`, hookify rules |
| Skill format changes | `.claude/skills/*/SKILL.md` |
| Agent tool changes | `.claude/agents/*.md` |
| Plugin manifest changes | `.claude-plugin/plugin.json` |
| MCP protocol changes | `.mcp.json` |
| Conductor pattern changes | `.claude/commands/conductor-*.md` |

## Report Template

```markdown
# Release Research Report

**Generated:** YYYY-MM-DD HH:MM
**Scope:** [all/claude/conductor/plugins/skills]
**Researcher:** release-researcher skill

## Executive Summary

- **Updates Available:** X repositories
- **Critical Updates:** X
- **Breaking Changes:** X
- **New Features:** X

## Detailed Findings

### anthropics/claude-code

| Metric | Value |
|--------|-------|
| Current Version | vX.Y.Z |
| Latest Version | vA.B.C |
| Days Behind | N |
| Breaking Changes | Yes/No |

**Changelog Highlights:**
- [Feature/Fix description]

**Required Actions:**
- [ ] Update CLAUDE.md section on X
- [ ] Modify hook configuration for Y

---

[Repeat for each repository]

## Impact Analysis

| Repository | Priority | Effort | Components Affected |
|------------|----------|--------|---------------------|
| claude-code | High | 2h | CLAUDE.md, hooks |
| conductor | Medium | 1h | Commands |

## Recommended Update Order

1. **[Repository]** - [Reason for priority]
2. **[Repository]** - [Reason]

## Next Research Date

Recommended: [Date based on findings]
```

## Quick Actions

### Full Research
```
/research-releases
```

### Scoped Research
```
/research-releases claude
/research-releases conductor
/research-releases plugins
```

### After Research

1. Review report for critical updates
2. Create conductor track if major updates needed
3. Update `conductor/tech-stack.md` with new versions
4. Update affected components
5. Run validation: `bash scripts/validate-workflow.sh`

## Related Files

- `conductor/tech-stack.md` - Current version tracking
- `.claude-plugin/plugin.json` - Plugin compatibility
- `docs/MULTI-AGENT-WORKFLOW.md` - Documented patterns
- `.claude/commands/research-releases.md` - Command definition
