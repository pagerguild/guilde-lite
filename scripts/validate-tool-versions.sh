#!/bin/bash
# Multi-Agent Workflow Tool Version Validator
# Validates all required tools meet minimum version requirements

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Required versions
REQUIRED_JJ_VERSION="0.37.0"
REQUIRED_AGENTIC_JJ_VERSION="2.3.6"
REQUIRED_JJ_MCP_VERSION="1.0.1"
REQUIRED_RECONCILE_AI_VERSION="1.0.3"
REQUIRED_OVADARE_VERSION="0.1.0"
REQUIRED_AGENTDB_SDK_VERSION="1.1.26"

# Track failures
FAILURES=0

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Multi-Agent Workflow Tool Version Validator${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Function to compare versions (returns 0 if $1 >= $2)
version_ge() {
    [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# Check jj
echo -e "${YELLOW}Checking jj (Jujutsu VCS)...${NC}"
if command -v jj &>/dev/null; then
    JJ_VERSION=$(jj --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if version_ge "$JJ_VERSION" "$REQUIRED_JJ_VERSION"; then
        echo -e "  ${GREEN}✓${NC} jj v$JJ_VERSION (required: >=$REQUIRED_JJ_VERSION)"
    else
        echo -e "  ${RED}✗${NC} jj v$JJ_VERSION is below required v$REQUIRED_JJ_VERSION"
        ((FAILURES++))
    fi
else
    echo -e "  ${RED}✗${NC} jj not installed"
    ((FAILURES++))
fi

# Helper to get npm version via curl (fallback when npm not in PATH)
get_npm_version() {
    local pkg="$1"
    # Try npm first, then bun, then curl
    if command -v npm &>/dev/null; then
        npm show "$pkg" version 2>/dev/null
    elif command -v bun &>/dev/null; then
        # bun doesn't have 'show' but we can use curl
        curl -s "https://registry.npmjs.org/$pkg" 2>/dev/null | grep -oE '"latest":"[0-9]+\.[0-9]+\.[0-9]+"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
    else
        curl -s "https://registry.npmjs.org/$pkg" 2>/dev/null | grep -oE '"latest":"[0-9]+\.[0-9]+\.[0-9]+"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
    fi
}

# Check agentic-jujutsu
echo -e "${YELLOW}Checking agentic-jujutsu...${NC}"
AGENTIC_VERSION=$(get_npm_version "agentic-jujutsu")
if [ -n "$AGENTIC_VERSION" ]; then
    if version_ge "$AGENTIC_VERSION" "$REQUIRED_AGENTIC_JJ_VERSION"; then
        echo -e "  ${GREEN}✓${NC} agentic-jujutsu v$AGENTIC_VERSION (required: >=$REQUIRED_AGENTIC_JJ_VERSION)"
    else
        echo -e "  ${RED}✗${NC} agentic-jujutsu v$AGENTIC_VERSION is below required v$REQUIRED_AGENTIC_JJ_VERSION"
        ((FAILURES++))
    fi
else
    echo -e "  ${RED}✗${NC} agentic-jujutsu not available on npm"
    ((FAILURES++))
fi

# Check jj-mcp-server
echo -e "${YELLOW}Checking jj-mcp-server...${NC}"
JJ_MCP_VERSION=$(get_npm_version "jj-mcp-server")
if [ -n "$JJ_MCP_VERSION" ]; then
    if version_ge "$JJ_MCP_VERSION" "$REQUIRED_JJ_MCP_VERSION"; then
        echo -e "  ${GREEN}✓${NC} jj-mcp-server v$JJ_MCP_VERSION (required: >=$REQUIRED_JJ_MCP_VERSION)"
    else
        echo -e "  ${RED}✗${NC} jj-mcp-server v$JJ_MCP_VERSION is below required v$REQUIRED_JJ_MCP_VERSION"
        ((FAILURES++))
    fi
else
    echo -e "  ${RED}✗${NC} jj-mcp-server not available on npm"
    ((FAILURES++))
fi

# Check @agentdb/sdk
echo -e "${YELLOW}Checking @agentdb/sdk...${NC}"
AGENTDB_VERSION=$(get_npm_version "@agentdb/sdk")
if [ -n "$AGENTDB_VERSION" ]; then
    if version_ge "$AGENTDB_VERSION" "$REQUIRED_AGENTDB_SDK_VERSION"; then
        echo -e "  ${GREEN}✓${NC} @agentdb/sdk v$AGENTDB_VERSION (required: >=$REQUIRED_AGENTDB_SDK_VERSION)"
    else
        echo -e "  ${RED}✗${NC} @agentdb/sdk v$AGENTDB_VERSION is below required v$REQUIRED_AGENTDB_SDK_VERSION"
        ((FAILURES++))
    fi
else
    echo -e "  ${RED}✗${NC} @agentdb/sdk not available on npm"
    ((FAILURES++))
fi

# Check reconcile-ai
echo -e "${YELLOW}Checking reconcile-ai...${NC}"
RECONCILE_VERSION=$(pip3 show reconcile-ai 2>/dev/null | grep -i version | awk '{print $2}' || echo "not found")
if [ -n "$RECONCILE_VERSION" ] && [ "$RECONCILE_VERSION" != "not found" ]; then
    if version_ge "$RECONCILE_VERSION" "$REQUIRED_RECONCILE_AI_VERSION"; then
        echo -e "  ${GREEN}✓${NC} reconcile-ai v$RECONCILE_VERSION (required: >=$REQUIRED_RECONCILE_AI_VERSION)"
    else
        echo -e "  ${RED}✗${NC} reconcile-ai v$RECONCILE_VERSION is below required v$REQUIRED_RECONCILE_AI_VERSION"
        ((FAILURES++))
    fi
else
    echo -e "  ${RED}✗${NC} reconcile-ai not installed"
    ((FAILURES++))
fi

# Check ovadare
echo -e "${YELLOW}Checking ovadare...${NC}"
OVADARE_VERSION=$(pip3 show ovadare 2>/dev/null | grep -i version | awk '{print $2}' || echo "not found")
if [ -n "$OVADARE_VERSION" ] && [ "$OVADARE_VERSION" != "not found" ]; then
    if version_ge "$OVADARE_VERSION" "$REQUIRED_OVADARE_VERSION"; then
        echo -e "  ${GREEN}✓${NC} ovadare v$OVADARE_VERSION (required: >=$REQUIRED_OVADARE_VERSION)"
    else
        echo -e "  ${RED}✗${NC} ovadare v$OVADARE_VERSION is below required v$REQUIRED_OVADARE_VERSION"
        ((FAILURES++))
    fi
else
    echo -e "  ${RED}✗${NC} ovadare not installed"
    ((FAILURES++))
fi

# Check jj colocated mode
echo ""
echo -e "${YELLOW}Checking jj colocated mode...${NC}"
if [ -d ".jj" ] && [ -d ".git" ]; then
    echo -e "  ${GREEN}✓${NC} jj colocated mode active"
else
    echo -e "  ${YELLOW}!${NC} jj colocated mode not initialized (run: jj git init --colocate)"
fi

# Check MCP configuration
echo -e "${YELLOW}Checking MCP configuration...${NC}"
if [ -f ".mcp.json" ]; then
    echo -e "  ${GREEN}✓${NC} .mcp.json exists"
else
    echo -e "  ${YELLOW}!${NC} .mcp.json not found"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}All tool version checks passed!${NC}"
    exit 0
else
    echo -e "${RED}$FAILURES tool version check(s) failed${NC}"
    exit 1
fi
