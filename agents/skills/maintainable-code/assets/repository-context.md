# Repository context excerpts

| Rule | Trigger | Required action | Limit |
|---|---|---|---|
| T1 — Select confirmed context | Repository context is missing. | Use only relevant excerpts below and replace placeholders with discovered or confirmed facts. | Do not insert the whole template or retain unresolved placeholders as policy. Preserve existing instructions. |
| T2 — Record vocabulary | A domain term is ambiguous to callers or maintainers. | Record its confirmed meaning, bounded context, and important distinctions/external mappings. | Do not invent glossary terms or merge intentionally different contexts. |
| T3 — Record boundaries | A dependency restriction is agreed. | Record source/forbidden dependency, rationale, existing enforcement, narrow exceptions, and compatibility constraints. | Observation alone is not an agreed boundary. Do not invent architecture or enforcement commands. |

## Instruction excerpt

- For API/domain naming changes, substantial refactors, or maintainability review, use the `maintainable-code` skill; consult `<glossary path>` and `<architecture path>` only when those confirmed documents exist.
- After implementation, run `<confirmed existing check commands>` and report passed, failed, or incomplete verification. Rerun affected checks after later source changes.
- Do not change policy to silence failures or interpret review-helper output as a quality verdict.

## Optional glossary structure

| Term | Meaning | Scope | Distinct from / external mapping |
|---|---|---|---|
| `<confirmed term>` | `<project definition>` | `<bounded context>` | `<important distinction>` |

## Optional boundary record

- Boundary: `<source modules> → <forbidden dependency>`
- Rationale: `<real constraint>`
- Enforcement: `<existing architecture check and its configuration>`
- Exceptions: `<specific documented exceptions, if agreed>`
- Compatibility: `<external contracts that must remain stable>`
