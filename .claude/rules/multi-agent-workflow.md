# Multi-Agent Workflow Guidelines

Guidelines for using parallel subagents effectively (not strict enforcement).

---

## Core Principle

**For complex tasks, consider leveraging parallel subagents for:**
1. Large-scale codebase exploration
2. Code review before commits
3. Multi-file validation
4. Comprehensive documentation updates

---

## When to Consider Multi-Agent Workflow

### Good Candidates for Subagents

| Task Type | Suggested Agents | When Useful |
|-----------|------------------|-------------|
| Multi-file code changes | code-reviewer | Before commits |
| Deep codebase exploration | Explore agent | Unknown architecture |
| Complex bug investigation | debugger agents | Non-obvious issues |
| New feature implementation | architect + reviewer | Significant additions |
| Documentation overhaul | docs-architect | Major rewrites |

### DO NOT Require Subagents For

**Simple tasks should be handled directly:**
- Status questions ("what is X?", "where is Y?")
- Simple file reads (single file lookups)
- Direct questions with known answers
- Quick explanations or clarifications
- Single-file edits or typo fixes
- Checking configuration values
- Answering "how does X work?" for small scopes
- Commands explicitly requesting single-agent

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

## When Parallel Execution Helps

### Good Uses of Parallelism

1. **Large research tasks:** Multiple Explore agents with different search strategies
2. **Validation tasks:** Multiple validators to catch different issues
3. **Review tasks:** Multiple reviewers for comprehensive coverage

### Example Patterns (Suggestions, Not Requirements)

#### Pattern 1: Complex Research Question
```
User: "How does authentication work in this codebase?"

If codebase is large/unfamiliar:
- Consider Explore agent for thorough search
- Synthesize findings

If you already know the codebase:
- Just read the relevant files directly
```

#### Pattern 2: Significant Code Change
```
User: "Add a new endpoint for user preferences"

Suggested approach:
1. Planning: Consider Plan agent for architecture
2. Implementation: Write code
3. Before commit: Consider code review

For small/simple changes, skip the ceremony.
```

#### Pattern 3: Complex Bug Fix
```
User: "Fix the authentication timeout bug"

If bug is non-obvious:
- Consider investigation agents
- Run tests after fix

If bug is straightforward:
- Just fix it and run tests
```

---

## Hook Integration (Optional Tracking)

### PreToolUse Hooks

**Write/Edit Tool Hooks:**
- Reminder for code review consideration (not blocking)
- Track tool usage for metrics

**Task Tool Hooks:**
- Track `agent_invoked` event for analytics
- Record which agents are being used

### PostToolUse Hooks

**Write/Edit Tool Hooks:**
- Track code changes for metrics
- Reminder about code review (non-blocking)

**Task Tool Hooks (for code-reviewer):**
- Track when code-reviewer agent is used
- Update metrics

### Metrics Tracking (Optional)

Usage metrics tracked via `scripts/multi-agent-metrics.sh`:

```bash
# Check metrics
bash scripts/multi-agent-metrics.sh check

# View report
bash scripts/multi-agent-metrics.sh report

# Export as JSON
bash scripts/multi-agent-metrics.sh json
```

### Code Review Recommendation

For substantive code changes (multi-file, new features):
1. Consider running code-reviewer before commit
2. This is a recommendation, not a hard block
3. Use judgment based on change scope

### SessionStart Hook

On session start:
- Load active track context from conductor/tracks.md
- Display current task and pending items
- Show workflow guidance (not enforcement)

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

## When to Reconsider Approach

### Signs You Might Benefit from Subagents

If you find yourself:
- Searching across many files with uncertain results
- Making changes that affect multiple systems
- Investigating a complex bug with unclear root cause
- Needing diverse perspectives on architecture

Consider using subagents for these scenarios.

### When Direct Approach is Fine

| Scenario | Approach |
|----------|----------|
| Simple status question | Answer directly |
| Single file lookup | Read the file |
| Known configuration check | Check directly |
| Straightforward explanation | Explain directly |

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

1. **Use judgment** - Match tool complexity to task complexity
2. **Parallel when beneficial** - Launch multiple agents for complex tasks
3. **Direct when simple** - Answer straightforward questions directly
4. **Track complex work** - Use TodoWrite for multi-step tasks
5. **Review before commits** - Consider code review for substantive changes
