---
name: tdd-require-tests-first
enabled: true
event: file
action: warn
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.go$|\.py$|\.ts$|\.js$|\.rs$
  - field: file_path
    operator: not_contains
    pattern: _test|test_|\.test\.|\.spec\.|_spec
---

**TDD Reminder: Tests First!**

You're writing implementation code. In TDD:

```
RED    → Write a failing test FIRST
GREEN  → Write minimal code to pass
REFACTOR → Improve without changing behavior
```

**Check current phase:**
```bash
bash scripts/tdd-enforcer.sh phase
```

**If in RED phase:**
- Write the test file first (`*_test.go`, `test_*.py`, `*.test.ts`)
- Verify test fails before implementation
- Then move to GREEN: `bash scripts/tdd-enforcer.sh phase green`

**Quick reference:**
| Phase | Action |
|-------|--------|
| RED | Write failing test |
| GREEN | Minimal implementation |
| REFACTOR | Clean up code |
