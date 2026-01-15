---
name: error-recovery
description: |
  Cascading error recovery for multi-agent workflows following 2024-2025 patterns.
  Use when:
  - Agent task fails and needs retry strategy
  - Tool call returns error
  - Build or test failures need diagnosis
  - Rate limiting encountered
  - Context window overflow
  - Subagent produces invalid output
  - Need graceful degradation strategy

  Do NOT use for:
  - User-facing error messages (use standard error handling)
  - Expected validation failures
  - Intentional test failures (TDD red phase)
---

# Error Recovery Skill

## Purpose

Implements cascading error recovery patterns for multi-agent workflows. Research shows most "agent failures" are orchestration and context-transfer issues, not model failures. This skill provides structured recovery strategies.

## Core Pattern: Cascading Recovery

```
┌─────────────────────────────────────────────────────────────────┐
│                    CASCADING RECOVERY TIERS                      │
│                                                                   │
│  Tier 1: Immediate Retry (Transient Errors)                      │
│  ├── Exponential backoff with jitter                             │
│  ├── Max 3 attempts                                              │
│  └── Applies to: Rate limits, network issues, timeouts           │
│         ↓ (if still failing)                                     │
│                                                                   │
│  Tier 2: Semantic Fallback (Output Issues)                       │
│  ├── Rephrase prompt                                             │
│  ├── Add explicit constraints                                    │
│  └── Applies to: Invalid output, format errors, hallucinations   │
│         ↓ (if still failing)                                     │
│                                                                   │
│  Tier 3: Agent Substitution (Capability Issues)                  │
│  ├── Route to backup agent (e.g., opus → sonnet)                 │
│  ├── Simplify task scope                                         │
│  └── Applies to: Task too complex, token overflow                │
│         ↓ (if still failing)                                     │
│                                                                   │
│  Tier 4: Human Escalation (Unrecoverable)                        │
│  ├── Document failure state                                      │
│  ├── Request user intervention                                   │
│  └── Applies to: After N total failures, blocking issues         │
└─────────────────────────────────────────────────────────────────┘
```

## Error Classification

### Transient Errors (Tier 1)

Temporary issues that often resolve on retry:

| Error | Recovery |
|-------|----------|
| Rate limit (429) | Exponential backoff + jitter |
| Timeout | Retry with longer timeout |
| Network error | Retry after delay |
| Service unavailable (503) | Retry with backoff |
| Temporary API error | Immediate retry |

### Output Errors (Tier 2)

Model produces invalid or unhelpful output:

| Error | Recovery |
|-------|----------|
| Invalid JSON | Add explicit format instructions |
| Missing required fields | List fields explicitly in prompt |
| Hallucinated facts | Add "only use provided context" |
| Off-topic response | Narrow prompt scope |
| Incomplete output | Request continuation |

### Capability Errors (Tier 3)

Task exceeds agent capabilities:

| Error | Recovery |
|-------|----------|
| Context overflow | Summarize context, use tiered loading |
| Task too complex | Decompose into subtasks |
| Domain mismatch | Route to specialized agent |
| Repeated failures | Downgrade model tier |

### Blocking Errors (Tier 4)

Require human intervention:

| Error | Recovery |
|-------|----------|
| Authentication failure | Request user credentials |
| Permission denied | Request access |
| External service down | Wait or skip |
| Ambiguous requirements | Ask for clarification |

## Recovery Strategies

### Exponential Backoff with Jitter

```python
def calculate_delay(attempt, base=1, max_delay=60):
    """
    Prevents thundering herd with jitter.
    """
    delay = min(base * (2 ** attempt), max_delay)
    jitter = random.uniform(0, delay * 0.1)
    return delay + jitter

# Delays: ~1s, ~2s, ~4s, ~8s, ~16s (capped)
```

### Semantic Fallback Prompts

When output is invalid, enhance prompt:

```markdown
Original: "Generate test cases for this function"

Enhanced: "Generate test cases for this function.

REQUIRED OUTPUT FORMAT:
- JSON array of test objects
- Each object has: name, input, expected_output
- Include at least 3 test cases

CONSTRAINTS:
- Only use information from the provided function
- Do not assume behavior not in the code
- Include edge cases

Example output structure:
[{"name": "test_empty", "input": [], "expected_output": 0}]"
```

### Agent Substitution

```yaml
fallback_chain:
  primary: opus
  secondary: sonnet
  tertiary: haiku

substitution_rules:
  - condition: context_overflow
    action: summarize_and_retry
  - condition: repeated_invalid_output
    action: downgrade_tier
  - condition: task_too_complex
    action: decompose_subtasks
```

### Human Escalation Format

```markdown
## Error Escalation

**Task:** [Original task description]
**Agent:** [Agent that failed]
**Attempts:** [Number of retries]
**Last Error:** [Error message]

**Context:**
- What was attempted
- Why it failed
- What's needed to proceed

**Options:**
1. [Option A]: [Description]
2. [Option B]: [Description]
3. Skip this task and continue

**User Action Required:**
Please choose an option or provide additional guidance.
```

## Circuit Breaker Pattern

Prevent cascading failures:

```yaml
circuit_breaker:
  failure_threshold: 3        # Consecutive failures
  recovery_timeout: 60        # Seconds before retry
  half_open_requests: 1       # Test requests when recovering

states:
  closed: Normal operation
  open: All requests fail fast
  half_open: Testing recovery
```

### Implementation

```python
class CircuitBreaker:
    def __init__(self, threshold=3, timeout=60):
        self.failures = 0
        self.threshold = threshold
        self.timeout = timeout
        self.state = "closed"
        self.last_failure = None

    def record_failure(self):
        self.failures += 1
        self.last_failure = time.time()
        if self.failures >= self.threshold:
            self.state = "open"

    def record_success(self):
        self.failures = 0
        self.state = "closed"

    def can_proceed(self):
        if self.state == "closed":
            return True
        if self.state == "open":
            if time.time() - self.last_failure > self.timeout:
                self.state = "half_open"
                return True
            return False
        return True  # half_open
```

## Recovery Actions by Error Type

### Build Failures

```
1. Parse error message
2. Identify failing component
3. Check for:
   - Missing dependency → Install
   - Type error → Fix type
   - Syntax error → Fix syntax
4. Re-run build
5. If still failing → Request help
```

### Test Failures

```
1. Parse test output
2. Identify failing tests
3. For each failure:
   - Expected vs actual
   - Is test correct?
   - Is implementation correct?
4. Fix appropriately
5. Re-run tests
```

### API Errors

```
1. Check error code
2. Rate limit? → Backoff and retry
3. Auth error? → Check credentials
4. Bad request? → Validate payload
5. Server error? → Retry with backoff
```

### Context Overflow

```
1. Identify context size
2. Apply tiered compression:
   - Summarize old conversation
   - Remove tool output details
   - Keep essential context only
3. Retry with reduced context
4. If still failing → Split task
```

## Observability

Track recovery metrics:

```bash
# Track error and recovery
bash scripts/multi-agent-metrics.sh track error_occurred
bash scripts/multi-agent-metrics.sh track recovery_attempted
bash scripts/multi-agent-metrics.sh track recovery_succeeded
```

### Metrics to Monitor

| Metric | Threshold | Alert |
|--------|-----------|-------|
| Error rate | >5% | Warning |
| Recovery success | <80% | Warning |
| Tier 4 escalations | >1/hour | Critical |
| Circuit breaker trips | >3/day | Warning |

## Quick Actions

### Handle Tool Error
```
1. Classify error (transient, output, capability, blocking)
2. Apply appropriate tier recovery
3. Track attempt count
4. If max attempts reached → escalate
```

### Handle Agent Failure
```
1. Check error type
2. Retry with backoff (Tier 1)
3. Enhance prompt (Tier 2)
4. Try alternate agent (Tier 3)
5. Escalate to user (Tier 4)
```

### Create Recovery Report
```
1. Document all attempts
2. List error messages
3. Note recovery actions taken
4. Recommend next steps
5. Present to user
```

## Related Files

- `.claude/rules/quality-gates.md` - Quality requirements
- `scripts/multi-agent-metrics.sh` - Metrics tracking
- `docs/CONDUCTOR-RESTART-PROTOCOL.md` - Session recovery

## Reference Files

For detailed information, see:
- `reference/error-codes.md` - Common error codes and meanings
- `reference/retry-strategies.md` - Advanced retry patterns
- `reference/escalation-templates.md` - User escalation templates
