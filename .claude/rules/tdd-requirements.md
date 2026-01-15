# TDD Requirements

Test-Driven Development is **mandatory** for guilde-lite.

---

## The TDD Cycle

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│    RED → GREEN → REFACTOR → (repeat)               │
│                                                     │
│    1. Write failing test (RED)                     │
│    2. Write minimal code to pass (GREEN)           │
│    3. Improve code quality (REFACTOR)              │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Phase Requirements

### RED Phase
- Write test BEFORE implementation
- Test must fail initially (proves test works)
- Test name describes expected behavior
- One assertion per test (prefer)

### GREEN Phase
- Write MINIMAL code to pass test
- No premature optimization
- No extra features
- Focus only on making the test pass

### REFACTOR Phase
- Improve code without changing behavior
- All tests must still pass
- Apply DRY, SOLID principles
- Update documentation if needed

---

## Coverage Requirements

| Type | Minimum | Target |
|------|---------|--------|
| Unit tests | 80% | 90% |
| Integration tests | 60% | 80% |
| E2E tests | Critical paths | Happy + error paths |

---

## Test Frameworks

| Language | Framework | Command |
|----------|-----------|---------|
| Go | go test | `go test -v ./...` |
| Python | pytest | `uv run pytest` |
| TypeScript | bun test | `bun test` |
| Rust | cargo test | `cargo test` |

---

## Test Structure

### Naming Convention
```
test_<function>_<scenario>_<expected_result>

# Examples:
test_user_create_valid_input_returns_user
test_user_create_duplicate_email_raises_conflict
test_auth_login_invalid_password_returns_401
```

### AAA Pattern
```python
def test_user_creation():
    # Arrange - Set up test data
    user_data = {"name": "Test", "email": "test@example.com"}

    # Act - Execute the code under test
    result = create_user(user_data)

    # Assert - Verify the outcome
    assert result.name == "Test"
    assert result.email == "test@example.com"
```

---

## When to Skip TDD

TDD may be relaxed for:
- Exploratory prototypes (marked `[PROTOTYPE]`)
- Configuration files
- Pure data structures
- External API mocks (test the integration, not the mock)

**Note:** Skipping requires explicit documentation of why.

---

## Enforcement

### PreToolUse Hook
Before writing implementation code, verify:
1. Test file exists for the module
2. New test written for the feature
3. Test fails (proving it's not trivially passing)

### PostToolUse Hook
After implementation changes:
1. Run relevant test suite
2. Verify test passes
3. Check coverage threshold

---

## Ralph Loop Integration

For continuous TDD with Claude Code:
```
/ralph-loop start
```

This activates the automated RED → GREEN → REFACTOR cycle with test verification at each step.
