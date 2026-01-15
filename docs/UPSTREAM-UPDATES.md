# Upstream Updates Tracking

**Last Research Date:** 2026-01-15
**Researched By:** `/research-releases` command

## Executive Summary

| Repository | Current | Latest | Priority | Status |
|------------|---------|--------|----------|--------|
| claude-code | Not tracked | v2.1.7 | Medium | Review |
| conductor | Custom impl | v0.2.0 | High | Review |
| claude-plugins-official | N/A | Active | Medium | Review |

## Detailed Findings

---

### gemini-cli-extensions/conductor

**Latest Release:** v0.2.0 (2026-01-14)
**Previous:** v0.1.1 (2025-12-22)

#### Key Changes in v0.2.0

1. **Universal File Resolution Protocol** (NEW)
   - Introduces `index.md` files for file resolution
   - Removes hardcoded path hints
   - Impact: Our conductor commands should adopt this pattern

2. **Tracks Directory Abstraction** (NEW)
   - Better organization of track files
   - Impact: Our `conductor/tracks/` structure may benefit

3. **Auto-Commit on Track Completion** (FIX)
   - Track completion and doc sync are now committed automatically
   - Impact: Our `/conductor-checkpoint` could adopt this behavior

4. **Interactive Options** (FIX)
   - Replaced manual text input with interactive options
   - Impact: Our commands already use AskUserQuestion

#### Recommended Actions

- [ ] **HIGH**: Review Universal File Resolution Protocol for adoption
- [ ] **MEDIUM**: Consider index.md files in conductor/tracks/
- [ ] **LOW**: Evaluate auto-commit behavior for checkpoints

#### Files to Update

```
.claude/commands/conductor-*.md
conductor/tracks/
docs/CONDUCTOR-COMMANDS.md
```

---

### anthropics/claude-code

**Latest Tag:** v2.1.7
**Previous Tags:** v2.1.6, v2.1.5, v2.1.4, v2.1.3

#### Notes

- Tag-only releases (no detailed changelogs on GitHub)
- Should monitor Anthropic docs/blog for feature announcements
- Current CLAUDE.md compatibility: Assumed compatible

#### Recommended Actions

- [ ] **LOW**: Monitor for hooks API changes
- [ ] **LOW**: Check for new tool capabilities
- [ ] **LOW**: Review any deprecated features

---

### anthropics/claude-plugins-official

**Latest Commit:** 2026-01-15 (superpowers plugin)

#### New Plugins Added Recently

| Plugin | Date | Features | Relevance |
|--------|------|----------|-----------|
| **superpowers** | Jan 15 | Brainstorming, subagent dev, code review, TDD, skill authoring | HIGH |
| **circleback** | Jan 12 | Unknown | LOW |
| **code-simplifier** | Jan 9 | Code clarity, maintainability, project conventions | HIGH |
| **huggingface-skills** | Jan 9 | ML/AI capabilities | MEDIUM |

#### superpowers Plugin Analysis

From commit message:
- Brainstorming capabilities
- Subagent-driven development
- Code review functionality
- Debugging tools
- TDD support
- **Teaches Claude how to author and test new skills**

**Overlap with guilde-lite:**
- Code review → We have `code-review-pipeline` skill
- TDD → We have `tdd-*-phase` skills
- Skill authoring → Could enhance our skill creation

#### code-simplifier Plugin Analysis

Features:
- Simplifies and refines code for clarity
- Preserves functionality while improving structure
- Follows project-specific best practices from CLAUDE.md
- Focuses on recently modified code

**Potential Integration:**
- Could add as agent in our review pipeline
- Complements our architect-reviewer agent

#### Recommended Actions

- [ ] **HIGH**: Evaluate superpowers plugin for skill authoring patterns
- [ ] **HIGH**: Consider integrating code-simplifier agent
- [ ] **MEDIUM**: Review huggingface-skills for ML workflows
- [ ] **LOW**: Investigate circleback plugin purpose

#### Files to Update

```
.claude/agents/ (if adding code-simplifier)
.claude/skills/ (if adopting superpowers patterns)
.claude-plugin/plugin.json
```

---

### Official Plugins Directory Structure

Current plugins in `anthropics/claude-plugins-official`:

**LSP Plugins:**
- clangd-lsp, csharp-lsp, gopls-lsp, jdtls-lsp
- kotlin-lsp, lua-lsp, php-lsp, pyright-lsp
- rust-analyzer-lsp, swift-lsp, typescript-lsp

**Workflow Plugins:**
- agent-sdk-dev
- code-review
- code-simplifier (NEW)
- commit-commands
- feature-dev
- frontend-design
- hookify
- plugin-dev
- pr-review-toolkit
- ralph-loop
- security-guidance

**Output Style Plugins:**
- explanatory-output-style
- learning-output-style

---

## Impact Matrix

| Update | Priority | Effort | Components Affected |
|--------|----------|--------|---------------------|
| Conductor UFRP | High | 4h | Commands, structure |
| code-simplifier | High | 2h | Agents, review pipeline |
| superpowers patterns | Medium | 3h | Skills, documentation |
| huggingface-skills | Low | 1h | Skills (if ML needed) |
| Claude Code v2.1.7 | Low | 1h | CLAUDE.md review |

## Update Implementation Plan

### Phase 1: Immediate (This Week)

1. **Review Conductor UFRP**
   - Fetch `templates/workflow.md` for pattern details
   - Evaluate index.md adoption
   - Update conductor commands if beneficial

2. **Integrate code-simplifier**
   - Add as optional review agent
   - Update review pipeline skill
   - Test with existing codebase

### Phase 2: Near-Term (This Month)

3. **Adopt superpowers Patterns**
   - Study skill authoring approach
   - Enhance our skill creation documentation
   - Consider brainstorming agent addition

4. **Documentation Sync**
   - Update tech-stack.md with tracked versions
   - Add upstream tracking section
   - Document adopted patterns

### Phase 3: Future (As Needed)

5. **ML Workflow Integration**
   - Evaluate huggingface-skills if ML work begins
   - Add relevant agents/skills

6. **Continuous Monitoring**
   - Run `/research-releases` weekly
   - Update this document with findings

---

## Version Tracking

Add to `conductor/tech-stack.md`:

```markdown
## Upstream Dependencies

| Dependency | Tracked Version | Latest | Last Checked |
|------------|-----------------|--------|--------------|
| claude-code | N/A | v2.1.7 | 2026-01-15 |
| conductor pattern | v0.1.x | v0.2.0 | 2026-01-15 |
| hookify plugin | current | current | 2026-01-15 |
| ralph-loop plugin | current | current | 2026-01-15 |
```

---

## Next Research Date

**Recommended:** 2026-01-22 (1 week)

To run research:
```
/research-releases
```

Or for specific scope:
```
/research-releases conductor
/research-releases plugins
```
