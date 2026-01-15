#!/bin/bash
# Mise-First Validation Script
# Validates that the environment follows mise-first patterns
#
# Usage:
#   bash scripts/validate-mise-first.sh          # Full validation
#   bash scripts/validate-mise-first.sh --ci     # CI mode (exit codes)
#   bash scripts/validate-mise-first.sh --fix    # Auto-fix where possible
#
# Exit codes:
#   0 - All checks passed
#   1 - Validation failures found
#   2 - Script error

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
ERRORS=0
WARNINGS=0
FIXES=0

# Options
CI_MODE=false
FIX_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --ci) CI_MODE=true; shift ;;
        --fix) FIX_MODE=true; shift ;;
        *) echo "Unknown option: $1"; exit 2 ;;
    esac
done

log_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

log_check() {
    echo -e "\n${CYAN}▶ $1${NC}"
}

log_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
}

log_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((ERRORS++))
}

log_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

log_fix() {
    echo -e "  ${GREEN}⚡${NC} Fixed: $1"
    ((FIXES++))
}

log_info() {
    echo -e "  ${CYAN}ℹ${NC} $1"
}

# =============================================================================
# CHECK 1: Mise Installation
# =============================================================================
check_mise_installed() {
    log_check "Checking mise installation"

    if ! command -v mise &>/dev/null; then
        log_fail "mise not installed"
        log_info "Install with: brew install mise"
        return 1
    fi

    local version=$(mise --version 2>/dev/null)
    log_pass "mise installed: $version"

    # Check mise is activated
    if [[ -z "${MISE_SHELL:-}" ]] && ! echo "$PATH" | grep -q "mise/shims"; then
        log_warn "mise may not be activated (no MISE_SHELL or shims in PATH)"
        log_info "Add to shell: eval \"\$(mise activate zsh)\""
    else
        log_pass "mise is activated"
    fi
}

# =============================================================================
# CHECK 2: Global Config Pattern
# =============================================================================
check_global_config() {
    log_check "Checking global mise config pattern"

    local global_config="$HOME/.config/mise/config.toml"

    if [[ ! -f "$global_config" ]]; then
        log_warn "No global config at $global_config"
        log_info "Create with: bash scripts/setup-global-ai-tools.sh"
        return 0
    fi

    log_pass "Global config exists: $global_config"

    # Check for non-"latest" versions (excluding aliases like "lts")
    local pinned_versions=$(grep -E '^\s*[a-zA-Z_-]+\s*=\s*"[0-9]' "$global_config" 2>/dev/null || true)

    if [[ -n "$pinned_versions" ]]; then
        log_warn "Global config has pinned versions (should use 'latest'):"
        echo "$pinned_versions" | while read -r line; do
            log_info "  $line"
        done

        if $FIX_MODE; then
            log_info "Auto-fix not implemented for global config (manual review recommended)"
        fi
    else
        log_pass "Global config uses 'latest' pattern"
    fi
}

# =============================================================================
# CHECK 3: Project mise.toml
# =============================================================================
check_project_config() {
    log_check "Checking project mise.toml"

    if [[ ! -f "mise.toml" ]]; then
        log_fail "No mise.toml in project root"
        return 1
    fi

    log_pass "Project mise.toml exists"

    # Validate syntax
    if mise config 2>&1 | grep -qi "error"; then
        log_fail "mise.toml has syntax errors"
        mise config 2>&1 | head -5
        return 1
    fi

    log_pass "mise.toml syntax is valid"

    # Check tools are installed
    local missing=$(mise ls --missing 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$missing" -gt 0 ]]; then
        log_warn "$missing tools not installed"

        if $FIX_MODE; then
            mise install
            log_fix "Installed missing tools"
        else
            log_info "Run: mise install"
        fi
    else
        log_pass "All tools installed"
    fi
}

# =============================================================================
# CHECK 4: Legacy Tool Detection
# =============================================================================
check_legacy_tools() {
    log_check "Checking for legacy version managers"

    local legacy_found=false

    # Check for nvm
    if [[ -d "$HOME/.nvm" ]] || command -v nvm &>/dev/null 2>&1; then
        log_warn "nvm detected - consider migrating to mise"
        log_info "Migration: mise use node@\$(node --version | tr -d 'v')"
        legacy_found=true
    fi

    # Check for pyenv
    if [[ -d "$HOME/.pyenv" ]] || command -v pyenv &>/dev/null 2>&1; then
        log_warn "pyenv detected - consider migrating to mise"
        log_info "Migration: mise use python@\$(python --version | cut -d' ' -f2)"
        legacy_found=true
    fi

    # Check for rbenv
    if [[ -d "$HOME/.rbenv" ]] || command -v rbenv &>/dev/null 2>&1; then
        log_warn "rbenv detected - consider migrating to mise"
        log_info "Migration: mise use ruby@\$(ruby --version | cut -d' ' -f2)"
        legacy_found=true
    fi

    # Check for goenv
    if [[ -d "$HOME/.goenv" ]] || command -v goenv &>/dev/null 2>&1; then
        log_warn "goenv detected - consider migrating to mise"
        log_info "Migration: mise use go@\$(go version | cut -d' ' -f3 | tr -d 'go')"
        legacy_found=true
    fi

    # Check shell config for legacy tool init
    for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
        if [[ -f "$rc" ]]; then
            if grep -qE '(nvm\.sh|pyenv init|rbenv init|goenv init)' "$rc" 2>/dev/null; then
                log_warn "Legacy tool initialization found in $rc"
                legacy_found=true
            fi
        fi
    done

    if ! $legacy_found; then
        log_pass "No legacy version managers detected"
    fi
}

# =============================================================================
# CHECK 5: Shims Configuration
# =============================================================================
check_shims() {
    log_check "Checking shims configuration"

    local shims_dir="$HOME/.local/share/mise/shims"

    if [[ ! -d "$shims_dir" ]]; then
        log_warn "Shims directory does not exist"

        if $FIX_MODE; then
            mise reshim
            log_fix "Created shims directory"
        else
            log_info "Run: mise reshim"
        fi
        return 0
    fi

    log_pass "Shims directory exists"

    # Check shims are in PATH
    if ! echo "$PATH" | grep -q "$shims_dir"; then
        log_warn "Shims not in PATH"
        log_info "Add to shell config: export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\""
    else
        log_pass "Shims are in PATH"
    fi

    # Count shims
    local shim_count=$(ls -1 "$shims_dir" 2>/dev/null | wc -l | tr -d ' ')
    log_info "Shims available: $shim_count"
}

# =============================================================================
# CHECK 6: AI CLI Tools
# =============================================================================
check_ai_tools() {
    log_check "Checking AI CLI tools availability"

    local tools=("gemini" "codex" "opencode" "claude")
    local missing_tools=()

    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            local version=$("$tool" --version 2>&1 | head -1 || echo "unknown")
            log_pass "$tool: $version"
        else
            log_warn "$tool not found"
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_info "Install missing tools:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                gemini)   log_info "  mise use npm:@google/gemini-cli@latest" ;;
                codex)    log_info "  mise use npm:@openai/codex@latest" ;;
                opencode) log_info "  mise use opencode@latest" ;;
                claude)   log_info "  curl -fsSL https://claude.ai/install.sh | bash" ;;
            esac
        done
    fi
}

# =============================================================================
# CHECK 7: Package Manager Patterns
# =============================================================================
check_package_managers() {
    log_check "Checking package manager patterns"

    # Check for pip usage in recent history (if available)
    if [[ -f "$HOME/.zsh_history" ]] || [[ -f "$HOME/.bash_history" ]]; then
        local history_file="${HISTFILE:-$HOME/.zsh_history}"
        if [[ -f "$history_file" ]]; then
            local pip_usage=$(grep -c "pip install" "$history_file" 2>/dev/null || echo "0")
            local uv_usage=$(grep -c "uv pip\|uvx" "$history_file" 2>/dev/null || echo "0")

            if [[ "$pip_usage" -gt 0 ]] && [[ "$uv_usage" -lt "$pip_usage" ]]; then
                log_warn "Recent pip usage detected ($pip_usage times) - prefer uv"
            fi
        fi
    fi

    # Check if uv is available
    if command -v uv &>/dev/null; then
        log_pass "uv is available: $(uv --version 2>&1 | head -1)"
    else
        log_warn "uv not found - install for faster Python package management"
        log_info "Install: mise use uv@latest"
    fi

    # Check if bun is available
    if command -v bun &>/dev/null; then
        log_pass "bun is available: $(bun --version 2>&1)"
    else
        log_warn "bun not found - install for faster JS/TS development"
        log_info "Install: mise use bun@latest"
    fi
}

# =============================================================================
# CHECK 8: Trusted Configs
# =============================================================================
check_trusted_configs() {
    log_check "Checking mise trust status"

    # Check if current directory config is trusted
    if mise trust --show 2>/dev/null | grep -q "$(pwd)"; then
        log_pass "Current directory config is trusted"
    else
        if [[ -f "mise.toml" ]]; then
            log_warn "Current mise.toml may not be trusted"

            if $FIX_MODE; then
                mise trust
                log_fix "Trusted current directory config"
            else
                log_info "Run: mise trust"
            fi
        fi
    fi

    # Check global config trust
    local global_config="$HOME/.config/mise/config.toml"
    if [[ -f "$global_config" ]]; then
        if mise trust --show 2>/dev/null | grep -q "$global_config"; then
            log_pass "Global config is trusted"
        else
            log_warn "Global config may not be trusted"

            if $FIX_MODE; then
                mise trust "$global_config"
                log_fix "Trusted global config"
            else
                log_info "Run: mise trust $global_config"
            fi
        fi
    fi
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    log_header "Mise-First Validation"

    if $CI_MODE; then
        echo -e "${CYAN}Running in CI mode${NC}"
    fi

    if $FIX_MODE; then
        echo -e "${CYAN}Running in fix mode${NC}"
    fi

    check_mise_installed
    check_global_config
    check_project_config
    check_legacy_tools
    check_shims
    check_ai_tools
    check_package_managers
    check_trusted_configs

    # Summary
    log_header "Summary"

    echo -e "  Errors:   ${RED}$ERRORS${NC}"
    echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"

    if $FIX_MODE; then
        echo -e "  Fixed:    ${GREEN}$FIXES${NC}"
    fi

    echo ""

    if [[ $ERRORS -gt 0 ]]; then
        echo -e "${RED}Validation failed with $ERRORS error(s)${NC}"
        exit 1
    elif [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}Validation passed with $WARNINGS warning(s)${NC}"
        if $CI_MODE; then
            exit 0  # Warnings don't fail CI
        fi
    else
        echo -e "${GREEN}All validations passed!${NC}"
    fi

    exit 0
}

main "$@"
