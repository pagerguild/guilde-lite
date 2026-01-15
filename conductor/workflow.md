# Development Workflow

**Version:** 1.0.0
**Last Updated:** January 2026

---

## Task Execution Protocol

### 1. Select Task
- Review `conductor/tracks.md` for active tracks
- Open the active track's `plan.md`
- Choose next `[ ]` pending task

### 2. Mark In Progress
- Change `[ ]` to `[~]` in plan.md
- Commit: `conductor(plan): Mark task '{task}' as in progress`

### 3. TDD: Write Failing Tests (RED)
```bash
task tdd:red    # Set phase to RED
```
- Create test file BEFORE implementation
- Write tests that define expected behavior
- Run tests and **VERIFY THEY FAIL**
- Commit: `test: Add failing tests for {feature}`

### 4. TDD: Implement to Pass (GREEN)
```bash
task tdd:green  # Set phase to GREEN
```
- Write MINIMAL code to pass tests
- No extra features or optimizations
- Run tests and **VERIFY THEY PASS**
- Commit: `feat: Implement {feature}`

### 5. TDD: Refactor (REFACTOR)
```bash
task tdd:refactor  # Set phase to REFACTOR
```
- Improve code quality without changing behavior
- Extract duplication, rename for clarity
- Run tests and **VERIFY STILL PASSING**
- Commit: `refactor: Improve {feature}`

### 6. Verify Coverage
- Run coverage report
- Ensure >80% coverage for new code
- Add tests if coverage insufficient

### 7. Document Deviations
- If patterns differ from tech-stack.md, update it
- If new decisions made, add to CLAUDE.md
- Commit any documentation changes

### 8. Update Plan
- Change `[~]` to `[x]` in plan.md
- Append commit SHA: `- [x] Task name (abc1234)`
- Commit: `conductor(plan): Mark task '{task}' as complete`

---

## Quality Gates

### Before Marking Task Complete

**Code Quality:**
- [ ] All tests pass (`task test`)
- [ ] Code coverage >80% for new code
- [ ] No linting errors (`task lint`)
- [ ] Type safety enforced (no `any` types)

**Security:**
- [ ] Security scan passed (`task security`)
- [ ] No secrets in code
- [ ] Input validation in place

**Documentation:**
- [ ] Public APIs documented
- [ ] Complex logic commented
- [ ] CHANGELOG updated if user-facing

**Performance:**
- [ ] No N+1 queries
- [ ] Response time acceptable
- [ ] No memory leaks

---

## Phase Completion Protocol

### Before Marking Phase Complete

1. **Run Full Test Suite**
   ```bash
   task test
   ```

2. **Run Security Audit**
   ```bash
   task security
   ```

3. **Verify Coverage**
   ```bash
   task coverage
   ```

4. **Execute Manual Verification**
   - List specific steps in plan.md
   - Actually perform each step
   - Document any issues found

5. **AWAIT USER CONFIRMATION**
   > "Phase {N} tasks complete. Manual verification steps:
   > 1. {step 1}
   > 2. {step 2}
   >
   > Does this meet your expectations? (yes/no)"

   **NEVER proceed without explicit "yes"**

6. **Create Checkpoint Commit**
   ```bash
   git add -A
   git commit -m "conductor(checkpoint): Complete Phase {N} - {phase name}"
   git notes add -m "Phase {N} checkpoint: {summary}" HEAD
   ```

7. **Update Track Status**
   - Update phase status in plan.md
   - Update tracks.md if track complete

---

## Commit Message Convention

### Format
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no logic change |
| `refactor` | Code change, no feature/fix |
| `test` | Adding tests |
| `chore` | Maintenance, tooling |
| `conductor` | Conductor workflow updates |

### Scopes

| Scope | Description |
|-------|-------------|
| `plan` | Track plan updates |
| `checkpoint` | Phase checkpoints |
| `spec` | Specification changes |
| `track` | Track management |

### Examples

```bash
# Task in progress
conductor(plan): Mark task 'Create API endpoint' as in progress

# Feature implementation
feat(api): Add user registration endpoint

# Test addition
test(api): Add tests for user registration

# Task complete
conductor(plan): Mark task 'Create API endpoint' as complete (abc1234)

# Phase checkpoint
conductor(checkpoint): Complete Phase 2 - API Development
```

---

## Error Recovery Protocol

### Tool Call Failure
1. **HALT** execution immediately
2. Announce the failure to user
3. Wait for user instructions
4. Do NOT retry automatically

### Test Failure
1. Debug for maximum 2 attempts
2. If still failing, escalate to user
3. Do NOT mark task complete with failing tests

### Missing Files
1. **HALT** and announce missing files
2. Instruct user to run `/conductor:setup`
3. Do NOT create conductor files manually

### Confirmation Required
1. Always **PAUSE** for user input
2. Never proceed without explicit "yes"
3. Document the confirmation in commit message

---

## Subagent Delegation

### When to Use Subagents

| Scenario | Agent | Model |
|----------|-------|-------|
| Explore codebase | `context-explorer` | Haiku |
| Write specifications | `spec-builder` | Sonnet |
| Design architecture | `backend-architect` | Opus |
| Implement frontend | `frontend-developer` | Sonnet |
| Write tests | `test-automator` | Sonnet |
| Review code | `code-reviewer` | Opus |
| Security audit | `security-auditor` | Opus |

### Parallel Execution

For independent tasks, launch subagents in parallel:

```
Use Task tool with subagent_type="backend-architect"
  Prompt: "Design API for user registration"

Use Task tool with subagent_type="test-automator"
  Prompt: "Write test suite for user registration"

(Both run in parallel, then integrate results)
```

---

## Session Management

### Starting a Session
1. Run `claude --continue` to resume last session
2. Or `claude --resume <id>` for specific session
3. Check `conductor/tracks.md` for active work

### Ending a Session
1. Complete current task if possible
2. If incomplete, save progress:
   - Commit any changes
   - Update plan.md with progress
   - Create SESSION_HANDOFF.md if complex
3. Use `/compact focus on {current work}` if needed

### Resuming Work
1. Read SESSION_HANDOFF.md if present
2. Check git status for uncommitted changes
3. Review plan.md for current task
4. Continue from last checkpoint

---

## TDD Workflow Details

### Phase Tracking

The TDD enforcer tracks your current phase:

```bash
# Check current phase
task tdd:status

# Move to next phase
task tdd:next

# Set specific phase
task tdd:red       # Write failing tests
task tdd:green     # Make tests pass
task tdd:refactor  # Improve code
```

### TDD Commands

| Command | Description |
|---------|-------------|
| `/tdd status` | Show current TDD phase |
| `/tdd red` | Start RED phase |
| `/tdd green` | Start GREEN phase |
| `/tdd refactor` | Start REFACTOR phase |
| `/tdd next` | Move to next phase |
| `/tdd check <file>` | Check if tests exist |
| `/tdd coverage` | Show coverage report |

### Test File Conventions

| Language | Source File | Test File |
|----------|-------------|-----------|
| Go | `user.go` | `user_test.go` |
| Python | `user.py` | `test_user.py` |
| TypeScript | `user.ts` | `user.test.ts` |
| Rust | `user.rs` | `tests/user.rs` |

### TDD + Multi-Agent Integration

The TDD workflow integrates with multi-agent review:

1. **RED Phase**: Write tests (triggers code-review reminder)
2. **GREEN Phase**: Implement (triggers code-review reminder)
3. **REFACTOR Phase**: Improve (triggers code-review reminder)
4. **Review**: Run code-reviewer agent before commit

### Ralph Loop Integration

For continuous TDD with automated test execution:

```bash
/ralph-loop start
```

This activates the automated RED → GREEN → REFACTOR cycle with test verification at each step.

---

## References

- [Multi-Agent Workflow Architecture](../docs/MULTI-AGENT-WORKFLOW.md)
- [TDD Requirements](.claude/rules/tdd-requirements.md)
- [Claude Code Memory](https://code.claude.com/docs/en/memory)
- [Claude Code Checkpointing](https://code.claude.com/docs/en/checkpointing)
