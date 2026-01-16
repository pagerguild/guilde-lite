---
name: test-gen-workflow
description: |
  AI-driven test generation with mutation testing and property-based testing.
  Research shows property-based tests find 50x more bugs than unit tests. Use when:
  - Need comprehensive test coverage for new code
  - Coverage gaps identified in existing code
  - Implementing TDD and need test scaffolding
  - Want to validate test quality with mutation testing
  - Edge cases need systematic discovery
  - Refactoring and need regression safety net

  Do NOT use for:
  - Trivial one-liner functions
  - Generated code with known patterns
  - Simple CRUD operations (use templates instead)
---

# Test Generation Workflow Skill

## Purpose

Implements AI-driven test generation following 2024-2025 best practices. Combines traditional unit tests with property-based testing (50x more effective at finding bugs) and mutation testing validation.

## Core Pattern: Test Quality Pyramid

```
┌─────────────────────────────────────────────────────────────────┐
│                    TEST QUALITY PYRAMID                          │
│                                                                   │
│                    ┌─────────────┐                               │
│                    │  Mutation   │  Validates test quality       │
│                    │   Testing   │  (are tests catching bugs?)   │
│                    └──────┬──────┘                               │
│                           │                                       │
│               ┌───────────┴───────────┐                          │
│               │   Property-Based      │  50x more effective      │
│               │      Testing          │  at finding bugs         │
│               └───────────┬───────────┘                          │
│                           │                                       │
│    ┌──────────────────────┴──────────────────────┐               │
│    │            Unit Tests (Examples)             │               │
│    │         Specific input → expected output     │               │
│    └──────────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

## Test Generation Workflow

### Phase 1: Analyze Code Under Test

```
1. Parse function/method signature
2. Identify:
   - Input types and constraints
   - Return types and invariants
   - Side effects (DB, file, network)
   - Error conditions
   - Dependencies to mock
```

### Phase 2: Generate Unit Tests (Examples)

```
Coverage targets:
- Happy path (normal operation)
- Edge cases (empty, nil, max values)
- Error cases (invalid input, failures)
- Boundary conditions
```

### Phase 3: Generate Property-Based Tests

Property-based testing checks invariants hold for ANY input:

```python
# Example: Property-based test for sorting
@given(lists(integers()))
def test_sort_is_idempotent(xs):
    assert sorted(sorted(xs)) == sorted(xs)

@given(lists(integers()))
def test_sort_preserves_length(xs):
    assert len(sorted(xs)) == len(xs)

@given(lists(integers()))
def test_sort_produces_ordered_output(xs):
    result = sorted(xs)
    assert all(result[i] <= result[i+1] for i in range(len(result)-1))
```

### Phase 4: Validate with Mutation Testing

Mutation testing introduces bugs and verifies tests catch them:

```
Mutation operators:
- Replace operators (+ → -, == → !=)
- Remove statements
- Change return values
- Modify boundary conditions

Goal: >60% mutation score
```

## Property Categories

Research shows these property types are most effective:

| Property Type | Effectiveness | Example |
|--------------|---------------|---------|
| Exception checking | 19x baseline | "Should not throw for valid input" |
| Collection inclusion | 19x baseline | "Output contains all input elements" |
| Type checking | 19x baseline | "Returns expected type" |
| Idempotency | High | "f(f(x)) == f(x)" |
| Commutativity | High | "f(a,b) == f(b,a)" |
| Associativity | High | "f(f(a,b),c) == f(a,f(b,c))" |
| Round-trip | High | "decode(encode(x)) == x" |

## Language-Specific Tools

### Go
```bash
# Property-based testing
go get github.com/leanovate/gopter

# Mutation testing
go install github.com/zimmski/go-mutesting/cmd/go-mutesting@latest
```

### Python
```bash
# Property-based testing
uv add hypothesis

# Mutation testing
uvx mutmut run
```

### TypeScript
```bash
# Property-based testing
bun add -d fast-check

# Mutation testing
bun add -d @stryker-mutator/core
```

## Test Generation Templates

### Unit Test Template

```go
func Test<Function>_<Scenario>(t *testing.T) {
    // Arrange
    input := <setup test data>
    expected := <expected result>

    // Act
    result := <Function>(input)

    // Assert
    assert.Equal(t, expected, result)
}
```

### Property-Based Test Template (Go)

```go
func TestProperty_<Invariant>(t *testing.T) {
    properties := gopter.NewProperties(nil)

    properties.Property("<invariant description>", prop.ForAll(
        func(input <Type>) bool {
            result := <Function>(input)
            return <invariant condition>
        },
        <generator>,
    ))

    properties.TestingRun(t)
}
```

### Property-Based Test Template (Python)

```python
from hypothesis import given, strategies as st

@given(st.<strategy>())
def test_<invariant>(input):
    result = function(input)
    assert <invariant condition>
```

## Coverage Targets

### Minimum Thresholds

| Metric | Target | Tool |
|--------|--------|------|
| Line coverage | 80% | go test, pytest, bun test |
| Branch coverage | 70% | go test, pytest |
| Mutation score | 60% | go-mutesting, mutmut, stryker |

### Coverage Commands

```bash
# Go
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Python
uv run pytest --cov=src --cov-report=html

# TypeScript
bun test --coverage
```

## Mutation Testing Integration

### Go
```bash
# Run mutation testing
go-mutesting ./...

# With threshold
go-mutesting --score-threshold 60 ./...
```

### Python
```bash
# Run mutations
uvx mutmut run

# View results
uvx mutmut results
uvx mutmut html
```

### TypeScript
```bash
# Configure stryker
npx stryker init

# Run mutations
npx stryker run
```

## AI-Assisted Generation Process

### Step 1: Analyze

```
Read function under test:
- Extract signature
- Identify invariants
- List edge cases
- Note dependencies
```

### Step 2: Generate Unit Tests

```
Create tests for:
1. Happy path with typical input
2. Empty/nil/zero input
3. Boundary values (max int, empty string)
4. Error conditions
5. Each error return path
```

### Step 3: Generate Property Tests

```
Identify properties:
1. Type-level: "always returns correct type"
2. Structural: "preserves length", "maintains order"
3. Semantic: business logic invariants
4. Round-trip: encode/decode, serialize/deserialize
```

### Step 4: Validate

```
Run mutation testing:
- If score < 60%, add more tests
- Focus on surviving mutants
- Iterate until threshold met
```

## Quick Actions

### Generate Tests for New Function
```
1. Read function implementation
2. Identify inputs, outputs, invariants
3. Generate unit tests (happy + edge cases)
4. Generate property tests (invariants)
5. Run and verify tests pass
6. Run mutation testing
7. Add tests for surviving mutants
```

### Improve Coverage
```
1. Run coverage report
2. Identify uncovered lines
3. Analyze why uncovered (edge case? error path?)
4. Generate targeted tests
5. Verify coverage improved
```

### Validate Test Quality
```
1. Run mutation testing
2. Review surviving mutants
3. For each survivor:
   - Add test that would kill mutant
   - Or document why mutant is equivalent
4. Re-run until score > 60%
```

## Related Files

- `.claude/skills/tdd-red-phase/` - TDD red phase guidance
- `.claude/skills/tdd-green-phase/` - TDD green phase guidance
- `.claude/rules/tdd-requirements.md` - TDD requirements
- `.claude/rules/quality-gates.md` - Coverage thresholds

## Reference Files

For detailed information, see:
- `reference/property-patterns.md` - Common property patterns by domain
- `reference/mutation-operators.md` - Mutation operator reference
- `reference/generator-patterns.md` - Custom generator patterns
