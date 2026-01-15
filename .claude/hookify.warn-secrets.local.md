---
name: warn-secrets-exposure
enabled: true
event: file
action: warn
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.env$|\.env\.|credentials|secrets|\.pem$|\.key$|id_rsa|\.p12$|\.pfx$
---

**Sensitive file detected**

You're editing a file that may contain sensitive data.

**Security checklist:**
- [ ] No hardcoded API keys, tokens, or passwords
- [ ] No database connection strings with credentials
- [ ] No private keys or certificates
- [ ] File is in `.gitignore` (if appropriate)
- [ ] Using environment variables or secrets manager

**Remember:**
- Never commit secrets to version control
- Use `.env.example` with placeholder values for documentation
- Consider using `sops` or `age` for encrypted secrets
