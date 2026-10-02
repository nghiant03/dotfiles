---
name: graphify
description: "Use for explicit /graphify operations or to explore an existing knowledge graph for architecture, caller/dependency relationships, and unfamiliar cross-module paths. Supports graph building, updates, and exports on request. Do not trigger merely because a graph exists, or for known-file edits, exact-text searches, routine debugging, or general programming/library questions."
metadata:
  management: local
  upstream-version: "0.9.73"
---

# Graphify

Use the graph as an optional map of relationships. Source files remain the
authority for implementation details. Choose the smallest lookup that answers
the question; a graph lookup is not a prerequisite for reading or editing code.

## Route the request

| Request | Action |
| --- | --- |
| Known file, exact text, routine fix, or implementation detail | Search/read the source directly. |
| Known symbol's callers or dependencies | Use MCP `get_node` / `get_neighbors`; see [query guide](references/query.md) when needed. |
| Relationship between two known concepts | Use MCP `shortest_path` or CLI `graphify path`. |
| Unfamiliar architecture / cross-module exploration | Use a scoped `query_graph`, initially depth 1, or a focused community lookup. |
| `/graphify`, `/graphify <path-or-url>`, explicit full build | Load [build workflow](references/build.md). Default build path is `.`. |
| Explicit full `--update` or `--cluster-only` | Load [update workflow](references/update.md); it links to the build steps it needs. |
| Add URL, watch, export, or hook installation | Load only the relevant reference below. |

For `--help` / `-h`, show usage without running commands. See the Usage section
of the build reference for the complete flag list.

## Everyday lookups

1. Check whether the target project has `graphify-out/graph.json`. If absent,
   answer through source exploration; build only when requested.
2. Prefer exact symbols or node IDs and narrow relation filters. Pass the
   absolute `project_path` to MCP tools so they query the intended project.
3. Use `get_neighbors` with `relation_filter: "calls"` for caller/callee
   relationships. Use a path-qualified symbol or exact ID when names collide.
4. For exploratory MCP queries, start with `depth: 1`, `token_budget: 800`, and
   a relevant `context_filter` (for example `["call"]` or `["import"]`). Budgets
   are soft. CLI `query` supports `--context` and `--budget`, but uses depth 2.
5. If the first lookup is irrelevant, truncated, or insufficient, use targeted
   search/read. Follow up only on a specific useful node or edge. Avoid broad
   retries, full vocabulary dumps, and routine report reads.
6. Cite source locations, distinguish extracted from inferred relationships,
   and verify behavioral claims in code. Missing edges are not proof of absence.

Do not automatically run reflection, save-result, graph rebuilds, or semantic
extraction during lookups. These add work and can mix unverified answers into
future retrieval. Load detailed query guidance only if the lookup needs it.

## Maintenance

If an existing graph was used during source changes, run `graphify update .`
once after the completed batch, unless a hook/watch already refreshed it. This
updates code structure only; semantic document changes require an explicit full
update. Skip refresh for read-only work or unrelated configuration changes.

This skill is locally maintained from Graphify 0.9.73. Keep it unstamped
(no `.graphify_version`) so package auto-refresh leaves this copy alone.
Explicit `graphify install` can replace it; review upstream changes manually.

## On-demand references

- [Query details and CLI fallback](references/query.md)
- [Build workflow and full usage](references/build.md)
- [Incremental updates and clustering](references/update.md)
- [Exports, wiki, and visualization](references/exports.md)
- [URL ingestion and watching](references/add-watch.md)
- [Commit hooks and host integration](references/hooks.md)
- [GitHub and multi-repository builds](references/github-and-merge.md)
- [Semantic extraction schema](references/extraction-spec.md)
- [Audio/video transcription](references/transcribe.md)
