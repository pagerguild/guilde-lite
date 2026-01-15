#!/bin/bash
# Context Preservation Script
# Saves and restores session context for Claude Code handoffs

set -e

CONTEXT_DIR=".claude/context"
HANDOFF_FILE=".claude/SESSION_HANDOFF.md"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [--save|--restore|--status|--list]"
    echo ""
    echo "Commands:"
    echo "  --save     Save current session context"
    echo "  --restore  Restore most recent context"
    echo "  --status   Show current context status"
    echo "  --list     List saved contexts"
    echo "  --clean    Remove old context snapshots (keep last 5)"
    exit 1
}

save_context() {
    echo -e "${BLUE}Saving session context...${NC}"

    mkdir -p "$CONTEXT_DIR"

    local snapshot_file="$CONTEXT_DIR/snapshot_$TIMESTAMP.json"

    # Gather context data
    cat > "$snapshot_file" << EOF
{
    "timestamp": "$TIMESTAMP",
    "git": {
        "branch": "$(git branch --show-current 2>/dev/null || echo 'detached')",
        "status": "$(git status --porcelain 2>/dev/null | head -20 | tr '\n' '|')",
        "last_commit": "$(git log -1 --oneline 2>/dev/null || echo 'none')"
    },
    "track": {
        "current": "$(grep -m1 'Current Phase' conductor/tracks/MULTI-001/plan.md 2>/dev/null | cut -d':' -f2 | xargs || echo 'unknown')",
        "progress": "$(grep -m1 'Overall Progress' conductor/tracks/MULTI-001/plan.md 2>/dev/null | cut -d':' -f2 | xargs || echo 'unknown')"
    },
    "jj": {
        "active": $([ -d ".jj" ] && echo "true" || echo "false"),
        "status": "$(jj status 2>/dev/null | head -5 | tr '\n' '|' || echo 'not active')"
    },
    "modified_files": [
        $(git diff --name-only 2>/dev/null | head -10 | sed 's/.*/"&"/' | tr '\n' ',' | sed 's/,$//')
    ],
    "staged_files": [
        $(git diff --cached --name-only 2>/dev/null | head -10 | sed 's/.*/"&"/' | tr '\n' ',' | sed 's/,$//')
    ]
}
EOF

    # Update handoff file timestamp
    if [ -f "$HANDOFF_FILE" ]; then
        sed -i '' "s/\*\*Last Updated:\*\*.*/\*\*Last Updated:\*\* $(date '+%Y-%m-%d %H:%M:%S')/" "$HANDOFF_FILE" 2>/dev/null || true
    fi

    echo -e "${GREEN}✓${NC} Context saved to $snapshot_file"
    echo -e "${GREEN}✓${NC} Update $HANDOFF_FILE with session notes before ending"
}

restore_context() {
    echo -e "${BLUE}Restoring session context...${NC}"

    local latest=$(ls -t "$CONTEXT_DIR"/snapshot_*.json 2>/dev/null | head -1)

    if [ -z "$latest" ]; then
        echo -e "${RED}✗${NC} No saved context found"
        exit 1
    fi

    echo -e "${YELLOW}Latest snapshot:${NC} $latest"
    echo ""

    # Parse and display context
    if command -v jq &>/dev/null; then
        echo -e "${BLUE}Git State:${NC}"
        jq -r '.git | "  Branch: \(.branch)\n  Last commit: \(.last_commit)"' "$latest"

        echo -e "\n${BLUE}Track Progress:${NC}"
        jq -r '.track | "  Current: \(.current)\n  Progress: \(.progress)"' "$latest"

        echo -e "\n${BLUE}Modified Files:${NC}"
        jq -r '.modified_files[]? // "  (none)"' "$latest" | sed 's/^/  /'

        echo -e "\n${BLUE}jj Status:${NC}"
        jq -r 'if .jj.active then "  Active: yes" else "  Active: no" end' "$latest"
    else
        echo "Install jq for formatted output. Raw content:"
        cat "$latest"
    fi

    echo ""
    echo -e "${GREEN}✓${NC} Review $HANDOFF_FILE for session notes"
}

show_status() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Session Context Status${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Git status
    echo -e "${YELLOW}Git:${NC}"
    echo "  Branch: $(git branch --show-current 2>/dev/null || echo 'detached')"
    echo "  Modified: $(git status --porcelain 2>/dev/null | wc -l | xargs) files"
    echo "  Last commit: $(git log -1 --oneline 2>/dev/null || echo 'none')"

    # Track status
    echo -e "\n${YELLOW}Track:${NC}"
    if [ -f "conductor/tracks/MULTI-001/plan.md" ]; then
        grep -E "^(\*\*Current Phase|\*\*Overall Progress)" conductor/tracks/MULTI-001/plan.md 2>/dev/null | head -2
    else
        echo "  No active track"
    fi

    # jj status
    echo -e "\n${YELLOW}jj:${NC}"
    if [ -d ".jj" ]; then
        echo "  Colocated mode: active"
        jj log --limit 3 2>/dev/null | head -6 | sed 's/^/  /'
    else
        echo "  Not initialized"
    fi

    # Saved contexts
    echo -e "\n${YELLOW}Saved Contexts:${NC}"
    local count=$(ls "$CONTEXT_DIR"/snapshot_*.json 2>/dev/null | wc -l | xargs)
    echo "  $count snapshot(s) available"

    # Handoff file
    echo -e "\n${YELLOW}Handoff:${NC}"
    if [ -f "$HANDOFF_FILE" ]; then
        echo "  $HANDOFF_FILE exists"
        grep "Last Updated" "$HANDOFF_FILE" 2>/dev/null | head -1 | sed 's/^/  /'
    else
        echo "  No handoff file"
    fi
}

list_contexts() {
    echo -e "${BLUE}Saved Context Snapshots:${NC}"
    echo ""

    if [ ! -d "$CONTEXT_DIR" ]; then
        echo "No contexts saved yet."
        exit 0
    fi

    ls -lt "$CONTEXT_DIR"/snapshot_*.json 2>/dev/null | while read -r line; do
        echo "  $line"
    done

    echo ""
    echo "Total: $(ls "$CONTEXT_DIR"/snapshot_*.json 2>/dev/null | wc -l | xargs) snapshots"
}

clean_contexts() {
    echo -e "${BLUE}Cleaning old context snapshots...${NC}"

    local keep=5
    local count=$(ls "$CONTEXT_DIR"/snapshot_*.json 2>/dev/null | wc -l | xargs)

    if [ "$count" -le "$keep" ]; then
        echo "Only $count snapshots exist. Nothing to clean."
        exit 0
    fi

    local to_remove=$((count - keep))
    ls -t "$CONTEXT_DIR"/snapshot_*.json | tail -n "$to_remove" | while read -r file; do
        rm -f "$file"
        echo -e "${GREEN}✓${NC} Removed: $file"
    done

    echo ""
    echo "Kept $keep most recent snapshots."
}

# Main
case "${1:-}" in
    --save)
        save_context
        ;;
    --restore)
        restore_context
        ;;
    --status)
        show_status
        ;;
    --list)
        list_contexts
        ;;
    --clean)
        clean_contexts
        ;;
    *)
        usage
        ;;
esac
