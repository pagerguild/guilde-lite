#!/bin/bash
# test-integration.sh - Integration tests for guilde-lite
# Tests tool interoperability and ecosystem functionality
# Note: Many tests run within zsh -i -c to access mise-managed tools

set -e

# Source Homebrew for CLI tools (needed in non-interactive bash)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

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

if command -v kubectl &>/dev/null && kubectl version --client &>/dev/null 2>&1; then
    log_pass "kubectl client available"
else
    log_warn "kubectl not available"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 3: Mise + Language Tools Integration (run in zsh context)
# -----------------------------------------------------------------------------
echo "--- 3. Mise + Languages ---"

# Test mise-managed tools within zsh interactive context
mise_languages="go python rust node bun deno"

for lang in $mise_languages; do
    case $lang in
        go)
            if zsh -i -c 'go version' &>/dev/null 2>&1; then
                log_pass "mise + go"
            else
                log_fail "mise + go broken"
            fi
            ;;
        python)
            if zsh -i -c 'python --version' &>/dev/null 2>&1; then
                log_pass "mise + python"
            else
                log_fail "mise + python broken"
            fi
            ;;
        rust)
            if zsh -i -c 'rustc --version' &>/dev/null 2>&1; then
                log_pass "mise + rust"
            else
                log_fail "mise + rust broken"
            fi
            ;;
        node)
            if zsh -i -c 'node --version' &>/dev/null 2>&1; then
                log_pass "mise + node"
            else
                log_fail "mise + node broken"
            fi
            ;;
        bun)
            if zsh -i -c 'bun --version' &>/dev/null 2>&1; then
                log_pass "mise + bun"
            else
                log_fail "mise + bun broken"
            fi
            ;;
        deno)
            if zsh -i -c 'deno --version' &>/dev/null 2>&1; then
                log_pass "mise + deno"
            else
                log_fail "mise + deno broken"
            fi
            ;;
    esac
done

echo ""

# -----------------------------------------------------------------------------
# Test 4: Python Ecosystem (uv + python) - run in zsh context
# -----------------------------------------------------------------------------
echo "--- 4. Python Ecosystem ---"

if zsh -i -c 'uv --version && python --version' &>/dev/null 2>&1; then
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
    log_warn "git defaultBranch not set to main"
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
# Test 7: Modern CLI Tools Integration (Homebrew tools)
# -----------------------------------------------------------------------------
echo "--- 7. Modern CLI Tools ---"

# Test ripgrep with actual search
if command -v rg &>/dev/null && echo "test" | rg "test" &>/dev/null; then
    log_pass "ripgrep works"
else
    log_warn "ripgrep not available"
fi

# Test fd with actual find
if command -v fd &>/dev/null && fd --version &>/dev/null; then
    log_pass "fd works"
else
    log_warn "fd not available"
fi

# Test bat
if command -v bat &>/dev/null && bat --version &>/dev/null; then
    log_pass "bat works"
else
    log_warn "bat not available"
fi

# Test jq with JSON
if command -v jq &>/dev/null && echo '{"test": 1}' | jq '.test' &>/dev/null; then
    log_pass "jq works"
else
    log_fail "jq broken"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 8: Oh-My-Zsh Plugin Integration
# -----------------------------------------------------------------------------
echo "--- 8. Oh-My-Zsh Plugins ---"

if zsh -i -c 'echo $plugins' 2>/dev/null | grep -q mise; then
    log_pass "mise plugin loaded"
else
    log_fail "mise plugin not loaded"
fi

if zsh -i -c 'echo $plugins' 2>/dev/null | grep -q brew; then
    log_pass "brew plugin loaded"
else
    log_fail "brew plugin not loaded"
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
