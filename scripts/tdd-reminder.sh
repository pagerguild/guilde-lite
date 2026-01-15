#!/bin/bash
# TDD Reminder Hook
# Outputs guidance for TDD practices - NEVER blocks

cat << 'EOF'
TDD REMINDER: This project follows TDD practices.
- Consider writing tests before implementation
- Consider code review before committing substantive changes

These are guidelines - use judgment based on change scope.
EOF

exit 0
