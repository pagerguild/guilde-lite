---
name: block-destructive-commands
enabled: true
event: bash
pattern: rm\s+-rf\s+[/~]|mkfs\s+|dd\s+if=/dev/zero|>\s*/dev/sd|chmod\s+-R\s+777\s+/
action: block
---

**BLOCKED: Destructive command detected!**

This command could cause irreversible damage:
- `rm -rf /` or `rm -rf ~` - Deletes critical system/user files
- `mkfs` - Formats filesystem, destroying all data
- `dd if=/dev/zero` - Overwrites disk with zeros
- `chmod -R 777 /` - Removes all security permissions

**What to do:**
1. Verify you really need this operation
2. Use a more targeted, safer approach
3. Create backups before proceeding
4. Ask user for explicit confirmation

This block is intentional to prevent accidents.
