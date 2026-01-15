# Claude Code Configuration Guide

Complete documentation of all Claude Code configurations for the guilde-lite project.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Hooks Configuration](#hooks-configuration)
3. [Rules Reference](#rules-reference)
4. [Enabled Plugins](#enabled-plugins)
5. [Multi-Agent Workflow](#multi-agent-workflow)
6. [Best Practices](#best-practices)

---

## Project Structure

```
.claude/
├── settings.json          # Hooks and plugin configuration
├── context.md             # Session state and active work
└── rules/
    ├── coding-standards.md        # Language conventions
    ├── documentation-standards.md # Doc requirements
    ├── multi-agent-workflow.md    # Parallel agent enforcement
    ├── quality-gates.md           # Code quality rules
    └── tdd-requirements.md        # Test-driven development

CLAUDE.md                  # Project memory (root level)
conductor/                 # Workflow orchestration
├── product.md             # Product definition
├── tech-stack.md          # Technology choices
├── workflow.md            # Task execution protocol
└── tracks.md              # Active work tracking
```

---

## Hooks Configuration

### SessionStart Hook

**Location:** `.claude/settings.json`

**Purpose:** Load project context at session start

**Behavior:**
```json
{
  "type": "command",
  "command": "bash scripts/session-startup.sh"
}
```

**Output Includes:**
- Active track status from conductor/tracks.md
- Pending tasks from plan.md
- Recent git commits
- Uncommitted changes count
- Multi-agent workflow requirements reminder

### UserPromptSubmit Hook

**Location:** `.claude/settings.json`

**Purpose:** Enforce multi-agent workflow on every user prompt

**Behavior:**
```json
{
  "type": "prompt",
  "prompt": "MULTI-AGENT WORKFLOW ENFORCEMENT: Before responding, consider if this task requires parallel subagents..."
}
```

**When Triggered:** Every user message submission

**Enforcement:**
- Reminds Claude to consider parallel subagent usage
- Points to `.claude/rules/multi-agent-workflow.md`
- Allows skipping for trivial tasks

---

## Rules Reference

### 1. Multi-Agent Workflow (`multi-agent-workflow.md`)

**Purpose:** Enforce parallel subagent usage

**Key Requirements:**
- Research tasks: 2-3 Explore agents with different paths
- Code changes: code-reviewer + test-automator agents
- Validation: Multiple validators in parallel
- Documentation: docs-architect + tutorial-engineer agents

**When to Skip:**
- Simple file reads
- Direct questions with known answers
- Trivial edits (typos, formatting)

### 2. Quality Gates (`quality-gates.md`)

**Pre-Commit Gates:**
- Test coverage: 80% minimum for new code
- Linting: Zero errors (Go, Python, TypeScript, Rust)
- Type safety: Strict mode enabled

**Pre-Merge Gates:**
- Review requirements for all changes
- Documentation updates for public APIs
- CI pipeline must pass

**Blocked Operations:**
- Destructive commands (`rm -rf /`, `mkfs`, etc.)
- Force pushes to main/master
- Publishing without approval

### 3. Coding Standards (`coding-standards.md`)

**General Principles:**
- Clarity over cleverness
- Explicit over implicit
- Fail fast
- Minimal dependencies

**Language-Specific:**
- Go: PascalCase/camelCase, explicit error handling
- Python: snake_case, type hints required
- TypeScript: Strict types, async/await
- Rust: Result types, explicit error handling

### 4. TDD Requirements (`tdd-requirements.md`)

**Cycle:** RED -> GREEN -> REFACTOR

**Coverage Requirements:**
| Type | Minimum | Target |
|------|---------|--------|
| Unit tests | 80% | 90% |
| Integration tests | 60% | 80% |
| E2E tests | Critical paths | All paths |

### 5. Documentation Standards (`documentation-standards.md`)

**Always Document:**
- Public APIs
- Architecture decisions
- Breaking changes
- Non-obvious behavior

**AI-Specific:**
- Keep CLAUDE.md under 500 lines
- Use progressive disclosure
- Link to detailed docs instead of duplicating

---

## Enabled Plugins

### Official Plugins (claude-plugins-official)

| Plugin | Purpose |
|--------|---------|
| `frontend-design` | Frontend interface creation |
| `github` | GitHub integration |
| `code-review` | Code review capabilities |
| `feature-dev` | Guided feature development |
| `commit-commands` | Git commit workflow |
| `pr-review-toolkit` | PR review with specialized agents |
| `plugin-dev` | Plugin development tools |
| `ralph-loop` | Continuous TDD automation |
| `hookify` | Rule and hook creation |
| `code-simplifier` | Code simplification |
| `agent-sdk-dev` | Agent SDK development |
| `security-guidance` | Security best practices |
| `learning-output-style` | Interactive learning mode |
| `explanatory-output-style` | Educational explanations |

### Workflow Plugins (claude-code-workflows)

**Development Workflows:**
- `agent-orchestration` - Multi-agent coordination
- `api-scaffolding` - API project templates
- `backend-development` - Backend patterns
- `frontend-mobile-development` - UI development
- `full-stack-orchestration` - End-to-end workflows

**Quality & Testing:**
- `tdd-workflows` - Test-driven development
- `unit-testing` - Test automation
- `code-review-ai` - AI-powered reviews
- `comprehensive-review` - Full code review

**DevOps & Infrastructure:**
- `cicd-automation` - CI/CD pipelines
- `cloud-infrastructure` - Cloud architecture
- `kubernetes-operations` - K8s management
- `deployment-strategies` - Deployment patterns
- `observability-monitoring` - Monitoring setup

**Debugging & Performance:**
- `debugging-toolkit` - Debug utilities
- `error-debugging` - Error investigation
- `error-diagnostics` - Error analysis
- `application-performance` - Performance optimization

**Documentation:**
- `documentation-generation` - Doc creation
- `code-documentation` - Code docs

**Security:**
- `security-scanning` - Security analysis
- `security-compliance` - Compliance checks
- `backend-api-security` - API security
- `frontend-mobile-security` - Frontend security

**Specialized:**
- `llm-application-dev` - LLM applications
- `machine-learning-ops` - ML operations
- `data-engineering` - Data pipelines
- `database-design` - Database architecture

---

## Multi-Agent Workflow

### Agent Selection by Task Type

#### Research Tasks
```yaml
agents:
  - subagent_type: Explore
    thoroughness: "very thorough"
  - subagent_type: Plan
    description: "Architecture planning"
```

#### Code Quality
```yaml
after_code_changes:
  - subagent_type: pr-review-toolkit:code-reviewer
  - subagent_type: tdd-workflows:code-reviewer
  - subagent_type: pr-review-toolkit:silent-failure-hunter
```

#### Validation
```yaml
tool_validation:
  - subagent_type: debugging-toolkit:debugger
  - subagent_type: unit-testing:test-automator
security_validation:
  - subagent_type: security-scanning:security-auditor
```

#### Documentation
```yaml
documentation_tasks:
  - subagent_type: documentation-generation:docs-architect
  - subagent_type: documentation-generation:tutorial-engineer
```

### Parallel Execution Pattern

Always launch independent agents in a single message with multiple Task tool calls:

```
# GOOD - Parallel execution
Message 1: [Task: code-reviewer] [Task: test-automator] [Task: security-auditor]

# BAD - Sequential execution
Message 1: [Task: code-reviewer]
Message 2: [Task: test-automator]
Message 3: [Task: security-auditor]
```

---

## Best Practices

### Memory Management (from claude.ai docs)

1. **Keep CLAUDE.md concise** - Under 500 lines
2. **Use hierarchy** - Enterprise -> Project -> Rules -> User
3. **Progressive disclosure** - Put critical info first
4. **Modular rules** - Use `.claude/rules/` directory

### Checkpointing

1. **Git for permanence** - Commits for long-term history
2. **Checkpoints for recovery** - Use /rewind or Esc+Esc
3. **Commit after milestones** - Not too frequently

### Skills Development

1. **Concise is key** - Brief, focused instructions
2. **Set degrees of freedom** - Clear but not over-constrained
3. **Test across models** - Ensure compatibility
4. **Progressive disclosure** - Overview + reference files

### Multi-Agent Best Practices

1. **Default to parallel** - Launch multiple agents simultaneously
2. **Synthesize results** - Combine outputs intelligently
3. **Track progress** - Use TodoWrite for visibility
4. **Validate always** - Never skip code review or tests
5. **Document changes** - Update context.md after significant work

---

## Quick Reference

### Common Commands

```bash
# Start session
claude                     # Hooks load context automatically

# View rules
cat .claude/rules/multi-agent-workflow.md

# Check configuration
cat .claude/settings.json | jq '.hooks'

# View active plugins
cat .claude/settings.json | jq '.enabledPlugins | keys | length'
```

### Key Files to Know

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project memory and build commands |
| `.claude/settings.json` | Hooks and plugins |
| `.claude/context.md` | Session state |
| `.claude/rules/*.md` | Modular enforcement rules |
| `conductor/tracks.md` | Active work tracking |
| `scripts/session-startup.sh` | Session initialization |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-14 | Initial documentation |

---

*Generated by Claude Code with multi-agent workflow*
