#!/bin/bash
# Self-hosted GitHub Actions runner for local macOS
# Usage: ./ci/runner-local.sh <GITHUB_TOKEN> <REPO_URL>
# Example: ./ci/runner-local.sh ghp_xxxxx https://github.com/org/repo

set -euo pipefail

GITHUB_TOKEN="${1:?Usage: $0 <GITHUB_TOKEN> <REPO_URL>}"
REPO_URL="${2:?Usage: $0 <GITHUB_TOKEN> <REPO_URL>}"

RUNNER_DIR="$HOME/.github-runner"
RUNNER_VERSION="2.321.0"  # Update as needed

echo "Setting up GitHub Actions runner for: $REPO_URL"

# Create runner directory
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

# Download runner if not exists
if [[ ! -f "./run.sh" ]]; then
    echo "Downloading runner v${RUNNER_VERSION}..."

    # Detect architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" ]]; then
        RUNNER_ARCH="osx-arm64"
    else
        RUNNER_ARCH="osx-x64"
    fi

    curl -sL "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz" | tar xz
fi

# Get registration token
echo "Getting registration token..."
REG_TOKEN=$(curl -sX POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "${REPO_URL}/actions/runners/registration-token" | jq -r '.token')

if [[ -z "$REG_TOKEN" || "$REG_TOKEN" == "null" ]]; then
    echo "Error: Could not get registration token. Check your GitHub token permissions."
    exit 1
fi

# Configure runner
echo "Configuring runner..."
./config.sh \
    --url "$REPO_URL" \
    --token "$REG_TOKEN" \
    --name "$(hostname)-mac" \
    --labels "self-hosted,macOS,ARM64,self-hosted-mac" \
    --work "_work" \
    --replace

# Install as service (macOS launchd)
echo "Installing as service..."
./svc.sh install
./svc.sh start

echo "Runner installed and started successfully!"
echo "View status: ./svc.sh status"
echo "Stop runner: ./svc.sh stop"
echo "Uninstall: ./svc.sh uninstall"
