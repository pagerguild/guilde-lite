# justfile - Simple command runner for guilde-lite
# Alternative to Taskfile.yml for those who prefer just's simpler syntax
# Run `just` to see all available recipes

# Default recipe: show help
default:
    @just --list

# Validate all configuration files (fast)
validate:
    task validate

# Comprehensive validation (includes slow checks)
validate-all:
    @chmod +x scripts/validate.sh
    @./scripts/validate.sh

# Quick validation (just schema check)
validate-quick:
    @python3 -m check_jsonschema --builtin-schema vendor.taskfile Taskfile.yml

# Run validation test suite
validate-test:
    @chmod +x scripts/test-validation.sh
    @./scripts/test-validation.sh

# Verify runtime installations
validate-runtimes:
    task validate:runtimes

# Install Stage 1 (core tools)
stage1:
    brew bundle install --file=brew/01-core.Brewfile

# Verify Stage 1
verify-stage1:
    @echo "=== Verifying Stage 1 ==="
    @command -v git && git --version
    @command -v jj && jj --version
    @command -v just && just --version
    @command -v mise && mise --version
    @command -v task && task --version
    @echo "✓ Stage 1 complete"

# Run all stages
setup-all:
    task setup

# Run minimal setup
setup-minimal:
    task setup:minimal

# Run developer setup
setup-dev:
    task setup:developer

# Run full setup
setup-full:
    task setup:full

# Start databases
db-up:
    docker compose -f docker/docker-compose.yml up -d

# Stop databases
db-down:
    docker compose -f docker/docker-compose.yml down

# Install pre-commit hooks
hooks-install:
    pip install pre-commit
    pre-commit install

# Run pre-commit on all files
hooks-run:
    pre-commit run --all-files

# Lint all code
lint:
    task lint

# Run all tests
test:
    task test

# Clean build artifacts
clean:
    task clean
