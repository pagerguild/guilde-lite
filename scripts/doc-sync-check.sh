#!/bin/bash
# scripts/doc-sync-check.sh
# Validates that documentation stays in sync with project state
# Run via: task docs:validate (add to Taskfile.yml)

set -euo pipefail

ERRORS=0
WARNINGS=0

echo "Checking documentation sync..."
echo ""

# Check 1: CLAUDE.md exists and has project state
if [[ ! -f CLAUDE.md ]]; then
    echo "ERROR: CLAUDE.md not found"
    ((ERRORS++))
else
    if ! grep -q "## Project State" CLAUDE.md; then
        echo "WARNING: CLAUDE.md missing Project State section"
        ((WARNINGS++))
    fi
fi

# Check 2: conductor/tracks.md exists
if [[ ! -f conductor/tracks.md ]]; then
    echo "ERROR: conductor/tracks.md not found"
    ((ERRORS++))
fi

# Check 3: Active track has plan.md
ACTIVE_TRACK=$(grep "| MULTI-" conductor/tracks.md 2>/dev/null | head -1 | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' || true)
if [[ -n "$ACTIVE_TRACK" ]]; then
    PLAN_PATH="conductor/tracks/${ACTIVE_TRACK}/plan.md"
    if [[ ! -f "$PLAN_PATH" ]]; then
        echo "ERROR: Active track $ACTIVE_TRACK missing plan.md at $PLAN_PATH"
        ((ERRORS++))
    else
        echo "OK: Active track $ACTIVE_TRACK has plan.md"
    fi
fi

# Check 4: Plan progress matches reality
if [[ -f conductor/tracks/MULTI-001/plan.md ]]; then
    CLAIMED_DONE=$(grep "Overall Progress:" conductor/tracks/MULTI-001/plan.md | grep -oE "[0-9]+" | head -1 || echo "0")
    ACTUAL_DONE=$(grep -c "^\- \[x\]" conductor/tracks/MULTI-001/plan.md || echo "0")

    if [[ "$CLAIMED_DONE" != "$ACTUAL_DONE" ]]; then
        echo "WARNING: Progress mismatch - claimed $CLAIMED_DONE done, but found $ACTUAL_DONE [x] markers"
        ((WARNINGS++))
    fi
fi

# Check 5: Key documentation files exist
REQUIRED_DOCS=(
    "docs/MULTI-AGENT-WORKFLOW.md"
    "conductor/workflow.md"
)

for doc in "${REQUIRED_DOCS[@]}"; do
    if [[ ! -f "$doc" ]]; then
        echo "ERROR: Required documentation missing: $doc"
        ((ERRORS++))
    fi
done

# Check 6: .claude/context.md is not stale (> 7 days)
if [[ -f .claude/context.md ]]; then
    CONTEXT_DATE=$(grep "Last Updated:" .claude/context.md | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || true)
    if [[ -n "$CONTEXT_DATE" ]]; then
        CONTEXT_TS=$(date -j -f "%Y-%m-%d" "$CONTEXT_DATE" "+%s" 2>/dev/null || date -d "$CONTEXT_DATE" "+%s" 2>/dev/null || echo "0")
        NOW_TS=$(date "+%s")
        AGE_DAYS=$(( (NOW_TS - CONTEXT_TS) / 86400 ))

        if [[ $AGE_DAYS -gt 7 ]]; then
            echo "WARNING: .claude/context.md is $AGE_DAYS days old - consider updating"
            ((WARNINGS++))
        fi
    fi
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [[ $ERRORS -gt 0 ]]; then
    echo "FAILED: $ERRORS errors, $WARNINGS warnings"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo "PASSED with warnings: $WARNINGS warnings"
    exit 0
else
    echo "PASSED: Documentation is in sync"
    exit 0
fi
