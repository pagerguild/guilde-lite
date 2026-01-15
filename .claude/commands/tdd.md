---
name: tdd
description: TDD workflow management - phase tracking, test validation, and coverage
arguments:
  - name: action
    description: Action to perform (status, red, green, refactor, next, check, coverage, help)
    required: false
    default: status
---

# /tdd Command

Test-Driven Development workflow management.

## TDD Cycle

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

## Actions

### `/tdd` or `/tdd status`

Show current TDD status:

```bash
bash scripts/tdd-enforcer.sh status
```

### `/tdd red`

Start RED phase - write failing tests:

```bash
bash scripts/tdd-enforcer.sh phase red
```

**Rules:**
- Write test BEFORE implementation
- Test must fail initially
- One behavior per test
- Descriptive test names

### `/tdd green`

Start GREEN phase - make tests pass:

```bash
bash scripts/tdd-enforcer.sh phase green
```

**Rules:**
- Write MINIMAL code to pass
- No extra features
- No premature optimization
- It's OK to hardcode if tests don't require more

### `/tdd refactor`

Start REFACTOR phase - improve code:

```bash
bash scripts/tdd-enforcer.sh phase refactor
```

**Rules:**
- All tests must still pass
- No new functionality
- Small, incremental improvements
- Apply DRY, SOLID principles

### `/tdd next`

Move to next phase in the cycle:

```bash
bash scripts/tdd-enforcer.sh phase next
```

RED → GREEN → REFACTOR → RED → ...

### `/tdd check <file>`

Check if tests exist for a file:

```bash
bash scripts/tdd-enforcer.sh check src/user.py
```

### `/tdd coverage`

Show test coverage report:

```bash
bash scripts/tdd-enforcer.sh coverage
```

### `/tdd help`

Show this help information.

## Test File Conventions

| Language | Implementation | Test File |
|----------|---------------|-----------|
| Go | `user.go` | `user_test.go` |
| Python | `user.py` | `test_user.py` |
| TypeScript | `user.ts` | `user.test.ts` |
| Rust | `user.rs` | `tests/user.rs` |

## Test Naming

```
test_<function>_<scenario>_<expected_result>

Examples:
- test_user_create_valid_input_returns_user
- test_order_total_with_discount_applies_percentage
- test_auth_login_wrong_password_returns_401
```

## Integration with Ralph Loop

For continuous TDD with automated cycles:

```
/ralph-loop start
```

## Related Commands

- `task tdd:status` - Show TDD status
- `task tdd:red` - Set RED phase
- `task tdd:green` - Set GREEN phase
- `task tdd:refactor` - Set REFACTOR phase
- `task tdd:next` - Move to next phase
- `task tdd:coverage` - Show coverage
