#!/usr/bin/env bash
# HOME is redirected: real home is read-only, gitnexus state (registry, FTS
# extension) lives under ~/.local/share/gitnexus-home (see ~/.local/bin/gitnexus).
set -eu

GN_REAL_HOME="/home/nghiant"
GN_HOME="$GN_REAL_HOME/.local/share/gitnexus-home"
GN_HOOK="$GN_REAL_HOME/.local/lib/node_modules/gitnexus/hooks/claude/gitnexus-hook.cjs"
GN_CLI="$GN_REAL_HOME/.local/lib/node_modules/gitnexus/dist/cli/index.js"

input=$(cat)

gn_dir="${CRUSH_CWD:-$PWD}"
gn_found=false
for _ in 1 2 3 4 5; do
  [ -d "$gn_dir/.gitnexus" ] && { gn_found=true; break; }
  gn_parent="$(dirname "$gn_dir")"
  [ "$gn_parent" = "$gn_dir" ] && break
  gn_dir="$gn_parent"
done

if [ "$gn_found" = false ]; then
  exit 0
fi

[ -f "$GN_HOOK" ] || exit 0
[ -f "$GN_CLI" ] || exit 0

tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
case "$tool" in
  bash) tool='Bash' ;;
  grep) tool='Grep' ;;
  glob) tool='Glob' ;;
  *) exit 0 ;;
esac

payload=$(printf '%s' "$input" | jq -c --arg tn "$tool" \
  '{hook_event_name: "PreToolUse", tool_name: $tn, tool_input: .tool_input, cwd: .cwd}')

out=$(printf '%s' "$payload" | \
  HOME="$GN_HOME" \
  GITNEXUS_HOOK_CLI_PATH="$GN_CLI" \
  node "$GN_HOOK" 2>/dev/null) || exit 0

ctx=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.additionalContext // empty' 2>/dev/null) || exit 0

if [ -n "$ctx" ]; then
  jq -n --arg c "$ctx" '{version: 1, context: $c}'
fi

exit 0
