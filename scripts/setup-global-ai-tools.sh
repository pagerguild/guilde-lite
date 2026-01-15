#!/bin/bash
# Setup Global AI CLI Tools
# Ensures AI tools (gemini, codex, opencode, claude) are available globally
#
# Usage: bash scripts/setup-global-ai-tools.sh

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Global AI CLI Tools Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check mise is installed
if ! command -v mise &>/dev/null; then
    echo -e "${RED}✗${NC} mise not installed. Install with: brew install mise"
    exit 1
fi
echo -e "${GREEN}✓${NC} mise installed: $(mise --version)"

# Create global mise config
MISE_GLOBAL_CONFIG="$HOME/.config/mise/config.toml"
echo -e "\n${YELLOW}Creating global mise config...${NC}"

mkdir -p ~/.config/mise
cat > "$MISE_GLOBAL_CONFIG" << 'EOF'
# Global Mise Configuration
# AI CLI tools and essential utilities available in all directories
#
# Location: ~/.config/mise/config.toml
# Docs: https://mise.jdx.dev/configuration.html

[tools]
# AI CLI Tools - available globally
"npm:@google/gemini-cli" = "latest"
"npm:@openai/codex" = "latest"
opencode = "latest"

# Essential global utilities
node = "lts"
bun = "latest"
uv = "latest"
python = "3.13"

# Version control
jj = "latest"

[settings]
# Automatically install tools when entering directories
auto_install = true
# Trust all config files in home directory
trusted_config_paths = ["~/.config/mise"]
EOF

echo -e "${GREEN}✓${NC} Global config created: $MISE_GLOBAL_CONFIG"

# Trust the config
echo -e "\n${YELLOW}Trusting global config...${NC}"
mise trust "$MISE_GLOBAL_CONFIG"
echo -e "${GREEN}✓${NC} Config trusted"

# Install tools
echo -e "\n${YELLOW}Installing global tools (this may take a moment)...${NC}"
mise install

# Regenerate shims
echo -e "\n${YELLOW}Regenerating shims...${NC}"
mise reshim
echo -e "${GREEN}✓${NC} Shims regenerated"

# Check if shims are in PATH
SHIMS_PATH="$HOME/.local/share/mise/shims"
if [[ ":$PATH:" != *":$SHIMS_PATH:"* ]]; then
    echo -e "\n${YELLOW}Adding shims to PATH...${NC}"

    # Detect shell config file
    if [[ -f "$HOME/.zshrc" ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        SHELL_RC="$HOME/.bashrc"
    else
        SHELL_RC="$HOME/.profile"
    fi

    # Check if already in config
    if ! grep -q 'mise/shims' "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Mise shims - ensures global tools available everywhere" >> "$SHELL_RC"
        echo "export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"" >> "$SHELL_RC"
        echo -e "${GREEN}✓${NC} Added shims to $SHELL_RC"
        echo -e "${YELLOW}!${NC} Run 'source $SHELL_RC' or restart terminal to activate"
    else
        echo -e "${GREEN}✓${NC} Shims already in $SHELL_RC"
    fi
fi

# Verify installation
echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Verification${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

export PATH="$HOME/.local/share/mise/shims:$PATH"

check_tool() {
    local name=$1
    local cmd=$2
    if command -v "$cmd" &>/dev/null; then
        local version=$($cmd --version 2>&1 | head -1)
        echo -e "${GREEN}✓${NC} $name: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $name: not found"
        return 1
    fi
}

FAILURES=0
check_tool "Gemini CLI" "gemini" || ((FAILURES++))
check_tool "OpenAI Codex" "codex" || ((FAILURES++))
check_tool "OpenCode" "opencode" || ((FAILURES++))
check_tool "Claude Code" "claude" || ((FAILURES++))
check_tool "Node.js" "node" || ((FAILURES++))
check_tool "Bun" "bun" || ((FAILURES++))
check_tool "uv" "uv" || ((FAILURES++))
check_tool "jj" "jj" || ((FAILURES++))

echo ""
if [[ $FAILURES -eq 0 ]]; then
    echo -e "${GREEN}All AI CLI tools are available globally!${NC}"
    echo ""
    echo "Usage:"
    echo "  gemini    - Google Gemini CLI"
    echo "  codex     - OpenAI Codex CLI"
    echo "  opencode  - OpenCode AI assistant"
    echo "  claude    - Claude Code CLI"
else
    echo -e "${RED}$FAILURES tool(s) not available. Check errors above.${NC}"
    exit 1
fi
