#!/usr/bin/env python3
"""Jupyter Notebook manager — read, edit, add, insert, and delete cells."""

import sys
import os
import nbformat

SCRIPT = os.path.basename(__file__)


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


def _validate_index(nb, idx, *, allow_append=False):
    """Validate cell index, exit on failure."""
    upper = len(nb.cells) if allow_append else len(nb.cells) - 1
    if idx < 0 or idx > upper:
        print(f"Error: Index {idx} out of range (0–{upper}).")
        sys.exit(1)


def _read_content(path):
    """Read temp-file content, exit on failure."""
    if not os.path.exists(path):
        print(f"Error: Content file '{path}' not found.")
        sys.exit(1)
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def _make_cell(source, cell_type="code"):
    if cell_type == "markdown":
        return nbformat.v4.new_markdown_cell(source)
    return nbformat.v4.new_code_cell(source)


# ── Commands ─────────────────────────────────────────────────────────

def read_notebook(filepath):
    """Print every cell with index, type, source, and truncated outputs."""
    nb = _load(filepath)
    total = len(nb.cells)
    print(f"--- NOTEBOOK: {filepath} ({total} cell{'s' if total != 1 else ''}) ---")

    for i, cell in enumerate(nb.cells):
        tag = cell.cell_type.upper()
        source = cell.source.strip()
        print(f"\n[CELL {i}] [{tag}]")
        print("```")
        print(source if source else "# (empty)")
        print("```")

        # Show outputs for code cells (text and errors only, truncated)
        if cell.cell_type == "code" and cell.get("outputs"):
            for out in cell.outputs:
                if out.output_type == "stream":
                    text = out.text.strip()
                    if text:
                        preview = text[:500] + ("…" if len(text) > 500 else "")
                        print(f"  → stdout: {preview}")
                elif out.output_type == "error":
                    print(f"  → error: {out.ename}: {out.evalue}")
                elif out.output_type in ("execute_result", "display_data"):
                    plain = out.data.get("text/plain", "").strip()
                    if plain:
                        preview = plain[:500] + ("…" if len(plain) > 500 else "")
                        print(f"  → result: {preview}")


def edit_cell(filepath, index, content_path):
    """Replace a cell's source and clear its outputs."""
    nb = _load(filepath)
    _validate_index(nb, index)
    new_source = _read_content(content_path)

    nb.cells[index].source = new_source
    if "outputs" in nb.cells[index]:
        nb.cells[index].outputs = []
    if "execution_count" in nb.cells[index]:
        nb.cells[index].execution_count = None

    _save(nb, filepath)
    print(f"OK: Cell {index} updated.")


def add_cell(filepath, content_path, cell_type="code"):
    """Append a new cell to the end of the notebook."""
    nb = _load(filepath)
    source = _read_content(content_path)
    nb.cells.append(_make_cell(source, cell_type))
    _save(nb, filepath)
    print(f"OK: Added {cell_type} cell at index {len(nb.cells) - 1}.")


def insert_cell(filepath, index, content_path, cell_type="code"):
    """Insert a new cell at a specific position."""
    nb = _load(filepath)
    _validate_index(nb, index, allow_append=True)
    source = _read_content(content_path)
    nb.cells.insert(index, _make_cell(source, cell_type))
    _save(nb, filepath)
    print(f"OK: Inserted {cell_type} cell at index {index}.")


def delete_cell(filepath, index):
    """Remove a cell by index."""
    nb = _load(filepath)
    _validate_index(nb, index)
    nb.cells.pop(index)
    _save(nb, filepath)
    print(f"OK: Deleted cell {index}. Notebook now has {len(nb.cells)} cell(s).")


# ── CLI ──────────────────────────────────────────────────────────────

USAGE = f"""\
Usage: {SCRIPT} <command> <notebook> [args...]

Commands:
  read   <notebook>                          Show all cells
  edit   <notebook> <index> <content_file>   Replace a cell's source
  add    <notebook> <content_file> [type]    Append cell (type: code|markdown)
  insert <notebook> <index> <file> [type]    Insert cell at position
  delete <notebook> <index>                  Remove a cell"""


def main():
    if len(sys.argv) < 3:
        print(USAGE)
        sys.exit(1)

    cmd, nb_path = sys.argv[1], sys.argv[2]

    if cmd == "read":
        read_notebook(nb_path)

    elif cmd == "edit" and len(sys.argv) == 5:
        edit_cell(nb_path, int(sys.argv[3]), sys.argv[4])

    elif cmd == "add" and len(sys.argv) in (4, 5):
        ctype = sys.argv[4] if len(sys.argv) == 5 else "code"
        add_cell(nb_path, sys.argv[3], ctype)

    elif cmd == "insert" and len(sys.argv) in (5, 6):
        ctype = sys.argv[5] if len(sys.argv) == 6 else "code"
        insert_cell(nb_path, int(sys.argv[3]), sys.argv[4], ctype)

    elif cmd == "delete" and len(sys.argv) == 4:
        delete_cell(nb_path, int(sys.argv[3]))

    else:
        print(USAGE)
        sys.exit(1)


if __name__ == "__main__":
    main()
