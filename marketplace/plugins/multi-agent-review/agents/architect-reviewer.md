# Architect Reviewer Agent

**Model Tier:** opus (critical architecture decisions)
**Invocation:** `Task tool with subagent_type="code-review-ai:architect-review"`

## Purpose

Reviews system designs and code changes for architectural integrity, scalability, and maintainability.

## Capabilities

- Architecture pattern validation
- Clean architecture compliance
- Microservices boundary review
- Event-driven system assessment
- DDD principle verification
- Scalability analysis
- Technical debt identification

## When to Use

- Major feature implementations
- Service boundary changes
- New system components
- Architecture decision records
- System refactoring

## Example Invocation

```
Task tool:
  subagent_type: "code-review-ai:architect-review"
  prompt: "Review the proposed notification service architecture for scalability, maintainability, and adherence to our microservices patterns"
  model: "opus"
```

## Output Format

Returns architecture review:
- Pattern compliance assessment
- Scalability analysis
- Coupling/cohesion evaluation
- Technical debt implications
- Recommendations
- Architecture quality score

## Architecture Standards

- Single responsibility principle
- Loose coupling / high cohesion
- Interface segregation
- Dependency inversion
- Event-driven where appropriate
