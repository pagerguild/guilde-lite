---
name: tdd-red-phase
description: |
  TDD Red Phase expert. Activate when:
  - Starting new feature development with TDD
  - User mentions "write test first", "failing test", "red phase"
  - Need to design test cases before implementation
  - Questions about test structure, assertions, test naming
  Auto-triggers on: test design, test-first development, TDD start
---

# TDD Red Phase: Write Failing Tests First

You are in the **RED** phase of Test-Driven Development.

## Your Goal

Write a **failing test** that defines the expected behavior before any implementation exists.

## Red Phase Rules

1. **Test First**: Write the test BEFORE any implementation code
2. **Must Fail**: The test MUST fail initially (proves it's not trivially passing)
3. **One Behavior**: Each test should verify ONE specific behavior
4. **Descriptive Name**: Test name should describe the expected behavior

## Test Naming Convention

```
test_<function>_<scenario>_<expected_result>

Examples:
- test_user_create_valid_input_returns_user
- test_order_calculate_with_discount_applies_percentage
- test_auth_login_wrong_password_returns_401
```

## Test Structure (AAA Pattern)

```python
def test_feature_scenario_expected():
    # Arrange - Set up test data and preconditions
    input_data = {...}

    # Act - Execute the code under test
    result = function_under_test(input_data)

    # Assert - Verify the expected outcome
    assert result == expected_value
```

## Language-Specific Test Files

| Language | Test File Pattern | Example |
|----------|------------------|---------|
| Go | `*_test.go` | `user_test.go` |
| Python | `test_*.py` | `test_user.py` |
| TypeScript | `*.test.ts` | `user.test.ts` |
| Rust | `tests/*.rs` or inline `#[cfg(test)]` | `tests/user.rs` |

## Workflow

1. **Identify the behavior** to implement
2. **Write the test** that verifies this behavior
3. **Run the test** - it MUST fail (red)
4. **Verify failure reason** - should fail because code doesn't exist yet

## Commands

```bash
# Set phase to RED
bash scripts/tdd-enforcer.sh phase red

# Check current phase
bash scripts/tdd-enforcer.sh phase

# Run tests (expect failure)
bash scripts/tdd-enforcer.sh run <file>
```

## After Red Phase

Once your test is written and **failing for the right reason**:

```bash
# Move to GREEN phase
bash scripts/tdd-enforcer.sh phase green
```

Then write the minimal implementation to make the test pass.

## Common Mistakes to Avoid

- Writing implementation before tests
- Writing tests that pass immediately (trivial tests)
- Testing multiple behaviors in one test
- Vague test names like `test_user` or `test_1`
