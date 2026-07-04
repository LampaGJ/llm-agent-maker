# Agent Metadata Schema

All agent metadata files must follow this schema for consistency and cross-agent analysis.

## Required Fields

```json
{
  "agent_name": "string - kebab-case identifier matching filename",
  "created": "string - ISO date YYYY-MM-DD",
  "specification": {
    "scope": "string - Narrow/Broad: description",
    "depth": "string - Expert (Top 5%) or Senior (Top 25%)",
    "function": "string - Generator, Analyzer, Quality Gate, Coordinator, or hybrid",
    "risk_profile": "string - Conservative/Balanced/Aggressive with context",
    "context": "string - Standalone or Team: description"
  },
  "workflow": {
    "method": "string - 'Parallel consensus' or 'Direct creation'",
    "iterations": "number - convergence iterations (1-5)",
    "final_verdict": "string - 'APPROVED'"
  },
  "core_capabilities": ["array of 3-5 capability strings"],
  "key_expertise": ["array of 4-8 expertise area strings"],
  "success_metrics": ["array of 3-5 metric strings with specific numbers"],
  "final_template": "string - relative path to agent file"
}
```

## Archetype-specific fields

The template schema is archetype-dispatched (see CLAUDE.md): consultative
agents carry Success Metrics; operational agents carry Validation Gates
instead — a Success Metrics section inside an operational template is a
schema-mixing failure. The registry mirrors that split:

```json
{
  "archetype": "string - 'consultative' (default) or 'operational'",
  "validation_gates": ["array of 3-5 gate strings — operational agents only, replaces success_metrics"]
}
```

- **Consultative** (or `archetype` omitted): `success_metrics` required, as above.
- **Operational** (`"archetype": "operational"`): `validation_gates` required
  (3-5 entries, each a mechanically checkable pass/fail condition, e.g.
  "`ls -la <path>` returns the deliverable"); `success_metrics` may be omitted.

## Optional Fields (for parallel consensus workflow)

```json
{
  "quality_scores": {
    "top_version": "string - e.g., 'v4'",
    "top_score": "string - e.g., '37/40'",
    "runner_ups": ["array of version strings"]
  },
  "consensus_elements": ["array of high-confidence elements from 6+ versions"],
  "key_decisions": ["array of synthesis decisions made"]
}
```

## Example

```json
{
  "agent_name": "agent-schema-architect",
  "created": "2025-11-22",
  "specification": {
    "scope": "Narrow: Schema Design",
    "depth": "Senior (Top 25%)",
    "function": "Generator",
    "risk_profile": "SQLite Advocate - defaults to SQLite, evidence-based exceptions",
    "context": "Team: Data Pipeline"
  },
  "workflow": {
    "method": "Parallel consensus",
    "iterations": 1,
    "final_verdict": "APPROVED"
  },
  "core_capabilities": [
    "Schema design from requirements",
    "Drizzle ORM configuration",
    "Query optimization for visualization",
    "Migration strategy",
    "SQLite advocacy with evidence-based exceptions"
  ],
  "key_expertise": [
    "SQLite internals (WAL, page cache, PRAGMAs)",
    "Drizzle ORM mastery",
    "Normalization judgment",
    "Index strategy for aggregations",
    "Visualization query patterns",
    "Data source integration"
  ],
  "success_metrics": [
    "90% queries <100ms on 10M rows",
    "15-minute schema comprehension",
    "Zero data loss, 95% migration success",
    "95% type safety coverage",
    "80% first-attempt unification success"
  ],
  "final_template": "agents/agent-schema-architect.md"
}
```

## File Naming Convention

**IMPORTANT**: Metadata filenames MUST match their markdown siblings exactly.

| Markdown File | Metadata File |
|---------------|---------------|
| `agents/agent-agentic-loop-architect.md` | `agents-metadata/agent-agentic-loop-architect.json` |
| `agents/agent-d3-custom-visualization-architect.md` | `agents-metadata/agent-d3-custom-visualization-architect.json` |

- **ALWAYS** use the `agent-` prefix (CLAUDE.md naming convention)
- **DO NOT** use `agents-consensus-` prefix in metadata filenames
- Metadata filename = markdown filename with `.json` instead of `.md`

## Directory Structure

**Final outputs** go in project root directories:
- `agents/` - Final approved agent templates (`.md`)
- `agents-metadata/` - Agent metadata files (`.json`)

**Working data** stays at project root:
- `.birth-working/[agent-name]/` - Recruiter versions, critic analysis, synthesis iterations (sandbox-safe for background Task subagents)

Working directories contain intermediate artifacts (facet drafts, critic feedback, validation reports). Like the templates themselves, they are **cleared on graduation** — git history is the archive (see the nursery model in CLAUDE.md).

## Validation

Before committing metadata:
- [ ] All required fields present
- [ ] Filename matches markdown sibling exactly (e.g., `foo.md` → `foo.json`)
- [ ] agent_name field matches filename (without `.json` suffix)
- [ ] specification has all 5 sub-fields
- [ ] Arrays have correct counts (capabilities: 3-5, expertise: 4-8, metrics/gates: 3-5)
- [ ] Consultative: metrics include specific numbers, not vague terms
- [ ] Operational: `archetype` is set and validation_gates are mechanically checkable
- [ ] final_template path is correct relative path
