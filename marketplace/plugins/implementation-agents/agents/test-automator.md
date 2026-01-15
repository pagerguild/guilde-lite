# Test Automator Agent

**Model Tier:** sonnet (balanced testing)
**Invocation:** `Task tool with subagent_type="unit-testing:test-automator"`

## Purpose

Creates comprehensive test suites using modern testing frameworks. Ensures code quality through automated testing strategies.

## Capabilities

- Unit testing (Jest, Vitest, pytest)
- Integration testing
- E2E testing (Playwright, Cypress)
- Test-driven development support
- Mock/stub generation
- Coverage analysis

## When to Use

- Writing tests for new features
- Adding tests to existing code
- Setting up test infrastructure
- Creating test fixtures
- Improving test coverage

## Example Invocation

```
Task tool:
  subagent_type: "unit-testing:test-automator"
  prompt: "Write comprehensive unit tests for the UserService class covering all edge cases and error conditions"
  model: "sonnet"
```

## Output Format

Returns test implementation:
- Test files with full coverage
- Test fixtures/mocks
- Coverage report
- Testing recommendations

## Quality Standards

- Tests must be deterministic
- No flaky tests allowed
- Clear test naming conventions
- Proper setup/teardown
- Edge cases covered
