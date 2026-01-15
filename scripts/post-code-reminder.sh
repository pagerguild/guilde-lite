#!/bin/bash
# Post-Code-Change Reminder Hook
# Outputs guidance after code changes - NEVER blocks

cat << 'EOF'
Code changed. Reminders:
- Run tests if this is substantive code
- Consider code review before committing major changes
- Update docs if this affects public APIs
EOF

exit 0
