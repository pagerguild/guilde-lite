# Coding Standards

Language-specific conventions for guilde-lite.

---

## General Principles

1. **Clarity over cleverness** - Write readable code
2. **Explicit over implicit** - No magic, no hidden behavior
3. **Fail fast** - Validate early, error explicitly
4. **Minimal dependencies** - Prefer standard library

---

## Go Standards

### Naming
- **Exported:** `PascalCase` (e.g., `UserService`)
- **Unexported:** `camelCase` (e.g., `userCount`)
- **Packages:** lowercase, single word (e.g., `auth`, `db`)

### Error Handling
```go
// Good - explicit error handling
if err != nil {
    return fmt.Errorf("failed to connect: %w", err)
}

// Bad - silent failure
_ = doSomething()
```

### Structure
- Group imports: stdlib, external, internal
- One type per file for complex types
- Tests in `*_test.go` files

---

## Python Standards

### Naming
- **Functions/variables:** `snake_case`
- **Classes:** `PascalCase`
- **Constants:** `SCREAMING_SNAKE_CASE`
- **Private:** `_single_underscore`

### Type Hints
```python
# Required for public APIs
def process_user(user_id: int, options: dict[str, Any] | None = None) -> User:
    ...
```

### Imports
```python
# Order: stdlib, third-party, local
from __future__ import annotations

import os
from pathlib import Path

import httpx
from pydantic import BaseModel

from .models import User
```

---

## TypeScript Standards

### Naming
- **Variables/functions:** `camelCase`
- **Classes/types:** `PascalCase`
- **Constants:** `SCREAMING_SNAKE_CASE`
- **Files:** `kebab-case.ts`

### Type Safety
```typescript
// Good - explicit types
function getUser(id: string): Promise<User> { ... }

// Bad - implicit any
function getUser(id) { ... }
```

### Async/Await
- Always use `async/await` over `.then()` chains
- Handle errors with try/catch or Result types

---

## Rust Standards

### Naming
- **Functions/variables:** `snake_case`
- **Types/traits:** `PascalCase`
- **Constants:** `SCREAMING_SNAKE_CASE`
- **Modules:** `snake_case`

### Error Handling
```rust
// Use Result for recoverable errors
fn parse_config(path: &Path) -> Result<Config, ConfigError> { ... }

// Use panic only for unrecoverable states
assert!(invariant, "This should never happen");
```

---

## Common Anti-Patterns

### Avoid
- Magic numbers without constants
- Deep nesting (max 3 levels)
- Functions longer than 50 lines
- Files longer than 500 lines
- Comments that explain "what" instead of "why"

### Prefer
- Early returns over nested conditionals
- Composition over inheritance
- Small, focused functions
- Descriptive variable names
