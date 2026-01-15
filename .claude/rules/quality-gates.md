# Quality Gates

Rules for code quality enforcement in guilde-lite.

---

## Pre-Commit Gates

### 1. Test Coverage
- **Threshold:** 80% minimum for new code
- **Enforcement:** `task test:coverage` must pass
- **Bypass:** Only with explicit user approval and documented reason

### 2. Linting
- **Go:** `golangci-lint run` - zero errors
- **Python:** `ruff check` - zero errors
- **TypeScript:** `bun run lint` - zero errors
- **Rust:** `cargo clippy` - zero warnings

### 3. Type Safety
- **TypeScript:** Strict mode enabled, no `any` types without justification
- **Python:** Type hints required for public APIs
- **Go:** `go vet` must pass

---

## Pre-Merge Gates

### 4. Review Requirements
- All changes require review before merge
- Architecture changes require consensus (2+ perspectives)
- Security-sensitive code requires security review

### 5. Documentation
- Public APIs must have docstrings
- Breaking changes must update CHANGELOG
- New features must update relevant docs

### 6. CI Pipeline
- All CI checks must pass
- No force-merge without explicit approval

---

## Blocked Operations

The following operations are **always blocked**:

```yaml
destructive_commands:
  - "rm -rf /"
  - "rm -rf ~"
  - "mkfs"
  - "dd if=/dev/zero"

git_operations:
  - "git push --force" to main/master
  - "git push --force-with-lease" to main/master
  - "git reset --hard" on shared branches

publishing:
  - "npm publish" without approval
  - "cargo publish" without approval
  - "twine upload" without approval
```

---

## Gate Bypass Protocol

When a gate must be bypassed:

1. **Document reason** in commit message
2. **Get explicit approval** from user
3. **Create follow-up task** to address the bypass
4. **Never bypass** security gates without review
