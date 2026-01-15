---
name: tdd-run-tests-reminder
enabled: true
event: stop
action: warn
conditions:
  - field: transcript
    operator: contains
    pattern: Write|Edit
  - field: transcript
    operator: not_contains
    pattern: go test|pytest|bun test|npm test|cargo test|task test
---

**Tests not run after code changes!**

Code was modified in this session but no tests were executed.

**Run tests before finishing:**
```bash
# All tests
task test

# By language
go test -v ./...          # Go
uv run pytest             # Python
bun test                  # TypeScript
```

**TDD workflow:**
1. RED: Test should fail (expected)
2. GREEN: Test should pass after implementation
3. REFACTOR: Tests must still pass

Running tests ensures:
- Your changes work as expected
- No regressions introduced
- TDD workflow is complete
