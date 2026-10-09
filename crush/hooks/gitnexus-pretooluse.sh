#!/usr/bin/env bash
# GitNexus PreToolUse adapter for Crush.
#
# Crush hook contract  ->  Claude Code contract (gitnexus-hook.cjs)  ->  Crush context.
#
# Crush sends: {"event":"PreToolUse","session_id":..,"cwd":..,"tool_name":"bash","tool_input":{...}}
# GitNexus expects:   {"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{...},"cwd":...}
# GitNexus replies:   {"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"..."}}
# Crush expects:      {"context":"..."} (no decision -> no opinion, tool proceeds normally)

set -eu

# Real home is read-only: gitnexus state (registry, .lbdb FTS extension) lives
# under a redirected HOME — see the wrapper at ~/.local/bin/gitnexus.
GN_REAL_HOME="/home/nghiant"
GN_HOME="$GN_REAL_HOME/.local/share/gitnexus-home"
GN_HOOK="$GN_REAL_HOME/.local/lib/node_modules/gitnexus/hooks/claude/gitnexus-hook.cjs"
# The hook script spawns this with `node <path> ...`, so it must be the JS
# entrypoint — NOT the ~/.local/bin/gitnexus shell wrapper (HOME is already
# redirected by this adapter, so the wrapper is unnecessary here anyway).
GN_CLI="$GN_REAL_HOME/.local/lib/node_modules/gitnexus/dist/cli/index.js"

input=$(cat)

[ -f "$GN_HOOK" ] || exit 0
[ -f "$GN_CLI" ] || exit 0

# GitNexus only augments search tools; map Crush's lowercase names to
# Claude Code's capitalized ones, exit silently for everything else.
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
