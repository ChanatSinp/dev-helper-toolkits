#!/usr/bin/env bash
# Mechanical consistency checks for plugins/development-pipeline. Exits non-zero on any failure.
set -u
cd "$(dirname "$0")/../plugins/development-pipeline" || exit 1
fail=0
bad() { echo "FAIL: $*"; fail=1; }

versions=$(grep -h '"version"' .claude-plugin/plugin.json .codex-plugin/plugin.json .cursor-plugin/plugin.json .antigravity-plugin/plugin.json | sort -u | wc -l)
[ "$versions" -eq 1 ] || bad "plugin.json versions differ across the four manifests"

plain='Write it in plain words for someone who did not follow the run: result first, short sentences, everyday terms. Name a thing by what it is; use an ID (`CR-2`, `WP1`, `AC-10`) only when the reader needs it to find or route the item, and say what it means next to it.'
for f in agents/*.md; do
  grep -qF "$plain" "$f" || bad "$f lacks the shared plain-wording sentence"
done

comment='One short line written the way a teammate would say it'
for f in agents/plan-driven-implementer.md agents/cdk-implementer.md; do
  grep -qF "$comment" "$f" || bad "$f lacks the shared comment-style line"
done

skill=skills/development-pipeline
for r in $(grep -o 'references/[a-z-]*\.md' "$skill/SKILL.md" | sort -u); do
  [ -f "$skill/$r" ] || bad "SKILL.md points at missing $r"
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/.claude/temp"
cat > "$tmp/.claude/temp/plan.md" <<'PLAN'
# Implementation Plan: sample

## Summary
Sample.

## Context Pack
- [shared] Commands: go test ./...
- [WP1] File map: `a.go`
- [WP2] File map: `b.go`

## Work Packages
| Package | Phases | Owned Files (exclusive) | Depends On | Tier | Owner |
|---------|--------|-------------------------|------------|------|-------|
| WP1 | Phase 1, Phase 3 | `a.go` | — | routine | app |
| WP2 | Phase 2 | `b.go` | WP1 | routine | app |

## Implementation Phases

### Phase 1: One — WP1
- [ ] Step 1
### Phase 2: Two — WP2
- [ ] Step 1
### Phase 3: Fix (fix round 1) — WP1
- [ ] Step 1

## Edge Case Coverage
| Package | Scenario | Expected Behavior (source) | Handling Step | How Verified |
|---------|----------|----------------------------|---------------|--------------|
| WP1 | empty | error | Phase 1 | unit |
| WP1 | nil (fix round 1) | error | Phase 3 | unit |
PLAN
awk -v r=0 '/^  mkdir -p \.claude\/temp\/wp; w=WP1; r=;/{r=1; next} r && /^  \x27 \.claude\/temp\/plan\.md/{exit} r{sub(/^  /,""); print}' agents/implementation-planner.md > "$tmp/slice.awk"
[ -s "$tmp/slice.awk" ] || bad "slice-extraction awk not found in implementation-planner.md"
slice() { (cd "$tmp" && awk -v w="$1" -v r="$2" -f slice.awk .claude/temp/plan.md); }
out=$(slice WP1 "")
echo "$out" | grep -q 'Phase 1: One' || bad "WP1 slice lacks Phase 1"
echo "$out" | grep -q 'Phase 2' && bad "WP1 slice leaks WP2's phase"
echo "$out" | grep -q '\[WP2\]' && bad "WP1 slice leaks WP2's Context Pack entry"
echo "$out" | grep -q '\[shared\]' || bad "WP1 slice lacks [shared] entries"
out=$(slice WP1 1)
echo "$out" | grep -q 'Phase 1: One' && bad "fix-round slice keeps earlier phases"
echo "$out" | grep -q 'Phase 3' || bad "fix-round slice lacks the round's phase"
echo "$out" | grep -q '| empty |' && bad "fix-round slice keeps earlier Edge Case rows"

[ "$fail" -eq 0 ] && echo "OK"
exit "$fail"
