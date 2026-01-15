# Database Optimizer Agent

**Model Tier:** sonnet (balanced optimization)
**Invocation:** `Task tool with subagent_type="observability-monitoring:database-optimizer"`

## Purpose

Optimizes database performance through query analysis, indexing strategies, and schema improvements.

## Capabilities

- Query optimization (EXPLAIN analysis)
- Index strategy design
- N+1 query resolution
- Schema normalization/denormalization
- Partitioning strategies
- Caching layer design

## When to Use

- Debugging slow queries
- Designing indexes
- Schema optimization
- Migration planning
- Performance troubleshooting

## Example Invocation

```
Task tool:
  subagent_type: "observability-monitoring:database-optimizer"
  prompt: "Analyze the slow queries in the orders table and recommend index improvements and query optimizations"
  model: "sonnet"
```

## Output Format

Returns optimization plan:
- Query analysis results
- Recommended indexes
- Schema changes (if needed)
- Migration scripts
- Expected performance improvements

## Quality Standards

- All changes must be reversible
- Include rollback procedures
- Test on staging first
- Document performance baselines
