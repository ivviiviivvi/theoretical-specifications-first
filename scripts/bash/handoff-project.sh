#!/usr/bin/env bash

# Handoff script for project import/export between SDD and non-SDD formats
#
# This script provides context and path information for the handoff command.
# The actual handoff logic is implemented in the command template.
#
# Usage: ./handoff-project.sh [--json]
#
# OPTIONS:
#   --json              Output in JSON format
#   --help, -h          Show help message
#
# OUTPUTS:
#   JSON mode: {"REPO_ROOT":"...", "SPECS_DIR":"...", "CONSTITUTION":"...", "STATUS":"..."}
#   Text mode: Human-readable status

set -e

# Parse command line arguments
JSON_MODE=false

for arg in "$@"; do
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --help|-h)
            cat << 'EOF'
Usage: handoff-project.sh [OPTIONS]

Provide context for project handoff operations (import/export).

OPTIONS:
  --json              Output in JSON format
  --help, -h          Show this help message

EXAMPLES:
  # Get handoff context in JSON
  ./handoff-project.sh --json
  
  # Get handoff context in human-readable format
  ./handoff-project.sh
  
EOF
            exit 0
            ;;
        *)
            echo "ERROR: Unknown option '$arg'. Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get repository context
REPO_ROOT=$(get_repo_root)
SPECS_DIR="$REPO_ROOT/specs"
CONSTITUTION="$REPO_ROOT/memory/constitution.md"
README="$REPO_ROOT/README.md"
TEMPLATES_DIR="$REPO_ROOT/.specify/templates"

# Check if this is an SDD repository
IS_SDD_REPO=false
if [ -d "$REPO_ROOT/.specify" ] || [ -d "$REPO_ROOT/memory" ]; then
    IS_SDD_REPO=true
fi

# Count existing features
FEATURE_COUNT=0
if [ -d "$SPECS_DIR" ]; then
    FEATURE_COUNT=$(find "$SPECS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
fi

# Determine current context
HAS_GIT=$(has_git && echo "true" || echo "false")
CURRENT_BRANCH=$(get_current_branch)

# Check constitution status
CONSTITUTION_STATUS="missing"
if [ -f "$CONSTITUTION" ]; then
    if [ -s "$CONSTITUTION" ]; then
        CONSTITUTION_STATUS="present"
    else
        CONSTITUTION_STATUS="empty"
    fi
fi

# Output results
if $JSON_MODE; then
    cat << EOF
{
    "REPO_ROOT": "$REPO_ROOT",
    "SPECS_DIR": "$SPECS_DIR",
    "CONSTITUTION": "$CONSTITUTION",
    "CONSTITUTION_STATUS": "$CONSTITUTION_STATUS",
    "README": "$README",
    "TEMPLATES_DIR": "$TEMPLATES_DIR",
    "IS_SDD_REPO": $IS_SDD_REPO,
    "HAS_GIT": $HAS_GIT,
    "CURRENT_BRANCH": "$CURRENT_BRANCH",
    "FEATURE_COUNT": $FEATURE_COUNT
}
EOF
else
    echo "Handoff Context:"
    echo "  Repository Root: $REPO_ROOT"
    echo "  Is SDD Repository: $IS_SDD_REPO"
    echo "  Constitution: $CONSTITUTION_STATUS"
    echo "  Feature Count: $FEATURE_COUNT"
    echo "  Git Available: $HAS_GIT"
    if [ "$HAS_GIT" = "true" ]; then
        echo "  Current Branch: $CURRENT_BRANCH"
    fi
fi
