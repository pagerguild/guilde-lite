#!/bin/bash
# validate.sh - Comprehensive validation for guilde-lite
# Validates Brewfiles, Taskfile.yml, and configuration files

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

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

echo "=== Guilde-Lite Validation Suite ==="
echo ""

# -----------------------------------------------------------------------------
# 1. Validate Taskfile.yml with JSON Schema
# -----------------------------------------------------------------------------
echo "--- Validating Taskfile.yml ---"

if command -v python3 &>/dev/null; then
    if python3 -c "import check_jsonschema" 2>/dev/null; then
        if python3 -m check_jsonschema --builtin-schema vendor.taskfile Taskfile.yml 2>/dev/null; then
            log_success "Taskfile.yml schema validation passed"
        else
            log_error "Taskfile.yml schema validation failed"
        fi
    else
        log_warn "check-jsonschema not installed (pip install check-jsonschema)"
    fi
else
    log_warn "Python3 not found, skipping schema validation"
fi

# Verify Taskfile is parseable by task
if command -v task &>/dev/null; then
    if task --list &>/dev/null; then
        log_success "Taskfile.yml is parseable by task"
    else
        log_error "Taskfile.yml cannot be parsed by task"
    fi
else
    log_warn "task (go-task) not installed"
fi

echo ""

# -----------------------------------------------------------------------------
# 2. Validate Brewfiles
# -----------------------------------------------------------------------------
echo "--- Validating Brewfiles ---"

# Check Ruby syntax of all Brewfiles
for brewfile in Brewfile brew/*.Brewfile; do
    if [ -f "$brewfile" ]; then
        if ruby -c "$brewfile" &>/dev/null; then
            log_success "$brewfile: Ruby syntax OK"
        else
            log_error "$brewfile: Ruby syntax error"
            ruby -c "$brewfile" 2>&1 | head -5
        fi
    fi
done

# Check for common Brewfile mistakes
echo ""
echo "--- Checking for common mistakes ---"

# Check for task vs go-task conflict
if grep -l 'brew "task"' Brewfile brew/*.Brewfile 2>/dev/null | grep -v "go-task"; then
    log_error "Found 'brew \"task\"' (Taskwarrior) - should be 'brew \"go-task\"'"
else
    log_success "No task/go-task naming conflict"
fi

# Check for deprecated taps
if grep -q 'tap "jdx/mise"' Brewfile brew/*.Brewfile 2>/dev/null; then
    log_error "Found deprecated jdx/mise tap - mise is now in homebrew-core"
else
    log_success "No deprecated taps found"
fi

# Check for duplicate entries
for brewfile in Brewfile brew/*.Brewfile; do
    if [ -f "$brewfile" ]; then
        dupes=$(grep -E '^(brew|cask|tap) ' "$brewfile" | sort | uniq -d)
        if [ -n "$dupes" ]; then
            log_error "$brewfile: Duplicate entries found:"
            echo "$dupes" | while read line; do log_info "  $line"; done
        fi
    fi
done

echo ""

# -----------------------------------------------------------------------------
# 3. Validate YAML files
# -----------------------------------------------------------------------------
echo "--- Validating YAML files ---"

if command -v yamllint &>/dev/null; then
    for yaml in Taskfile.yml mise.toml docker/*.yml .github/workflows/*.yml; do
        if [ -f "$yaml" ]; then
            if yamllint -d relaxed "$yaml" &>/dev/null; then
                log_success "$yaml: YAML lint passed"
            else
                log_warn "$yaml: YAML lint warnings"
            fi
        fi
    done
else
    log_warn "yamllint not installed (pip install yamllint)"
fi

echo ""

# -----------------------------------------------------------------------------
# 4. Validate shell scripts
# -----------------------------------------------------------------------------
echo "--- Validating shell scripts ---"

if command -v shellcheck &>/dev/null; then
    for script in install.sh scripts/*.sh ci/*.sh; do
        if [ -f "$script" ]; then
            if shellcheck -x "$script" &>/dev/null; then
                log_success "$script: shellcheck passed"
            else
                log_warn "$script: shellcheck warnings"
            fi
        fi
    done
else
    log_warn "shellcheck not installed (brew install shellcheck)"
fi

echo ""

# -----------------------------------------------------------------------------
# 5. Dry-run brew bundle
# -----------------------------------------------------------------------------
echo "--- Dry-run Homebrew validation ---"

if command -v brew &>/dev/null; then
    # Check if all formulas exist
    echo "Checking if all formulas/casks exist in Homebrew..."

    for brewfile in brew/01-core.Brewfile; do
        if [ -f "$brewfile" ]; then
            # Extract formula names and check each one
            formulas=$(grep -E '^brew "' "$brewfile" | sed 's/brew "\([^"]*\)".*/\1/')
            all_exist=true
            for formula in $formulas; do
                if ! brew info "$formula" &>/dev/null; then
                    log_error "Formula not found: $formula"
                    all_exist=false
                fi
            done
            if $all_exist; then
                log_success "$brewfile: All formulas exist"
            fi
        fi
    done
else
    log_warn "Homebrew not installed"
fi

echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "=== Validation Summary ==="
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}All validations passed!${NC}"
    if [ $warnings -gt 0 ]; then
        echo -e "${YELLOW}$warnings warning(s)${NC}"
    fi
    exit 0
else
    echo -e "${RED}$errors error(s) found${NC}"
    if [ $warnings -gt 0 ]; then
        echo -e "${YELLOW}$warnings warning(s)${NC}"
    fi
    exit 1
fi
