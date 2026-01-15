---
description: Show multi-agent workflow status, compliance metrics, and pending reviews
argument-hint: "[status|report|check|clear|help]"
allowed-tools: ["Read", "Glob", "Grep", "Task"]
---

# /multi-agent Command

Multi-agent workflow status and compliance tracking.

## Actions

### `/multi-agent` or `/multi-agent status`

Show current multi-agent compliance status:

1. **Check for pending reviews**:
   ```bash
   bash scripts/multi-agent-metrics.sh check
   ```

2. **Show quick compliance stats**:
   ```bash
   bash scripts/multi-agent-metrics.sh json
   ```

3. **Report summary** to user including:
   - Pending code reviews count
   - Recent compliance rate
   - Recommendations for improvement

### `/multi-agent report`

Show full compliance report with details:

```bash
bash scripts/multi-agent-metrics.sh report
```

This shows:
- Total events tracked
- Violation counts by type
- Compliant usage counts
- Compliance rate with visual bar
- Recent events history

### `/multi-agent check`

Check if there are pending reviews that must be done before committing:

```bash
bash scripts/multi-agent-metrics.sh check
```

**IMPORTANT**: If pending reviews exist, you MUST invoke a code-reviewer agent before committing.

### `/multi-agent clear`

Mark pending reviews as complete (only after actually running code review):

```bash
bash scripts/multi-agent-metrics.sh track code_change_reviewed
```

### `/multi-agent help`

Display this help and link to documentation:

- `.claude/rules/multi-agent-workflow.md` - Full workflow rules
- `scripts/multi-agent-metrics.sh` - Metrics tracking script

## Multi-Agent Workflow Requirements

### ALWAYS Use Subagents For:

| Task Type | Required Agents | Minimum |
|-----------|-----------------|---------|
| Code changes | code-reviewer, test-automator | 2 |
| Research questions | Explore (multiple paths) | 2-3 |
| Bug investigation | debugger, error-detective | 2 |
| New features | architect-review, code-reviewer | 2 |

### Skip Multi-Agent Only For:

- Simple file reads (single file)
- Direct questions with known answers
- Trivial edits (typos, formatting)

## Agent Invocation Examples

### After Writing Code
```
Launch parallel agents:
1. Task with subagent_type: "pr-review-toolkit:code-reviewer"
2. Task with subagent_type: "unit-testing:test-automator"
```

### For Research Questions
```
Launch parallel Explore agents:
1. Task with subagent_type: "Explore", thoroughness: "medium"
2. Task with subagent_type: "Explore", different search angle
```

### For Bug Fixes
```
Launch parallel debugging agents:
1. Task with subagent_type: "debugging-toolkit:debugger"
2. Task with subagent_type: "error-debugging:error-detective"
```

## Compliance Tracking

Events tracked automatically:

| Event | Trigger |
|-------|---------|
| `code_change_no_review` | Write/Edit tool used |
| `code_change_reviewed` | code-reviewer agent invoked |
| `agent_invoked` | Any Task tool call |

View compliance with `/multi-agent report`.

## Integration with Commit Workflow

Before committing:
1. Run `/multi-agent check` to see pending reviews
2. If pending, invoke code-reviewer agent
3. Then proceed with commit

The `/commit` command should also check for pending reviews.
