#!/bin/bash
# test-shell-config.sh - Validate shell configuration for guilde-lite
# Tests: plugins, tools, aliases, environment variables, exit codes

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

echo "=== Shell Configuration Test Suite ==="
echo ""

# -----------------------------------------------------------------------------
# Test 1: Shell files exit cleanly
# -----------------------------------------------------------------------------
echo "--- 1. Shell File Exit Codes ---"

for file in ~/.zshenv ~/.zprofile ~/.zshrc; do
    if [[ -f "$file" ]]; then
        if zsh -c "source $file" 2>/dev/null; then
            log_pass "$file exits cleanly"
        else
            log_fail "$file exits with error"
        fi
    else
        log_warn "$file does not exist"
    fi
done

echo ""

# -----------------------------------------------------------------------------
# Test 2: Interactive shell works
# -----------------------------------------------------------------------------
echo "--- 2. Interactive Shell ---"

if zsh -i -c 'true' 2>/dev/null; then
    log_pass "Interactive shell starts successfully"
else
    log_fail "Interactive shell fails to start"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 3: Plugins loaded
# -----------------------------------------------------------------------------
echo "--- 3. Oh-My-Zsh Plugins ---"

expected_plugins="brew mise git gh golang rust bun uv docker docker-compose terraform macos"
loaded_plugins=$(zsh -i -c 'echo $plugins' 2>/dev/null | grep -v WARN || echo "")

for plugin in $expected_plugins; do
    if [[ " $loaded_plugins " =~ " $plugin " ]]; then
        log_pass "Plugin: $plugin"
    else
        log_fail "Plugin missing: $plugin"
    fi
done

echo ""

# -----------------------------------------------------------------------------
# Test 4: Tools available
# -----------------------------------------------------------------------------
echo "--- 4. Tool Availability ---"

tools="brew mise git gh go rustc node bun python uv docker terraform deno jj just rg fd bat eza jq yq starship zoxide fzf kubectl helm"

for tool in $tools; do
    if zsh -i -c "command -v $tool" &>/dev/null 2>&1; then
        log_pass "Tool: $tool"
    else
        log_fail "Tool missing: $tool"
    fi
done

echo ""

# -----------------------------------------------------------------------------
# Test 5: Key aliases defined
# -----------------------------------------------------------------------------
echo "--- 5. Key Aliases ---"

aliases="bi bup gst gco gp tf tfa dps drit mi mls uva uvs uvr gob gor got ll la"

for a in $aliases; do
    if zsh -i -c "alias $a" &>/dev/null 2>&1; then
        log_pass "Alias: $a"
    else
        log_fail "Alias missing: $a"
    fi
done

echo ""

# -----------------------------------------------------------------------------
# Test 6: Environment variables
# -----------------------------------------------------------------------------
echo "--- 6. Environment Variables ---"

check_env() {
    local var=$1
    local value
    value=$(zsh -i -c "echo \$$var" 2>/dev/null | grep -v WARN || echo "")
    if [[ -n "$value" ]]; then
        log_pass "Env: $var=$value"
    else
        log_fail "Env missing: $var"
    fi
}

check_env HOMEBREW_PREFIX
check_env MISE_SHELL
check_env LANG
check_env EDITOR

echo ""

# -----------------------------------------------------------------------------
# Test 7: Mise-managed tool versions
# -----------------------------------------------------------------------------
echo "--- 7. Mise Tool Versions ---"

mise_tools="bun node python go rust deno terraform uv"

for tool in $mise_tools; do
    version=$(zsh -i -c "mise ls $tool 2>/dev/null | awk '{print \$2}'" 2>/dev/null | grep -v WARN | head -1 || echo "")
    if [[ -n "$version" ]]; then
        log_pass "Mise: $tool=$version"
    else
        log_warn "Mise: $tool not installed"
    fi
done

echo ""

# -----------------------------------------------------------------------------
# Test 8: Tool Execution (handles aliased tools like uv)
# -----------------------------------------------------------------------------
echo "--- 8. Tool Execution (including aliased tools) ---"

# Test that tools execute correctly even when aliased (e.g., uv = "noglob uv")
tool_commands=(
    "brew:brew --version"
    "mise:mise --version"
    "git:git --version"
    "gh:gh --version"
    "go:go version"
    "rustc:rustc --version"
    "node:node --version"
    "bun:bun --version"
    "python:python --version"
    "uv:uv --version"
    "docker:docker --version"
    "terraform:terraform --version"
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

for entry in "${tool_commands[@]}"; do
    tool="${entry%%:*}"
    cmd="${entry#*:}"
    if zsh -i -c "$cmd" &>/dev/null 2>&1; then
        log_pass "Executes: $tool"
    else
        log_fail "Execution failed: $tool ($cmd)"
    fi
done

echo ""

# -----------------------------------------------------------------------------
# Test 9: Shell contexts
# -----------------------------------------------------------------------------
echo "--- 9. Shell Contexts ---"

# Interactive login
if zsh -l -i -c 'command -v node' &>/dev/null 2>&1; then
    log_pass "Interactive login shell: tools available"
else
    log_fail "Interactive login shell: tools missing"
fi

# Non-interactive login (SSH simulation)
if zsh -l -c 'command -v node' &>/dev/null 2>&1; then
    log_pass "Non-interactive login shell: tools available"
else
    log_fail "Non-interactive login shell: tools missing"
fi

# Non-interactive (scripts)
if zsh -c 'command -v node' &>/dev/null 2>&1; then
    log_pass "Non-interactive shell: tools available"
else
    log_fail "Non-interactive shell: tools missing"
fi

echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "=== Summary ==="
if [[ $errors -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
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
