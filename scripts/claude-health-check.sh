#!/bin/bash
# scripts/claude-health-check.sh
# Non-interactive Claude Code health check (subset of `claude doctor`)
# Run `claude doctor` manually for full interactive diagnostics

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

errors=0
warnings=0

log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; errors=$((errors + 1)); }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; warnings=$((warnings + 1)); }
log_info() { echo -e "  $1"; }

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "                    CLAUDE CODE HEALTH CHECK                              "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# -----------------------------------------------------------------------------
# 1. Check Claude Code installation
# -----------------------------------------------------------------------------
echo "--- Installation ---"

if command -v claude &>/dev/null; then
    CLAUDE_PATH=$(command -v claude)
    log_success "Claude Code found: $CLAUDE_PATH"

    # Check version
    if CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1); then
        log_success "Version: $CLAUDE_VERSION"
    else
        log_warn "Could not determine Claude version"
    fi
else
    log_error "Claude Code not found in PATH"
    log_info "Install with: curl -fsSL https://claude.ai/install.sh | bash"
fi

echo ""

# -----------------------------------------------------------------------------
# 2. Check configuration files
# -----------------------------------------------------------------------------
echo "--- Configuration ---"

# Check project settings
if [[ -f ".claude/settings.json" ]]; then
    if jq empty .claude/settings.json 2>/dev/null; then
        log_success ".claude/settings.json is valid JSON"

        # Check hooks configuration
        if jq -e '.hooks' .claude/settings.json >/dev/null 2>&1; then
            HOOK_COUNT=$(jq '.hooks | keys | length' .claude/settings.json)
            log_success "Hooks configured: $HOOK_COUNT event types"
        else
            log_info "No hooks configured"
        fi

        # Check plugins
        if jq -e '.enabledPlugins' .claude/settings.json >/dev/null 2>&1; then
            PLUGIN_COUNT=$(jq '.enabledPlugins | keys | length' .claude/settings.json)
            log_success "Plugins enabled: $PLUGIN_COUNT"
        else
            log_info "No plugins configured"
        fi
    else
        log_error ".claude/settings.json is invalid JSON"
    fi
else
    log_warn "No project .claude/settings.json found"
fi

# Check user settings
USER_SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$USER_SETTINGS" ]]; then
    if jq empty "$USER_SETTINGS" 2>/dev/null; then
        log_success "User settings.json is valid"
    else
        log_error "User settings.json is invalid JSON: $USER_SETTINGS"
    fi
fi

# Check CLAUDE.md
if [[ -f "CLAUDE.md" ]]; then
    CLAUDE_MD_LINES=$(wc -l < CLAUDE.md | tr -d ' ')
    if [[ "$CLAUDE_MD_LINES" -le 500 ]]; then
        log_success "CLAUDE.md exists ($CLAUDE_MD_LINES lines - within 500 line best practice)"
    else
        log_warn "CLAUDE.md is $CLAUDE_MD_LINES lines (best practice: under 500)"
    fi
else
    log_info "No CLAUDE.md found (optional but recommended)"
fi

echo ""

# -----------------------------------------------------------------------------
# 3. Check rules directory
# -----------------------------------------------------------------------------
echo "--- Rules ---"

if [[ -d ".claude/rules" ]]; then
    RULE_COUNT=$(find .claude/rules -name "*.md" | wc -l | tr -d ' ')
    log_success ".claude/rules/ directory exists with $RULE_COUNT rule files"

    # Validate each rule file is readable
    for rule in .claude/rules/*.md; do
        if [[ -f "$rule" ]]; then
            if [[ -r "$rule" ]]; then
                :  # File is readable, all good
            else
                log_error "Rule file not readable: $rule"
            fi
        fi
    done
else
    log_info "No .claude/rules/ directory (optional)"
fi

echo ""

# -----------------------------------------------------------------------------
# 4. Check MCP servers (if configured)
# -----------------------------------------------------------------------------
echo "--- MCP Servers ---"

if [[ -f ".mcp.json" ]]; then
    if jq empty .mcp.json 2>/dev/null; then
        log_success ".mcp.json is valid JSON"
        SERVER_COUNT=$(jq '.mcpServers | keys | length' .mcp.json 2>/dev/null || echo "0")
        log_success "MCP servers configured: $SERVER_COUNT"
    else
        log_error ".mcp.json is invalid JSON"
    fi
else
    log_info "No .mcp.json found (optional)"
fi

echo ""

# -----------------------------------------------------------------------------
# 5. Check environment
# -----------------------------------------------------------------------------
echo "--- Environment ---"

# Check for common issues
if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
    log_success "ANTHROPIC_API_KEY is set"
elif [[ -n "${CLAUDE_API_KEY:-}" ]]; then
    log_success "CLAUDE_API_KEY is set"
else
    log_info "No API key environment variable (using OAuth or other auth)"
fi

# Check git (required for many operations)
if command -v git &>/dev/null; then
    log_success "Git is available"
else
    log_error "Git not found (required for Claude Code)"
fi

# Check node/bun (for npm packages)
if command -v bun &>/dev/null; then
    log_success "Bun available for npm packages"
elif command -v node &>/dev/null; then
    log_success "Node.js available for npm packages"
elif mise which bun &>/dev/null 2>&1; then
    log_success "Bun available via mise"
elif mise which node &>/dev/null 2>&1; then
    log_success "Node.js available via mise"
else
    log_warn "Neither bun nor node found (needed for npm: packages)"
fi

echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $errors -eq 0 ]]; then
    echo -e "${GREEN}Health check passed!${NC}"
    if [[ $warnings -gt 0 ]]; then
        echo -e "${YELLOW}$warnings warning(s)${NC}"
    fi
    echo ""
    echo "For full interactive diagnostics, run: claude doctor"
    exit 0
else
    echo -e "${RED}$errors error(s) found${NC}"
    if [[ $warnings -gt 0 ]]; then
        echo -e "${YELLOW}$warnings warning(s)${NC}"
    fi
    echo ""
    echo "Fix errors and run: claude doctor (interactive)"
    exit 1
fi
