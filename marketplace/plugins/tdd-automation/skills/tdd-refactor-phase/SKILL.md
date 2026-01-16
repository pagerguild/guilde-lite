---
name: tdd-refactor-phase
description: |
  TDD Refactor Phase expert. Activate when:
  - Tests are passing, need to improve code quality
  - User mentions "refactor", "clean up", "improve code"
  - Applying DRY, SOLID, or design patterns
  - Code review findings need addressing
  Auto-triggers on: refactoring, code improvement, cleanup, tech debt
---

# TDD Refactor Phase: Improve Code Quality

You are in the **REFACTOR** phase of Test-Driven Development.

## Your Goal

Improve code quality **without changing behavior**. All tests must continue to pass.

## Refactor Phase Rules

1. **Tests Must Pass**: Run tests before AND after every change
2. **No New Features**: Don't add functionality (that requires new tests)
3. **Small Steps**: Make one improvement at a time
4. **Behavior Preserved**: External behavior must not change

## Refactoring Checklist

### Code Smells to Address

- [ ] **Duplication**: Extract repeated code into functions
- [ ] **Long Functions**: Break into smaller, focused functions
- [ ] **Magic Numbers**: Replace with named constants
- [ ] **Poor Names**: Rename variables/functions for clarity
- [ ] **Deep Nesting**: Flatten with early returns or extraction
- [ ] **Large Classes**: Split into smaller, focused classes

### SOLID Principles

- **S**ingle Responsibility: One reason to change
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable
- **I**nterface Segregation: Many specific interfaces over one general
- **D**ependency Inversion: Depend on abstractions, not concretions

### Clean Code Patterns

```python
# Before (GREEN phase code)
def process(d):
    if d['type'] == 'A':
        return d['value'] * 2
    elif d['type'] == 'B':
        return d['value'] * 3
    return d['value']

# After (REFACTOR phase)
MULTIPLIERS = {'A': 2, 'B': 3}

def calculate_value(data: dict) -> int:
    """Calculate value with type-specific multiplier."""
    multiplier = MULTIPLIERS.get(data['type'], 1)
    return data['value'] * multiplier
```

## Workflow

1. **Run tests** - ensure they pass before starting
2. **Identify improvement** - pick ONE thing to improve
3. **Make the change** - small, focused refactoring
4. **Run tests** - verify they still pass
5. **Repeat** - or move to next RED phase

## Commands

```bash
# Verify you're in REFACTOR phase
bash scripts/tdd-enforcer.sh phase

# Run tests (must pass!)
bash scripts/tdd-enforcer.sh run <file>

# Check coverage hasn't dropped
bash scripts/tdd-enforcer.sh coverage

# When done, return to RED for next feature
bash scripts/tdd-enforcer.sh phase red
```

## Safe Refactorings

These preserve behavior:

- **Rename**: Variable, function, class names
- **Extract**: Pull code into new function/method
- **Inline**: Replace function call with its body
- **Move**: Relocate code to better location
- **Introduce Constant**: Replace magic values

## When to Stop Refactoring

- Tests still pass
- Code is "good enough" (not perfect!)
- Next feature waiting
- Time-boxed limit reached

## After Refactor Phase

Once code quality is improved and **tests pass**:

```bash
# Return to RED for next feature
bash scripts/tdd-enforcer.sh phase red
```

The cycle continues: RED → GREEN → REFACTOR → RED → ...

## Common Mistakes to Avoid

- Refactoring without running tests
- Adding new functionality during refactor
- Making too many changes at once
- Chasing perfection (diminishing returns)
- Breaking existing tests
