---
name: jupyter
description: Complete tool to read, edit, and extend Jupyter Notebooks safely.
---

# Instructions

Use this skill for **every** interaction with `.ipynb` files.
Never open notebooks with raw text tools (`cat`, `sed`, `vim`, `view`, `edit`)—their JSON structure will break.

All commands below use the helper script:
```
MGR=~/.config/crush/skills/jupyter/manager.py
```

## 1. Read a Notebook
Display every cell with its index, type, source, and output summary:
```bash
python $MGR read <notebook>
```

## 2. Edit an Existing Cell
Replace a cell's content (clears outputs automatically):
1. Find the **cell index** from the `read` output.
2. Write the full replacement to a temp file.
3. Apply and clean up:
```bash
cat > _tmp.py << 'CELL'
<new cell content here>
CELL
python $MGR edit <notebook> <cell_index> _tmp.py && rm _tmp.py
```

## 3. Add a Cell at the End
Append a new cell (defaults to `code`; pass `markdown` for prose):
```bash
cat > _tmp.py << 'CELL'
<cell content>
CELL
python $MGR add <notebook> _tmp.py [code|markdown] && rm _tmp.py
```

## 4. Insert a Cell at a Position
Insert before a given index (other cells shift down):
```bash
cat > _tmp.py << 'CELL'
<cell content>
CELL
python $MGR insert <notebook> <index> _tmp.py [code|markdown] && rm _tmp.py
```

## 5. Delete a Cell
Remove a cell by index (remaining cells re-index):
```bash
python $MGR delete <notebook> <index>
```

## Tips
- Always `read` first so you have correct cell indices.
- After `delete` or `insert`, indices shift—re-read if making multiple changes.
- Use `markdown` type for headings, explanations, and documentation cells.
