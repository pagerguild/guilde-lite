# Multi-Agent Workflow Enforcement

Rules for enforcing parallel subagent usage on every user prompt.

---

## Core Principle

**EVERY substantive user request MUST leverage parallel subagents for:**
1. Research and exploration
2. Validation and verification
3. Code review
4. Documentation updates

---

## When to Use Multi-Agent Workflow

### ALWAYS Use Subagents For

| Task Type | Required Agents | Minimum |
|-----------|-----------------|---------|
| Code changes | code-reviewer, test-automator | 2 |
| Research questions | Explore (multiple paths) | 2-3 |
| Bug investigation | debugger, error-detective | 2 |
| New features | architect-review, code-reviewer | 2 |
| Documentation | docs-architect, tutorial-engineer | 2 |
| Validation | Tool-specific validators | 2+ |

### Skip Multi-Agent Only For

- Simple file reads (single file)
- Direct questions with known answers
- Commands explicitly requesting single-agent
- Trivial edits (typos, formatting)

---

## Subagent Selection Guide

### Research & Exploration
```yaml
codebase_questions:
  - subagent_type: Explore
    thoroughness: medium to very thorough

architecture_questions:
  - subagent_type: Plan
  - subagent_type: feature-dev:code-architect
```

### Code Quality
```yaml
after_code_changes:
  - subagent_type: pr-review-toolkit:code-reviewer
  - subagent_type: tdd-workflows:code-reviewer

before_commits:
  - subagent_type: pr-review-toolkit:silent-failure-hunter
  - subagent_type: pr-review-toolkit:comment-analyzer
```

### Validation
```yaml
tool_validation:
  - subagent_type: debugging-toolkit:debugger
  - subagent_type: unit-testing:test-automator

security_validation:
  - subagent_type: security-scanning:security-auditor
  - subagent_type: full-stack-orchestration:security-auditor
```

### Documentation
```yaml
documentation_tasks:
  - subagent_type: documentation-generation:docs-architect
  - subagent_type: documentation-generation:tutorial-engineer
  - subagent_type: code-documentation:docs-architect
```

---

## Parallel Execution Requirements

### Minimum Parallelism

1. **Research tasks:** Launch 2-3 Explore agents with different search strategies
2. **Validation tasks:** Launch all relevant validators simultaneously
3. **Review tasks:** Launch code-reviewer AND type-specific reviewers together

### Example Patterns

#### Pattern 1: Research Question
```
User: "How does authentication work in this codebase?"

Required response:
- Launch Explore agent (thoroughness: "very thorough")
- Search auth-related files, patterns, and flows
- Synthesize findings from multiple exploration paths
```

#### Pattern 2: Code Change
```
User: "Add a new endpoint for user preferences"

Required response:
1. Planning phase: Use Plan agent OR feature-dev:code-architect
2. Implementation phase: Write code
3. Validation phase (PARALLEL):
   - pr-review-toolkit:code-reviewer
   - tdd-workflows:tdd-orchestrator
   - security-scanning:security-auditor
```

#### Pattern 3: Bug Fix
```
User: "Fix the authentication timeout bug"

Required response:
1. Investigation (PARALLEL):
   - debugging-toolkit:debugger
   - error-debugging:error-detective
2. Fix implementation
3. Validation (PARALLEL):
   - unit-testing:test-automator
   - pr-review-toolkit:silent-failure-hunter
```

---

## Enforcement Hooks (STRICT)

### PreToolUse Hooks

**Write/Edit Tool Hooks:**
- Display reminder: "MULTI-AGENT CODE REVIEW REQUIREMENT"
- Claude must mentally track that review is required

**Task Tool Hooks:**
- Track `agent_invoked` event automatically
- Record which agents are being used

### PostToolUse Hooks

**Write/Edit Tool Hooks:**
- Track `code_change_no_review` event automatically
- Display reminder about pending review requirement
- Increment pending review counter

**Task Tool Hooks (for code-reviewer):**
- Detect when code-reviewer agent is invoked
- Track `code_change_reviewed` event
- Clear pending review counter

### Metrics Tracking

All compliance is tracked via `scripts/multi-agent-metrics.sh`:

```bash
# Check pending reviews
bash scripts/multi-agent-metrics.sh check

# View compliance report
bash scripts/multi-agent-metrics.sh report

# Export metrics as JSON
bash scripts/multi-agent-metrics.sh json
```

### Commit Blocking (CRITICAL)

Before ANY commit:
1. Check `scripts/multi-agent-metrics.sh check` for pending reviews
2. If pending reviews exist, BLOCK commit and invoke code-reviewer
3. Only after review clears pending count, proceed with commit

### SessionStart Hook

On session start:
- Load active track context from conductor/tracks.md
- Display current task and pending items
- Remind about multi-agent requirements
- Show pending review count if any

---

## Agent Invocation Syntax

### Single Agent (Use When Appropriate)
```
Task tool with subagent_type: "Explore"
prompt: "Find all authentication-related code"
```

### Parallel Agents (PREFERRED)
```
Multiple Task tool calls in SINGLE message:
1. subagent_type: "pr-review-toolkit:code-reviewer"
2. subagent_type: "tdd-workflows:tdd-orchestrator"
3. subagent_type: "debugging-toolkit:debugger"
```

---

## Violations and Recovery

### If Multi-Agent Not Used

1. **Stop** current approach
2. **Identify** appropriate subagents for the task
3. **Launch** parallel agents
4. **Synthesize** results before proceeding

### Common Violations

| Violation | Recovery |
|-----------|----------|
| Direct code edit without review | Launch code-reviewer agent |
| Research without Explore agent | Restart with proper exploration |
| Validation skipped | Launch validation agents before commit |
| Single-path exploration | Add parallel exploration paths |

---

## Integration with TodoWrite

Every multi-agent workflow should:
1. **Track** tasks with TodoWrite
2. **Update** status as agents complete
3. **Document** findings in context.md

```yaml
workflow_tracking:
  - Use TodoWrite for complex tasks
  - Mark agent tasks as in_progress when launched
  - Mark completed immediately upon agent return
  - Add follow-up tasks discovered during execution
```

---

## Best Practices Summary

1. **Default to parallel** - Launch multiple agents simultaneously
2. **Synthesize results** - Combine agent outputs intelligently
3. **Track progress** - Use TodoWrite for visibility
4. **Validate always** - Never skip code review or tests
5. **Document changes** - Update context.md after significant work
