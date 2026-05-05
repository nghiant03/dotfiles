---
name: jupyter-notebook
description: Complete tool to inspect, edit, and maintain Jupyter Notebooks safely and token-efficiently.
---

# Instructions

Use this skill for **every** interaction with `.ipynb` files.
Never open notebooks with raw text tools (`cat`, `sed`, `vim`, `view`, `edit`)—their JSON structure can break and full notebooks waste tokens.

All notebook operations use the helper script:
```bash
MGR=~/.config/crush/skills/jupyter-notebook/manager.py
```

Requirements: `python` with `nbformat` available. If missing, install it outside the task with `python -m pip install nbformat` or inside the available virtual environment.

## Token-Efficient Inspection

Start with the smallest command that can answer the question.

### 1. Summarize a Notebook

Use this first for unfamiliar notebooks. It prints only index, type, size, first line, and output counts.
```bash
python $MGR summary <notebook>
```

### 2. Show One Cell

Use after `summary` or `search` identifies the relevant index.
```bash
python $MGR show <notebook> <cell_index>
```

### 3. Show a Small Range

Use for nearby context without dumping the full notebook.
```bash
python $MGR range <notebook> <start_index> <end_index>
```

### 4. Search Cell Sources

Use to locate relevant cells by text.
```bash
python $MGR search <notebook> <query>
```

### 5. Read All Cells

Use only when a global notebook review is necessary. Output is truncated by default.
```bash
python $MGR read <notebook>
```

## Editing Cells

Always inspect the target cell first with `show` or `range` so the cell index is correct.
Mutation commands automatically create a timestamped `.bak-*` backup next to the notebook and clear stale outputs when appropriate.

### Replace an Existing Cell

1. Use `write` to create a temporary content file.
2. Apply the replacement.
3. Run `check`, then inspect the changed cell.

```bash
python $MGR edit <notebook> <cell_index> <content_file>
python $MGR check <notebook>
python $MGR show <notebook> <cell_index>
```

### Add a Cell at the End

Defaults to `code`; allowed types are `code`, `markdown`, and `raw`.
```bash
python $MGR add <notebook> <content_file> [code|markdown|raw]
python $MGR check <notebook>
```

### Insert a Cell at a Position

Inserts before the given index. Existing cells shift down.
```bash
python $MGR insert <notebook> <index> <content_file> [code|markdown|raw]
python $MGR check <notebook>
```

### Delete a Cell

```bash
python $MGR delete <notebook> <index>
python $MGR check <notebook>
```

## Maintenance Commands

### Validate Notebook Schema

Run after every edit and before finishing notebook work.
```bash
python $MGR check <notebook>
```

### Clear Outputs

Clear all code-cell outputs:
```bash
python $MGR clear <notebook>
```

Clear one code-cell output:
```bash
python $MGR clear <notebook> <index>
```

### Change Cell Type

Preserves source and metadata while rebuilding the cell.
```bash
python $MGR type <notebook> <index> <code|markdown|raw>
```

### Move a Cell

Moves the source cell before the target index.
```bash
python $MGR move <notebook> <source_index> <target_index>
```

## Required Workflow

- Use `summary` first unless the exact target cell is already known.
- Use `search`, `show`, or `range` for targeted context instead of `read` whenever possible.
- Re-run `summary` after `insert`, `delete`, or `move` because indices shift.
- Run `check` after every mutation.
- Prefer creating temp content files with Crush `write`; avoid shell heredocs for large or complex content.
- Do not execute notebooks unless the user explicitly asks and the project environment is safe.
