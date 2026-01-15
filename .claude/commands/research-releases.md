---
name: research-releases
description: Research latest releases from relevant GitHub repositories to identify updates for guilde-lite
arguments:
  - name: scope
    description: "Scope of research: all, claude, conductor, plugins, skills"
    required: false
    default: "all"
---

# Research Releases Command

Research the latest releases from repositories relevant to guilde-lite multi-agent workflows.

## Repositories to Check

### Core Claude Code
- **claude-code**: https://github.com/anthropics/claude-code/tags
  - Check for new features, hooks API changes, agent improvements
  - Impact: Core functionality, may require CLAUDE.md updates

### Official Plugins & Skills
- **claude-plugins-official**: https://github.com/anthropics/claude-plugins-official
  - Check for new plugins, updated patterns, deprecations
  - Impact: Plugin structure, hookify rules, skill patterns

- **skills**: https://github.com/anthropics/skills
  - Check for new skill templates, best practices
  - Impact: Skill packaging, progressive disclosure patterns

### Conductor Pattern
- **gemini-conductor**: https://github.com/gemini-cli-extensions/conductor/releases
  - Check for conductor pattern updates, phase management
  - Impact: Conductor commands, track management

### Additional Relevant Repos
- **anthropic-cookbook**: https://github.com/anthropics/anthropic-cookbook
  - Check for new multi-agent patterns, orchestration examples
  - Impact: Agent definitions, workflow patterns

- **model-context-protocol**: https://github.com/modelcontextprotocol/servers
  - Check for MCP server updates, new integrations
  - Impact: MCP configuration, tool integrations

## Instructions

Based on the scope argument ($ARGUMENTS.scope), research the relevant repositories:

### If scope is "all" or unspecified:
1. Fetch releases/tags from ALL repositories listed above
2. Compare versions against what's documented in `conductor/tech-stack.md`
3. Identify breaking changes, new features, and deprecations
4. Generate update recommendations

### If scope is "claude":
Focus only on claude-code tags and anthropic repositories

### If scope is "conductor":
Focus only on gemini-conductor releases

### If scope is "plugins":
Focus only on claude-plugins-official

### If scope is "skills":
Focus only on skills repository

## Output Format

Generate a report with:

```markdown
# Release Research Report

**Date:** [Current date]
**Scope:** [Scope parameter]

## Summary
[Brief overview of findings]

## Updates Found

### [Repository Name]
- **Latest Version:** vX.Y.Z
- **Current in Project:** vA.B.C (or "not tracked")
- **Release Date:** YYYY-MM-DD
- **Breaking Changes:** [Yes/No]

**Key Changes:**
- [Change 1]
- [Change 2]

**Recommended Actions:**
- [ ] [Action item 1]
- [ ] [Action item 2]

## Impact Analysis

| Repository | Update Priority | Affected Components |
|------------|-----------------|---------------------|
| ... | High/Medium/Low | ... |

## Next Steps
[Prioritized list of updates to make]
```

## Research Approach

1. Use GitHub MCP tools if available:
   ```
   mcp__plugin_github_github__list_releases
   mcp__plugin_github_github__list_tags
   mcp__plugin_github_github__get_latest_release
   ```

2. For repositories without MCP access, use WebFetch to check release pages

3. Cross-reference findings with:
   - `conductor/tech-stack.md` - Current versions
   - `.claude-plugin/plugin.json` - Plugin compatibility
   - `docs/MULTI-AGENT-WORKFLOW.md` - Documented patterns

4. Flag any changes that would require updates to:
   - Agent definitions (`.claude/agents/`)
   - Skills (`.claude/skills/`)
   - Hookify rules (`.claude/hookify.*.local.md`)
   - Conductor commands (`.claude/commands/conductor-*.md`)

## Automation

After research, optionally create GitHub issues or update tracking in:
- `conductor/tracks/` for major updates requiring implementation
- `docs/CHANGELOG.md` for documentation updates
