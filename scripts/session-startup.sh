#!/bin/bash
# scripts/session-startup.sh
# Shows project status at session start for Claude Code context loading

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "                         PROJECT STATUS                                    "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Show active track from tracks.md
if [[ -f conductor/tracks.md ]]; then
    echo ""
    echo "ACTIVE TRACK:"
    grep -A 1 "| MULTI-" conductor/tracks.md 2>/dev/null | head -2 || echo "  No active tracks"
    echo ""
fi

# Show next pending task
if [[ -f conductor/tracks/MULTI-001/plan.md ]]; then
    echo "NEXT PENDING TASKS:"
    grep "^\- \[ \]" conductor/tracks/MULTI-001/plan.md 2>/dev/null | head -3 | sed 's/^/  /'
    echo ""
fi

# Show in-progress tasks
IN_PROGRESS=$(grep "^\- \[~\]" conductor/tracks/MULTI-001/plan.md 2>/dev/null | head -1 || true)
if [[ -n "$IN_PROGRESS" ]]; then
    echo "IN PROGRESS:"
    echo "  $IN_PROGRESS"
    echo ""
fi

# Show recent git activity
echo "RECENT COMMITS:"
git log --oneline -3 2>/dev/null | sed 's/^/  /' || echo "  No commits yet"
echo ""

# Show uncommitted changes
CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [[ "$CHANGES" -gt 0 ]]; then
    echo "UNCOMMITTED CHANGES: $CHANGES files"
    git status --porcelain 2>/dev/null | head -5 | sed 's/^/  /'
    echo ""
fi

# Check for session handoff
if [[ -f SESSION_HANDOFF.md ]]; then
    echo "SESSION HANDOFF FILE PRESENT - Review before continuing"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Read CLAUDE.md for full context. Run: cat conductor/tracks/MULTI-001/plan.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
