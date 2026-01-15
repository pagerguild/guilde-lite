#!/bin/bash
# TDD Enforcer Script
# Validates test-driven development practices
#
# Usage:
#   bash scripts/tdd-enforcer.sh check <file>      - Check if tests exist for file
#   bash scripts/tdd-enforcer.sh run <file>        - Run tests for file
#   bash scripts/tdd-enforcer.sh coverage          - Check test coverage
#   bash scripts/tdd-enforcer.sh phase <phase>     - Set/get current TDD phase
#   bash scripts/tdd-enforcer.sh status            - Show TDD status
#
# TDD Phases: red, green, refactor

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# State tracking
TDD_STATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tdd-enforcer"
TDD_PHASE_FILE="$TDD_STATE_DIR/current-phase"
TDD_METRICS_FILE="$TDD_STATE_DIR/metrics.jsonl"

mkdir -p "$TDD_STATE_DIR"

# Initialize phase file if needed
if [[ ! -f "$TDD_PHASE_FILE" ]]; then
    echo "red" > "$TDD_PHASE_FILE"
fi

# Initialize metrics file if needed
if [[ ! -f "$TDD_METRICS_FILE" ]]; then
    echo '{"initialized":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}' > "$TDD_METRICS_FILE"
fi

# Detect language from file extension
detect_language() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        go) echo "go" ;;
        py) echo "python" ;;
        ts|tsx) echo "typescript" ;;
        js|jsx) echo "javascript" ;;
        rs) echo "rust" ;;
        rb) echo "ruby" ;;
        *) echo "unknown" ;;
    esac
}

# Find test file for a given source file
find_test_file() {
    local file="$1"
    local lang
    lang=$(detect_language "$file")
    local dir
    dir=$(dirname "$file")
    local base
    base=$(basename "$file")
    local name="${base%.*}"

    case "$lang" in
        go)
            # Go: foo.go -> foo_test.go
            local test_file="${dir}/${name}_test.go"
            if [[ -f "$test_file" ]]; then
                echo "$test_file"
                return 0
            fi
            ;;
        python)
            # Python: foo.py -> test_foo.py or tests/test_foo.py
            local test_file1="${dir}/test_${name}.py"
            local test_file2="${dir}/tests/test_${name}.py"
            local test_file3="tests/test_${name}.py"
            for tf in "$test_file1" "$test_file2" "$test_file3"; do
                if [[ -f "$tf" ]]; then
                    echo "$tf"
                    return 0
                fi
            done
            ;;
        typescript|javascript)
            # TS/JS: foo.ts -> foo.test.ts or foo.spec.ts or __tests__/foo.test.ts
            local ext="${base##*.}"
            local test_file1="${dir}/${name}.test.${ext}"
            local test_file2="${dir}/${name}.spec.${ext}"
            local test_file3="${dir}/__tests__/${name}.test.${ext}"
            for tf in "$test_file1" "$test_file2" "$test_file3"; do
                if [[ -f "$tf" ]]; then
                    echo "$tf"
                    return 0
                fi
            done
            ;;
        rust)
            # Rust: inline tests or tests/foo.rs
            local test_file="tests/${name}.rs"
            if [[ -f "$test_file" ]]; then
                echo "$test_file"
                return 0
            fi
            # Check for inline tests
            if grep -q "#\[cfg(test)\]" "$file" 2>/dev/null; then
                echo "$file (inline)"
                return 0
            fi
            ;;
    esac

    return 1
}

# Check if tests exist for a file
check_tests_exist() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo -e "${RED}File not found: $file${NC}"
        return 1
    fi

    local lang
    lang=$(detect_language "$file")

    if [[ "$lang" == "unknown" ]]; then
        echo -e "${YELLOW}Unknown language for: $file${NC}"
        return 0  # Don't enforce TDD for unknown languages
    fi

    local test_file
    if test_file=$(find_test_file "$file"); then
        echo -e "${GREEN}✓ Test file found: $test_file${NC}"
        return 0
    else
        echo -e "${RED}✗ No test file found for: $file${NC}"
        echo -e "${CYAN}Expected test file locations:${NC}"

        case "$lang" in
            go)
                echo "  - ${file%.*}_test.go"
                ;;
            python)
                local dir
                dir=$(dirname "$file")
                local name
                name=$(basename "${file%.*}")
                echo "  - ${dir}/test_${name}.py"
                echo "  - tests/test_${name}.py"
                ;;
            typescript|javascript)
                local dir
                dir=$(dirname "$file")
                local base
                base=$(basename "$file")
                local name="${base%.*}"
                echo "  - ${dir}/${name}.test.${base##*.}"
                echo "  - ${dir}/${name}.spec.${base##*.}"
                ;;
            rust)
                echo "  - tests/$(basename "${file%.*}").rs"
                echo "  - Or add #[cfg(test)] module in the file"
                ;;
        esac

        return 1
    fi
}

# Run tests for a file
run_tests() {
    local file="$1"
    local lang
    lang=$(detect_language "$file")
    local dir
    dir=$(dirname "$file")

    echo -e "${BLUE}Running tests for: $file${NC}"

    case "$lang" in
        go)
            go test -v "./$dir/..." 2>&1
            ;;
        python)
            if command -v uv &>/dev/null; then
                uv run pytest "$dir" -v 2>&1
            else
                pytest "$dir" -v 2>&1
            fi
            ;;
        typescript|javascript)
            if command -v bun &>/dev/null; then
                bun test "$dir" 2>&1
            elif [[ -f "package.json" ]]; then
                npm test -- --testPathPattern="$dir" 2>&1
            else
                echo -e "${YELLOW}No test runner found for TypeScript/JavaScript${NC}"
                echo "Install bun (recommended) or ensure package.json exists with test script"
                return 1
            fi
            ;;
        rust)
            cargo test --lib 2>&1
            ;;
        *)
            echo -e "${YELLOW}No test runner configured for: $lang${NC}"
            return 1
            ;;
    esac
}

# Check test coverage
check_coverage() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Test Coverage Report${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    local found_tests=false

    # Go coverage
    if [[ -f "go.mod" ]]; then
        echo -e "${CYAN}Go Coverage:${NC}"
        go test -cover ./... 2>/dev/null || echo "  No Go tests found"
        found_tests=true
        echo ""
    fi

    # Python coverage
    if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        echo -e "${CYAN}Python Coverage:${NC}"
        if command -v uv &>/dev/null; then
            uv run pytest --cov --cov-report=term-missing 2>/dev/null || echo "  No Python tests found"
        fi
        found_tests=true
        echo ""
    fi

    # TypeScript/JavaScript coverage
    if [[ -f "package.json" ]]; then
        echo -e "${CYAN}TypeScript/JavaScript Coverage:${NC}"
        if command -v bun &>/dev/null; then
            bun test --coverage 2>/dev/null || echo "  No TS/JS tests found"
        fi
        found_tests=true
        echo ""
    fi

    if ! $found_tests; then
        echo -e "${YELLOW}No test frameworks detected in this project.${NC}"
    fi
}

# Get/set current TDD phase
handle_phase() {
    local action="${1:-get}"

    case "$action" in
        get)
            local phase
            phase=$(cat "$TDD_PHASE_FILE")
            echo "$phase"
            ;;
        red|green|refactor)
            echo "$action" > "$TDD_PHASE_FILE"

            # Track phase change
            local json
            json=$(printf '{"ts":"%s","event":"phase_change","phase":"%s"}' \
                "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$action")
            echo "$json" >> "$TDD_METRICS_FILE"

            case "$action" in
                red)
                    echo -e "${RED}🔴 TDD Phase: RED${NC}"
                    echo "   Write a failing test first!"
                    ;;
                green)
                    echo -e "${GREEN}🟢 TDD Phase: GREEN${NC}"
                    echo "   Write minimal code to pass the test!"
                    ;;
                refactor)
                    echo -e "${YELLOW}🔄 TDD Phase: REFACTOR${NC}"
                    echo "   Improve code quality, keep tests passing!"
                    ;;
            esac
            ;;
        next)
            local current
            current=$(cat "$TDD_PHASE_FILE")
            local next_phase
            case "$current" in
                red) next_phase="green" ;;
                green) next_phase="refactor" ;;
                refactor) next_phase="red" ;;
                *) next_phase="red" ;;
            esac
            handle_phase "$next_phase"
            ;;
        *)
            echo "Usage: $0 phase [red|green|refactor|next|get]"
            return 1
            ;;
    esac
}

# Show TDD status
show_status() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   TDD Enforcer Status${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Current phase
    local phase
    phase=$(cat "$TDD_PHASE_FILE")
    echo -e "${CYAN}Current Phase:${NC}"
    case "$phase" in
        red)
            echo -e "  ${RED}🔴 RED${NC} - Write failing test"
            ;;
        green)
            echo -e "  ${GREEN}🟢 GREEN${NC} - Make test pass"
            ;;
        refactor)
            echo -e "  ${YELLOW}🔄 REFACTOR${NC} - Improve code"
            ;;
    esac
    echo ""

    # Phase cycle reminder
    echo -e "${CYAN}TDD Cycle:${NC}"
    echo "  RED → GREEN → REFACTOR → (repeat)"
    echo ""

    # Recent activity
    if [[ -f "$TDD_METRICS_FILE" ]]; then
        local phase_changes
        phase_changes=$(grep -c '"event":"phase_change"' "$TDD_METRICS_FILE" 2>/dev/null || echo "0")
        phase_changes=$(echo "$phase_changes" | tr -d ' \n')
        [[ -z "$phase_changes" ]] && phase_changes=0

        echo -e "${CYAN}Statistics:${NC}"
        echo "  Phase changes: $phase_changes"
    fi
    echo ""

    # Quick commands
    echo -e "${CYAN}Quick Commands:${NC}"
    echo "  bash scripts/tdd-enforcer.sh phase red      # Start RED phase"
    echo "  bash scripts/tdd-enforcer.sh phase next     # Move to next phase"
    echo "  bash scripts/tdd-enforcer.sh check <file>   # Check test exists"
    echo "  bash scripts/tdd-enforcer.sh run <file>     # Run tests"
    echo ""
}

# Validate implementation against TDD rules
validate_tdd() {
    local file="$1"
    local phase
    phase=$(cat "$TDD_PHASE_FILE")

    echo -e "${BLUE}Validating TDD compliance for: $file${NC}"
    echo -e "Current phase: $phase"
    echo ""

    case "$phase" in
        red)
            # In RED phase, should be writing tests, not implementation
            local lang
            lang=$(detect_language "$file")
            local is_test=false

            case "$lang" in
                go)
                    [[ "$file" == *"_test.go" ]] && is_test=true
                    ;;
                python)
                    [[ "$file" == *"test_"* ]] && is_test=true
                    ;;
                typescript|javascript)
                    [[ "$file" == *".test."* ]] || [[ "$file" == *".spec."* ]] && is_test=true
                    ;;
            esac

            if $is_test; then
                echo -e "${GREEN}✓ Correct: Writing test file in RED phase${NC}"
                return 0
            else
                echo -e "${YELLOW}⚠ Warning: Writing implementation in RED phase${NC}"
                echo "  In RED phase, you should write tests first!"
                echo "  Suggestion: Write tests in a *_test.* file first"
                return 1
            fi
            ;;
        green)
            # In GREEN phase, should be writing implementation
            echo -e "${GREEN}✓ GREEN phase: Implementation allowed${NC}"
            echo "  Remember: Write MINIMAL code to pass the test"
            return 0
            ;;
        refactor)
            # In REFACTOR phase, can modify but tests must pass
            echo -e "${YELLOW}🔄 REFACTOR phase: Code improvement allowed${NC}"
            echo "  Remember: All tests must still pass after changes"
            return 0
            ;;
    esac
}

# Main dispatch
case "${1:-status}" in
    check)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 check <file>"
            exit 1
        fi
        check_tests_exist "$2"
        ;;
    run)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 run <file>"
            exit 1
        fi
        run_tests "$2"
        ;;
    coverage)
        check_coverage
        ;;
    phase)
        handle_phase "${2:-get}"
        ;;
    validate)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 validate <file>"
            exit 1
        fi
        validate_tdd "$2"
        ;;
    status)
        show_status
        ;;
    *)
        echo "TDD Enforcer - Test-Driven Development Enforcement"
        echo ""
        echo "Usage: $0 {check|run|coverage|phase|validate|status}"
        echo ""
        echo "Commands:"
        echo "  check <file>     - Check if tests exist for file"
        echo "  run <file>       - Run tests for file"
        echo "  coverage         - Show test coverage report"
        echo "  phase [phase]    - Get/set TDD phase (red|green|refactor|next)"
        echo "  validate <file>  - Validate file against TDD rules"
        echo "  status           - Show TDD status"
        exit 1
        ;;
esac
