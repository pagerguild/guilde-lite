# MARKETPLACE-001: Plugin Marketplace Creation

**Track ID:** MARKETPLACE-001
**Title:** Create guilde-plugins Marketplace
**Type:** Enhancement
**Priority:** P1
**Status:** Not Started
**Created:** 2026-01-15

---

## Summary

Create a public plugin marketplace repository (pagerguild/guilde-plugins) following Claude Code marketplace best practices. Modularize guilde-lite's components into granular, single-purpose plugins for easy installation and composition.

---

## Problem Statement

Currently, guilde-lite bundles all agents, commands, and skills together:
1. Users must install everything even if they only need specific functionality
2. Components cannot be installed independently
3. No marketplace.json registry for plugin discovery
4. Not following official Claude Code plugin marketplace patterns

---

## Solution

Create a marketplace repository with:
1. **marketplace.json** - Registry following official schema
2. **Granular plugins** - Single-purpose, 2-8 components each
3. **Progressive disclosure** - Skills load knowledge only when triggered
4. **Validation** - Use plugin-dev toolkit for quality assurance

---

## Acceptance Criteria

### AC-1: Marketplace Repository Structure
- [ ] pagerguild/guilde-plugins repository created
- [ ] .claude-plugin/marketplace.json with official schema reference
- [ ] README.md with installation instructions
- [ ] LICENSE file (MIT)

### AC-2: Plugin Migration - Conductor Workflows
- [ ] conductor-workflows plugin created
- [ ] 6 commands migrated (setup, new-track, implement, checkpoint, status, sync-docs)
- [ ] Plugin validates with plugin-validator agent
- [ ] Can be installed independently

### AC-3: Plugin Migration - TDD Automation
- [ ] tdd-automation plugin created
- [ ] 1 command migrated (tdd)
- [ ] 3 skills migrated (red-phase, green-phase, refactor-phase)
- [ ] Plugin validates with plugin-validator agent

### AC-4: Plugin Migration - Review Agents
- [ ] multi-agent-review plugin created
- [ ] 3 agents migrated (code-reviewer, security-auditor, architect-reviewer)
- [ ] Plugin validates with plugin-validator agent

### AC-5: Plugin Migration - Exploration Agents
- [ ] exploration-agents plugin created
- [ ] 3 agents migrated (context-explorer, codebase-analyzer, docs-researcher)
- [ ] Plugin validates with plugin-validator agent

### AC-6: Plugin Migration - Implementation Agents
- [ ] implementation-agents plugin created
- [ ] 5 agents migrated (backend-architect, frontend-developer, database-optimizer, test-automator, tdd-orchestrator)
- [ ] Plugin validates with plugin-validator agent

### AC-7: Plugin Migration - Specification Agents
- [ ] spec-agents plugin created
- [ ] 1 agent migrated (spec-builder)
- [ ] Plugin validates with plugin-validator agent

### AC-8: Plugin Migration - Mise Tools
- [ ] mise-tools plugin created
- [ ] 1 command migrated (mise)
- [ ] 1 skill migrated (mise-expert)
- [ ] Plugin validates with plugin-validator agent

### AC-9: Plugin Migration - Context Preservation
- [ ] context-preservation plugin created
- [ ] 2 skills migrated (context-loader, error-recovery)
- [ ] Plugin validates with plugin-validator agent

### AC-10: Plugin Migration - Diagram Generation
- [ ] diagram-generation plugin created
- [ ] 2 skills migrated (mermaid-generator, c4-generator)
- [ ] Plugin validates with plugin-validator agent

### AC-11: Plugin Migration - Code Review Pipeline
- [ ] code-review-pipeline plugin created
- [ ] 1 command migrated (review-all)
- [ ] 2 skills migrated (code-review-pipeline, test-gen-workflow)
- [ ] Plugin validates with plugin-validator agent

### AC-12: Plugin Migration - Release Research
- [ ] release-research plugin created
- [ ] 1 command migrated (research-releases)
- [ ] 1 skill migrated (release-researcher)
- [ ] Plugin validates with plugin-validator agent

### AC-13: Plugin Migration - Documentation Sync
- [ ] docs-sync plugin created
- [ ] 1 command migrated (docs-sync)
- [ ] Plugin validates with plugin-validator agent

### AC-14: Documentation Complete
- [ ] Marketplace README with overview and installation guide
- [ ] Each plugin has README.md
- [ ] guilde-lite README updated to reference marketplace

### AC-15: End-to-End Validation
- [ ] All plugins validate with plugin-validator
- [ ] marketplace.json validates against official schema
- [ ] At least one plugin can be installed and used successfully

---

## Technical Specifications

### Marketplace Structure

```
pagerguild/guilde-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── conductor-workflows/
│   ├── tdd-automation/
│   ├── multi-agent-review/
│   ├── exploration-agents/
│   ├── implementation-agents/
│   ├── spec-agents/
│   ├── mise-tools/
│   ├── context-preservation/
│   ├── diagram-generation/
│   ├── code-review-pipeline/
│   ├── release-research/
│   └── docs-sync/
├── README.md
└── LICENSE
```

### marketplace.json Schema

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "guilde-plugins",
  "owner": {
    "name": "pagerguild",
    "url": "https://github.com/pagerguild"
  },
  "metadata": {
    "repository": "https://github.com/pagerguild/guilde-plugins",
    "documentation": "https://github.com/pagerguild/guilde-plugins#readme"
  },
  "plugins": [...]
}
```

### Plugin Entry Schema

```json
{
  "name": "plugin-name",
  "source": "./plugins/plugin-name",
  "description": "Brief description",
  "version": "1.0.0",
  "keywords": ["keyword1", "keyword2"],
  "category": "workflow|development|review|tools",
  "commands": ["./commands/*.md"],
  "agents": ["./agents/*.md"],
  "skills": ["./skills/*"]
}
```

---

## Dependencies

- GitHub MCP server for repository operations
- plugin-dev toolkit for validation (optional but recommended)

---

## Out of Scope

- Automated publishing to claude-code-marketplace (future track)
- Version management automation (future track)
- CI/CD for plugin validation (future track)

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Component interdependencies | Plugins may need each other | Document dependencies in README |
| Skill trigger conflicts | Skills may not load correctly | Use strong, specific trigger phrases |
| Path resolution issues | ${CLAUDE_PLUGIN_ROOT} failures | Test each plugin independently |

---

## Success Metrics

- 12 plugins created and validated
- marketplace.json validates against official schema
- Documentation complete for each plugin
- At least one plugin successfully installed and tested

---

## References

- [Claude Code Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [wshobson/agents marketplace](https://github.com/wshobson/agents) - Pattern reference
- [claude-plugins-official](https://github.com/anthropics/claude-plugins-official) - Official examples
- [plugin-dev toolkit](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/plugin-dev)
