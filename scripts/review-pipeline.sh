#!/bin/bash
# Review Pipeline Script
# Orchestrates multi-stage code review pipeline
#
# Usage:
#   bash scripts/review-pipeline.sh [scope] [options]
#
# Scopes:
#   staged    - Review staged changes (default)
#   unstaged  - Review unstaged changes
#   branch    - Review branch vs main
#   all       - Review all uncommitted changes
#
# Options:
#   --quick     - Stage 1 only (automated checks)
#   --verbose   - Show detailed output
#   --json      - Output as JSON
#   --help      - Show help

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Show help (defined early for --help flag)
show_help() {
    echo "Review Pipeline - Multi-stage code review"
    echo ""
    echo "Usage: $0 [scope] [options]"
    echo ""
    echo "Scopes:"
    echo "  staged    Review staged changes (default)"
    echo "  unstaged  Review unstaged changes"
    echo "  branch    Review branch vs main"
    echo "  all       Review all uncommitted changes"
    echo ""
    echo "Options:"
    echo "  --quick   Stage 1 only (automated checks)"
    echo "  --verbose Show detailed output"
    echo "  --json    Output as JSON"
    echo "  --help    Show this help"
}

# Check for --help first (before any argument processing)
for arg in "$@"; do
    if [[ "$arg" == "--help" ]] || [[ "$arg" == "-h" ]]; then
        show_help
        exit 0
    fi
done

# Configuration
SCOPE="${1:-staged}"
VERBOSE=false
QUICK=false
JSON_OUTPUT=false

# Parse options (skip scope argument)
shift || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --quick) QUICK=true; shift ;;
        --verbose) VERBOSE=true; shift ;;
        --json) JSON_OUTPUT=true; shift ;;
        *) shift ;;
    esac
done

log() {
    if [[ "$VERBOSE" == "true" ]] || [[ "$JSON_OUTPUT" == "false" ]]; then
        echo -e "$@"
    fi
}

# Stage 1: Automated Checks
stage1_lint() {
    log "${BLUE}Running linters...${NC}"
    local lint_passed=true
    local lint_results=""

    # Go lint
    if [[ -f "go.mod" ]]; then
        if go vet ./... 2>/dev/null; then
            lint_results+="go:pass "
        else
            lint_results+="go:fail "
            lint_passed=false
        fi
    fi

    # Python lint
    if [[ -f "pyproject.toml" ]] || [[ -f "requirements.txt" ]]; then
        if command -v uv >/dev/null 2>&1 && uv run ruff check . 2>/dev/null; then
            lint_results+="python:pass "
        elif uv run ruff check . --quiet 2>/dev/null; then
            lint_results+="python:pass "
        else
            lint_results+="python:fail "
            lint_passed=false
        fi
    fi

    # TypeScript lint
    if [[ -f "package.json" ]]; then
        if command -v bun >/dev/null 2>&1 && bun run lint 2>/dev/null; then
            lint_results+="typescript:pass "
        elif bun run lint --quiet 2>/dev/null; then
            lint_results+="typescript:pass "
        else
            lint_results+="typescript:fail "
            lint_passed=false
        fi
    fi

    if [[ "$lint_passed" == "true" ]]; then
        log "${GREEN}✓ Linting passed${NC} ($lint_results)"
        return 0
    else
        log "${RED}✗ Linting failed${NC} ($lint_results)"
        return 1
    fi
}

stage1_tests() {
    log "${BLUE}Running tests...${NC}"
    local tests_passed=true
    local test_results=""

    # Go tests
    if [[ -f "go.mod" ]]; then
        if go test -v ./... 2>/dev/null | tail -1 | grep -q "ok\|PASS"; then
            test_results+="go:pass "
        elif go test ./... 2>/dev/null; then
            test_results+="go:pass "
        else
            test_results+="go:fail "
            tests_passed=false
        fi
    fi

    # Python tests
    if [[ -f "pyproject.toml" ]]; then
        if uv run pytest -q 2>/dev/null; then
            test_results+="python:pass "
        else
            test_results+="python:fail "
            tests_passed=false
        fi
    fi

    # TypeScript tests
    if [[ -f "package.json" ]] && grep -q '"test"' package.json 2>/dev/null; then
        if bun test 2>/dev/null; then
            test_results+="typescript:pass "
        else
            test_results+="typescript:fail "
            tests_passed=false
        fi
    fi

    if [[ -z "$test_results" ]]; then
        log "${YELLOW}⚠ No tests found${NC}"
        return 0
    elif [[ "$tests_passed" == "true" ]]; then
        log "${GREEN}✓ Tests passed${NC} ($test_results)"
        return 0
    else
        log "${RED}✗ Tests failed${NC} ($test_results)"
        return 1
    fi
}

stage1_typecheck() {
    log "${BLUE}Running type checks...${NC}"
    local typecheck_passed=true

    # Go type check (via build)
    if [[ -f "go.mod" ]]; then
        if go build ./... 2>/dev/null; then
            log "${GREEN}✓ Go type check passed${NC}"
        else
            log "${RED}✗ Go type check failed${NC}"
            typecheck_passed=false
        fi
    fi

    # Python type check
    if [[ -f "pyproject.toml" ]] && command -v mypy >/dev/null 2>&1; then
        if uv run mypy . 2>/dev/null; then
            log "${GREEN}✓ Python type check passed${NC}"
        else
            log "${YELLOW}⚠ Python type check had warnings${NC}"
        fi
    fi

    # TypeScript type check
    if [[ -f "tsconfig.json" ]]; then
        if bun run typecheck 2>/dev/null || bun tsc --noEmit 2>/dev/null; then
            log "${GREEN}✓ TypeScript type check passed${NC}"
        else
            log "${RED}✗ TypeScript type check failed${NC}"
            typecheck_passed=false
        fi
    fi

    [[ "$typecheck_passed" == "true" ]]
}

# Get diff based on scope
get_diff() {
    case "$SCOPE" in
        staged)
            git diff --cached
            ;;
        unstaged)
            git diff
            ;;
        branch)
            local base_branch
            base_branch=$(git remote show origin 2>/dev/null | grep "HEAD branch" | cut -d: -f2 | tr -d ' ' || echo "main")
            git diff "${base_branch}...HEAD"
            ;;
        all)
            git diff HEAD
            ;;
        *)
            git diff --cached
            ;;
    esac
}

# Get changed files based on scope
get_changed_files() {
    case "$SCOPE" in
        staged)
            git diff --cached --name-only
            ;;
        unstaged)
            git diff --name-only
            ;;
        branch)
            local base_branch
            base_branch=$(git remote show origin 2>/dev/null | grep "HEAD branch" | cut -d: -f2 | tr -d ' ' || echo "main")
            git diff --name-only "${base_branch}...HEAD"
            ;;
        all)
            git diff --name-only HEAD
            ;;
    esac
}

# Summary
show_summary() {
    local files_changed
    files_changed=$(get_changed_files | wc -l | tr -d ' ')

    log ""
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BOLD}${BLUE}   REVIEW PIPELINE SUMMARY${NC}"
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log ""
    log "Scope: $SCOPE"
    log "Files changed: $files_changed"
    log ""

    if [[ "$files_changed" -gt 0 ]]; then
        log "${CYAN}Changed files:${NC}"
        get_changed_files | head -10 | while read -r file; do
            echo "  - $file"
        done
        if [[ "$files_changed" -gt 10 ]]; then
            log "  ... and $((files_changed - 10)) more"
        fi
    fi
    log ""
}

# Main execution
main() {
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BOLD}${BLUE}   REVIEW PIPELINE - Stage 1: Automated Checks${NC}"
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log ""

    local stage1_passed=true

    # Run Stage 1 checks
    stage1_lint || stage1_passed=false
    stage1_tests || stage1_passed=false
    stage1_typecheck || stage1_passed=false

    log ""

    if [[ "$stage1_passed" == "true" ]]; then
        log "${GREEN}${BOLD}Stage 1: ALL CHECKS PASSED${NC}"
    else
        log "${RED}${BOLD}Stage 1: SOME CHECKS FAILED${NC}"
    fi

    if [[ "$QUICK" == "true" ]]; then
        log ""
        log "${YELLOW}Quick mode: Skipping Stage 2 agent reviews${NC}"
        show_summary
        exit 0
    fi

    log ""
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log "${BOLD}${BLUE}   Stage 2: Agent Reviews${NC}"
    log "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log ""
    log "To run Stage 2 agent reviews, invoke the following agents in parallel:"
    log ""
    log "${CYAN}1. Code Reviewer (opus):${NC}"
    log "   Task tool: subagent_type='pr-review-toolkit:code-reviewer'"
    log ""
    log "${CYAN}2. Security Auditor (opus):${NC}"
    log "   Task tool: subagent_type='full-stack-orchestration:security-auditor'"
    log ""
    log "${CYAN}3. Architect Reviewer (opus):${NC}"
    log "   Task tool: subagent_type='code-review-ai:architect-review'"
    log ""
    log "${YELLOW}Use /review-all command to orchestrate these reviews automatically.${NC}"

    show_summary

    # Track review event
    if [[ -f "scripts/multi-agent-metrics.sh" ]]; then
        bash scripts/multi-agent-metrics.sh track review_pipeline_stage1 2>/dev/null || true
    fi
}

main
