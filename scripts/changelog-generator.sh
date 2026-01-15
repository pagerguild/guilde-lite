#!/bin/bash
# Changelog Generator
# Generates and updates CHANGELOG.md from git commits
#
# Usage:
#   bash scripts/changelog-generator.sh generate          - Generate changelog from commits
#   bash scripts/changelog-generator.sh add <type> <msg>  - Add manual entry
#   bash scripts/changelog-generator.sh preview           - Preview unreleased changes
#   bash scripts/changelog-generator.sh release <version> - Create release entry
#   bash scripts/changelog-generator.sh status            - Show changelog status
#
# Commit types recognized:
#   feat:     → Added
#   fix:      → Fixed
#   docs:     → Documentation
#   refactor: → Changed
#   perf:     → Performance
#   test:     → Testing
#   chore:    → Maintenance
#   security: → Security
#   breaking: → Breaking Changes

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

CHANGELOG_FILE="CHANGELOG.md"
STATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/changelog"
UNRELEASED_FILE="$STATE_DIR/unreleased.json"

mkdir -p "$STATE_DIR"

# Initialize unreleased file if needed
if [[ ! -f "$UNRELEASED_FILE" ]]; then
    echo '{"entries":[]}' > "$UNRELEASED_FILE"
fi

# Map commit type to changelog category
map_type_to_category() {
    local type="$1"
    case "$type" in
        feat|feature) echo "Added" ;;
        fix|bugfix) echo "Fixed" ;;
        docs|documentation) echo "Documentation" ;;
        refactor|style) echo "Changed" ;;
        perf|performance) echo "Performance" ;;
        test|tests) echo "Testing" ;;
        chore|build|ci) echo "Maintenance" ;;
        security|sec) echo "Security" ;;
        breaking|break) echo "Breaking Changes" ;;
        *) echo "Other" ;;
    esac
}

# Parse conventional commit message
parse_commit() {
    local message="$1"
    local type scope description

    # Match: type(scope): description or type: description
    # Using simpler regex patterns for bash compatibility
    local pattern1='^([a-z]+)\(([^)]+)\): *(.+)$'
    local pattern2='^([a-z]+): *(.+)$'

    if [[ "$message" =~ $pattern1 ]]; then
        type="${BASH_REMATCH[1]}"
        scope="${BASH_REMATCH[2]}"
        description="${BASH_REMATCH[3]}"
    elif [[ "$message" =~ $pattern2 ]]; then
        type="${BASH_REMATCH[1]}"
        scope=""
        description="${BASH_REMATCH[2]}"
    else
        type="other"
        scope=""
        description="$message"
    fi

    local category
    category=$(map_type_to_category "$type")

    # Escape double quotes in description for JSON
    description="${description//\"/\\\"}"

    printf '{"type":"%s","scope":"%s","description":"%s","category":"%s"}' \
        "$type" "$scope" "$description" "$category"
}

# Generate changelog from git commits
generate_changelog() {
    local since="${1:-}"
    local commits

    echo -e "${BLUE}Generating changelog entries...${NC}"
    echo ""

    if [[ -n "$since" ]]; then
        commits=$(git log "$since"..HEAD --oneline --no-merges 2>/dev/null || true)
    else
        # Get commits since last tag or last 50 commits
        local last_tag
        last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
        if [[ -n "$last_tag" ]]; then
            commits=$(git log "$last_tag"..HEAD --oneline --no-merges 2>/dev/null || true)
        else
            commits=$(git log -50 --oneline --no-merges 2>/dev/null || true)
        fi
    fi

    if [[ -z "$commits" ]]; then
        echo -e "${YELLOW}No commits found for changelog generation.${NC}"
        return 0
    fi

    # Use temporary files for category grouping (bash 3 compatible)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    # Use function for cleanup to properly quote the variable
    cleanup_tmp() { rm -rf "$tmp_dir"; }
    trap cleanup_tmp EXIT

    # Initialize category files
    for cat in "Added" "Fixed" "Changed" "Documentation" "Performance" "Security" "Breaking_Changes" "Maintenance" "Other"; do
        touch "$tmp_dir/$cat"
    done

    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local sha message
            sha=$(echo "$line" | cut -d' ' -f1)
            message=$(echo "$line" | cut -d' ' -f2-)

            local parsed
            parsed=$(parse_commit "$message")
            local category description
            category=$(echo "$parsed" | jq -r '.category')
            description=$(echo "$parsed" | jq -r '.description')

            # Replace space with underscore for filename
            local cat_file="${category// /_}"
            echo "- $description ($sha)" >> "$tmp_dir/$cat_file"
        fi
    done <<< "$commits"

    # Output formatted changelog section
    echo "## [Unreleased]"
    echo ""

    for cat in "Breaking_Changes" "Added" "Fixed" "Changed" "Performance" "Security" "Documentation" "Maintenance" "Other"; do
        if [[ -s "$tmp_dir/$cat" ]]; then
            # Convert underscore back to space for display
            local display_cat="${cat//_/ }"
            echo "### $display_cat"
            cat "$tmp_dir/$cat"
            echo ""
        fi
    done
}

# Add manual changelog entry
add_entry() {
    local type="$1"
    local message="$2"

    local category
    category=$(map_type_to_category "$type")

    # Use jq --arg for proper JSON escaping (handles quotes, newlines, etc.)
    local entry
    entry=$(jq -n \
        --arg type "$type" \
        --arg category "$category" \
        --arg message "$message" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{type: $type, category: $category, message: $message, timestamp: $timestamp}')

    local updated
    updated=$(jq --argjson entry "$entry" '.entries += [$entry]' "$UNRELEASED_FILE")
    echo "$updated" > "$UNRELEASED_FILE" || { echo "Failed to write entry"; return 1; }

    echo -e "${GREEN}Added changelog entry:${NC}"
    echo "  Category: $category"
    echo "  Message: $message"
}

# Preview unreleased changes
preview_unreleased() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Unreleased Changes Preview${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # From manual entries
    local manual_count
    manual_count=$(jq '.entries | length' "$UNRELEASED_FILE")

    if [[ "$manual_count" -gt 0 ]]; then
        echo -e "${CYAN}Manual Entries:${NC}"
        jq -r '.entries[] | "  - [\(.category)] \(.message)"' "$UNRELEASED_FILE"
        echo ""
    fi

    # From git commits
    echo -e "${CYAN}From Git Commits:${NC}"
    generate_changelog | tail -n +3  # Skip the header
}

# Create release entry
create_release() {
    local version="$1"

    if [[ -z "$version" ]]; then
        echo "Usage: $0 release <version>"
        echo "Example: $0 release 1.0.0"
        return 1
    fi

    # Validate version format (semver: x.y.z or x.y.z-suffix)
    if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
        echo -e "${RED}Invalid version format: $version${NC}"
        echo "Expected: semver format (e.g., 1.0.0, 2.1.0-beta.1)"
        return 1
    fi

    local release_date
    release_date=$(date +%Y-%m-%d)

    echo -e "${BLUE}Creating release entry for v$version...${NC}"

    # Check if CHANGELOG.md exists
    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        # Create new changelog
        cat > "$CHANGELOG_FILE" << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

EOF
    fi

    # Generate release content
    local release_content
    release_content=$(generate_changelog)

    # Replace [Unreleased] header with version (using | as delimiter to avoid / in version)
    release_content=$(echo "$release_content" | sed "s|## \[Unreleased\]|## [$version] - $release_date|")

    # Create timestamped backup
    local backup_file="$CHANGELOG_FILE.bak.$(date +%s)"
    cp "$CHANGELOG_FILE" "$backup_file"
    echo "Backup created: $backup_file"

    # Insert release content after the [Unreleased] section
    local before after
    before=$(sed -n '1,/## \[Unreleased\]/p' "$CHANGELOG_FILE" | head -n -1)
    after=$(sed -n '/## \[Unreleased\]/,$p' "$CHANGELOG_FILE" | tail -n +2)

    # Rebuild changelog
    {
        echo "$before"
        echo ""
        echo "## [Unreleased]"
        echo ""
        echo "$release_content"
        echo "$after"
    } > "$CHANGELOG_FILE" || { echo "Failed to write changelog"; return 1; }

    # Clear unreleased entries
    echo '{"entries":[]}' > "$UNRELEASED_FILE"

    echo -e "${GREEN}Created release entry for v$version${NC}"
    echo "Updated: $CHANGELOG_FILE"
}

# Show changelog status
show_status() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   Changelog Status${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Check if CHANGELOG.md exists
    if [[ -f "$CHANGELOG_FILE" ]]; then
        local lines words
        lines=$(wc -l < "$CHANGELOG_FILE" | tr -d ' ')
        words=$(wc -w < "$CHANGELOG_FILE" | tr -d ' ')
        echo -e "${GREEN}✓ $CHANGELOG_FILE exists${NC} ($lines lines, $words words)"

        # Show recent versions
        echo ""
        echo -e "${CYAN}Recent versions:${NC}"
        grep -E "^## \[" "$CHANGELOG_FILE" | head -5 | while read -r line; do
            echo "  $line"
        done
    else
        echo -e "${YELLOW}⚠ $CHANGELOG_FILE does not exist${NC}"
        echo "  Run: bash scripts/changelog-generator.sh release <version>"
    fi

    echo ""

    # Manual entries count
    local manual_count
    manual_count=$(jq '.entries | length' "$UNRELEASED_FILE" 2>/dev/null || echo "0")
    echo -e "${CYAN}Unreleased entries:${NC} $manual_count manual entries"

    # Commits since last tag
    local last_tag commits_since
    last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    if [[ -n "$last_tag" ]]; then
        commits_since=$(git rev-list "$last_tag"..HEAD --count 2>/dev/null || echo "0")
        echo -e "${CYAN}Commits since $last_tag:${NC} $commits_since"
    else
        commits_since=$(git rev-list HEAD --count 2>/dev/null || echo "0")
        echo -e "${CYAN}Total commits:${NC} $commits_since (no tags yet)"
    fi

    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo "  bash scripts/changelog-generator.sh preview       - Preview unreleased"
    echo "  bash scripts/changelog-generator.sh add feat msg  - Add entry"
    echo "  bash scripts/changelog-generator.sh release 1.0.0 - Create release"
}

# Main dispatch
case "${1:-status}" in
    generate)
        generate_changelog "${2:-}"
        ;;
    add)
        if [[ -z "${2:-}" || -z "${3:-}" ]]; then
            echo "Usage: $0 add <type> <message>"
            echo "Types: feat, fix, docs, refactor, perf, security, breaking"
            exit 1
        fi
        add_entry "$2" "$3"
        ;;
    preview)
        preview_unreleased
        ;;
    release)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 release <version>"
            exit 1
        fi
        create_release "$2"
        ;;
    status)
        show_status
        ;;
    *)
        echo "Changelog Generator"
        echo ""
        echo "Usage: $0 {generate|add|preview|release|status}"
        echo ""
        echo "Commands:"
        echo "  generate         - Generate changelog from git commits"
        echo "  add <type> <msg> - Add manual changelog entry"
        echo "  preview          - Preview unreleased changes"
        echo "  release <ver>    - Create release entry"
        echo "  status           - Show changelog status"
        echo ""
        echo "Types for 'add': feat, fix, docs, refactor, perf, security, breaking, chore"
        exit 1
        ;;
esac
