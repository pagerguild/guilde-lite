# multi-agent-review

Parallel code review agents for comprehensive quality assurance.

## Commands

| Command | Description |
|---------|-------------|
| `/multi-agent` | Show multi-agent workflow status and compliance metrics |
| `/multi-agent status` | Quick compliance status |
| `/multi-agent report` | Full compliance report |
| `/multi-agent check` | Check for pending reviews |
| `/multi-agent clear` | Mark pending reviews as complete |
| `/multi-agent help` | Show help and documentation links |

## Agents

| Agent | Model | Focus |
|-------|-------|-------|
| `code-reviewer` | opus | Code quality, bugs, conventions |
| `security-auditor` | opus | OWASP, vulnerabilities, auth |
| `architect-reviewer` | opus | Patterns, scalability, tech debt |

## Usage

### Single Agent

```
Use Task tool with subagent_type: "multi-agent-review:code-reviewer"
prompt: "Review the changes in src/auth/"
```

### Parallel Review (Recommended)

Launch all three agents in parallel for comprehensive review:

```
# In a single message, invoke all three:

Task tool: subagent_type="multi-agent-review:code-reviewer"
Task tool: subagent_type="multi-agent-review:security-auditor"
Task tool: subagent_type="multi-agent-review:architect-reviewer"
```

## Agent Details

### code-reviewer

Reviews code for:
- Logic errors and bugs
- Code quality issues
- Convention violations
- Performance concerns

### security-auditor

Reviews code for:
- OWASP Top 10 vulnerabilities
- Authentication/authorization issues
- Input validation problems
- Secrets exposure

### architect-reviewer

Reviews code for:
- Design pattern adherence
- Scalability concerns
- Technical debt
- Architecture violations

## Installation

```bash
# Add the marketplace (if not already added)
claude plugin marketplace add ./marketplace

# Install this plugin
claude plugin install multi-agent-review@guilde-plugins
```
