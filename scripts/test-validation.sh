#!/bin/bash
# test-validation.sh - Test suite for validation logic
# Ensures validation checks catch known issues

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

passed=0
failed=0

test_pass() { echo -e "${GREEN}PASS${NC}: $1"; passed=$((passed + 1)); }
test_fail() { echo -e "${RED}FAIL${NC}: $1"; failed=$((failed + 1)); }

echo "=== Validation Test Suite ==="
echo ""

# -----------------------------------------------------------------------------
# Test 1: task/go-task detection pattern
# -----------------------------------------------------------------------------
echo "--- Test: task/go-task detection ---"

# Create temp test file
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

# Test: Should detect 'brew "task"' (Taskwarrior)
echo 'brew "task"' > "$temp_dir/bad.Brewfile"
if grep -E 'brew "[^"]*\btask"' "$temp_dir/bad.Brewfile" 2>/dev/null | grep -qv 'go-task'; then
    test_pass "Detects bare 'brew \"task\"' (Taskwarrior)"
else
    test_fail "Should detect 'brew \"task\"'"
fi

# Test: Should NOT flag 'brew "go-task"'
echo 'brew "go-task"' > "$temp_dir/good.Brewfile"
if grep -E 'brew "[^"]*\btask"' "$temp_dir/good.Brewfile" 2>/dev/null | grep -qv 'go-task'; then
    test_fail "Should NOT flag 'brew \"go-task\"'"
else
    test_pass "Does not flag 'brew \"go-task\"'"
fi

# Test: Should detect 'brew "task"' even with options
echo 'brew "task", restart_service: :changed' > "$temp_dir/bad-options.Brewfile"
if grep -E 'brew "[^"]*\btask"' "$temp_dir/bad-options.Brewfile" 2>/dev/null | grep -qv 'go-task'; then
    test_pass "Detects 'brew \"task\"' with options"
else
    test_fail "Should detect 'brew \"task\"' with options"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 2: Brewfile Ruby syntax validation
# -----------------------------------------------------------------------------
echo "--- Test: Brewfile syntax validation ---"

# Test: Valid Brewfile syntax
cat > "$temp_dir/valid.Brewfile" << 'EOF'
brew "git"
cask "visual-studio-code"
tap "homebrew/cask-fonts"
EOF
if ruby -c "$temp_dir/valid.Brewfile" &>/dev/null; then
    test_pass "Valid Brewfile passes Ruby syntax check"
else
    test_fail "Valid Brewfile should pass"
fi

# Test: Invalid Brewfile syntax
echo 'brew "git' > "$temp_dir/invalid.Brewfile"
if ruby -c "$temp_dir/invalid.Brewfile" &>/dev/null; then
    test_fail "Invalid Brewfile should fail"
else
    test_pass "Invalid Brewfile fails Ruby syntax check"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 3: Deprecated tap detection
# -----------------------------------------------------------------------------
echo "--- Test: Deprecated tap detection ---"

echo 'tap "jdx/mise"' > "$temp_dir/deprecated.Brewfile"
if grep -q 'tap "jdx/mise"' "$temp_dir/deprecated.Brewfile"; then
    test_pass "Detects deprecated jdx/mise tap"
else
    test_fail "Should detect deprecated tap"
fi

echo ""

# -----------------------------------------------------------------------------
# Test 4: Duplicate entry detection
# -----------------------------------------------------------------------------
echo "--- Test: Duplicate entry detection ---"

cat > "$temp_dir/dupes.Brewfile" << 'EOF'
brew "git"
brew "gh"
brew "git"
EOF
dupes=$(grep -E '^(brew|cask|tap) ' "$temp_dir/dupes.Brewfile" | sort | uniq -d)
if [ -n "$dupes" ]; then
    test_pass "Detects duplicate entries"
else
    test_fail "Should detect duplicate entries"
fi

echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "=== Test Summary ==="
echo "Passed: $passed"
echo "Failed: $failed"

if [ $failed -gt 0 ]; then
    echo -e "${RED}Some tests failed${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed${NC}"
    exit 0
fi
