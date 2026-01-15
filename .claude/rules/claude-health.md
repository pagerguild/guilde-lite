# Claude Code Health Requirements

Rules for maintaining a healthy Claude Code installation.

---

## Health Check Requirements

### Automated Checks (SessionStart)

The following are validated on every session start via `scripts/claude-health-check.sh`:

| Check | Requirement | Recovery |
|-------|-------------|----------|
| Claude installation | `claude` command available | `curl -fsSL https://claude.ai/install.sh \| bash` |
| settings.json | Valid JSON | Fix syntax errors |
| CLAUDE.md | Under 500 lines | Refactor using `.claude/rules/` |
| Rules directory | Files readable | Check permissions |
| MCP servers | Valid .mcp.json | Fix JSON syntax |
| Git | Available in PATH | Install git |

### Manual Checks (Periodic)

Run `claude doctor` manually at least:
- **Weekly** for active development
- **After updates** to Claude Code
- **When issues occur** with tool execution

```bash
# Interactive health check
claude doctor

# Non-interactive subset
bash scripts/claude-health-check.sh
```

---

## Configuration Validation

### settings.json Structure

Required structure for hooks:
```json
{
  "hooks": {
    "EventName": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "..."
          }
        ]
      }
    ]
  }
}
```

### Common Issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| Invalid JSON | Hooks don't trigger | Run `jq empty .claude/settings.json` |
| Missing hooks array | Schema validation fails | Wrap hooks in `{ "hooks": [...] }` |
| Large CLAUDE.md | Slow context loading | Extract rules to `.claude/rules/` |
| Stale plugins | Features missing | Run `claude mcp` to refresh |

---

## Hook Health

### SessionStart Hook Validation

The SessionStart hook should:
1. Load project context
2. Display active work status
3. Remind about multi-agent workflow
4. Run health check (optional)

### UserPromptSubmit Hook Validation

The UserPromptSubmit hook should:
1. Inject workflow reminders
2. Not block on failure
3. Be concise (under 500 chars)

---

## Recovery Procedures

### If hooks fail silently:

```bash
# 1. Validate JSON
jq empty .claude/settings.json

# 2. Check hook structure
jq '.hooks' .claude/settings.json

# 3. Test command manually
bash scripts/session-startup.sh
```

### If Claude Code is slow:

1. Check CLAUDE.md size: `wc -l CLAUDE.md`
2. Check plugin count: `jq '.enabledPlugins | length' .claude/settings.json`
3. Disable unused plugins in settings

### If MCP servers fail:

```bash
# Check configuration
jq '.' .mcp.json

# Restart MCP servers
claude mcp
```

---

## Enforcement

### PreToolUse (optional)

Before major operations, consider validating:
- Git working directory clean
- No pending hook errors
- Configuration files valid

### PostToolUse (optional)

After file modifications, could validate:
- JSON files still valid
- No syntax errors introduced

---

## Best Practices

1. **Run health check on project setup**
   ```bash
   bash scripts/claude-health-check.sh
   ```

2. **Run full doctor periodically**
   ```bash
   claude doctor
   ```

3. **Keep configuration minimal**
   - Only enable plugins you use
   - Keep CLAUDE.md under 500 lines
   - Use modular rules in `.claude/rules/`

4. **Monitor for warnings**
   - Address warnings before they become errors
   - Update Claude Code when prompted
