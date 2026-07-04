#!/bin/bash

# Pre-commit Hook for Agent Frontmatter Validation
#
# Install this hook to prevent commits with invalid agent frontmatter:
#
#   cp .claude/templates/pre-commit-hook.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# This hook will:
# 1. Run frontmatter validation on any agent files being committed
# 2. Block the commit if validation fails
# 3. Provide helpful error messages with remediation steps

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
VALIDATOR="${PROJECT_ROOT}/.claude/scripts/validate-frontmatter.sh"

# Check if validator exists
if [[ ! -f "$VALIDATOR" ]]; then
    echo "Warning: frontmatter validator not found at $VALIDATOR"
    echo "Skipping frontmatter validation (install .claude/scripts/validate-frontmatter.sh to enable)"
    exit 0
fi

# Get list of staged agent files
STAGED_AGENTS=$(git diff --cached --name-only --diff-filter=ACM | grep -E "agents/agent-.*\.md$" || true)

if [[ -z "$STAGED_AGENTS" ]]; then
    # No agent files being committed
    exit 0
fi

echo "Validating staged agent templates..."
echo ""

# Create a temporary file to hold validator output
TEMP_VALIDATION=$(mktemp)
trap "rm -f $TEMP_VALIDATION" EXIT

# Run validation on each staged agent
VALIDATION_FAILED=false

for agent_file in $STAGED_AGENTS; do
    if ! "$VALIDATOR" "$PROJECT_ROOT/$agent_file" >> "$TEMP_VALIDATION" 2>&1; then
        VALIDATION_FAILED=true
    fi
done

# If validation failed, show output and reject commit
if [[ "$VALIDATION_FAILED" == true ]]; then
    cat "$TEMP_VALIDATION"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ COMMIT BLOCKED: Agent frontmatter validation failed"
    echo ""
    echo "To fix frontmatter errors, edit the agent file and ensure:"
    echo "  1. YAML frontmatter starts with --- and ends with ---"
    echo "  2. Required fields: name, description, tools, model"
    echo "  3. name: must be kebab-case and match the filename"
    echo "  4. description: must be one sentence, 80-150 characters"
    echo "  5. tools: must be comma-separated string (not YAML array)"
    echo "  6. model: must be sonnet, opus, or haiku"
    echo ""
    echo "See .claude/FRONTMATTER_SPEC.md for complete validation rules."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi

# Validation passed
cat "$TEMP_VALIDATION"
exit 0
