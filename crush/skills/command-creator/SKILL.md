---
name: command-creator
description: Create new Crush custom commands, modify existing commands, and improve saved prompt workflows. Use this skill whenever the user wants to create a command, slash command, saved prompt, reusable workflow, command file under commands/, or asks for something similar to skill-creator but for Crush commands.
---

# Command Creator

A skill for creating and improving Crush custom commands.

Custom commands are saved prompts stored as Markdown files. They are most useful for workflows a user wants to run repeatedly from the command dialog, such as review checklists, release procedures, issue triage, or project-specific automations.

At a high level, the process is:

- Understand what repeated workflow the user wants to capture
- Decide whether it belongs in global user commands or project-local commands
- Draft a concise command prompt with the right instructions and arguments
- Save it as a Markdown file in the correct `commands/` directory
- Validate that the command ID, placeholders, and workflow behave as intended
- Improve the command based on user feedback or obvious gaps

## Communicating with the user

Be direct and practical. Most command-creation requests do not need a long interview. Extract intent from the current conversation first, ask only when a missing detail materially changes the command, and otherwise create the best command using existing project patterns.

Prefer short final responses that include the command ID, path, and any arguments.

## Crush custom command model

Crush loads custom commands from Markdown files in these locations:

1. Global user commands:

   ```text
   $XDG_CONFIG_HOME/crush/commands/
   ```

   On this system, that is usually:

   ```text
   ~/.config/crush/commands/
   ```

2. Project-local commands:

   ```text
   <PROJECT DIR>/.crush/commands/
   ```

Each Markdown file becomes a custom command. The file name without `.md` becomes the command name.

Commands can be organized into subdirectories:

```text
~/.config/crush/commands/git/commit.md
```

This creates a command ID like:

```text
user:git:commit
```

A project-local command uses the project command namespace instead of `user:`.

## Command arguments

Crush supports named arguments in command Markdown using placeholders in this format:

```text
$NAME
```

Argument names must:

- Start with an uppercase letter
- Contain only uppercase letters, numbers, and underscores

When the command runs, Crush prompts the user for each unique placeholder.

Use arguments for values the assistant cannot reliably infer, such as:

- `$ISSUE_NUMBER`
- `$BRANCH_NAME`
- `$SEARCH_PATTERN`
- `$DIRECTORY`
- `$RELEASE_VERSION`

Do not use placeholders for values the assistant should discover by searching or reading files.

When documenting placeholder syntax inside generated commands, avoid accidental runtime placeholders unless they are intentionally part of the command.

## Creating a command

### Capture intent

Start by understanding the user’s goal. The current conversation may already contain the workflow they want to capture. Extract:

1. What the command should enable the assistant to do
2. When the user would run it
3. Whether it should be global or project-local
4. What inputs should become command arguments
5. What output format the command should produce
6. Which tools, files, safety checks, or tests it should require

If the user asks for a command based on an existing workflow, reconstruct the exact sequence, including corrections the user made and successful verification steps.

### Choose the command location

Use this default decision rule:

- Use global user commands for reusable workflows that should work across repositories.
- Use project-local commands for workflows tied to a specific repository’s scripts, file layout, conventions, deployment process, or private context.

Before writing:

- Check `~/.config/crush/commands/` for existing global commands.
- Check `<project>/.crush/commands/` for existing project commands when inside a project.
- Read any existing command you will modify.
- Avoid overwriting unrelated commands.

### Name the command

Use short, action-oriented, lowercase kebab-case filenames.

Good names:

```text
review-pr.md
triage-issue.md
write-tests.md
release-check.md
security-audit.md
```

Use subdirectories for categories when useful:

```text
git/commit.md
github/review-pr.md
project/release.md
```

### Draft the Markdown

A custom command is a saved prompt. It should be concise enough to use repeatedly but complete enough that the assistant can execute without asking avoidable questions.

A strong command usually includes:

- A clear title
- The objective
- Required context-gathering steps
- The action sequence
- Safety constraints for destructive or high-risk actions
- Verification steps
- Final response format

Prefer imperative instructions.

Explain why key steps matter when it improves behavior, but keep the command lean. Do not turn every command into a full skill; commands should be focused reusable prompts.

## Recommended command template

Use this structure when it fits:

```markdown
# [Command title]

[One-sentence objective.]

## Context

- Inspect [relevant files/state].
- Infer [values] when possible.
- Ask only if [specific blocker].

## Workflow

1. [Step one]
2. [Step two]
3. [Step three]

## Verification

- Run [specific checks/tests] when applicable.
- If a check fails, fix the issue and rerun it.

## Final response

Report:
- [item 1]
- [item 2]
```

For commands with arguments:

```markdown
# Review GitHub Issue $ISSUE_NUMBER

Review issue $ISSUE_NUMBER and propose an implementation plan.

## Workflow

1. Run `gh issue view $ISSUE_NUMBER --json title,body,comments,labels`.
2. Search the codebase for related files.
3. Summarize the likely change, risks, and test plan.

## Final response

Return a concise plan with file references.
```

## Safety and quality rules

When creating commands:

- Do not include secrets, tokens, or private credentials in command files.
- Do not create commands that facilitate malware, credential theft, unauthorized access, or destructive behavior.
- Include confirmation requirements for destructive operations when appropriate.
- Do not add comments or TODOs in generated code unless the user asked for them.
- Do not modify Crush provider settings unless the user explicitly requested configuration changes.
- Do not commit or push unless the user explicitly asks.

When a command will modify files or run tests, bake in the normal Crush workflow:

- Search before assuming
- Read files before editing
- Use exact edits
- Run relevant tests after changes
- Fix failures caused by the change
- Keep final output concise

## Improving an existing command

When the user asks to update or improve a command:

1. Find the command file in global and project command directories.
2. Read it before editing.
3. Identify what is missing, ambiguous, too verbose, or over-constrained.
4. Preserve useful behavior and command arguments.
5. Make targeted edits.
6. Read the result and mentally test realistic invocations.

Look for these common improvements:

- Add context-gathering steps so the assistant does not ask unnecessary questions.
- Add verification steps.
- Tighten final response format.
- Replace brittle specifics with project-discoverable instructions.
- Add arguments only where runtime input is genuinely needed.
- Remove accidental placeholders that would trigger unnecessary prompts.

## Testing a command

After writing or editing a command, validate it without requiring a full UI run:

1. Read the saved command file.
2. Confirm the file path maps to the intended command ID.
3. Search for placeholders with the pattern for command arguments and ensure each one is intentional.
4. Mentally simulate at least two realistic invocations:
   - A normal successful use
   - An edge case or missing-context use
5. If the command is too vague or asks too many questions, revise it once.

For objective workflows, consider creating 2-3 test prompts and comparing expected assistant behavior before and after the command. Full benchmark infrastructure is usually unnecessary for simple custom commands; reserve it for complex reusable workflows where quality is hard to judge by inspection.

## Final response after creating or editing

Keep the final response short. Include:

- Command ID
- File path
- Runtime arguments, if any
- How to run it: `Ctrl+p` → `Tab` → User Commands, or the relevant project command tab

Example:

```text
Created `user:github:review-pr` at `~/.config/crush/commands/github/review-pr.md`.
Arguments: `PR_NUMBER`.
Run it with `Ctrl+p` → `Tab` → User Commands.
```
