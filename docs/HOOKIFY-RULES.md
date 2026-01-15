# Hookify Rules Configuration

This document describes the hookify rules configured for guilde-lite to enforce best practices and prevent mistakes.

## Overview

Hookify rules are stored in `.claude/hookify.*.local.md` files with YAML frontmatter defining the rule behavior and markdown body containing the message shown when triggered.

## Configured Rules

| Rule | Event | Action | Purpose |
|------|-------|--------|---------|
| `block-destructive-commands` | bash | block | Prevents dangerous system commands |
| `warn-secrets-exposure` | file | warn | Alerts when editing sensitive files |
| `require-confirmation-dangerous` | bash | warn | Requires confirmation for risky operations |
| `tdd-require-tests-first` | file | warn | Reminds to write tests before implementation |
| `tdd-run-tests-reminder` | stop | warn | Reminds to run tests before finishing |
| `doc-sync-reminder` | file | warn | Reminds to update docs when changing APIs |
| `track-progress-reminder` | stop | warn | Reminds to track progress for multi-step tasks |

## Rule Categories

### Safety Rules

#### block-destructive-commands
**File:** `.claude/hookify.block-destructive.local.md`
**Action:** BLOCK

Blocks potentially catastrophic commands:
- `rm -rf /` or `rm -rf ~`
- `mkfs` (filesystem formatting)
- `dd if=/dev/zero` (disk overwriting)
- `chmod -R 777 /` (permission stripping)

#### warn-secrets-exposure
**File:** `.claude/hookify.warn-secrets.local.md`
**Action:** WARN

Warns when editing files that may contain secrets:
- `.env` files
- Files with "credentials" or "secrets" in name
- Private keys (`.pem`, `.key`, `id_rsa`)
- Certificates (`.p12`, `.pfx`)

#### require-confirmation-dangerous
**File:** `.claude/hookify.require-confirmation.local.md`
**Action:** WARN

Warns before dangerous git/publish operations:
- `git push --force`
- `git reset --hard`
- `npm publish`, `cargo publish`, `twine upload`
- `docker push`

### TDD Rules

#### tdd-require-tests-first
**File:** `.claude/hookify.tdd-tests-first.local.md`
**Action:** WARN

Reminds about TDD when writing implementation files (`.go`, `.py`, `.ts`, `.js`, `.rs`) that aren't test files. Encourages checking the current TDD phase before writing implementation.

#### tdd-run-tests-reminder
**File:** `.claude/hookify.tdd-auto-test.local.md`
**Action:** WARN

Triggers at session stop if code was modified but no test commands were run. Ensures the TDD cycle is complete.

### Documentation Rules

#### doc-sync-reminder
**File:** `.claude/hookify.doc-sync-reminder.local.md`
**Action:** WARN

Reminds to update documentation when editing:
- Config files
- API routes/handlers
- Schema files
- OpenAPI/Swagger specs

### Workflow Rules

#### track-progress-reminder
**File:** `.claude/hookify.track-progress.local.md`
**Action:** WARN

Triggers at session stop if substantial work was done but TodoWrite wasn't used for tracking. Encourages proper progress visibility.

## Managing Rules

### List All Rules

```bash
ls .claude/hookify.*.local.md
```

Or use the hookify plugin:
```
/hookify:list
```

### Enable/Disable a Rule

Edit the rule file and change `enabled: true` to `enabled: false`:

```yaml
---
name: rule-name
enabled: false  # Disabled
event: bash
action: warn
---
```

### Create a New Rule

Use the hookify command:
```
/hookify Block commands that use sudo
```

Or create manually:
```bash
cat > .claude/hookify.my-rule.local.md << 'EOF'
---
name: my-rule
enabled: true
event: bash
pattern: sudo
action: warn
---

Your warning message here.
EOF
```

### Delete a Rule

```bash
rm .claude/hookify.my-rule.local.md
```

## Rule Schema

```yaml
---
name: string           # Unique rule identifier
enabled: true|false    # Whether rule is active
event: bash|file|stop  # When to trigger
pattern: regex         # Pattern to match (for bash/file events)
action: block|warn     # Block execution or just warn
conditions:            # Optional complex conditions
  - field: file_path|transcript
    operator: contains|not_contains|regex_match
    pattern: string
---

Markdown message shown when rule triggers.
```

## Events

| Event | Trigger | Use Case |
|-------|---------|----------|
| `bash` | Before bash command | Block/warn on dangerous commands |
| `file` | When editing file | Warn on sensitive file edits |
| `stop` | Before session ends | Ensure tasks are complete |

## Actions

| Action | Behavior |
|--------|----------|
| `block` | Prevents the operation |
| `warn` | Shows warning but allows proceeding |

## Integration with Hooks

Hookify rules complement the hooks in `.claude/settings.json`. The main difference:

- **Hooks (settings.json):** Run commands, track metrics, complex logic
- **Hookify rules (.local.md):** Pattern-based warnings/blocks, user-facing messages

Both can be used together for comprehensive workflow enforcement.

## Related

- [Quality Gates](.claude/rules/quality-gates.md)
- [Coding Standards](.claude/rules/coding-standards.md)
- [TDD Requirements](.claude/rules/tdd-requirements.md)
