# Focused graph queries

Use only the sections needed for the current lookup. A graph is a navigation
aid, not a replacement for source verification. Do not build a missing graph
just to answer a question; search/read the source instead.

## MCP: prefer a known node over keyword traversal

Pass the target project's absolute `project_path` to each tool. Inspect the
available tool schema when unsure of parameters.

| Goal | Tool and parameters |
| --- | --- |
| Resolve a symbol or inspect its metadata | `get_node(label=...)` or `get_node(node_id=...)` |
| Caller/callee neighborhood | `get_neighbors(node_id=..., relation_filter="calls", token_budget=800)` |
| Other direct relationships | `get_neighbors` with a relation actually present in the graph, or without a filter |
| Connect two known endpoints | `shortest_path(source=..., target=..., max_hops=6)` |
| Small exploratory query | `query_graph(question=..., depth=1, token_budget=800, context_filter=["call"])` |
| Explore a known community | `get_community(community_id=..., token_budget=800)` |

Use labels directly when unambiguous. If multiple files define the same name,
resolve the path-qualified symbol (`path/to/file::Symbol`) or its exact node ID
first; do not guess which duplicate a fuzzy label picked. `get_node` can return
substantial detail, so it is not a mandatory preliminary call for every lookup.

`relation_filter` matches a relationship such as `calls`; `context_filter`
matches an edge context such as `call` or `import`. They are different fields.
Filter only when the requested relationship warrants it. An empty filtered
result can mean missing extraction/context tags, not that no dependency exists.

Inspect direction arrows and provenance. A shortest path describes stored
relationships, not necessarily runtime control flow. Respect stored direction;
request `undirected=true` only for an explicitly undirected relationship search
and label that interpretation in the answer.

## CLI fallback

Run from the intended project root, or specify `--graph` explicitly:

```sh
graphify explain "lua/jove/output.lua::render_cell"
graphify path "ConceptA" "ConceptB"
graphify query "render_cell" --context call --budget 800
```

These commands are supported by Graphify 0.9.73. CLI `query` uses depth 2;
use MCP for depth control. `--dfs` selects depth-first exploration, not a
guaranteed execution trace. `query --help` is interpreted as a query in this
version; use the installed documentation for syntax rather than probing that
form. Do not append `head` to graph results: it can hide edges and diagnostics.

Token budgets are soft. The renderer can keep all edges when its nodes fit,
even if the combined output exceeds the budget. Prefer a narrower operation
instead of blindly raising or lowering the budget.

## Relevance and fallback

- Select a few concrete symbols or module names from the request or existing
  context. Generic words can select unrelated high-degree nodes.
- Check the returned source files before treating a fuzzy match as relevant.
- If the first lookup is irrelevant, truncated, or insufficient, switch to
  targeted source search/read. A follow-up is worthwhile only when a specific
  useful result identifies the next node or relationship to inspect.
- Avoid full vocabulary dumps, automatic reflection, and report-first reads.
  The wiki/report is for a requested broad overview, not a lookup prerequisite.
- If CLI/MCP is unavailable, use ordinary source tools rather than installing
  dependencies or writing a graph traversal script for a routine question.

## Evidence and freshness

Cite `source_file` / `source_location` when available. Verify actual behavior,
signatures, and edit locations in current source. State when a relationship is
inferred or ambiguous; do not invent missing edges. Source reads remain useful
even with a fresh graph because extraction may omit dynamic dependencies.

Queries do not require `.graphify_python`, a rebuild, or saving answers back to
the graph. Run `save-result` or reflection only on an explicit work-memory
request, with source-verified facts and an honest outcome.
