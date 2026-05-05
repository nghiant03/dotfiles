#!/usr/bin/env python3
"""Token-efficient Jupyter Notebook manager."""

import os
import shutil
import sys
from datetime import datetime

try:
    import nbformat
except ImportError:
    print("Error: Missing dependency 'nbformat'. Install it with: python -m pip install nbformat")
    sys.exit(1)

SCRIPT = os.path.basename(__file__)
CELL_TYPES = {"code", "markdown", "raw"}
DEFAULT_SOURCE_LIMIT = 1200
DEFAULT_OUTPUT_LIMIT = 500


def _load(filepath):
    """Load notebook, exit on failure."""
    if not os.path.exists(filepath):
        print(f"Error: '{filepath}' not found.")
        sys.exit(1)
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            return nbformat.read(f, as_version=4)
    except Exception as exc:
        print(f"Error: Cannot parse '{filepath}' as a notebook: {exc}")
        sys.exit(1)


def _save(nb, filepath):
    with open(filepath, "w", encoding="utf-8") as f:
        nbformat.write(nb, f)


def _backup(filepath):
    backup_path = f"{filepath}.bak-{datetime.now().strftime('%Y%m%d%H%M%S%f')}"
    shutil.copy2(filepath, backup_path)
    return backup_path


def _parse_index(value):
    try:
        return int(value)
    except ValueError:
        print(f"Error: Index must be an integer, got '{value}'.")
        sys.exit(1)


def _validate_index(nb, idx, *, allow_append=False):
    """Validate cell index, exit on failure."""
    upper = len(nb.cells) if allow_append else len(nb.cells) - 1
    if idx < 0 or idx > upper:
        print(f"Error: Index {idx} out of range (0–{upper}).")
        sys.exit(1)


def _validate_type(cell_type):
    if cell_type not in CELL_TYPES:
        print(f"Error: Cell type must be one of: {', '.join(sorted(CELL_TYPES))}.")
        sys.exit(1)
    return cell_type


def _read_content(path):
    """Read temp-file content, exit on failure."""
    if not os.path.exists(path):
        print(f"Error: Content file '{path}' not found.")
        sys.exit(1)
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def _make_cell(source, cell_type="code"):
    cell_type = _validate_type(cell_type)
    if cell_type == "markdown":
        return nbformat.v4.new_markdown_cell(source)
    if cell_type == "raw":
        return nbformat.v4.new_raw_cell(source)
    return nbformat.v4.new_code_cell(source)


def _clip(text, limit):
    if limit < 0 or len(text) <= limit:
        return text
    return text[:limit] + f"… [truncated {len(text) - limit} chars]"


def _first_line(source):
    stripped = source.strip()
    if not stripped:
        return "# (empty)"
    return stripped.splitlines()[0]


def _output_summary(cell):
    if cell.cell_type != "code":
        return ""
    outputs = cell.get("outputs", [])
    if not outputs:
        return "outputs=0"
    kinds = {}
    for output in outputs:
        kind = output.get("output_type", "unknown")
        kinds[kind] = kinds.get(kind, 0) + 1
    detail = ",".join(f"{kind}:{count}" for kind, count in sorted(kinds.items()))
    return f"outputs={len(outputs)} ({detail})"


def _print_cell(cell, index, *, source_limit=DEFAULT_SOURCE_LIMIT, output_limit=DEFAULT_OUTPUT_LIMIT, outputs="summary"):
    tag = cell.cell_type.upper()
    source = cell.source.strip()
    print(f"\n[CELL {index}] [{tag}] lines={len(source.splitlines()) if source else 0} chars={len(source)}")
    print("```")
    print(_clip(source if source else "# (empty)", source_limit))
    print("```")

    if cell.cell_type == "code" and outputs != "none" and cell.get("outputs"):
        for out in cell.outputs:
            if out.output_type == "stream":
                text = out.text.strip()
                if text:
                    print(f"  → stdout: {_clip(text, output_limit)}")
            elif out.output_type == "error":
                print(f"  → error: {out.ename}: {out.evalue}")
            elif out.output_type in ("execute_result", "display_data"):
                plain = out.data.get("text/plain", "").strip()
                if plain:
                    print(f"  → result: {_clip(plain, output_limit)}")
                elif outputs == "full":
                    keys = ", ".join(sorted(out.data.keys()))
                    print(f"  → data: {keys}")


def _mutating_save(nb, filepath, backup):
    backup_path = _backup(filepath) if backup else None
    _save(nb, filepath)
    if backup_path:
        print(f"Backup: {backup_path}")


# ── Commands ─────────────────────────────────────────────────────────

def summary_notebook(filepath):
    """Print compact table of cells."""
    nb = _load(filepath)
    total = len(nb.cells)
    print(f"--- NOTEBOOK: {filepath} ({total} cell{'s' if total != 1 else ''}) ---")
    for i, cell in enumerate(nb.cells):
        source = cell.source or ""
        line_count = len(source.strip().splitlines()) if source.strip() else 0
        output = _output_summary(cell)
        suffix = f" | {output}" if output else ""
        print(f"{i:>3} | {cell.cell_type:<8} | lines={line_count:<4} chars={len(source):<5} | {_clip(_first_line(source), 120)}{suffix}")


def read_notebook(filepath):
    """Print every cell with bounded source and output summaries."""
    nb = _load(filepath)
    total = len(nb.cells)
    print(f"--- NOTEBOOK: {filepath} ({total} cell{'s' if total != 1 else ''}) ---")
    for i, cell in enumerate(nb.cells):
        _print_cell(cell, i)


def show_cell(filepath, index):
    """Print one full cell."""
    nb = _load(filepath)
    _validate_index(nb, index)
    _print_cell(nb.cells[index], index, source_limit=-1, output_limit=DEFAULT_OUTPUT_LIMIT)


def range_cells(filepath, start, end):
    """Print a bounded inclusive cell range."""
    nb = _load(filepath)
    _validate_index(nb, start)
    _validate_index(nb, end)
    if end < start:
        print("Error: End index must be greater than or equal to start index.")
        sys.exit(1)
    for i in range(start, end + 1):
        _print_cell(nb.cells[i], i)


def search_notebook(filepath, query):
    """Search cell sources and print matching cell previews."""
    nb = _load(filepath)
    needle = query.lower()
    matches = 0
    for i, cell in enumerate(nb.cells):
        source = cell.source or ""
        if needle in source.lower():
            matches += 1
            print(f"{i:>3} | {cell.cell_type:<8} | {_clip(_first_line(source), 160)}")
    print(f"Matches: {matches}")


def check_notebook(filepath):
    """Validate notebook schema."""
    nb = _load(filepath)
    try:
        nbformat.validate(nb)
    except Exception as exc:
        print(f"Error: Notebook schema validation failed: {exc}")
        sys.exit(1)
    print(f"OK: Notebook is valid ({len(nb.cells)} cell(s)).")


def edit_cell(filepath, index, content_path, *, backup=True):
    """Replace a cell's source and clear its outputs."""
    nb = _load(filepath)
    _validate_index(nb, index)
    new_source = _read_content(content_path)

    nb.cells[index].source = new_source
    if "outputs" in nb.cells[index]:
        nb.cells[index].outputs = []
    if "execution_count" in nb.cells[index]:
        nb.cells[index].execution_count = None

    _mutating_save(nb, filepath, backup)
    print(f"OK: Cell {index} updated.")


def add_cell(filepath, content_path, cell_type="code", *, backup=True):
    """Append a new cell to the end of the notebook."""
    nb = _load(filepath)
    source = _read_content(content_path)
    nb.cells.append(_make_cell(source, cell_type))
    _mutating_save(nb, filepath, backup)
    print(f"OK: Added {cell_type} cell at index {len(nb.cells) - 1}.")


def insert_cell(filepath, index, content_path, cell_type="code", *, backup=True):
    """Insert a new cell at a specific position."""
    nb = _load(filepath)
    _validate_index(nb, index, allow_append=True)
    source = _read_content(content_path)
    nb.cells.insert(index, _make_cell(source, cell_type))
    _mutating_save(nb, filepath, backup)
    print(f"OK: Inserted {cell_type} cell at index {index}.")


def delete_cell(filepath, index, *, backup=True):
    """Remove a cell by index."""
    nb = _load(filepath)
    _validate_index(nb, index)
    nb.cells.pop(index)
    _mutating_save(nb, filepath, backup)
    print(f"OK: Deleted cell {index}. Notebook now has {len(nb.cells)} cell(s).")


def clear_outputs(filepath, index=None, *, backup=True):
    """Clear outputs for one code cell or all code cells."""
    nb = _load(filepath)
    if index is not None:
        _validate_index(nb, index)
        cells = [(index, nb.cells[index])]
    else:
        cells = list(enumerate(nb.cells))

    cleared = 0
    for _, cell in cells:
        if cell.cell_type == "code":
            if cell.get("outputs"):
                cleared += 1
            cell.outputs = []
            cell.execution_count = None

    _mutating_save(nb, filepath, backup)
    print(f"OK: Cleared outputs in {cleared} cell(s).")


def change_type(filepath, index, cell_type, *, backup=True):
    """Change a cell type while preserving source."""
    nb = _load(filepath)
    _validate_index(nb, index)
    new_cell = _make_cell(nb.cells[index].source, cell_type)
    new_cell.metadata = nb.cells[index].get("metadata", {})
    nb.cells[index] = new_cell
    _mutating_save(nb, filepath, backup)
    print(f"OK: Cell {index} changed to {cell_type}.")


def move_cell(filepath, source_index, target_index, *, backup=True):
    """Move a cell before target index."""
    nb = _load(filepath)
    _validate_index(nb, source_index)
    _validate_index(nb, target_index, allow_append=True)
    cell = nb.cells.pop(source_index)
    if target_index > source_index:
        target_index -= 1
    nb.cells.insert(target_index, cell)
    _mutating_save(nb, filepath, backup)
    print(f"OK: Moved cell {source_index} to {target_index}.")


# ── CLI ──────────────────────────────────────────────────────────────

USAGE = f"""\
Usage: {SCRIPT} <command> <notebook> [args...]

Token-efficient inspection:
  summary <notebook>                         Show compact cell table
  show    <notebook> <index>                 Show one full cell
  range   <notebook> <start> <end>           Show inclusive cell range
  search  <notebook> <query>                 Search cell sources
  read    <notebook>                         Show all cells with truncation
  check   <notebook>                         Validate notebook schema

Mutation commands create timestamped .bak files:
  edit    <notebook> <index> <content_file>  Replace a cell's source
  add     <notebook> <content_file> [type]   Append cell (type: code|markdown|raw)
  insert  <notebook> <index> <file> [type]   Insert cell at position
  delete  <notebook> <index>                 Remove a cell
  clear   <notebook> [index]                 Clear outputs in one or all code cells
  type    <notebook> <index> <type>          Change cell type
  move    <notebook> <source> <target>       Move cell before target index"""


def main():
    if len(sys.argv) < 3:
        print(USAGE)
        sys.exit(1)

    cmd, nb_path = sys.argv[1], sys.argv[2]

    if cmd == "summary" and len(sys.argv) == 3:
        summary_notebook(nb_path)
    elif cmd == "show" and len(sys.argv) == 4:
        show_cell(nb_path, _parse_index(sys.argv[3]))
    elif cmd == "range" and len(sys.argv) == 5:
        range_cells(nb_path, _parse_index(sys.argv[3]), _parse_index(sys.argv[4]))
    elif cmd == "search" and len(sys.argv) == 4:
        search_notebook(nb_path, sys.argv[3])
    elif cmd == "read" and len(sys.argv) == 3:
        read_notebook(nb_path)
    elif cmd == "check" and len(sys.argv) == 3:
        check_notebook(nb_path)
    elif cmd == "edit" and len(sys.argv) == 5:
        edit_cell(nb_path, _parse_index(sys.argv[3]), sys.argv[4])
    elif cmd == "add" and len(sys.argv) in (4, 5):
        ctype = sys.argv[4] if len(sys.argv) == 5 else "code"
        add_cell(nb_path, sys.argv[3], ctype)
    elif cmd == "insert" and len(sys.argv) in (5, 6):
        ctype = sys.argv[5] if len(sys.argv) == 6 else "code"
        insert_cell(nb_path, _parse_index(sys.argv[3]), sys.argv[4], ctype)
    elif cmd == "delete" and len(sys.argv) == 4:
        delete_cell(nb_path, _parse_index(sys.argv[3]))
    elif cmd == "clear" and len(sys.argv) in (3, 4):
        index = _parse_index(sys.argv[3]) if len(sys.argv) == 4 else None
        clear_outputs(nb_path, index)
    elif cmd == "type" and len(sys.argv) == 5:
        change_type(nb_path, _parse_index(sys.argv[3]), sys.argv[4])
    elif cmd == "move" and len(sys.argv) == 5:
        move_cell(nb_path, _parse_index(sys.argv[3]), _parse_index(sys.argv[4]))
    else:
        print(USAGE)
        sys.exit(1)


if __name__ == "__main__":
    main()
