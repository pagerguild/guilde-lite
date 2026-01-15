# INFRA-001: Jujutsu & Agentic-Jujutsu Integration

**Track ID:** INFRA-001
**Title:** Jujutsu VCS & Agent Coordination Integration
**Type:** Infrastructure
**Priority:** P1
**Status:** Complete
**Completed:** 2026-01-15
**Created:** 2026-01-15

---

## Summary

Integrate Jujutsu (jj) version control and agentic-jujutsu agent coordination tools to enable conflict-free parallel subagent operations. This replaces git-based workflows for multi-agent scenarios.

---

## Problem Statement

When multiple Claude Code subagents work in parallel:
1. Git operations can conflict (lock contention, merge conflicts)
2. Agents may overwrite each other's work
3. No coordination mechanism exists to prevent race conditions
4. Recovery from conflicts is manual and error-prone

---

## Solution

Implement jj/agentic-jujutsu integration providing:
1. **jj-mcp-server** - MCP tools for standard jj operations
2. **agentic-jujutsu** - Native module with agent coordination, AgentDB, quantum signing
3. **Agent Coordination** - Register agents, detect conflicts, coordinate operations
4. **Documentation** - Clear guidance for using jj in multi-agent workflows

---

## Acceptance Criteria

### AC-1: MCP Servers Functional ✅
- [x] jj-mcp-server responds to MCP initialize request
- [x] agentic-jujutsu MCP server responds to MCP initialize request
- [x] Both servers listed in .mcp.json with valid configuration
- [x] `/doctor` shows no warnings for MCP configuration (fixed: removed VS Code syntax)

### AC-2: Agent Coordination Working ✅
- [x] `enableAgentCoordination()` succeeds without error
- [x] Multiple agents can be registered (4+ agents)
- [x] `listAgents()` returns registered agents
- [x] `getCoordinationStats()` returns valid statistics
- [x] `checkAgentConflicts()` detects file-level conflicts

### AC-3: Quantum Signing Functional ✅
- [x] `generateSigningKeypair()` returns valid keypair
- [x] `signMessage()` produces signature (requires byte array API)
- [x] `verifySignature()` validates correct signatures
- [x] `verifySignature()` rejects invalid signatures

### AC-4: AgentDB Learning Active ✅
- [x] `getLearningStats()` returns data
- [x] Operations are tracked
- [x] Stats persist across operations

### AC-5: Documentation Complete ✅
- [x] Integration guide created (docs/JJ-INTEGRATION.md - 1511 lines)
- [x] API reference documented
- [x] Usage examples provided
- [x] Troubleshooting section included

### AC-6: Security Review Passed ✅
- [x] No hardcoded secrets in configuration
- [x] No command injection vulnerabilities (note: jj-mcp-server uses execSync - upstream)
- [x] Dependencies audited (npm audit: 0 vulnerabilities)
- [x] MCP server sandboxed appropriately

### AC-7: Code Review Passed ✅
- [x] Code follows project conventions
- [x] No obvious bugs or issues
- [x] Error handling is appropriate
- [x] Test coverage adequate (9 test cases)

---

## Technical Specifications

### Components

| Component | Type | Location |
|-----------|------|----------|
| jj-mcp-server | npm package | node_modules/jj-mcp-server |
| agentic-jujutsu | npm package (local) | node_modules/agentic-jujutsu |
| MCP config | JSON | .mcp.json |
| Test script | JavaScript | scripts/test-agent-coordination.js |
| Documentation | Markdown | docs/JJ-INTEGRATION.md |

### Dependencies

```json
{
  "jj-mcp-server": "^1.0.1",
  "agentic-jujutsu": "file:./vendor/agentic-jujutsu-2.3.6.tgz"
}
```

### MCP Server Configuration

```json
{
  "mcpServers": {
    "jj-mcp-server": {
      "command": "npx",
      "args": ["jj-mcp-server"]
    },
    "agentic-jujutsu": {
      "command": "node",
      "args": ["node_modules/agentic-jujutsu/bin/mcp-server.js"]
    }
  }
}
```

---

## Out of Scope

- Full subagent prompt integration (separate track)
- Git interception hooks (separate track)
- Workspace isolation implementation (separate track)
- Remote repository operations (push/pull/fetch)

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Native module compatibility | Build failures | Pre-built for darwin-arm64 |
| API version mismatch | Runtime errors | Pin versions, validate at startup |
| Performance overhead | Slow operations | Benchmarked at <1ms overhead |

---

## Success Metrics

- All acceptance criteria pass
- No security vulnerabilities (npm audit)
- Code review approval
- Documentation complete and accurate

---

## References

- [Jujutsu VCS](https://github.com/martinvonz/jj)
- [agentic-flow repo](https://github.com/ruvnet/agentic-flow)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [docs/JJ-MULTI-AGENT-PATTERNS.md](../../docs/JJ-MULTI-AGENT-PATTERNS.md)
