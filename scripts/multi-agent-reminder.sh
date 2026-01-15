#!/bin/bash
# Multi-Agent Workflow Reminder Hook
# This script outputs guidance text that gets added to context
# It ALWAYS exits 0 (never blocks) - it's guidance, not enforcement

# Output guidance as context (stdout gets added to conversation)
cat << 'EOF'
MULTI-AGENT WORKFLOW REMINDER:

For COMPLEX tasks, consider using subagents:
- Large codebase exploration → Explore agent (thoroughness: "very thorough")
- Code review before commits → code-reviewer agent
- Multi-file validation → parallel validation agents
- Architecture decisions → Plan agent

Answer DIRECTLY (no subagents needed) for:
- Status questions ("what is X?", "where is Y?")
- Simple file reads or lookups
- Configuration checks
- Quick explanations
- Single-file operations

Use judgment to match complexity of approach to complexity of task.
EOF

# Always exit 0 - this is guidance, not enforcement
exit 0
