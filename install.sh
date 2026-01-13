#!/bin/bash
# Bootstrap Script - One-command environment setup
# Supports staged installation for testing
#
# Usage:
#   ./install.sh              # Full setup (all stages)
#   ./install.sh minimal      # Core + CLI + runtimes only
#   ./install.sh developer    # Minimal + terminal + containers
#   ./install.sh full         # Everything including AI and databases
#   ./install.sh stage N      # Run specific stage (1-9)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_help() {
    echo ""
    echo "Usage: ./install.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  (none)      Full setup - all stages"
    echo "  minimal     Core + CLI + runtimes only"
    echo "  developer   Minimal + terminal + containers + build tools"
    echo "  full        Everything including AI and databases"
    echo "  stage N     Run specific stage (1-9, runtimes, configs)"
    echo "  help        Show this help message"
    echo ""
    echo "Stages:"
    echo "  1           Core tools (git, mise, task)"
    echo "  2           Modern CLI (ripgrep, fd, bat, etc.)"
    echo "  3           Terminal (Ghostty, tmux, fonts)"
    echo "  4           Containers (OrbStack, kubectl, helm)"
    echo "  5           Database clients (psql, redis-cli)"
    echo "  6           Cloud/AWS (awscli, granted)"
    echo "  7           AI tools (Cursor)"
    echo "  8           Security (age, sops, trivy)"
    echo "  9           Build tools (cmake, ninja)"
    echo "  runtimes    Languages via mise (Go, Python, Rust, Bun)"
    echo "  configs     Shell, git, tmux, ghostty configs"
    echo "  databases   Start database containers"
    echo "  ai-tools    Claude Code and AI tools"
    echo ""
}

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║   🚀 Development Environment Bootstrap                          ║"
echo "║                                                                  ║"
echo "║   Modern, reproducible setup for AI/Agent development           ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Handle help
if [[ "${1:-}" == "help" ]] || [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    show_help
    exit 0
fi

# =============================================================================
# PRE-FLIGHT CHECKS
# =============================================================================

log_info "Running pre-flight checks..."

# Check macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is designed for macOS. For Linux, see docs/linux-setup.md"
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
    log_warn "This setup is optimized for Apple Silicon (arm64). You're on $ARCH."
fi

# Check for Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    log_warn "Please complete the Xcode CLT installation and re-run this script."
    exit 1
fi

log_success "Pre-flight checks passed"

# =============================================================================
# HOMEBREW
# =============================================================================

if ! command -v brew &>/dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Add to .zprofile for future sessions
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    log_success "Homebrew installed"
else
    log_success "Homebrew already installed"
fi

# Update Homebrew
log_info "Updating Homebrew..."
brew update

# =============================================================================
# TASK RUNNER (Required for all installation types)
# =============================================================================

if ! command -v task &>/dev/null; then
    log_info "Installing Task runner..."
    brew install go-task/tap/task
    log_success "Task installed"
else
    log_success "Task already installed"
fi

# =============================================================================
# MISE (Required for runtimes)
# =============================================================================

if ! command -v mise &>/dev/null; then
    log_info "Installing mise..."
    brew install mise

    # Activate mise in current shell
    eval "$(mise activate bash)"
    log_success "mise installed"
else
    log_success "mise already installed"
fi

# =============================================================================
# DETERMINE INSTALLATION TYPE
# =============================================================================

INSTALL_TYPE="${1:-setup}"
STAGE_NUM="${2:-}"

echo ""
log_info "Installation type: $INSTALL_TYPE"
echo ""

case "$INSTALL_TYPE" in
    "minimal")
        log_info "Running minimal setup..."
        task setup:minimal
        ;;
    "developer")
        log_info "Running developer setup..."
        task setup:developer
        ;;
    "full")
        log_info "Running full setup..."
        task setup:full
        ;;
    "stage")
        if [[ -z "$STAGE_NUM" ]]; then
            log_error "Please specify a stage number: ./install.sh stage N"
            show_help
            exit 1
        fi
        log_info "Running stage: $STAGE_NUM"
        task "stage:$STAGE_NUM"
        ;;
    "setup"|"")
        log_info "Running default setup (all Homebrew packages + runtimes + configs)..."
        task setup
        ;;
    *)
        log_error "Unknown option: $INSTALL_TYPE"
        show_help
        exit 1
        ;;
esac

# =============================================================================
# POST-INSTALL INSTRUCTIONS
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║   ✅ Installation Complete!                                     ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "  1. Restart your terminal (or run: source ~/.zshrc)"
echo ""
echo "  2. Verify the installation:"
echo "     task verify"
echo ""
echo "  3. See staged installation guide:"
echo "     task help:stages"
echo ""
echo "  4. If you ran minimal/developer setup, continue with:"
echo "     task stage:N          # Run additional stages"
echo "     task setup:full       # Complete full setup"
echo ""
echo "Documentation: ./README.md"
echo ""
