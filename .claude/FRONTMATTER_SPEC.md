# Agent Frontmatter Specification

**Authority**: Anthropic Managed Agents API + Claude Code Agent SDK  
**Last Updated**: 2026-04-10  
**Status**: Authoritative for all agent templates

---

## Required Fields

Every agent template (`.md` file in `agents/`) MUST have these four fields in YAML frontmatter:

```yaml
---
name: [kebab-case-identifier]
description: [One transformative sentence describing the agent's mission]
tools: [Comma-separated list of available tools]
model: [sonnet|opus|haiku]
---
```

---

## Field Specifications

### `name` (REQUIRED)

**Format**: Kebab-case (lowercase letters, digits, hyphens only)  
**Pattern**: `^[a-z0-9\-]+$`  
**Examples**:
- ✅ `agent-creative-ideator`
- ✅ `agent-code-reverse-engineer-analyst`
- ❌ `agent_creative_ideator` (snake_case)
- ❌ `Agent-Creative-Ideator` (mixed case)

**Purpose**: Machine-readable identifier used by Claude Code for agent selection.

**Rules**:
- MUST start with `agent-` prefix (unless core framework agents like `llm-recruiter`, `llm-critic`)
- MUST be globally unique across `agents/` and subdirectories
- Used in metadata filenames: `agent-{name}.md` ↔ `agent-{name}.json`

---

### `description` (REQUIRED)

**Format**: One complete, transformative sentence  
**Max length**: ~150 characters (fits in one line; ~30 words typical)

**Purpose**: Machine-readable summary of what the agent does. Same as Core Mission section.

**Examples** (✅ Good):
- "Transform bloated browser state into token-budgeted diagnostic payloads for LLM-driven test debugging."
- "Generate novel multi-capability app ideas with high-temperature creativity and belief in user proposals."
- "Reverse-engineer architecture from tangled codebases to diagnose technical debt and prescribe fixes."

**Anti-patterns** (❌ Bad):
- "Helps with code reviews" (vague, transactional)
- "Expert in testing and quality assurance" (generic, no transformation)
- "Does A, B, C, and D and also E" (lists, not sentences; too long)

**Mechanical check**: Fits on one line in terminal (80-150 chars), reads as one complete thought.

---

### `tools` (REQUIRED)

**Format**: Comma-separated string (NOT YAML array)

**Correct**:
```yaml
tools: Read, Write, Edit, Bash, Grep
```

**Incorrect** (YAML array format):
```yaml
tools:
  - Read
  - Write
  - Edit
```

**Tool Categories** (per AGENT_FRAMEWORK.md):

| Use Case | Tool Set |
|----------|----------|
| Read-only analysis | `Read, Grep, Glob` |
| Code modification | `Read, Edit, MultiEdit, Grep, Write, Bash` |
| Full access | `Read, Edit, MultiEdit, Grep, Glob, Write, Bash` |
| Web research | `WebSearch, WebFetch` |
| Minimal tools | `WebSearch, WebFetch, Bash` |

**Special MCP Tools** (claude-code-style references):
- ✅ `mcp__sequential-thinking__sequentialthinking` (Sequential MCP)
- ✅ `mcp__claude_ai_HubSpot__search_crm_objects` (HubSpot MCP)
- NOT RECOMMENDED: Complex MCP tool names in comma-separated string; document separately in metadata

**Validation**: Every tool listed MUST exist in Claude Code's available tool set.

---

### `model` (REQUIRED)

**Format**: One of three values (lowercase)
- `sonnet` — Claude 3.5 Sonnet (default; balanced speed/capability)
- `opus` — Claude Opus 4.6 (highest capability; slowest)
- `haiku` — Claude 3.5 Haiku (fastest; lowest capability)

**Examples**:
```yaml
model: sonnet        # ✅ Default choice for most agents
model: opus          # ✅ For complex reasoning (deep analysis, multi-step)
model: haiku         # ✅ For simple/fast tasks
model: claude-opus   # ❌ Wrong: use short form only
model: sonnet-4      # ❌ Wrong: use short form only
```

**When to Use Each**:
- **`sonnet`** (default): General-purpose, balanced, good for complex reasoning without extreme slowness
- **`opus`**: Safety-critical analysis, architectural design, multi-domain synthesis, expert-level work
- **`haiku`**: Formatting, simple parsing, lightweight routing, prototyping

---

## Optional Fields

Teams may add these for metadata/tracking, but they are NOT part of the core frontmatter spec:

```yaml
---
name: agent-example
description: ...
tools: ...
model: sonnet
# Optional fields below:
category: backend        # Organizational category
version: 1.0.0          # Semantic version
created: 2026-04-10     # ISO date of creation
keywords: [kw1, kw2]    # Search tags
---
```

**Note**: These do NOT appear in `AGENT_FRAMEWORK.md`'s required list. Only use if your project has custom versioning needs. Prefer metadata files (`.json`) for non-core tracking.

---

## Mechanical Validation Checklist

Use this before committing any agent template:

- [ ] Line 1 is exactly `---`
- [ ] `name:` field present and kebab-case (matches `agent-[name]` filename)
- [ ] `description:` field present (one transformative sentence, 80-150 chars)
- [ ] `tools:` field present as **comma-separated string** (not array)
- [ ] `model:` field present and is one of `sonnet`, `opus`, `haiku`
- [ ] Line after `model:` is exactly `---` (closes frontmatter)
- [ ] No extra fields between core fields (optional fields are fine, but keep to standard)
- [ ] Content section starts AFTER closing `---` (no blank lines between `---` and first section)

---

## Examples

### Example 1: Minimal Correct Format
```yaml
---
name: agent-simple-formatter
description: Format code and text according to specified style conventions.
tools: Read, Write, Edit, Bash
model: haiku
---

# Simple Formatter

## Core Mission

...
```

### Example 2: Full Format with Optional Metadata
```yaml
---
name: agent-creative-ideator
description: Generate novel multi-capability app ideas with high-temperature creativity and belief in user proposals.
tools: WebSearch, WebFetch, Bash
model: sonnet
category: ideation
keywords: [ideation, synthesis, creativity, brainstorming]
---

## Position: Creative Ideator

...
```

### Example 3: Complex Tools List
```yaml
---
name: agent-playwright-llm-testing-architect
description: Transform bloated browser state into token-budgeted diagnostic payloads for LLM-driven test debugging.
tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash, WebSearch, WebFetch
model: sonnet
---

## Position: Playwright LLM Testing Architect

...
```

---

## Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|---|---|
| `name: Agent-Name` | Mixed case; not kebab-case | Use `agent-name` |
| `description: "word word word..."` (too long) | Doesn't fit one line; unclear | One sentence, ~30 words max |
| YAML array for tools | Violates spec; breaks parsing | Use comma-separated string |
| `model: claude-opus-4.6` | Full model ID; not short form | Use `opus` |
| Missing `description` field | Breaks discovery/selection | Add one-sentence mission |
| Extra blank lines after `---` | Content structure breaks | Keep tight: `---` → field → `---` |

---

## `/birth` and `/rebirth` Validation Requirements

**Phase 7 (Deploy)** of `/birth` workflow must:

1. **Pre-flight validation** (before writing to `agents/`):
   - Verify all 4 required fields present
   - Validate `name:` matches filename
   - Validate `tools:` is comma-separated string (not array)
   - Validate `model:` is one of `[sonnet, opus, haiku]`
   - Validate `description:` is single sentence, <150 chars

2. **Reject and escalate** if validation fails:
   - Do NOT write file to `agents/`
   - Report specific validation failures
   - Suggest corrections
   - Ask user to retry or fix spec

3. **Generate metadata** with workflow stats:
   - Include `frontmatter_validated_at: <timestamp>`
   - Include validation pass/fail status

---

## Anthropic Authority

This specification is derived from:
- [Anthropic Managed Agents API Docs](https://platform.claude.com/docs/en/managed-agents/agent-setup) — required fields
- [Claude Agent SDK Docs](https://code.claude.com/docs/en/agent-sdk/overview) — tool ecosystem
- Project's own `.claude/AGENT_FRAMEWORK.md` — 7-section template structure

**Deviations from Anthropic spec**:
- Tools format: Anthropic uses JSON arrays in API; Claude Code agents use comma-separated strings (for simplicity in markdown)
- Model field: Anthropic accepts full model IDs; this spec enforces short form (`sonnet`, `opus`, `haiku`)
