---
description: Switch the oh-my-opencode-slim plugin preset (openai, hyper, opencode-go) and report the current one.
---

# oh-my-opencode-slim Preset: $ARGUMENTS

Manage the `preset` key in `~/.config/opencode/oh-my-opencode-slim.json` (the oh-my-opencode-slim plugin config).

## Workflow

1. Read the active preset: `jq -r '.preset' ~/.config/opencode/oh-my-opencode-slim.json`
2. List available presets: `jq -r '.presets | keys | join(", ")' ~/.config/opencode/oh-my-opencode-slim.json`
3. If `$ARGUMENTS` is empty, stop and report the active preset plus the available options.
4. If `$ARGUMENTS` names an available preset, update only the top-level `preset` key, keeping the JSON valid:
   `jq --arg p "$ARGUMENTS" '.preset = $p' ~/.config/opencode/oh-my-opencode-slim.json > /tmp/oms-preset.tmp && mv /tmp/oms-preset.tmp ~/.config/opencode/oh-my-opencode-slim.json`
5. If `$ARGUMENTS` is not a recognized preset, do not edit; list valid presets instead.
6. Verify: `jq -r '.preset' ~/.config/opencode/oh-my-opencode-slim.json`

## Final response

Report: previous preset, new preset, and remind the user to restart OpenCode for the plugin to pick it up.
