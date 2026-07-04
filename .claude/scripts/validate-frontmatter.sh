#!/bin/bash

# Agent Frontmatter Validator
# Validates all agent templates against FRONTMATTER_SPEC.md requirements
#
# Usage:
#   ./validate-frontmatter.sh [path]
#   ./validate-frontmatter.sh agents/           # Validate all agents
#   ./validate-frontmatter.sh agents/agent-*.md # Validate matching agents
#
# Exit codes:
#   0 = All agents valid
#   1 = Validation failures found
#   2 = Validation errors (file not found, etc)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="${PROJECT_ROOT}/agents"
VALIDATION_PASSED=true
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0
SUMMARY_LINE=""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function to print errors
print_error() {
    local file="$1"
    local line="$2"
    local message="$3"
    echo -e "${RED}✗ $file:$line${NC} $message"
    ((VALIDATION_ERRORS++))
    VALIDATION_PASSED=false
}

# Helper function to print warnings
print_warning() {
    local file="$1"
    local line="$2"
    local message="$3"
    echo -e "${YELLOW}⚠ $file:$line${NC} $message"
    ((VALIDATION_WARNINGS++))
}

# Helper function to print passes
print_pass() {
    local file="$1"
    echo -e "${GREEN}✓ $file${NC} Frontmatter valid"
}

# Validate a single agent file
validate_agent() {
    local file="$1"
    local filename=$(basename "$file")

    # Check file exists
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}✗ File not found: $file${NC}"
        return 2
    fi

    # Check if file starts with frontmatter
    if ! head -n 1 "$file" | grep -q "^---$"; then
        print_error "$filename" "1" "Missing opening frontmatter delimiter (---)"
        return 1
    fi

    # Extract frontmatter lines
    local frontmatter_lines=$(awk '/^---$/{if(++n==2) exit} n==1' "$file")
    if [[ -z "$frontmatter_lines" ]]; then
        print_error "$filename" "2" "Missing closing frontmatter delimiter (---)"
        return 1
    fi

    # Parse YAML fields
    local name=$(echo "$frontmatter_lines" | grep "^name:" | sed 's/^name: *//')
    local description=$(echo "$frontmatter_lines" | grep "^description:" | sed 's/^description: *//')
    local tools=$(echo "$frontmatter_lines" | grep "^tools:" | sed 's/^tools: *//')
    local model=$(echo "$frontmatter_lines" | grep "^model:" | sed 's/^model: *//')

    # Expected name from filename (agent-XXX.md -> agent-XXX)
    local expected_name="${filename%.md}"

    local has_errors=false
    local line_num=1

    # Validation: name field
    if [[ -z "$name" ]]; then
        print_error "$filename" "2" "Missing 'name:' field"
        has_errors=true
    else
        # Check kebab-case format
        if ! echo "$name" | grep -qE "^[a-z0-9-]+$"; then
            print_error "$filename" "2" "name: '$name' is not kebab-case (lowercase letters, digits, hyphens only)"
            has_errors=true
        fi
        # Check filename match
        if [[ "$name" != "$expected_name" ]]; then
            print_error "$filename" "2" "name: '$name' does not match filename '$expected_name'"
            has_errors=true
        fi
    fi

    # Validation: description field
    if [[ -z "$description" ]]; then
        print_error "$filename" "3" "Missing 'description:' field"
        has_errors=true
    else
        # Check length
        if (( ${#description} < 20 )); then
            print_warning "$filename" "3" "description is very short (${#description} chars, expected 80-150)"
        fi
        if (( ${#description} > 200 )); then
            print_error "$filename" "3" "description is too long (${#description} chars, max 150)"
            has_errors=true
        fi
    fi

    # Validation: tools field
    if [[ -z "$tools" ]]; then
        print_error "$filename" "4" "Missing 'tools:' field"
        has_errors=true
    else
        # Check if it's a YAML array (anti-pattern)
        if echo "$tools" | grep -qE "^\s*$|^\[|^-\s"; then
            print_error "$filename" "4" "tools: is YAML array format (use comma-separated string instead)"
            print_error "$filename" "4" "Change 'tools:\\n  - Read\\n  - Write' to 'tools: Read, Write'"
            has_errors=true
        fi
        # Warn about complex MCP tool names
        if echo "$tools" | grep -qE "mcp__.*__"; then
            print_warning "$filename" "4" "tools: contains complex MCP tool names; consider documenting in metadata instead"
        fi
    fi

    # Validation: model field
    if [[ -z "$model" ]]; then
        print_error "$filename" "5" "Missing 'model:' field"
        has_errors=true
    else
        if ! echo "$model" | grep -qE "^(sonnet|opus|haiku)$"; then
            print_error "$filename" "5" "model: '$model' is invalid (must be sonnet, opus, or haiku)"
            has_errors=true
        fi
    fi

    # Check for extra blank lines after closing ---
    local closing_line=$(awk '/^---$/{if(++n==2) {print NR; exit}}' "$file")
    if [[ -n "$closing_line" ]]; then
        local next_line=$((closing_line + 1))
        if sed -n "${next_line}p" "$file" | grep -qE "^$"; then
            print_warning "$filename" "$next_line" "Extra blank line after closing frontmatter delimiter"
        fi
    fi

    # If no errors, print pass
    if [[ "$has_errors" == false ]]; then
        print_pass "$filename"
        return 0
    else
        return 1
    fi
}

# Main script
main() {
    local target="${1:-.}"

    # Determine what to validate
    local files_to_validate=()

    if [[ -d "$target" ]]; then
        # Directory: find all agent-*.md files
        while IFS= read -r -d '' file; do
            files_to_validate+=("$file")
        done < <(find "$target" -name "agent-*.md" -print0 2>/dev/null | sort -z)
    elif [[ -f "$target" ]]; then
        # Single file
        files_to_validate=("$target")
    elif [[ "$target" == "agent-"* ]]; then
        # Glob pattern (shell expansion already happened)
        for file in $target; do
            if [[ -f "$file" ]]; then
                files_to_validate+=("$file")
            fi
        done
    else
        echo "Usage: $0 [agents/ | agents/agent-*.md | path/to/agent.md]"
        echo ""
        echo "Validates YAML frontmatter in agent templates against FRONTMATTER_SPEC.md"
        exit 2
    fi

    # Check if we found any files
    if [[ ${#files_to_validate[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No agent files found at '$target'${NC}"
        exit 2
    fi

    # Validate each file
    echo "Validating ${#files_to_validate[@]} agent template(s)..."
    echo ""

    for file in "${files_to_validate[@]}"; do
        validate_agent "$file"
    done

    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ "$VALIDATION_PASSED" == true ]]; then
        echo -e "${GREEN}✓ All ${#files_to_validate[@]} agent(s) passed frontmatter validation${NC}"
        if (( VALIDATION_WARNINGS > 0 )); then
            echo -e "${YELLOW}  (with $VALIDATION_WARNINGS warning(s))${NC}"
        fi
        exit 0
    else
        echo -e "${RED}✗ Validation failed${NC}"
        echo -e "  Errors: $VALIDATION_ERRORS"
        if (( VALIDATION_WARNINGS > 0 )); then
            echo -e "  Warnings: $VALIDATION_WARNINGS"
        fi
        exit 1
    fi
}

main "$@"
