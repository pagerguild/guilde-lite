#!/bin/bash
# Context Preservation Reminder Hook
# Outputs guidance before compaction - NEVER blocks

cat << 'EOF'
Context preservation reminder: Consider saving important context to .claude/SESSION_HANDOFF.md if there's complex work in progress.
EOF

exit 0
