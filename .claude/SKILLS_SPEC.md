# Agent Skills Specification

**Authority**: Anthropic Agent Skills API + Claude Code Skills  
**Last Updated**: 2026-04-10  
**Scope**: Optional enhancement for agent templates via `/birth` and `/rebirth`

---

## Overview

Agent Skills are **modular, reusable capabilities** that extend agent functionality beyond what's in the agent template itself. They package domain-specific expertise, workflows, and reference materials that Claude loads on-demand (progressive disclosure).

**Key distinction from agent templates**:
- **Agent templates** (`agents/agent-{name}.md`): Define the agent's identity, mission, expertise, and metrics
- **Agent skills** (`.claude/skills/agent-{name}/SKILL.md`): Define domain-specific workflows, reference materials, and procedural knowledge

---

## When to Create Skills

Create skills when an agent needs:

| Scenario | Example | Skill Type |
|----------|---------|-----------|
| **Workflow documentation** | Step-by-step procedures for complex tasks | Instructional |
| **Reference materials** | API docs, schema definitions, style guides | Reference |
| **Decision trees** | Diagnostic flowcharts, troubleshooting guides | Procedural |
| **Code templates** | Reusable boilerplate, configuration examples | Template |
| **Best practices** | Canonized approaches, anti-patterns, gotchas | Guidance |

**Don't create skills for**:
- Core agent identity (that's the template)
- General capabilities (those are in "What You'll Do")
- One-off tasks (inline in system prompt)

---

## Skill Structure

Every custom skill requires a `SKILL.md` file in `.claude/skills/{agent-name}/`:

```
.claude/skills/agent-creative-ideator/
├── SKILL.md                          # Required: metadata + core instructions
├── WORKFLOWS.md                      # Optional: detailed procedures
├── EXAMPLES.md                       # Optional: concrete examples
├── ANTI_PATTERNS.md                  # Optional: what NOT to do
└── templates/                        # Optional: reference templates
    ├── app-canvas.md
    └── integration-checklist.md
```

---

## SKILL.md Format

Every skill MUST have a `SKILL.md` with YAML frontmatter:

```yaml
---
name: skill-name
description: One sentence describing what this skill does and when to use it
---

# Skill Display Name

## What This Skill Does

[1-2 paragraph overview of the skill's purpose and scope]

## When to Use This Skill

[Decision criteria for when Claude should invoke this skill]

## How to Use This Skill

### Quick Start
[5-minute walkthrough for the most common use case]

### Advanced Usage
[Additional capabilities and edge cases]

## Examples

### Example 1: [Concrete Scenario]
[Step-by-step example with expected output]

### Example 2: [Different Scenario]
[Contrasting example showing different path through the skill]

## Common Mistakes

[Anti-patterns to avoid and what to do instead]

## Reference

[Links to additional files: WORKFLOWS.md, EXAMPLES.md, etc.]
```

---

## YAML Frontmatter Requirements

### `name` (REQUIRED)

**Format**: Kebab-case, max 64 characters  
**Pattern**: `^[a-z0-9\-]{1,64}$`  
**Examples**:
- ✅ `creative-ideation-workflow`
- ✅ `api-design-process`
- ❌ `Skill_Name` (mixed case)
- ❌ `this-is-a-really-long-skill-name-that-exceeds-the-character-limit` (>64 chars)

**Rules**:
- Cannot contain "anthropic" or "claude"
- Cannot contain XML tags
- MUST be unique within the agent's skill directory

### `description` (REQUIRED)

**Format**: One complete sentence, max 1024 characters

**Purpose**: Tells Claude when and why to use this skill

**Examples** (✅ Good):
- "Multi-capability integration workflow that maps capability synergies, identifies failure modes, and produces API contracts"
- "Structured diagnostic checklist for browser test failures with token-budgeted formatting and error taxonomy"

**Anti-patterns** (❌ Bad):
- "Useful information" (vague, no trigger)
- "This skill contains workflows" (describes itself, not usage)
- "Help with X" (passive, vague)

**Template**: 
> "Do X when you need to [decision criterion]. Produces [output type] that [downstream consumer] can use for [specific purpose]."

---

## Bundled File Patterns

Skills can include additional files that Claude loads on-demand:

### WORKFLOWS.md
Detailed step-by-step procedures for multi-step tasks

```markdown
# Detailed Workflows

## Workflow 1: [Task Name]

1. **Phase A** — [What to do]
   - Sub-step 1
   - Sub-step 2
2. **Phase B** — [Next action]
   - Sub-step 3

## Workflow 2: [Different Task]

[Alternative procedure]
```

### EXAMPLES.md
Concrete examples with input/output

```markdown
# Examples

## Example 1: [Specific Scenario]

**Input**: [User request or artifact]

**Process**:
- Step 1
- Step 2

**Output**: [Expected result]

**Key decision**: Why this approach?

## Example 2: [Contrasting Scenario]

[Alternative example showing different branch]
```

### ANTI_PATTERNS.md
What NOT to do and why

```markdown
# Common Mistakes

## ❌ Mistake 1: [Wrong Approach]

**Why it fails**: [Reason]

**Correct approach**: [Right way]

## ❌ Mistake 2: [Another Error]

[Explanation and fix]
```

### templates/
Reference templates and boilerplate

```
templates/
├── integration-checklist.md     # Checklist template
├── api-contract.yaml           # Example API spec
└── data-model.sql              # Schema template
```

Claude loads these files only when referenced in instructions, keeping token cost low.

---

## Registering Skills with Agents

Link skills in metadata file `agents-metadata/agent-{name}.json`:

```json
{
  "name": "agent-creative-ideator",
  "version": "1.0.0",
  "skills": [
    {
      "name": "creative-ideation-workflow",
      "type": "custom",
      "location": ".claude/skills/agent-creative-ideator/SKILL.md",
      "version": "1.0.0",
      "description": "Structured workflow for identifying novel capability combinations"
    }
  ],
  "consuming_agents": ["agentic-loop-architect"],
  "workflow": { ... }
}
```

**Fields** (canonical 5-field shape — do NOT add extras):
- `name`: Skill identifier (must match SKILL.md frontmatter)
- `type`: `custom` (owned by this agent) OR `shared-reference` (canonically owned by a different agent — see Shared Skills below)
- `location`: Path to SKILL.md relative to project root
- `version`: Semantic version of skill
- `description`: One-line summary (the semantic-classifier invocation trigger)

The Phase 3.6 skills-writer enforces this shape at generation time. Inventing extras (`path`, `owner`, `mode`, `usage_mode`, `shared`, `canonical_owner`, `backs_capability`, `binds_to_*`, `supports_*`, `aligned_metrics`, `bundle_files`, etc.) is forbidden — these cluttered the first skills-writer runs and each had to be normalized back out during metadata splicing.

---

## Shared Skills

Some skills serve multiple agents (e.g., `anti-patterns-catalog` is consulted by `agent-llm-critic` at detection time and by `agent-llm-recruiter` at generation time). Shared skills require a convention to avoid forking the artifact across agents.

### Canonical owner

**Rule**: The canonical owner of a shared skill is the FIRST agent whose Phase 3.6 invocation materializes it. The SKILL.md lives in that owner's skills directory:

```
.claude/skills/agent-llm-<canonical-owner>/<skill-name>/SKILL.md
```

Subsequent agents that need the same skill reference it WITHOUT forking. No `.claude/skills/shared/` namespace exists — shared skills live under their canonical owner's directory tree.

### Metadata on referrers

Referrer agents (non-owners) emit a `skills[]` entry pointing to the canonical path with `type: "shared-reference"`:

```json
{
  "name": "anti-patterns-catalog",
  "type": "shared-reference",
  "location": ".claude/skills/agent-llm-critic/anti-patterns-catalog/SKILL.md",
  "version": "1.0.0",
  "description": "Shared catalog consulted generation-side by this agent."
}
```

The owner's `skills[]` entry uses `type: "custom"` with the same `location`.

### Phase 3.6 handling

When the Phase 3.6 context packet Item 6 (Existing Skill Inventory) includes an incoming skill that semantically overlaps an already-registered skill, the `agent-llm-skills-writer`:

1. Emits a **consolidation proposal** instead of generating a duplicate SKILL.md
2. Produces only the referrer's metadata `skills[]` entry with `type: "shared-reference"` and the canonical owner's `location`
3. Proposes the referrer's capability patch with the same `Apply \`<skill-name>\` for <purpose>.` format

### Examples

| Shared skill | Canonical owner | Referrers |
|---|---|---|
| `anti-patterns-catalog` | `agent-llm-critic` (detection-side consumer; first to materialize it) | `agent-llm-recruiter` (generation-side consumer) |

Future shared skills follow the same pattern. If in doubt about which agent should canonically own a skill, pick the one whose Phase 3.6 runs FIRST in the birth-ordering sequence.

---

## Progressive Disclosure: Loading Strategy

Skills use **progressive disclosure** — Claude loads content in stages:

### Level 1: Metadata (Always)
```yaml
---
name: creative-ideation-workflow
description: Workflow for identifying novel capability combinations and designing integration architectures
---
```
**Token cost**: ~100 tokens (always loaded, shown in agent discovery)

### Level 2: SKILL.md Body (When Triggered)
When Claude matches the skill description to a task, the main instructions load:

```markdown
# Creative Ideation Workflow

## What This Skill Does
[Overview of workflow]

## When to Use This Skill
[Trigger criteria]

## How to Use This Skill
[Core instructions]
```
**Token cost**: Typically 1-5K tokens (loaded once per session when needed)

### Level 3: Bundled Files (As Needed)
Additional files load only when referenced:

```markdown
See [WORKFLOWS.md](WORKFLOWS.md) for detailed multi-step procedures.
See [EXAMPLES.md](EXAMPLES.md) for concrete examples.
```

Bundled files execute via bash without loading content into context, so large datasets, code, and reference materials have effectively zero token cost when not used.

---

## `/birth` Workflow Enhancement

When `/birth` generates an agent template (Phase 7 - Deploy):

### Phase 3.5: Skills Definition (Tier 2+, Optional)

After Phase 3 (Generation) completes, ask:

```
Does this agent need custom skills?

Options:
- No skills (agent template only)
- 1 skill (e.g., core workflow)
- Multiple skills (e.g., workflow + reference materials + anti-patterns)
```

If YES → Proceed to Phase 3.6

### Phase 3.6: Skills Generation (Tier 2+, if triggered)

For each skill needed:

```
Skill Generator Subagent
├── Input: Agent template + skill requirements
├── Output: SKILL.md with bundled files
└── Write to: .claude/skills/{agent-name}/{skill-name}/SKILL.md
```

Skills generator produces:
- **SKILL.md** (required): Metadata + core instructions
- **WORKFLOWS.md** (if applicable): Detailed procedures
- **EXAMPLES.md** (if applicable): Concrete examples
- **ANTI_PATTERNS.md** (if applicable): What NOT to do
- **templates/** (if applicable): Reference materials

### Phase 7: Deploy (Enhanced)

After writing agent template and metadata, **also**:

1. Write each skill's SKILL.md to `.claude/skills/{agent-name}/`
2. Register skills in metadata JSON:
   ```json
   "skills": [
     {
       "name": "workflow-name",
       "type": "custom",
       "location": ".claude/skills/...",
       "version": "1.0.0"
     }
   ]
   ```
3. List skills in deployment summary

---

## Skills for Different Agent Tiers

| Tier | Skills Recommended | Why |
|------|---|---|
| **Tier 1 (Quick)** | Optional | Simple agents rarely need them |
| **Tier 2 (Standard)** | Optional | Add if agent has procedures/workflows |
| **Tier 3 (Deep)** | Recommended | Domain-specific expertise benefits from skills |
| **Tier 4 (Expert)** | Strongly recommended | Safety-critical agents need reference materials |

---

## Security Considerations

⚠️ **Skills are powerful** — they provide Claude with executable code and filesystem access.

**Security rules**:
- ✅ **Author internally**: Create only skills you or your team authored
- ✅ **Audit bundled code**: Review any scripts in `templates/`
- ✅ **Scope narrowly**: Skills should be focused on specific domain, not general-purpose
- ✅ **Document decisions**: Anti-pattern sections should explain security/safety considerations

❌ **Never**:
- Use skills from untrusted external sources
- Bundle malicious code disguised as templates
- Use skills to access sensitive data without explicit authorization

---

## Examples

### Example 1: Minimal Skill (Instructional)
```
.claude/skills/agent-creative-ideator/
└── SKILL.md (450 lines)
    ├── What This Skill Does
    ├── When to Use This Skill
    ├── How to Use This Skill (Quick Start + Advanced)
    ├── Examples (2-3 concrete scenarios)
    └── Common Mistakes
```

### Example 2: Multi-File Skill (Reference + Procedures)
```
.claude/skills/agent-playwright-testing/
├── SKILL.md (200 lines)
│   ├── Core workflow overview
│   └── Reference to bundled materials
├── WORKFLOWS.md (500 lines)
│   ├── Diagnostic workflow
│   ├── Token budget enforcement workflow
│   └── Error taxonomy application workflow
├── ANTI_PATTERNS.md (300 lines)
│   ├── Why NOT to use page.content()
│   ├── Why NOT to use page.waitForLoadState()
│   └── Why NOT to embed full trace files inline
└── templates/
    └── error-taxonomy.md (reference taxonomy)
```

### Example 3: Reference Material Skill (API Documentation)
```
.claude/skills/agent-api-architect/
├── SKILL.md (150 lines)
│   └── "See bundled API reference"
└── docs/
    ├── openapi-3.1-specification.md
    ├── rest-api-design-principles.md
    ├── security-patterns.md
    └── examples/
        ├── basic-crud.yaml
        └── pagination.yaml
```

Claude loads SKILL.md (~1K tokens), then reads specific docs on-demand when designing APIs.

---

## Checklist: Creating a New Skill

Before /birth generates a skill:

- [ ] **Scope is narrow**: Skill covers one workflow or one reference domain
- [ ] **Trigger is clear**: `description` field explains when Claude uses this skill
- [ ] **Content is organized**: SKILL.md + bundled files follow the pattern
- [ ] **Files are complete**: SKILL.md doesn't reference missing files
- [ ] **No secrets**: No API keys, passwords, or sensitive data bundled
- [ ] **Examples are concrete**: EXAMPLES.md has real input/output
- [ ] **Anti-patterns are explained**: Why each wrong approach fails
- [ ] **Metadata is registered**: Skill is listed in agent's `agents-metadata/{agent-name}.json`

---

## Anthropic Authority

This specification is derived from:
- [Anthropic Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Agent Skills with Managed Agents](https://platform.claude.com/docs/en/managed-agents/skills)
- [Skills Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
