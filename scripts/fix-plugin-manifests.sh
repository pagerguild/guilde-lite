#!/bin/bash
# fix-plugin-manifests.sh
# Fixes missing plugin.json files for claude-code-workflows plugins
# These plugins are from https://github.com/wshobson/agents

set -e

CACHE_DIR="$HOME/.claude/plugins/cache/claude-code-workflows"
FIXED=0
SKIPPED=0
ERRORS=0

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║     FIXING MISSING PLUGIN MANIFESTS (claude-code-workflows)     ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

for plugin_dir in "$CACHE_DIR"/*/; do
    plugin_name=$(basename "$plugin_dir")

    for version_dir in "$plugin_dir"*/; do
        if [ ! -d "$version_dir" ]; then
            continue
        fi

        version=$(basename "$version_dir")
        manifest_dir="$version_dir/.claude-plugin"
        manifest_file="$manifest_dir/plugin.json"

        # Skip if already has plugin.json
        if [ -f "$manifest_file" ]; then
            echo "⏭  SKIP: $plugin_name ($version) - already has plugin.json"
            SKIPPED=$((SKIPPED+1))
            continue
        fi

        # Create .claude-plugin directory
        mkdir -p "$manifest_dir"

        # Generate description from plugin name
        description=$(echo "$plugin_name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

        # Create plugin.json
        cat > "$manifest_file" << EOF
{
  "name": "$plugin_name",
  "version": "$version",
  "description": "$description plugin for Claude Code",
  "author": {
    "name": "Seth Hobson",
    "email": "seth@major7apps.com",
    "url": "https://github.com/wshobson"
  },
  "homepage": "https://github.com/wshobson/agents",
  "repository": "https://github.com/wshobson/agents",
  "license": "MIT",
  "keywords": ["$(echo $plugin_name | tr '-' ',')"],
  "category": "development"
}
EOF

        if [ -f "$manifest_file" ]; then
            echo "✓ FIXED: $plugin_name ($version)"
            FIXED=$((FIXED+1))
        else
            echo "✗ ERROR: $plugin_name ($version) - failed to create plugin.json"
            ERRORS=$((ERRORS+1))
        fi
    done
done

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "                           SUMMARY"
echo "═══════════════════════════════════════════════════════════════════"
echo "  Fixed:   $FIXED"
echo "  Skipped: $SKIPPED (already had plugin.json)"
echo "  Errors:  $ERRORS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║  ✓ ALL PLUGIN MANIFESTS FIXED SUCCESSFULLY                      ║"
    echo "║                                                                  ║"
    echo "║  Restart Claude Code and run /doctor to verify                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
else
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║  ⚠ SOME ERRORS OCCURRED - CHECK OUTPUT ABOVE                    ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    exit 1
fi
