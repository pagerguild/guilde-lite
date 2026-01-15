# tdd-automation

Test-driven development workflow with red/green/refactor phase enforcement.

## Components

### Commands

| Command | Description |
|---------|-------------|
| `/tdd` | TDD workflow management - phase tracking, test validation, coverage |

### Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| `tdd-red-phase` | "write failing test", "TDD red phase" | Guide writing failing tests first |
| `tdd-green-phase` | "make test pass", "TDD green phase" | Guide minimal implementation |
| `tdd-refactor-phase` | "refactor code", "TDD refactor phase" | Guide code improvement |

## Usage

```bash
# Check TDD status
/tdd status

# Start RED phase (write failing tests)
/tdd red

# Move to GREEN phase (implement)
/tdd green

# Move to REFACTOR phase (improve)
/tdd refactor

# Check coverage
/tdd coverage
```

## TDD Workflow

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

## Installation

```bash
# Add the marketplace (if not already added)
claude plugin marketplace add ./marketplace

# Install this plugin
claude plugin install tdd-automation@guilde-plugins
```
