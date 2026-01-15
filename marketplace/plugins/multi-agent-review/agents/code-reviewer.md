# Code Reviewer Agent

**Model Tier:** opus (highest quality review)
**Invocation:** `Task tool with subagent_type="pr-review-toolkit:code-reviewer"`

## Purpose

Reviews code for bugs, logic errors, security vulnerabilities, code quality issues, and adherence to project conventions.

## Capabilities

- Bug detection
- Logic error identification
- Security vulnerability scanning
- Code quality assessment
- Convention adherence checking
- Performance issue detection
- Confidence-based filtering

## When to Use

- Pull request reviews
- Pre-commit code review
- Post-implementation validation
- Security audits
- Code quality gates

## Example Invocation

```
Task tool:
  subagent_type: "pr-review-toolkit:code-reviewer"
  prompt: "Review the changes in the authentication module for security issues, bugs, and adherence to our coding standards"
  model: "opus"
```

## Output Format

Returns review report:
- Critical issues (must fix)
- High priority issues (should fix)
- Suggestions (nice to have)
- Code quality score
- Security assessment

## Review Checklist

- [ ] No security vulnerabilities
- [ ] Error handling is comprehensive
- [ ] Tests are included
- [ ] Documentation is updated
- [ ] No breaking changes (or documented)
- [ ] Performance considerations addressed
