# MARKETPLACE-001 Implementation Plan

**Track:** MARKETPLACE-001 - Create guilde-plugins Marketplace
**Created:** 2026-01-15
**Status:** Phase 2 Complete

---

## Progress Summary

| Phase | Description | Status | Tasks |
|-------|-------------|--------|-------|
| 1 | Repository Setup | Complete | 4/4 |
| 2 | Conductor Plugin | Complete | 5/5 |
| 3 | TDD Plugin | Not Started | 0/5 |
| 4 | Review Agents Plugin | Not Started | 0/4 |
| 5 | Exploration Agents Plugin | Not Started | 0/4 |
| 6 | Implementation Agents Plugin | Not Started | 0/4 |
| 7 | Utility Plugins | Not Started | 0/6 |
| 8 | Validation & Documentation | Not Started | 0/5 |

**Overall:** 9/37 tasks (24%)

---

## Phase 1: Repository Setup

**Objective:** Create the marketplace repository with proper structure

### Tasks

- [x] 1.1 Create pagerguild/guilde-plugins repository on GitHub (762056005e4d)
- [x] 1.2 Create .claude-plugin/marketplace.json with schema reference (762056005e4d)
- [x] 1.3 Create README.md with marketplace overview (762056005e4d)
- [x] 1.4 Create LICENSE (MIT) (762056005e4d)

### Verification
- Repository accessible at github.com/pagerguild/guilde-plugins
- marketplace.json references official schema
- README contains installation instructions

---

## Phase 2: Conductor Plugin [checkpoint: 79d59c0]

**Objective:** Migrate conductor workflow commands

### Tasks

- [x] 2.1 Create plugins/conductor-workflows/ directory structure (554cac2)
- [x] 2.2 Migrate 6 commands (setup, new-track, implement, checkpoint, status, sync-docs) (554cac2)
- [x] 2.3 Create plugin README.md (554cac2)
- [x] 2.4 Add plugin entry to marketplace.json (79d59c0)
- [x] 2.5 Validate plugin structure (79d59c0)

### Components to Migrate

| Type | Source | Destination |
|------|--------|-------------|
| Command | commands/conductor-setup.md | plugins/conductor-workflows/commands/ |
| Command | commands/conductor-new-track.md | plugins/conductor-workflows/commands/ |
| Command | commands/conductor-implement.md | plugins/conductor-workflows/commands/ |
| Command | commands/conductor-checkpoint.md | plugins/conductor-workflows/commands/ |
| Command | commands/conductor-status.md | plugins/conductor-workflows/commands/ |
| Command | commands/conductor-sync-docs.md | plugins/conductor-workflows/commands/ |

### Verification
- All 6 commands present in plugin
- Plugin validates successfully
- Commands documented in plugin README

---

## Phase 3: TDD Plugin

**Objective:** Migrate TDD automation components

### Tasks

- [ ] 3.1 Create plugins/tdd-automation/ directory structure
- [ ] 3.2 Migrate tdd command
- [ ] 3.3 Migrate 3 TDD skills (red, green, refactor phases)
- [ ] 3.4 Add plugin entry to marketplace.json
- [ ] 3.5 Validate plugin structure

### Components to Migrate

| Type | Source | Destination |
|------|--------|-------------|
| Command | commands/tdd.md | plugins/tdd-automation/commands/ |
| Skill | skills/tdd-red-phase/ | plugins/tdd-automation/skills/ |
| Skill | skills/tdd-green-phase/ | plugins/tdd-automation/skills/ |
| Skill | skills/tdd-refactor-phase/ | plugins/tdd-automation/skills/ |

### Verification
- Command and all 3 skills present
- Skills have strong trigger phrases
- Plugin validates successfully

---

## Phase 4: Review Agents Plugin

**Objective:** Migrate code review agents

### Tasks

- [ ] 4.1 Create plugins/multi-agent-review/ directory structure
- [ ] 4.2 Migrate 3 review agents (code-reviewer, security-auditor, architect-reviewer)
- [ ] 4.3 Add plugin entry to marketplace.json
- [ ] 4.4 Validate plugin structure

### Components to Migrate

| Type | Source | Destination |
|------|--------|-------------|
| Agent | agents/code-reviewer.md | plugins/multi-agent-review/agents/ |
| Agent | agents/security-auditor.md | plugins/multi-agent-review/agents/ |
| Agent | agents/architect-reviewer.md | plugins/multi-agent-review/agents/ |

### Verification
- All 3 agents present with proper frontmatter
- Agent descriptions include usage examples
- Plugin validates successfully

---

## Phase 5: Exploration Agents Plugin

**Objective:** Migrate codebase exploration agents

### Tasks

- [ ] 5.1 Create plugins/exploration-agents/ directory structure
- [ ] 5.2 Migrate 3 exploration agents (context-explorer, codebase-analyzer, docs-researcher)
- [ ] 5.3 Add plugin entry to marketplace.json
- [ ] 5.4 Validate plugin structure

### Components to Migrate

| Type | Source | Destination |
|------|--------|-------------|
| Agent | agents/context-explorer.md | plugins/exploration-agents/agents/ |
| Agent | agents/codebase-analyzer.md | plugins/exploration-agents/agents/ |
| Agent | agents/docs-researcher.md | plugins/exploration-agents/agents/ |

### Verification
- All 3 agents present with proper frontmatter
- Plugin validates successfully

---

## Phase 6: Implementation Agents Plugin

**Objective:** Migrate development and implementation agents

### Tasks

- [ ] 6.1 Create plugins/implementation-agents/ directory structure
- [ ] 6.2 Migrate 5 implementation agents
- [ ] 6.3 Add plugin entry to marketplace.json
- [ ] 6.4 Validate plugin structure

### Components to Migrate

| Type | Source | Destination |
|------|--------|-------------|
| Agent | agents/backend-architect.md | plugins/implementation-agents/agents/ |
| Agent | agents/frontend-developer.md | plugins/implementation-agents/agents/ |
| Agent | agents/database-optimizer.md | plugins/implementation-agents/agents/ |
| Agent | agents/test-automator.md | plugins/implementation-agents/agents/ |
| Agent | agents/tdd-orchestrator.md | plugins/implementation-agents/agents/ |

### Verification
- All 5 agents present with proper frontmatter
- Plugin validates successfully

---

## Phase 7: Utility Plugins

**Objective:** Migrate remaining utility plugins

### Tasks

- [ ] 7.1 Create and migrate spec-agents plugin (1 agent)
- [ ] 7.2 Create and migrate mise-tools plugin (1 command, 1 skill)
- [ ] 7.3 Create and migrate context-preservation plugin (2 skills)
- [ ] 7.4 Create and migrate diagram-generation plugin (2 skills)
- [ ] 7.5 Create and migrate code-review-pipeline plugin (1 command, 2 skills)
- [ ] 7.6 Create and migrate remaining plugins (release-research, docs-sync)

### Components Summary

| Plugin | Commands | Agents | Skills |
|--------|----------|--------|--------|
| spec-agents | 0 | 1 | 0 |
| mise-tools | 1 | 0 | 1 |
| context-preservation | 0 | 0 | 2 |
| diagram-generation | 0 | 0 | 2 |
| code-review-pipeline | 1 | 0 | 2 |
| release-research | 1 | 0 | 1 |
| docs-sync | 1 | 0 | 0 |

### Verification
- All plugins created with proper structure
- marketplace.json updated with all entries
- All plugins validate successfully

---

## Phase 8: Validation & Documentation

**Objective:** Final validation and documentation

### Tasks

- [ ] 8.1 Validate marketplace.json against official schema
- [ ] 8.2 Run plugin-validator on all plugins
- [ ] 8.3 Test installation of at least 2 plugins
- [ ] 8.4 Update guilde-lite README to reference marketplace
- [ ] 8.5 Create release tag v1.0.0 for marketplace

### Verification Checklist

- [ ] marketplace.json passes schema validation
- [ ] All 12 plugins pass validation
- [ ] conductor-workflows plugin installs correctly
- [ ] tdd-automation plugin installs correctly
- [ ] guilde-lite README updated
- [ ] Release created

---

## Commit Convention

```
marketplace(phase): Description

# Examples:
marketplace(setup): Create guilde-plugins repository
marketplace(plugin): Add conductor-workflows plugin
marketplace(plugin): Add tdd-automation plugin
marketplace(validation): Validate all plugins
marketplace(docs): Update marketplace README
```

---

## Dependencies

### External
- GitHub MCP server for repository operations
- plugin-dev toolkit (optional) for validation

### Internal
- guilde-lite v1.1.0 as source for components

---

## Notes

### Migration Checklist Per Plugin

1. Create plugin directory structure
2. Copy component files
3. Update any hardcoded paths to use ${CLAUDE_PLUGIN_ROOT}
4. Create plugin README.md
5. Add entry to marketplace.json
6. Validate with plugin-validator (if available)

### Skill Migration Notes

Skills require special attention:
- Ensure SKILL.md has proper YAML frontmatter
- Strong trigger phrases in description
- Reference bundled resources (examples/, references/, scripts/)
- Progressive disclosure pattern

### Agent Migration Notes

Agents require:
- YAML frontmatter with name, description, model, tools
- Description with <example> blocks for reliable triggering
- System prompt as markdown body
