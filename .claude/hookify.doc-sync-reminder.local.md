---
name: doc-sync-reminder
enabled: true
event: file
action: warn
conditions:
  - field: file_path
    operator: regex_match
    pattern: config|schema|api|route|endpoint|handler|\.proto$|openapi|swagger
---

**Documentation may need updating**

You're modifying a file that likely affects documentation:

| File Type | Docs to Update |
|-----------|----------------|
| API routes/handlers | API docs, OpenAPI spec |
| Config files | Configuration guide |
| Schema/Proto | Data model docs |
| Public interfaces | Reference docs |

**Check if docs need sync:**
```bash
bash scripts/doc-sync-check.sh check <file>
```

**Remember to update:**
- [ ] README if behavior changes
- [ ] API documentation for endpoint changes
- [ ] CHANGELOG for user-facing changes
- [ ] Comments/docstrings for code changes

Run `/docs-sync` to check all documentation.
