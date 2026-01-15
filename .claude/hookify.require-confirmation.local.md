---
name: require-confirmation-dangerous
enabled: true
event: bash
pattern: git\s+push\s+.*--force|git\s+reset\s+--hard|npm\s+publish|cargo\s+publish|twine\s+upload|docker\s+push
action: warn
---

**Confirmation required for potentially dangerous operation**

This command has significant consequences:

| Command | Risk |
|---------|------|
| `git push --force` | Overwrites remote history, affects collaborators |
| `git reset --hard` | Discards uncommitted changes permanently |
| `npm/cargo/twine publish` | Publishes to public registry |
| `docker push` | Pushes image to registry |

**Before proceeding:**
1. Verify you have explicit user approval
2. Ensure you're targeting the correct branch/registry
3. Confirm this is intentional, not accidental
4. For publishing: verify version numbers and changelog

**Ask user:** "Please confirm you want to run this command."
