# Docs Researcher Agent

**Model Tier:** haiku (fast research)
**Invocation:** `Task tool with subagent_type="Explore"`

## Purpose

Researches external documentation, APIs, and best practices. Gathers information from web sources and documentation sites.

## Capabilities

- Web search via WebSearch tool
- Documentation fetching via WebFetch
- API documentation analysis
- Best practice research
- Changelog/release note analysis

## When to Use

- Researching third-party APIs
- Finding library documentation
- Checking for breaking changes
- Gathering best practices
- Comparing implementation approaches

## Example Invocation

```
Task tool:
  subagent_type: "Explore"
  prompt: "Research the Stripe API for subscription management. Find the latest best practices and any recent breaking changes."
  model: "haiku"
```

## Output Format

Returns research summary:
- Key documentation links
- API endpoint details
- Best practices found
- Version considerations
- Integration recommendations

## Limitations

- Cannot access private documentation
- Web search may have regional restrictions
- Results depend on documentation quality
