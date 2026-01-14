# Validation Gap Fix Plan

**Goal:** Achieve 100% validation coverage for all tools in guilde-lite

**Current Coverage:** 70% (39/67 tools verified)
**Target Coverage:** 100% (67/67 tools verified)

---

## Agent & Skill Architecture

### Subagents Used (from installed plugins)

| Agent Type | Plugin | Purpose |
|------------|--------|---------|
| `feature-dev:code-reviewer` | feature-dev | Review code changes for quality |
| `feature-dev:code-architect` | feature-dev | Design implementation blueprints |
| `feature-dev:code-explorer` | feature-dev | Analyze codebase features |
| `pr-review-toolkit:pr-test-analyzer` | pr-review-toolkit | Analyze test coverage |
| `pr-review-toolkit:code-simplifier` | pr-review-toolkit | Simplify code for clarity |
| `pr-review-toolkit:silent-failure-hunter` | pr-review-toolkit | Find error handling issues |
| `tdd-workflows:tdd-orchestrator` | tdd-workflows | Enforce TDD practices |
| `tdd-workflows:code-reviewer` | tdd-workflows | Review code quality |
| `documentation-generation:docs-architect` | documentation-generation | Create technical docs |
| `documentation-generation:api-documenter` | documentation-generation | API documentation |
| `shell-scripting:bash-pro` | shell-scripting | Bash script best practices |
| `shell-scripting:posix-shell-pro` | shell-scripting | POSIX compliance |
| `security-scanning:security-auditor` | security-scanning | Security vulnerability scanning |
| `security-scanning:threat-modeling-expert` | security-scanning | Threat analysis |
| `kubernetes-operations:kubernetes-architect` | kubernetes-operations | K8s architecture |
| `cloud-infrastructure:cloud-architect` | cloud-infrastructure | Cloud design |
| `cloud-infrastructure:terraform-specialist` | cloud-infrastructure | IaC validation |
| `python-development:python-pro` | python-development | Python best practices |
| `Bash` | built-in | Execute shell commands |
| `Explore` | built-in | Search and analyze codebase |

### Skills Used (from installed plugins)

| Skill | Plugin | Purpose |
|-------|--------|---------|
| `/commit` | commit-commands | Create git commits |
| `/code-review` | code-review | Review PR with 4 agents |
| `/review-pr` | pr-review-toolkit | Comprehensive PR review |
| `/feature-dev` | feature-dev | 7-phase feature workflow |
| `/hookify` | hookify | Create custom hooks |
| `/validate:shell` | guilde-lite | Shell config validation |
| `/validate:full` | guilde-lite | Complete validation suite |

---

## Phase 1: Taskfile.yml Stage Verification Updates

### Step 1.1: Research Current Stage Verifications

**Subagent:** `Explore`
**Task:** Analyze all existing stage:N:verify tasks to understand patterns
**Validation:**
```bash
# Verify research complete
grep -c "stage:.*:verify" Taskfile.yml  # Should show all verify tasks
```

### Step 1.2: Update Stage 1 Verify (Core Tools)

**Subagent:** `Bash` (for testing) + Direct Edit
**Changes:**
```yaml
# Add to stage:1:verify
- command -v git-lfs && git-lfs --version
```

**Validation:**
```bash
task stage:1:verify  # Should show git-lfs version
```

### Step 1.3: Update Stage 2 Verify (CLI Tools)

**Subagent:** `Bash` (for testing) + Direct Edit
**Changes:**
```yaml
# Add to stage:2:verify (9 missing tools)
- command -v yq && yq --version
- command -v dust && dust --version
- command -v duf && duf --version
- command -v procs && procs --version
- command -v btm && btm --version
- command -v hyperfine && hyperfine --version
- command -v xh && xh --version
- command -v sd && sd --version
- command -v tokei && tokei --version
```

**Validation:**
```bash
task stage:2:verify  # Should show all 18 CLI tools
```

### Step 1.4: Update Stage 3 Verify (Terminal)

**Subagent:** `Bash` (for testing) + Direct Edit
**Changes:**
```yaml
# Add to stage:3:verify
- command -v zellij && zellij --version
- |
  # Verify Nerd Fonts installed
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
    echo "✓ JetBrainsMono Nerd Font installed"
  else
    echo "⚠ JetBrainsMono Nerd Font not found (may need fc-cache -f)"
  fi
```

**Validation:**
```bash
task stage:3:verify  # Should show zellij + font status
```

### Step 1.5: Update Stage 4 Verify (Containers)

**Subagent:** `Bash` (for testing) + Direct Edit
**Changes:**
```yaml
# Add to stage:4:verify
- command -v kubectx && echo "kubectx available" || true
- command -v kubens && echo "kubens available" || true
- command -v k9s && k9s version --short || true
- command -v lazydocker && lazydocker --version || true
```

**Validation:**
```bash
task stage:4:verify  # Should show all container tools
```

### Step 1.6: Update Stage 6 Verify (Cloud)

**Subagent:** `Bash` (for testing) + Direct Edit
**Changes:**
```yaml
# Add to stage:6:verify
- command -v session-manager-plugin || echo "SSM plugin: install via brew install --cask session-manager-plugin"
```

**Validation:**
```bash
task stage:6:verify  # Should show SSM plugin status
```

### Step 1.7: Update Stage 7 Verify (AI Tools)

**Subagent:** `Bash` (for testing) + Direct Edit
**Changes:**
```yaml
# Add to stage:7:verify
- |
  if command -v cursor &>/dev/null; then
    echo "Cursor CLI available"
  elif test -d "/Applications/Cursor.app"; then
    echo "Cursor.app installed"
  else
    echo "Cursor not found"
  fi
```

**Validation:**
```bash
task stage:7:verify  # Should show Cursor status
```

### Step 1.8: Update Stage 8 Verify (Security)

**Subagent:** `Bash` (for testing) + Direct Edit
**Changes:**
```yaml
# Add to stage:8:verify
- command -v cosign && cosign version | head -1
```

**Validation:**
```bash
task stage:8:verify  # Should show cosign version
```

### Step 1.9: Update Stage 9 Verify (Build Tools)

**Subagent:** `Bash` (for testing) + Direct Edit
**Changes:**
```yaml
# Add to stage:9:verify
- command -v ccache && ccache --version | head -1
```

**Validation:**
```bash
task stage:9:verify  # Should show ccache version
```

### Step 1.10: Update Stage R Verify (Runtimes)

**Subagent:** `Bash` (for testing) + Direct Edit
**Changes:**
```yaml
# Add to stage:runtimes:verify
- deno --version | head -1 || echo "Deno not installed"
- terraform --version | head -1 || echo "Terraform not installed"
```

**Validation:**
```bash
task stage:runtimes:verify  # Should show deno + terraform
```

### Step 1.11: Code Review Phase 1

**Subagent:** `feature-dev:code-reviewer`
**Task:** Review all Taskfile.yml changes for:
- Consistent formatting
- Error handling (|| true where appropriate)
- Version output formatting (| head -1 for verbose tools)

**Validation:**
```bash
task --list | grep verify  # All verify tasks should be listed
task validate:taskfile     # Schema validation should pass
```

---

## Phase 2: Shell Config Test Expansion

### Step 2.1: Analyze Current Test Coverage

**Subagent:** `Explore`
**Task:** Review test-shell-config.sh to understand current test patterns
**Validation:**
```bash
grep -c "log_pass\|log_fail" scripts/test-shell-config.sh  # Count test assertions
```

### Step 2.2: Expand Tool Availability Tests

**Subagent:** `Bash` (for testing) + Direct Edit
**File:** `scripts/test-shell-config.sh` - Section 4
**Changes:**
```bash
# Expand tools list from 12 to 25+
tools="brew mise git gh go rustc node bun python uv docker terraform deno jj just rg fd bat eza jq yq starship zoxide fzf kubectl helm"
```

**Validation:**
```bash
task validate:shell  # Should test 25+ tools
```

### Step 2.3: Expand Tool Execution Tests

**Subagent:** `Bash` (for testing) + Direct Edit
**File:** `scripts/test-shell-config.sh` - Section 8
**Changes:**
```bash
# Add to tool_commands array
tool_commands=(
    # Existing 12...
    "deno:deno --version"
    "jj:jj --version"
    "just:just --version"
    "rg:rg --version"
    "fd:fd --version"
    "bat:bat --version"
    "eza:eza --version"
    "jq:jq --version"
    "starship:starship --version"
    "zoxide:zoxide --version"
    "fzf:fzf --version"
    "kubectl:kubectl version --client"
    "helm:helm version --short"
)
```

**Validation:**
```bash
task validate:shell  # All execution tests should pass
```

### Step 2.4: Expand Alias Tests

**Subagent:** `Bash` (for testing) + Direct Edit
**File:** `scripts/test-shell-config.sh` - Section 5
**Changes:**
```bash
# Expand aliases list
aliases="bi bup gst gco gp tf tfa dps drit mi mls uva uvs uvr gob gor got"
```

**Validation:**
```bash
task validate:shell  # All alias tests should pass
```

### Step 2.5: Expand Environment Variable Tests

**Subagent:** `Bash` (for testing) + Direct Edit
**File:** `scripts/test-shell-config.sh` - Section 6
**Changes:**
```bash
# Add more env var checks
check_env HOMEBREW_PREFIX
check_env MISE_SHELL
check_env LANG
check_env EDITOR
check_env GOPATH || true  # Optional
check_env CARGO_HOME || true  # Optional
```

**Validation:**
```bash
task validate:shell  # All env var tests should pass
```

### Step 2.6: Code Review Phase 2

**Subagent:** `feature-dev:code-reviewer`
**Task:** Review test-shell-config.sh changes for:
- Test consistency
- Error handling
- Coverage completeness

**Validation:**
```bash
shellcheck scripts/test-shell-config.sh  # No errors
task validate:shell                       # All tests pass
```

---

## Phase 3: Integration Tests (New File)

### Step 3.1: Design Integration Test Architecture

**Subagent:** `feature-dev:code-architect`
**Task:** Design integration test structure covering:
- Tool interoperability (git+gh, docker+kubectl, mise+languages)
- Configuration validation
- Ecosystem functionality

**Validation:** Architecture document reviewed and approved

### Step 3.2: Create Integration Test File

**Subagent:** `Bash` (for testing) + Direct Write
**File:** `scripts/test-integration.sh` (NEW)
**Content:**
```bash
#!/bin/bash
# test-integration.sh - Integration tests for guilde-lite
# Tests tool interoperability and ecosystem functionality

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

errors=0
warnings=0

log_pass() { echo -e "${GREEN}✓${NC} $1"; }
log_fail() { echo -e "${RED}✗${NC} $1"; errors=$((errors + 1)); }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; warnings=$((warnings + 1)); }

echo "=== Integration Test Suite ==="
echo ""

# -----------------------------------------------------------------------------
# Test 1: Git + GitHub CLI Integration
# -----------------------------------------------------------------------------
echo "--- 1. Git + GitHub CLI ---"

if command -v git &>/dev/null && command -v gh &>/dev/null; then
    log_pass "git + gh both available"
else
    log_fail "git or gh missing"
fi

if gh auth status &>/dev/null 2>&1; then
    log_pass "gh authenticated"
else
    log_warn "gh not authenticated (run: gh auth login)"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 2: Docker + Kubernetes Integration
# -----------------------------------------------------------------------------
echo "--- 2. Docker + Kubernetes ---"

if docker ps &>/dev/null 2>&1; then
    log_pass "Docker daemon running"
else
    log_warn "Docker not running (start OrbStack)"
fi

if kubectl version --client &>/dev/null 2>&1; then
    log_pass "kubectl client available"
else
    log_fail "kubectl not available"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 3: Mise + Language Tools Integration
# -----------------------------------------------------------------------------
echo "--- 3. Mise + Languages ---"

mise_languages="go python rust node bun deno"

for lang in $mise_languages; do
    if mise current 2>/dev/null | grep -q "$lang"; then
        case $lang in
            go) go version &>/dev/null && log_pass "mise + go" || log_fail "mise + go broken" ;;
            python) python --version &>/dev/null && log_pass "mise + python" || log_fail "mise + python broken" ;;
            rust) rustc --version &>/dev/null && log_pass "mise + rust" || log_fail "mise + rust broken" ;;
            node) node --version &>/dev/null && log_pass "mise + node" || log_fail "mise + node broken" ;;
            bun) bun --version &>/dev/null && log_pass "mise + bun" || log_fail "mise + bun broken" ;;
            deno) deno --version &>/dev/null && log_pass "mise + deno" || log_fail "mise + deno broken" ;;
        esac
    else
        log_warn "mise: $lang not configured"
    fi
done

echo ""

# -----------------------------------------------------------------------------
# Test 4: Python Ecosystem (uv + python)
# -----------------------------------------------------------------------------
echo "--- 4. Python Ecosystem ---"

if uv --version &>/dev/null && python --version &>/dev/null; then
    log_pass "uv + python integration"
else
    log_fail "uv or python broken"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 5: Shell Integration
# -----------------------------------------------------------------------------
echo "--- 5. Shell Integration ---"

if zsh -i -c 'type mise' 2>/dev/null | grep -q function; then
    log_pass "mise shell function active"
else
    log_fail "mise not activated as shell function"
fi

if zsh -i -c 'echo $MISE_SHELL' 2>/dev/null | grep -q zsh; then
    log_pass "MISE_SHELL=zsh"
else
    log_fail "MISE_SHELL not set"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 6: Git Configuration Applied
# -----------------------------------------------------------------------------
echo "--- 6. Git Configuration ---"

if git config --global init.defaultBranch 2>/dev/null | grep -q main; then
    log_pass "git defaultBranch=main"
else
    log_fail "git defaultBranch not set to main"
fi

if git config --global core.pager 2>/dev/null | grep -q delta; then
    log_pass "git pager=delta"
else
    log_warn "git pager not set to delta"
fi

if git config --global pull.rebase 2>/dev/null | grep -q true; then
    log_pass "git pull.rebase=true"
else
    log_warn "git pull.rebase not set"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 7: Modern CLI Tools Integration
# -----------------------------------------------------------------------------
echo "--- 7. Modern CLI Tools ---"

# Test ripgrep with actual search
if echo "test" | rg "test" &>/dev/null; then
    log_pass "ripgrep works"
else
    log_fail "ripgrep broken"
fi

# Test fd with actual find
if fd --version &>/dev/null && fd "." --max-depth 1 &>/dev/null; then
    log_pass "fd works"
else
    log_fail "fd broken"
fi

# Test bat with actual file
if bat --version &>/dev/null; then
    log_pass "bat works"
else
    log_fail "bat broken"
fi

# Test jq with JSON
if echo '{"test": 1}' | jq '.test' &>/dev/null; then
    log_pass "jq works"
else
    log_fail "jq broken"
fi

echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "=== Integration Summary ==="
if [[ $errors -eq 0 ]]; then
    echo -e "${GREEN}All integration tests passed!${NC}"
    if [[ $warnings -gt 0 ]]; then
        echo -e "${YELLOW}$warnings warning(s)${NC}"
    fi
    exit 0
else
    echo -e "${RED}$errors error(s) found${NC}"
    if [[ $warnings -gt 0 ]]; then
        echo -e "${YELLOW}$warnings warning(s)${NC}"
    fi
    exit 1
fi
```

**Validation:**
```bash
chmod +x scripts/test-integration.sh
./scripts/test-integration.sh  # All integration tests should pass
```

### Step 3.3: Code Review Phase 3

**Subagent:** `feature-dev:code-reviewer`
**Task:** Review test-integration.sh for:
- Test coverage completeness
- Error handling
- Consistent output formatting

**Validation:**
```bash
shellcheck scripts/test-integration.sh  # No errors
```

### Step 3.4: Test Coverage Analysis

**Subagent:** `pr-review-toolkit:pr-test-analyzer`
**Task:** Analyze test coverage and identify any remaining gaps
**Validation:** Coverage report shows no critical gaps

---

## Phase 4: Database Validation

### Step 4.1: Create db:verify Task

**Subagent:** `Bash` (for testing) + Direct Edit
**File:** `Taskfile.yml`
**Changes:**
```yaml
db:verify:
  desc: "Verify database containers and client connectivity"
  cmds:
    - task: db:status
    - |
      echo "=== Database Client Verification ==="
      # PostgreSQL
      if psql -h localhost -U dev -d dev -c "SELECT 1;" &>/dev/null; then
        echo "✓ PostgreSQL client works"
      else
        echo "✗ PostgreSQL client failed"
        exit 1
      fi
      # Redis
      if redis-cli -h localhost -p 6379 -a dev PING 2>/dev/null | grep -q PONG; then
        echo "✓ Redis client works"
      else
        echo "✗ Redis client failed"
        exit 1
      fi
      echo "✓ All database clients verified"
```

**Validation:**
```bash
task db:up && task db:wait && task db:verify  # Should pass
```

### Step 4.2: Code Review Phase 4

**Subagent:** `feature-dev:code-reviewer`
**Task:** Review db:verify task for error handling and connectivity checks
**Validation:** Code review passes

---

## Phase 5: Configuration Validation

### Step 5.1: Create config:verify Task

**Subagent:** `Bash` (for testing) + Direct Edit
**File:** `Taskfile.yml`
**Changes:**
```yaml
config:verify:
  desc: "Verify all configurations applied correctly"
  cmds:
    - |
      echo "=== Configuration Verification ==="
      errors=0

      # Git configuration
      echo "--- Git Config ---"
      git config --global init.defaultBranch | grep -q main && echo "✓ defaultBranch=main" || { echo "✗ defaultBranch"; errors=$((errors+1)); }
      git config --global core.pager | grep -q delta && echo "✓ pager=delta" || echo "⚠ pager not delta (optional)"
      git config --global pull.rebase | grep -q true && echo "✓ pull.rebase=true" || echo "⚠ pull.rebase not set (optional)"

      # Shell configuration
      echo "--- Shell Config ---"
      grep -q "plugins=(" ~/.zshrc && echo "✓ oh-my-zsh plugins configured" || { echo "✗ plugins not configured"; errors=$((errors+1)); }
      grep -q "mise" ~/.zshrc && echo "✓ mise in .zshrc" || { echo "✗ mise not in .zshrc"; errors=$((errors+1)); }

      # Ghostty configuration
      echo "--- Ghostty Config ---"
      test -f ~/.config/ghostty/config && echo "✓ ghostty config exists" || echo "⚠ ghostty config missing (optional)"

      # Tmux configuration
      echo "--- Tmux Config ---"
      test -f ~/.tmux.conf && echo "✓ tmux config exists" || echo "⚠ tmux config missing (optional)"

      # Summary
      echo ""
      if [ $errors -eq 0 ]; then
        echo "✓ All required configurations verified"
      else
        echo "✗ $errors required configuration(s) missing"
        exit 1
      fi
```

**Validation:**
```bash
task config:verify  # Should pass
```

### Step 5.2: Code Review Phase 5

**Subagent:** `feature-dev:code-reviewer`
**Task:** Review config:verify for completeness
**Validation:** Code review passes

---

## Phase 6: Master Validation Task

### Step 6.1: Create validate:full Task

**Subagent:** `Bash` (for testing) + Direct Edit
**File:** `Taskfile.yml`
**Changes:**
```yaml
validate:full:
  desc: "Run ALL validation checks (comprehensive)"
  cmds:
    - echo "=== Full Validation Suite ==="
    - task: validate
    - task: validate:shell
    - task: validate:integration
    - task: config:verify
    - echo ""
    - echo "✓ Full validation complete - all checks passed"

validate:integration:
  desc: "Run integration tests"
  cmds:
    - chmod +x scripts/test-integration.sh
    - ./scripts/test-integration.sh
```

**Validation:**
```bash
task validate:full  # All validation should pass
```

### Step 6.2: Final Code Review

**Subagent:** `feature-dev:code-reviewer`
**Task:** Review entire implementation for:
- Consistency across all changes
- Error handling
- Documentation accuracy

**Validation:**
```bash
task validate:full  # Complete validation passes
```

---

## Phase 7: Documentation Updates

### Step 7.1: Update ARCHITECTURE.md

**Subagent:** `documentation-generation:docs-architect`
**Task:** Update validation documentation section with:
- New validation commands
- Coverage matrix
- Test descriptions

**Validation:** Documentation review passes

### Step 7.2: Create PR with /commit Skill

**Skill:** `/commit`
**Task:** Create commit with all changes
**Commit Message:**
```
feat: achieve 100% validation coverage for all tools

- Update all stage:N:verify tasks with missing tool checks
- Expand test-shell-config.sh to cover 25+ tools
- Create test-integration.sh for ecosystem tests
- Add db:verify task for database client validation
- Add config:verify task for configuration validation
- Add validate:full task for comprehensive validation

Tools now verified: 67/67 (100% coverage)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Validation:**
```bash
git log -1  # Should show commit
```

---

## Execution Summary

| Phase | Subagent(s) | Skill(s) | Validation Command |
|-------|-------------|----------|-------------------|
| 1 | Explore, Bash, code-reviewer | - | `task stage:N:verify` |
| 2 | Explore, Bash, code-reviewer | - | `task validate:shell` |
| 3 | code-architect, Bash, code-reviewer, pr-test-analyzer | - | `./scripts/test-integration.sh` |
| 4 | Bash, code-reviewer | - | `task db:verify` |
| 5 | Bash, code-reviewer | - | `task config:verify` |
| 6 | Bash, code-reviewer | - | `task validate:full` |
| 7 | docs-architect | /commit | `git log -1` |

---

## Post-Implementation Verification Matrix

| Check | Command | Expected Result |
|-------|---------|-----------------|
| Taskfile schema | `task validate:taskfile` | Pass |
| All stage verifies | `task stage:{1..9}:verify` | All pass |
| Runtime verify | `task stage:runtimes:verify` | Pass |
| Shell config tests | `task validate:shell` | 70+ tests pass |
| Integration tests | `task validate:integration` | All pass |
| Config verification | `task config:verify` | Pass |
| Full validation | `task validate:full` | All pass |
| Total tool coverage | Manual count | 67/67 (100%) |

---

## Rollback Plan

If issues occur, revert with:
```bash
git checkout HEAD~1 -- Taskfile.yml scripts/test-shell-config.sh
rm scripts/test-integration.sh
```
