#!/bin/bash

# Recruit agents - move generated agents to ~/.claude/agents/

set -e
shopt -s nullglob globstar

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_AGENTS_DIR="$REPO_ROOT/agents"
PROJECT_SKILLS_DIR="$REPO_ROOT/.claude/skills"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"

# Ensure directories exist
mkdir -p "$PROJECT_AGENTS_DIR"
mkdir -p "$CLAUDE_AGENTS_DIR"
mkdir -p "$CLAUDE_SKILLS_DIR"

# Flatten an agent's owned skills to user level.
# Claude Code discovers skills ONE level deep ($HOME/.claude/skills/<name>/SKILL.md),
# so agent-owned skills nested in-project at .claude/skills/<agent>/<skill>/ must be
# copied UP to the flat user-level location or they will not be found.
recruit_skills() {
  local agent_name="$1"
  local src="$PROJECT_SKILLS_DIR/$agent_name"
  [ -d "$src" ] || return 0
  for skilldir in "$src"/*/; do
    [ -d "$skilldir" ] || continue
    local skill; skill="$(basename "$skilldir")"
    if [ -e "$CLAUDE_SKILLS_DIR/$skill" ]; then
      echo "  ⚠ skill '$skill' already exists at user level — skipped (review manually)"
    else
      cp -R "$skilldir" "$CLAUDE_SKILLS_DIR/$skill"
      echo "  ✓ skill flattened: $skill"
    fi
  done
}

# Find all .md files in project agents directory
# (globstar ** already matches direct children, so one pattern — a second
#  top-level glob would list every agent twice)
PROJECT_AGENT_FILES=()
for file in "$PROJECT_AGENTS_DIR"/**/*.md; do
  if [ -f "$file" ]; then
    filename=$(basename "$file")
    # Skip docs (README/CLAUDE_ROLES etc.) — only agent-*.md are recruitable
    case "$filename" in agent-*.md) ;; *) continue ;; esac
    # Only add if not already in ~/.claude/agents/
    if [ ! -f "$CLAUDE_AGENTS_DIR/$filename" ]; then
      PROJECT_AGENT_FILES+=("$file")
    fi
  fi
done

if [ ${#PROJECT_AGENT_FILES[@]} -eq 0 ]; then
  echo "✓ All agents are already recruited! No new agents to bring in."
  exit 0
fi

echo "📋 Available agents to recruit:"
echo ""

# Display options with numbers
for i in "${!PROJECT_AGENT_FILES[@]}"; do
  file="${PROJECT_AGENT_FILES[$i]}"
  filename=$(basename "$file")
  agent_name="${filename%.md}"
  echo "  [$((i+1))] $agent_name"
done

echo ""
echo "Select agents to recruit (comma-separated numbers, or 'all' for everything):"
read -r selection

# Parse selection
if [ "$selection" == "all" ]; then
  selected_indices=($(seq 0 $((${#PROJECT_AGENT_FILES[@]} - 1))))
else
  selected_indices=()
  IFS=',' read -ra parts <<< "$selection"
  for part in "${parts[@]}"; do
    part="${part// /}"
    # Non-numeric input would abort the whole script under set -e; skip it instead
    if ! [[ "$part" =~ ^[0-9]+$ ]]; then
      echo "  ⚠ ignoring invalid selection: '$part'"
      continue
    fi
    idx=$((part - 1))
    if [ "$idx" -ge 0 ] && [ "$idx" -lt ${#PROJECT_AGENT_FILES[@]} ]; then
      selected_indices+=("$idx")
    fi
  done
fi

if [ ${#selected_indices[@]} -eq 0 ]; then
  echo "No valid selection made. Exiting."
  exit 1
fi

# Copy selected agents AND flatten their skills to user level.
# RECRUITMENT GATE (CLAUDE.md invariant): an agent is not certified as recruited
# until its metadata is present in agents-metadata/ AND valid per METADATA_SCHEMA.
# The gate blocks promotion of any agent whose registry metadata is missing/incomplete.
recruited_count=0
blocked_count=0
recruited_names=()
for idx in "${selected_indices[@]}"; do
  file="${PROJECT_AGENT_FILES[$idx]}"
  filename=$(basename "$file")
  agent_name="${filename%.md}"

  if ! node "$REPO_ROOT/scripts/validate-metadata.mjs" --dir "$REPO_ROOT/agents-metadata" "$agent_name"; then
    echo "✗ BLOCKED: $agent_name — register agents-metadata/$agent_name.json (valid per METADATA_SCHEMA) before recruiting"
    blocked_count=$((blocked_count + 1))
    continue
  fi

  cp "$file" "$CLAUDE_AGENTS_DIR/$filename"
  echo "✓ Recruited: $agent_name"
  recruit_skills "$agent_name"
  recruited_count=$((recruited_count + 1))
  recruited_names+=("$agent_name")
done

echo ""
if [ "$blocked_count" -gt 0 ]; then
  echo "⛔ $blocked_count agent(s) blocked by the metadata gate — not recruited."
fi
if [ "$recruited_count" -eq 0 ]; then
  echo "No agents recruited."
  exit 1
fi
echo "✓ Successfully recruited $recruited_count agent(s)!"
echo "📍 Agents: $CLAUDE_AGENTS_DIR"
echo "📍 Skills: $CLAUDE_SKILLS_DIR (agent-owned skills flattened for discovery)"

# Discard step (CLAUDE.md Process Rule 2): the grown self at user level is now
# authoritative — clear the nursery copies; git history remains the archive.
echo ""
echo "🧹 Graduation cleanup — run this to clear the nursery copies (git history keeps the lineage):"
discard_paths=()
for name in "${recruited_names[@]}"; do
  discard_paths+=("agents/$name.md" "agents-metadata/$name.json")
  [ -d "$PROJECT_SKILLS_DIR/$name" ] && discard_paths+=(".claude/skills/$name")
done
echo "   git rm -r ${discard_paths[*]}"
