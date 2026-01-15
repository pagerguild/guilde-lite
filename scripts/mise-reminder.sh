#!/bin/bash
# Mise-First Reminder Hook
# Outputs guidance for mise-managed tools - NEVER blocks

cat << 'EOF'
MISE-FIRST REMINDER: This project prefers mise-managed tools:
- pip install → prefer 'uv pip install' or 'uvx'
- npm install -g → prefer 'mise use npm:<pkg>@latest'
- brew install <runtime> → prefer 'mise use <runtime>@latest'

These are preferences, not hard blocks. Proceed if appropriate.
EOF

exit 0
