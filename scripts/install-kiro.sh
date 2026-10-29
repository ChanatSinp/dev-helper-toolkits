#!/usr/bin/env bash
# Install a dev-helper-toolkits plugin into a target project's .kiro/ directory.
#
# Kiro has no plugin marketplace that imports an arbitrary repo, so installation
# is a flatten-copy (same idea as the Antigravity harness): the plugin's skill
# becomes an auto-included steering file, its agents/ become Kiro custom
# sub-agents, and its references/ ride along beside the steering file.
#
# Usage:
#   scripts/install-kiro.sh <target-project-dir> [plugin-name]
#   scripts/install-kiro.sh --global [plugin-name]
#
# Defaults to the development-pipeline plugin.
#   <target-project-dir>  installs into that project's .kiro/ (workspace scope).
#   --global              installs into ~/.kiro/ (every Kiro session, every project).
set -euo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)              # repo root

if [ $# -lt 1 ]; then
  echo "usage: $0 <target-project-dir> [plugin-name]" >&2
  echo "       $0 --global [plugin-name]" >&2
  exit 2
fi

# Resolve scope: --global targets the home directory (so .kiro/ becomes ~/.kiro/).
if [ "$1" = --global ] || [ "$1" = -g ]; then
  target=$HOME
  scope=global
  plugin=${2:-development-pipeline}
else
  target=$1
  scope=project
  plugin=${2:-development-pipeline}
fi

src="$here/plugins/$plugin"

[ -d "$src" ] || { echo "no such plugin: $src" >&2; exit 1; }
[ -d "$src/skills" ] || { echo "plugin has no skills/ directory: $src" >&2; exit 1; }
[ -d "$target" ] || { echo "target dir does not exist: $target" >&2; exit 1; }

# The plugin ships exactly one skill directory; its name is the steering name.
skill_dir=$(find "$src/skills" -mindepth 1 -maxdepth 1 -type d | head -n1)
skill_name=$(basename "$skill_dir")

steering_dir="$target/.kiro/steering"
agents_dir="$target/.kiro/agents"
mkdir -p "$steering_dir/$skill_name" "$agents_dir"

# 1. References ride along beside the steering file so #[[file:...]] and brief
#    paths resolve inside the target project.
if [ -d "$skill_dir/references" ]; then
  rm -rf "$steering_dir/$skill_name/references"
  cp -r "$skill_dir/references" "$steering_dir/$skill_name/references"
fi

# 2. The orchestrator: the Kiro binding header (from this repo's own .kiro
#    steering file) followed by the verbatim skill body, with reference paths
#    rewritten to the installed location.
#    We reuse the committed .kiro/steering/<skill>.md as the header source of
#    truth when installing the same plugin this repo ships; otherwise we
#    synthesize a minimal header.
dest_steering="$steering_dir/$skill_name.md"
if [ -f "$here/.kiro/steering/$skill_name.md" ] && [ "$plugin" = development-pipeline ]; then
  # Rewrite repo-relative reference/skill paths to the installed layout.
  sed \
    -e "s#plugins/$plugin/skills/$skill_name/references/#.kiro/steering/$skill_name/references/#g" \
    -e "s#plugins/$plugin/skills/$skill_name/SKILL.md#.kiro/steering/$skill_name/SKILL.md#g" \
    "$here/.kiro/steering/$skill_name.md" > "$dest_steering"
  cp "$skill_dir/SKILL.md" "$steering_dir/$skill_name/SKILL.md"
else
  # Generic fallback: drop the raw SKILL.md as an always-on steering file.
  cp "$skill_dir/SKILL.md" "$dest_steering"
fi

# 3. Agents: one Kiro custom-agent JSON per agents/*.md. Each points its prompt
#    at the copied agent markdown via a file:// URI (single source of truth).
if [ -d "$src/agents" ]; then
  cp -r "$src/agents" "$steering_dir/$skill_name/agents"
  for a in "$src"/agents/*.md; do
    [ -e "$a" ] || continue
    name=$(basename "$a" .md)
    # First paragraph of the frontmatter description, best-effort.
    desc=$(awk '/^description:/{sub(/^description: */,""); print; exit}' "$a")
    [ -n "$desc" ] || desc="Development-pipeline stage agent: $name"
    # JSON-escape the description.
    desc_json=$(printf '%s' "$desc" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().strip()))' 2>/dev/null \
      || printf '"%s"' "$(printf '%s' "$desc" | sed 's/\\/\\\\/g; s/"/\\"/g')")
    cat > "$agents_dir/$name.json" <<JSON
{
  "name": "$name",
  "description": $desc_json,
  "prompt": "file://../steering/$skill_name/agents/$name.md",
  "tools": ["read", "write", "shell"]
}
JSON
  done
fi

echo "Installed '$plugin' ($scope scope) into $target/.kiro/"
echo "  steering: $dest_steering"
echo "  agents:   $agents_dir/*.json"
echo "  refs:     $steering_dir/$skill_name/references/"
if [ "$scope" = global ]; then
  echo "Active in every Kiro session. Workspace .kiro/ still overrides per project."
fi
