#!/bin/bash
# Multi-Agent Workflow Validation Script
# Validates all components of the conductor pattern implementation
#
# Usage:
#   bash scripts/validate-workflow.sh [component]
#
# Components:
#   all       - Run all validations (default)
#   commands  - Validate conductor commands
#   agents    - Validate agent definitions
#   skills    - Validate skill packages
#   hooks     - Validate hookify rules
#   telemetry - Validate telemetry configuration
#   structure - Validate directory structure

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0
WARN=0

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS++)) || true
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL++)) || true
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARN++)) || true
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

# Validation functions
validate_structure() {
    header "VALIDATING DIRECTORY STRUCTURE"

    # Required directories
    local dirs=(
        "conductor"
        "conductor/tracks"
        "conductor/tracks/MULTI-001"
        ".claude/commands"
        ".claude/agents"
        ".claude/skills"
        ".claude/rules"
        ".claude-plugin"
    )

    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            pass "Directory exists: $dir"
        else
            fail "Directory missing: $dir"
        fi
    done

    # Required files
    local files=(
        "CLAUDE.md"
        "conductor/tracks.md"
        "conductor/product.md"
        "conductor/tech-stack.md"
        ".claude-plugin/plugin.json"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            pass "File exists: $file"
        else
            fail "File missing: $file"
        fi
    done
}

validate_commands() {
    header "VALIDATING CONDUCTOR COMMANDS"

    local commands=(
        "conductor-setup"
        "conductor-new-track"
        "conductor-implement"
        "conductor-status"
        "conductor-checkpoint"
        "conductor-sync-docs"
    )

    for cmd in "${commands[@]}"; do
        local file=".claude/commands/${cmd}.md"
        if [ -f "$file" ]; then
            # Check YAML frontmatter
            if head -1 "$file" | grep -q "^---"; then
                # Check required fields
                if grep -q "^name:" "$file" && grep -q "^description:" "$file"; then
                    pass "Command valid: $cmd"
                else
                    fail "Command missing fields: $cmd"
                fi
            else
                fail "Command missing frontmatter: $cmd"
            fi
        else
            fail "Command missing: $cmd"
        fi
    done
}

validate_agents() {
    header "VALIDATING AGENT DEFINITIONS"

    local agents=(
        "context-explorer"
        "spec-builder"
        "docs-researcher"
        "codebase-analyzer"
        "backend-architect"
        "frontend-developer"
        "test-automator"
        "database-optimizer"
        "code-reviewer"
        "security-auditor"
        "architect-reviewer"
        "tdd-orchestrator"
    )

    for agent in "${agents[@]}"; do
        local file=".claude/agents/${agent}.md"
        if [ -f "$file" ]; then
            # Check for key sections
            if grep -q "## Purpose\|## Focus" "$file"; then
                pass "Agent valid: $agent"
            else
                warn "Agent missing sections: $agent"
            fi
        else
            fail "Agent missing: $agent"
        fi
    done

    # Check agent selection guide
    if [ -f ".claude/agents/AGENT-SELECTION.md" ]; then
        pass "Agent selection guide exists"
    else
        warn "Agent selection guide missing"
    fi
}

validate_skills() {
    header "VALIDATING SKILL PACKAGES"

    local skills=(
        "mise-expert"
        "tdd-red-phase"
        "tdd-green-phase"
        "tdd-refactor-phase"
        "mermaid-generator"
        "c4-generator"
        "context-loader"
        "code-review-pipeline"
        "test-gen-workflow"
        "error-recovery"
    )

    for skill in "${skills[@]}"; do
        local file=".claude/skills/${skill}/SKILL.md"
        if [ -f "$file" ]; then
            # Check YAML frontmatter
            if head -1 "$file" | grep -q "^---"; then
                # Check for name and description
                if grep -q "^name:" "$file" && grep -q "^description:" "$file"; then
                    pass "Skill valid: $skill"
                else
                    fail "Skill missing fields: $skill"
                fi
            else
                fail "Skill missing frontmatter: $skill"
            fi
        else
            fail "Skill missing: $skill"
        fi
    done
}

validate_hooks() {
    header "VALIDATING HOOKIFY RULES"

    local hooks=(
        "block-destructive"
        "warn-secrets"
        "require-confirmation"
        "tdd-tests-first"
        "tdd-auto-test"
        "doc-sync-reminder"
        "track-progress"
    )

    for hook in "${hooks[@]}"; do
        local file=".claude/hookify.${hook}.local.md"
        if [ -f "$file" ]; then
            # Check YAML frontmatter and required fields
            if head -1 "$file" | grep -q "^---" && \
               grep -q "^name:" "$file" && \
               grep -q "^enabled:" "$file" && \
               grep -q "^event:" "$file" && \
               grep -q "^action:" "$file"; then
                pass "Hook valid: $hook"
            else
                fail "Hook missing fields: $hook"
            fi
        else
            fail "Hook missing: $hook"
        fi
    done

    # Check settings.json hooks
    if [ -f ".claude/settings.json" ]; then
        if python3 -c "import json; json.load(open('.claude/settings.json'))" 2>/dev/null; then
            pass "settings.json is valid JSON"
        else
            fail "settings.json is invalid JSON"
        fi
    else
        fail "settings.json missing"
    fi
}

validate_telemetry() {
    header "VALIDATING TELEMETRY CONFIGURATION"

    # Check telemetry files
    if [ -f ".env.telemetry" ]; then
        pass "Telemetry environment file exists"

        # Check key variables
        if grep -q "OTEL_EXPORTER_OTLP_ENDPOINT" .env.telemetry; then
            pass "OTLP endpoint configured"
        else
            warn "OTLP endpoint not configured"
        fi
    else
        fail "Telemetry environment file missing"
    fi

    # Check observability stack
    if [ -f "docker/observability-compose.yml" ]; then
        pass "Observability compose file exists"
    else
        warn "Observability compose file missing"
    fi

    # Check telemetry scripts
    if [ -f "scripts/telemetry-hook.sh" ] && [ -x "scripts/telemetry-hook.sh" ]; then
        pass "Telemetry hook script exists and executable"
    else
        warn "Telemetry hook script missing or not executable"
    fi

    if [ -f "scripts/validate-telemetry.sh" ]; then
        pass "Telemetry validation script exists"
    else
        warn "Telemetry validation script missing"
    fi
}

validate_plugin() {
    header "VALIDATING PLUGIN STRUCTURE"

    local plugin_json=".claude-plugin/plugin.json"

    if [ -f "$plugin_json" ]; then
        if python3 -c "import json; json.load(open('$plugin_json'))" 2>/dev/null; then
            pass "plugin.json is valid JSON"

            # Check required fields
            local fields=("name" "version" "description" "components")
            for field in "${fields[@]}"; do
                if python3 -c "import json; d=json.load(open('$plugin_json')); assert '$field' in d" 2>/dev/null; then
                    pass "plugin.json has field: $field"
                else
                    fail "plugin.json missing field: $field"
                fi
            done
        else
            fail "plugin.json is invalid JSON"
        fi
    else
        fail "plugin.json missing"
    fi
}

validate_documentation() {
    header "VALIDATING DOCUMENTATION"

    local docs=(
        "docs/MULTI-AGENT-WORKFLOW.md"
        "docs/CONDUCTOR-COMMANDS.md"
        "docs/SKILLS.md"
        "docs/HOOKIFY-RULES.md"
        "docs/REVIEW-PIPELINE.md"
        "docs/TELEMETRY-SETUP.md"
    )

    for doc in "${docs[@]}"; do
        if [ -f "$doc" ]; then
            pass "Documentation exists: $doc"
        else
            warn "Documentation missing: $doc"
        fi
    done
}

print_summary() {
    header "VALIDATION SUMMARY"

    echo ""
    echo -e "  ${GREEN}Passed:${NC}  $PASS"
    echo -e "  ${RED}Failed:${NC}  $FAIL"
    echo -e "  ${YELLOW}Warnings:${NC} $WARN"
    echo ""

    local total=$((PASS + FAIL))
    if [ $total -gt 0 ]; then
        local percentage=$((PASS * 100 / total))
        echo -e "  Success Rate: ${percentage}%"
    fi
    echo ""

    if [ $FAIL -eq 0 ]; then
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}                    ALL VALIDATIONS PASSED                      ${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        return 0
    else
        echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}                    SOME VALIDATIONS FAILED                     ${NC}"
        echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
        return 1
    fi
}

# Main
main() {
    local component="${1:-all}"

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║     MULTI-AGENT WORKFLOW VALIDATION                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"

    case "$component" in
        all)
            validate_structure
            validate_commands
            validate_agents
            validate_skills
            validate_hooks
            validate_telemetry
            validate_plugin
            validate_documentation
            ;;
        structure)
            validate_structure
            ;;
        commands)
            validate_commands
            ;;
        agents)
            validate_agents
            ;;
        skills)
            validate_skills
            ;;
        hooks)
            validate_hooks
            ;;
        telemetry)
            validate_telemetry
            ;;
        plugin)
            validate_plugin
            ;;
        docs)
            validate_documentation
            ;;
        *)
            echo "Unknown component: $component"
            echo "Usage: $0 [all|structure|commands|agents|skills|hooks|telemetry|plugin|docs]"
            exit 1
            ;;
    esac

    print_summary
}

main "$@"
