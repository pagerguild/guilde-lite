#!/bin/bash
# Documentation Sync Checker
# Validates that documentation stays in sync with code changes
#
# Usage:
#   bash scripts/doc-sync-check.sh check <file>     - Check if docs need updating
#   bash scripts/doc-sync-check.sh scan             - Scan all modified files
#   bash scripts/doc-sync-check.sh validate         - Validate documentation structure
#   bash scripts/doc-sync-check.sh report           - Generate doc-sync report
#   bash scripts/doc-sync-check.sh mappings         - Show code-to-doc mappings
#   bash scripts/doc-sync-check.sh status           - Show documentation status
#
# Exit codes:
#   0 - Documentation is in sync
#   1 - Documentation may need updates

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# State tracking
DOC_STATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/doc-sync"
DOC_MAPPINGS_FILE="$DOC_STATE_DIR/mappings.json"
DOC_HISTORY_FILE="$DOC_STATE_DIR/history.jsonl"

mkdir -p "$DOC_STATE_DIR"

# Initialize mappings file with default mappings
if [[ ! -f "$DOC_MAPPINGS_FILE" ]]; then
    cat > "$DOC_MAPPINGS_FILE" << 'EOF'
{
  "mappings": [
    {
      "pattern": "^conductor/.*",
      "docs": ["docs/MULTI-AGENT-WORKFLOW.md", "conductor/workflow.md"],
      "description": "Conductor workflow files"
    },
    {
      "pattern": "^scripts/.*\\.sh$",
      "docs": ["README.md", "CLAUDE.md"],
      "description": "Shell scripts"
    },
    {
      "pattern": "^\\.claude/settings\\.json$",
      "docs": ["docs/MULTI-AGENT-WORKFLOW.md", "CLAUDE.md"],
      "description": "Claude settings"
    },
    {
      "pattern": "^\\.claude/agents/.*",
      "docs": ["docs/MULTI-AGENT-WORKFLOW.md", ".claude/AGENT-SELECTION.md"],
      "description": "Agent definitions"
    },
    {
      "pattern": "^\\.claude/skills/.*",
      "docs": ["docs/MULTI-AGENT-WORKFLOW.md"],
      "description": "Skill definitions"
    },
    {
      "pattern": "^\\.claude/commands/.*",
      "docs": ["CLAUDE.md"],
      "description": "Command definitions"
    },
    {
      "pattern": "^Taskfile\\.yml$",
      "docs": ["README.md", "CLAUDE.md"],
      "description": "Task runner configuration"
    },
    {
      "pattern": "^mise\\.toml$",
      "docs": ["README.md", "conductor/tech-stack.md"],
      "description": "Runtime version configuration"
    },
    {
      "pattern": "^docker/.*",
      "docs": ["README.md", "CLAUDE.md"],
      "description": "Docker configuration"
    },
    {
      "pattern": "^sandbox/.*",
      "docs": ["CLAUDE.md"],
      "description": "Sandbox configurations"
    }
  ]
}
EOF
fi

# Initialize history file
if [[ ! -f "$DOC_HISTORY_FILE" ]]; then
    echo '{"initialized":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}' > "$DOC_HISTORY_FILE"
fi

# Find related docs for a file
find_related_docs() {
    local file="$1"
    local docs=()

    # Read mappings and check patterns
    while IFS= read -r mapping; do
        local pattern
        pattern=$(echo "$mapping" | jq -r '.pattern')
        local doc_list
        doc_list=$(echo "$mapping" | jq -r '.docs[]')

        if [[ "$file" =~ $pattern ]]; then
            while IFS= read -r doc; do
                if [[ -f "$doc" ]]; then
                    docs+=("$doc")
                fi
            done <<< "$doc_list"
        fi
    done < <(jq -c '.mappings[]' "$DOC_MAPPINGS_FILE")

    # Remove duplicates and print
    if [[ ${#docs[@]} -gt 0 ]]; then
        printf '%s\n' "${docs[@]}" | sort -u
    fi
}

# Check if a file needs doc updates
check_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        echo -e "${RED}File not found: $file${NC}"
        return 1
    fi

    echo -e "${BLUE}Checking documentation for: $file${NC}"
    echo ""

    local related_docs
    related_docs=$(find_related_docs "$file")

    if [[ -z "$related_docs" ]]; then
        echo -e "${YELLOW}No documentation mappings found for this file.${NC}"
        echo "Consider adding a mapping in: $DOC_MAPPINGS_FILE"
        return 0
    fi

    echo -e "${CYAN}Related documentation:${NC}"
    local needs_review=false

    while IFS= read -r doc; do
        if [[ -n "$doc" ]]; then
            local file_mtime doc_mtime
            file_mtime=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
            doc_mtime=$(stat -f %m "$doc" 2>/dev/null || stat -c %Y "$doc" 2>/dev/null)

            if [[ "$file_mtime" -gt "$doc_mtime" ]]; then
                echo -e "  ${YELLOW}⚠ $doc${NC} (may need update)"
                needs_review=true
            else
                echo -e "  ${GREEN}✓ $doc${NC} (up to date)"
            fi
        fi
    done <<< "$related_docs"

    echo ""

    if $needs_review; then
        echo -e "${YELLOW}Documentation may need review based on file timestamps.${NC}"

        # Log the check
        local json
        json=$(printf '{"ts":"%s","event":"doc_check","file":"%s","needs_review":true}' \
            "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$file")
        echo "$json" >> "$DOC_HISTORY_FILE"

        return 1
    else
        echo -e "${GREEN}Documentation appears to be in sync.${NC}"
        return 0
    fi
}

# Scan all modified files
scan_modified() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Documentation Sync Scan${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    local modified_files
    modified_files=$(git diff --name-only HEAD 2>/dev/null || true)

    if [[ -z "$modified_files" ]]; then
        # Try staged files
        modified_files=$(git diff --cached --name-only 2>/dev/null || true)
    fi

    if [[ -z "$modified_files" ]]; then
        echo -e "${GREEN}No modified files detected.${NC}"
        return 0
    fi

    local needs_update=()
    local in_sync=()

    echo -e "${CYAN}Scanning modified files...${NC}"
    echo ""

    while IFS= read -r file; do
        if [[ -n "$file" && -f "$file" ]]; then
            local related_docs
            related_docs=$(find_related_docs "$file")

            if [[ -n "$related_docs" ]]; then
                echo -e "  ${BLUE}$file${NC}"

                while IFS= read -r doc; do
                    if [[ -n "$doc" ]]; then
                        local file_mtime doc_mtime
                        file_mtime=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
                        doc_mtime=$(stat -f %m "$doc" 2>/dev/null || stat -c %Y "$doc" 2>/dev/null)

                        if [[ "$file_mtime" -gt "$doc_mtime" ]]; then
                            echo -e "    ${YELLOW}→ $doc (may need update)${NC}"
                            needs_update+=("$doc")
                        else
                            echo -e "    ${GREEN}→ $doc (OK)${NC}"
                            in_sync+=("$doc")
                        fi
                    fi
                done <<< "$related_docs"
            fi
        fi
    done <<< "$modified_files"

    echo ""

    # Summary
    local unique_needs_update=0
    if [[ ${#needs_update[@]} -gt 0 ]]; then
        unique_needs_update=$(printf '%s\n' "${needs_update[@]}" | sort -u | wc -l | tr -d ' ')
    fi

    if [[ "$unique_needs_update" -gt 0 ]]; then
        echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}   $unique_needs_update document(s) may need updates${NC}"
        echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo "Documents to review:"
        printf '%s\n' "${needs_update[@]}" | sort -u | while read -r doc; do
            echo "  - $doc"
        done
        return 1
    else
        echo -e "${GREEN}All documentation appears to be in sync.${NC}"
        return 0
    fi
}

# Validate documentation structure (original functionality)
validate_structure() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Documentation Structure Validation${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    local ERRORS=0
    local WARNINGS=0

    # Check 1: CLAUDE.md exists
    if [[ ! -f CLAUDE.md ]]; then
        echo -e "${RED}ERROR: CLAUDE.md not found${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}✓ CLAUDE.md exists${NC}"
    fi

    # Check 2: conductor/tracks.md exists
    if [[ ! -f conductor/tracks.md ]]; then
        echo -e "${RED}ERROR: conductor/tracks.md not found${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}✓ conductor/tracks.md exists${NC}"
    fi

    # Check 3: Active track has plan.md
    if [[ -f conductor/tracks.md ]]; then
        local ACTIVE_TRACK
        ACTIVE_TRACK=$(grep "| MULTI-" conductor/tracks.md 2>/dev/null | head -1 | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' || true)
        if [[ -n "$ACTIVE_TRACK" ]]; then
            local PLAN_PATH="conductor/tracks/${ACTIVE_TRACK}/plan.md"
            if [[ ! -f "$PLAN_PATH" ]]; then
                echo -e "${RED}ERROR: Active track $ACTIVE_TRACK missing plan.md${NC}"
                ((ERRORS++))
            else
                echo -e "${GREEN}✓ Active track $ACTIVE_TRACK has plan.md${NC}"
            fi
        fi
    fi

    # Check 4: Key documentation files exist
    local REQUIRED_DOCS=(
        "docs/MULTI-AGENT-WORKFLOW.md"
        "conductor/workflow.md"
    )

    for doc in "${REQUIRED_DOCS[@]}"; do
        if [[ ! -f "$doc" ]]; then
            echo -e "${RED}ERROR: Required documentation missing: $doc${NC}"
            ((ERRORS++))
        else
            echo -e "${GREEN}✓ $doc exists${NC}"
        fi
    done

    # Check 5: .claude/context.md staleness
    if [[ -f .claude/context.md ]]; then
        local CONTEXT_DATE
        CONTEXT_DATE=$(grep "Last Updated:" .claude/context.md | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || true)
        if [[ -n "$CONTEXT_DATE" ]]; then
            local CONTEXT_TS NOW_TS AGE_DAYS
            CONTEXT_TS=$(date -j -f "%Y-%m-%d" "$CONTEXT_DATE" "+%s" 2>/dev/null || date -d "$CONTEXT_DATE" "+%s" 2>/dev/null || echo "0")
            NOW_TS=$(date "+%s")
            AGE_DAYS=$(( (NOW_TS - CONTEXT_TS) / 86400 ))

            if [[ $AGE_DAYS -gt 7 ]]; then
                echo -e "${YELLOW}WARNING: .claude/context.md is $AGE_DAYS days old${NC}"
                ((WARNINGS++))
            fi
        fi
    fi

    echo ""

    # Summary
    if [[ $ERRORS -gt 0 ]]; then
        echo -e "${RED}FAILED: $ERRORS errors, $WARNINGS warnings${NC}"
        return 1
    elif [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}PASSED with warnings: $WARNINGS warnings${NC}"
        return 0
    else
        echo -e "${GREEN}PASSED: Documentation structure is valid${NC}"
        return 0
    fi
}

# Generate documentation report
generate_report() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Documentation Sync Report${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Count documentation files
    local doc_count
    doc_count=$(find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*" 2>/dev/null | wc -l | tr -d ' ')

    echo -e "${CYAN}Documentation Overview:${NC}"
    echo "  Total markdown files: $doc_count"
    echo ""

    # List key documentation
    echo -e "${CYAN}Key Documentation:${NC}"
    for doc in README.md CLAUDE.md CHANGELOG.md docs/MULTI-AGENT-WORKFLOW.md conductor/workflow.md; do
        if [[ -f "$doc" ]]; then
            local lines words
            lines=$(wc -l < "$doc" | tr -d ' ')
            words=$(wc -w < "$doc" | tr -d ' ')
            echo "  ✓ $doc ($lines lines, $words words)"
        else
            echo "  ✗ $doc (missing)"
        fi
    done
    echo ""

    # Check recent doc history
    if [[ -f "$DOC_HISTORY_FILE" ]]; then
        local review_count
        review_count=$(grep -c '"needs_review":true' "$DOC_HISTORY_FILE" 2>/dev/null || echo "0")
        echo -e "${CYAN}History:${NC}"
        echo "  Documentation checks needing review: $review_count"
    fi
    echo ""

    # Show mapping coverage
    echo -e "${CYAN}Mapping Coverage:${NC}"
    local mapping_count
    mapping_count=$(jq '.mappings | length' "$DOC_MAPPINGS_FILE" 2>/dev/null || echo "0")
    echo "  Active mappings: $mapping_count"
    echo ""

    # Recent commits affecting docs
    echo -e "${CYAN}Recent Documentation Changes:${NC}"
    git log --oneline -5 -- "*.md" 2>/dev/null | while read -r line; do
        echo "  $line"
    done
    echo ""
}

# Show current mappings
show_mappings() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Code-to-Documentation Mappings${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    jq -r '.mappings[] | "\(.description):\n  Pattern: \(.pattern)\n  Docs: \(.docs | join(", "))\n"' "$DOC_MAPPINGS_FILE"

    echo ""
    echo -e "${CYAN}Mappings file: $DOC_MAPPINGS_FILE${NC}"
    echo "Edit this file to add custom mappings."
}

# Show documentation status
show_status() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Documentation Sync Status${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Quick stats
    echo -e "${CYAN}Quick Stats:${NC}"

    local md_count
    md_count=$(find . -name "*.md" -not -path "./.git/*" -not -path "./node_modules/*" 2>/dev/null | wc -l | tr -d ' ')
    echo "  Markdown files: $md_count"

    local mapping_count
    mapping_count=$(jq '.mappings | length' "$DOC_MAPPINGS_FILE" 2>/dev/null || echo "0")
    echo "  Active mappings: $mapping_count"

    echo ""

    # Check for uncommitted docs
    local uncommitted_docs
    uncommitted_docs=$(git status --porcelain -- "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$uncommitted_docs" -gt 0 ]]; then
        echo -e "${YELLOW}Uncommitted documentation changes: $uncommitted_docs${NC}"
        git status --porcelain -- "*.md" 2>/dev/null | head -5
        echo ""
    else
        echo -e "${GREEN}All documentation changes committed.${NC}"
        echo ""
    fi

    # Commands
    echo -e "${CYAN}Commands:${NC}"
    echo "  bash scripts/doc-sync-check.sh check <file>  - Check specific file"
    echo "  bash scripts/doc-sync-check.sh scan          - Scan modified files"
    echo "  bash scripts/doc-sync-check.sh validate      - Validate structure"
    echo "  bash scripts/doc-sync-check.sh report        - Full report"
    echo "  bash scripts/doc-sync-check.sh mappings      - Show mappings"
    echo ""
}

# Main dispatch
case "${1:-status}" in
    check)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 check <file>"
            exit 1
        fi
        check_file "$2"
        ;;
    scan)
        scan_modified
        ;;
    validate)
        validate_structure
        ;;
    report)
        generate_report
        ;;
    mappings)
        show_mappings
        ;;
    status)
        show_status
        ;;
    *)
        echo "Documentation Sync Checker"
        echo ""
        echo "Usage: $0 {check|scan|validate|report|mappings|status}"
        echo ""
        echo "Commands:"
        echo "  check <file>    - Check if docs need updating for file"
        echo "  scan            - Scan all modified files"
        echo "  validate        - Validate documentation structure"
        echo "  report          - Generate documentation report"
        echo "  mappings        - Show code-to-doc mappings"
        echo "  status          - Show documentation status"
        exit 1
        ;;
esac
