#!/bin/bash
# Bootstrap Script - One-command environment setup
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/guilde-lite/main/install.sh | bash
# Or: ./install.sh

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

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║   🚀 Development Environment Bootstrap                          ║"
echo "║                                                                  ║"
echo "║   Modern, reproducible setup for AI/Agent development           ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

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
# TASK RUNNER
# =============================================================================

if ! command -v task &>/dev/null; then
    log_info "Installing Task runner..."
    brew install go-task/tap/task
    log_success "Task installed"
else
    log_success "Task already installed"
fi

# =============================================================================
# MISE (Runtime Version Manager)
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
# HAND OFF TO TASKFILE
# =============================================================================

echo ""
log_info "Handing off to Taskfile for remaining setup..."
echo ""

# Run full setup
task setup

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
echo "  2. Start databases:"
echo "     task db:up"
echo ""
echo "  3. Verify everything works:"
echo "     task verify"
echo ""
echo "  4. For AI agent sandboxing, build the container:"
echo "     task sandbox:build"
echo ""
echo "  5. See all available commands:"
echo "     task"
echo ""
echo "Documentation: ./README.md"
echo ""
