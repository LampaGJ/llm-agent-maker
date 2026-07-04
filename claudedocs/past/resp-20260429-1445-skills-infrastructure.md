# Claude Skills Infrastructure Investigation

**Date**: 2026-04-29  
**Scope**: How skills work in Claude Code, agent-llm-skills-writer specifics, registration mechanism, skills vs commands vs agents

---

## 1. Claude Skills Basics

### What Skills Are

**Skills** are modular, reusable capabilities that extend Claude Code functionality. They are invoked via the `/skill-name` pattern and operate as system prompt enhancements — Claude matches user intent against the skill's `description` field and auto-invokes the skill when the description semantically matches the user's request.

### Registration Mechanism

Skills are registered and discoverable through:

1. **Frontmatter (YAML)** — Every skill has metadata:
   - `name`: Kebab-case identifier (max 64 chars)
   - `description`: One sentence describing when/why to invoke (max 1024 chars) — this is the semantic classifier
   - Other optional fields: `tools`, `model`, argument schemas

2. **File Location** — Skills live in `.claude/skills/` at the project or global level:
   - Project-level: `.claude/skills/agent-{name}/{skill-name}/SKILL.md`
   - Can also exist at `~/.claude/skills/` for global availability

3. **Invocation**: `/skill-name` command or auto-invocation when description matches user intent

4. **Progressive Disclosure**:
   - **Level 1** (Always): YAML frontmatter metadata (~100 tokens) — what Claude needs to decide if skill applies
   - **Level 2** (When triggered): SKILL.md body instructions (~1-5K tokens) — loaded when description matches
   - **Level 3** (On demand): Bundled files (WORKFLOWS.md, EXAMPLES.md, ANTI_PATTERNS.md, templates/) — loaded only when referenced, effectively zero token cost when unused

### The Description Field: Semantic Classifier

This is the most critical field. The `description` is NOT a human-readable summary; it is a semantic router that Claude uses to decide whether to invoke a skill.

**Well-engineered**: "Synthesizes SKILL.md artifacts from validated context packets without elicitation; emits BLOCKED reports on invalid input."
- Action-verb lead ("synthesizes")
- Domain-specific vocabulary ("context packets", "BLOCKED reports")
- Precise conditions (what happens when valid vs invalid)
- Distinguishes from adjacent capabilities

**Poorly engineered**: "Helps with skill file creation"
- Passive, vague
- Invokes too broadly (any skill creation question)
- Provides no semantic routing signal

### How `/skill-name` Invocation Works

1. User types `/skill-name` explicitly, OR
2. Claude reads user's message, semantically matches it against all available skill descriptions
3. When match confidence exceeds threshold: Skill triggers automatically
4. Skill's frontmatter + SKILL.md body loads into Claude's context
5. Skill executes per its instructions

---

## 2. agent-llm-skills-writer Specifics

### Position & Purpose

**Position Title**: Birth-Pipeline Skill Artifact Synthesizer

**Core Mission**: Ingest a validated 7-item context packet from the birth orchestrator and emit the full triad of non-interactive deliverables — SKILLS_SPEC-conformant SKILL.md files, `skills[]` metadata stanzas for the host agent's JSON record, and named-anchor capability-patch proposals — while producing structured BLOCKED reports when the packet fails validation and consolidation proposals when the existing skill inventory would otherwise accrue duplicates.

### What It Does (5 Capabilities)

1. **Validate the Context Packet** — Inspect all 7 items before producing any artifact:
   - (1) Finalized agent template
   - (2) Success metrics anchor
   - (3) Capabilities section with per-skill mapping
   - (4) Requested skill list with intent statements
   - (5) Target paths
   - (6) Existing skill inventory
   - (7) Non-interactive contract
   - Emit structured BLOCKED report (never clarifying questions) if validation fails

2. **Generate SKILL.md Artifacts** — Produce one SKILL.md per requested skill with:
   - 6 mandated sections: What/When/How/Examples/Common Mistakes/Reference
   - YAML description as semantic classifier (not prose summary)
   - Decomposition into WORKFLOWS.md, EXAMPLES.md, ANTI_PATTERNS.md, templates/ when ~150-line threshold + independent invocation paths justify splitting

3. **Splice Metadata Directly** — Read target metadata JSON, construct `skills[]` entry using ONLY 5 canonical fields:
   - `name`, `type`, `location`, `version`, `description`
   - Valid `type` values: `custom` (owned by this agent) or `shared-reference` (canonically owned by different agent)
   - Do NOT invent extra fields (pinned schema)
   - Splice directly via Edit tool (not standalone text in response)

4. **Propose Capability Patches (Additive Only)** — For each skill, draft single-sentence annotation to append to host agent's template:
   - Canonical format: `` Apply `skill-name` for <one-line purpose>. ``
   - Target capabilities by named anchor (bolded lead phrase), never by ordinal position
   - Forbidden: replacing, rewriting, splitting/merging capabilities, multi-sentence edits
   - If capability already names skill inline: report "already-linked", don't propose patch

5. **Detect & Propose Consolidation** — Cross-reference requested skills against existing inventory:
   - Identify semantic overlap (by comparing When-section trigger conditions, not just names)
   - Emit consolidation proposal naming candidate duplicate, incumbent skill, recommended resolution
   - Do this BEFORE generating artifact for conflicting skill

### Required Expertise

- **SKILLS_SPEC 6-section schema internalization**: Holds structure as checklist, catches violations like Examples duplicating How steps
- **Description-field semantic classifier engineering**: Writes descriptions with vocabulary/specificity that orchestrator's pattern-matcher encounters at call time
- **Progressive disclosure threshold judgment**: ~150-line heuristic is trigger for evaluation, not automatic split; weighs whether decomposed sections have independent invocation paths
- **Context-packet validation-before-generation discipline**: Treats 7-item packet as contract; knows failure taxonomy cold (missing fields, empty fields, internally consistent but contradictory to sibling fields)
- **Named-anchor cross-reference stability**: Uses named anchors not line numbers, because templates are living documents and positional references rot on first edit
- **Skill-inventory overlap detection**: Detects semantic near-duplicates by comparing When-section trigger conditions
- **BLOCKED-report authoring as structured refusal**: Writes reports with enough specificity for orchestrator to correct without re-running pipeline (exact field, observed value, expected type/constraint, blocking artifact)

### Success Metrics

- **Schema Conformance Rate**: ≥95% of generated SKILL.md files pass automated 6-section schema validation across minimum 50-artifact test set
- **BLOCKED Report Precision**: Correctly identifies specific failing field(s) in ≥90% of cases with zero false blocks on valid packets
- **Auto-Invocation Routing Precision**: SKILL.md descriptions + metadata stanzas route correctly when tested against 20-prompt harness per artifact; ≥0.88 threshold averaged across all artifacts
- **Consolidation Detection Coverage**: Surfaces consolidation proposal for ≥85% of seeded semantic-duplicate pairs while producing <10% false positives on genuinely distinct skills
- **Capability-Patch Stability**: Named-anchor patches remain structurally valid after template reordering/edits in ≥92% of cases in controlled edit-and-recheck cycle

### Input Formats & Context Packets

**Input**: Validated 7-item context packet from birth orchestrator (Phase 3.6 invocation):
1. Finalized agent template markdown
2. Success metrics anchor (reference section name)
3. Capabilities section with per-skill mapping (which skill supports which capability)
4. Requested skill list with intent statements (skill names + what they do)
5. Target paths (where to write SKILL.md and metadata JSON)
6. Existing skill inventory (skills that already exist in `.claude/skills/`)
7. Non-interactive contract (constraints, tool permissions, execution context)

**Output**:
- SKILL.md files written to `.claude/skills/{agent-name}/{skill-name}/SKILL.md`
- Optional bundled files: WORKFLOWS.md, EXAMPLES.md, ANTI_PATTERNS.md, templates/
- Metadata `skills[]` entries spliced directly into `agents-metadata/{agent-name}.json`
- Capability-patch proposals as list of `{capability-anchor, append-sentence}` pairs
- Consolidation proposals if semantic overlap detected
- BLOCKED reports if validation fails

### Known Limitations & Constraints

- **Non-interactive only**: Never asks clarifying questions, never elicits scope. Birth orchestrator is sole caller.
- **No runtime evolution**: Skills are finalized at generation time; no incremental refinement within same birth run
- **7-item packet contract is hard**: If packet invalid, stops cleanly with BLOCKED report rather than degrading
- **Shared skill ownership**: When multiple agents need same skill, only first agent to materialize it owns the `.claude/skills/` directory; others reference via `shared-reference` metadata type
- **No auto-merging**: When consolidation detected, agent generates NO artifact for conflicting skill; consolidation proposal must be resolved before skill materializes
- **Semantic matcher scope**: Only detects overlaps in existing inventory that birth orchestrator provides; doesn't scan entire `.claude/skills/` tree independently

### Comparison: claude-code-skills-writer

The `agent-claude-code-skills-writer` is the **interactive sibling** in Claude Code's skill infrastructure:

| Aspect | claude-code-skills-writer | agent-llm-skills-writer |
|--------|---------------------------|------------------------|
| **Caller** | Direct user or any Claude workflow | Birth orchestrator only |
| **Elicitation** | Asks 5-10 clarifying questions before writing | Zero elicitation; works from validated packet only |
| **Output** | Single SKILL.md + optional supporting files | SKILL.md + metadata splice + capability patches + consolidation proposals |
| **Invocation** | `/skills-writer "rough idea"` | Spawned as Task subagent by birth orchestrator in Phase 3.6 |
| **Error handling** | Graceful degradation, asks for clarification | Hard refusal via BLOCKED report |
| **Model** | Sonnet (focused on multi-turn dialogue) | Opus (higher capability for complex packet analysis) |
| **Tools** | Read, Write, Edit, Grep, Glob, Bash | Read, Write, Edit, Grep, Glob |

---

## 3. Registration Mechanism

### File Structure for Skills

Skills live at `.claude/skills/{agent-name}/{skill-name}/`:

```
.claude/skills/agent-llm-researcher/
├── brief-structure/
│   ├── SKILL.md                              (required)
│   ├── WORKFLOWS.md                          (optional)
│   ├── EXAMPLES.md                           (optional)
│   ├── ANTI_PATTERNS.md                      (optional)
│   └── templates/                            (optional)
│       ├── domain-brief-template.md
│       └── ...
├── vocabulary-extraction/
│   ├── SKILL.md
│   └── ...
└── primary-source-hierarchy/
    ├── SKILL.md
    └── ...
```

### Metadata Registration

Each agent's metadata JSON in `agents-metadata/agent-{name}.json` includes a `skills[]` array:

```json
{
  "name": "agent-creative-ideator",
  "version": "1.0.0",
  "skills": [
    {
      "name": "creative-ideation-workflow",
      "type": "custom",
      "location": ".claude/skills/agent-creative-ideator/creative-ideation-workflow/SKILL.md",
      "version": "1.0.0",
      "description": "Structured workflow for identifying novel capability combinations"
    },
    {
      "name": "anti-patterns-catalog",
      "type": "shared-reference",
      "location": ".claude/skills/agent-llm-critic/anti-patterns-catalog/SKILL.md",
      "version": "1.0.0",
      "description": "Shared anti-pattern catalog consulted by generation-side agents"
    }
  ],
  "skills_planned": [...]  // audit trail: what was planned vs materialized
}
```

**Five-field schema (PINNED — no extras allowed)**:
- `name`: Kebab-case identifier (must match SKILL.md frontmatter)
- `type`: `custom` or `shared-reference`
- `location`: Relative path to SKILL.md
- `version`: Semantic version
- `description`: One-line trigger phrase

### Shared Skills Convention

When multiple agents need the same skill:

1. **Canonical owner**: The FIRST agent whose Phase 3.6 invocation materializes the skill becomes the canonical owner
   - SKILL.md lives at `.claude/skills/{canonical-owner}/{skill-name}/SKILL.md`
2. **Referrers**: Other agents that need the same skill emit `skills[]` entry with `type: "shared-reference"`
   - Points to canonical owner's location (no copy)
3. **No shared/ namespace**: Shared skills live under their canonical owner's directory tree, not in `.claude/skills/shared/`

### How Claude Code Discovers Skills

1. **Agent template loads**: When Claude is invoked with an agent template as system prompt
2. **Metadata JSON loaded**: Claude Code reads `agents-metadata/{agent-name}.json` to discover available skills
3. **Skill descriptions indexed**: Description field becomes searchable semantic index
4. **Auto-invocation**: User message semantically matched against all skill descriptions; highest-confidence match triggers
5. **Skill content loaded**: SKILL.md body (and any referenced files) load into context
6. **Execution**: Skill runs per its instructions; bundled files load on-demand only when referenced

### Validation & Pre-Commit

**Phase 7 (Deploy) validation** (in `/birth`):
- YAML frontmatter presence and format
- `name`, `description`, `tools`, `model` fields required and correctly typed
- Rejects invalid files before writing to `agents/`

**Pre-commit hook** (in team repos):
- Validates all agent files before allowing commits
- Prevents invalid frontmatter from reaching version control

---

## 4. Skills vs Commands vs Agents

### Clarification: Three Distinct Concepts

#### **Agents** (`agents/agent-{name}.md`)
- 7-section templates that define an LLM persona/role
- Used as system prompts to activate specialized behavior
- Spawned as Task subagents via `/birth`, invoked via `/consult {agent-name}`, or used as system context
- Examples: `agent-llm-recruiter.md`, `agent-llm-critic.md`, `agent-snapstream-marketing-copywriter.md`

#### **Skills** (`.claude/skills/{agent-name}/{skill-name}/SKILL.md`)
- Modular procedural knowledge, workflows, reference materials, decision trees
- Bundle domain-specific expertise alongside agent templates via progressive disclosure
- Auto-invoked when description matches user intent, or via `/skill-name` explicitly
- Optional enhancement to agent templates (Tier 3-4 agents especially)
- Examples: `brief-structure`, `anti-patterns-catalog`, `creative-ideation-workflow`

#### **Commands** (`.claude/commands/{name}.md` or in frontmatter as `/slash-commands`)
- Interactive workflows that ask clarifying questions, make decisions, guide user through multi-step processes
- Tied to Claude Code harness directly (not general agent templates)
- Examples: `/birth`, `/rebirth`, `/recruit`, `/consult`, `/loop`, `/schedule`

### When to Use Each

| Use Case | Agent | Skill | Command |
|----------|-------|--------|---------|
| **Activate LLM expertise in a domain** | ✅ Agent template | — | — |
| **Encode procedural knowledge alongside agent** | Agent (template) | ✅ Skill (enhancement) | — |
| **Provide decision trees, anti-patterns, workflows** | — | ✅ Skill | — |
| **Bundle reference materials (APIs, style guides, examples)** | — | ✅ Skill | — |
| **Build interactive user-driven workflow** | — | — | ✅ Command |
| **Create orchestration that spawns subagents** | ✅ Agent (can coordinate) | — | ✅ Command (better for user-facing) |

### Invocation Patterns

**Agents**:
- Direct system prompt: `You are {agent template}.` (when used as context)
- Subagent spawn: `Task(role: agent-llm-recruiter)`
- Persona mode: `/consult agent-llm-recruiter "question"`

**Skills**:
- Explicit: `/skill-name "input"`
- Auto-invocation: User message matches description; Claude invokes automatically
- Nested in agents: Agent template can instruct "apply `skill-name` for X"

**Commands**:
- Explicit slash: `/birth "Spec: ..."`, `/loop`, `/schedule`
- Plugin ecosystem: Registered in Claude Code plugin system

---

## 5. The /birth Workflow and Skills Integration

### Phase 3.5 — Skills Definition

After template generation completes (Phase 3), `/birth` asks:

```
Does this agent need custom skills?

Options:
- No skills (agent template only)
- 1 skill (e.g., core workflow)
- Multiple skills (e.g., workflow + reference + anti-patterns)
```

User response determines whether Phase 3.6 executes.

### Phase 3.6 — Skills Generation

If user answers "yes":

```
For each skill needed:
  Skill Generator Subagent (agent-llm-skills-writer)
  ├── Input: Agent template + skill requirements
  ├── Output: SKILL.md + bundled files + metadata stanza
  └── Write to: .claude/skills/{agent-name}/{skill-name}/SKILL.md
```

Produces:
- **SKILL.md** (required): Metadata + 6-section core instructions
- **WORKFLOWS.md** (if applicable): Detailed step-by-step procedures
- **EXAMPLES.md** (if applicable): Concrete input/output examples
- **ANTI_PATTERNS.md** (if applicable): What NOT to do and why
- **templates/** (if applicable): Reference boilerplate, schema examples

### Phase 7 — Deploy (Enhanced)

After final template approval:

1. **Write agent template** to `agents/agent-[name].md`
2. **Write each skill** to `.claude/skills/[agent-name]/[skill-name]/SKILL.md` (+ bundled files)
3. **Register skills in metadata** JSON with 5-field canonical shape
4. **List skills in deployment summary**

---

## 6. Practical Examples

### Example 1: Skill Within Birth Workflow

**Agent**: `agent-d3-charting-expert`  
**Skills needed**: Yes (Tier 3)

Phase 3.6 generates:
```
.claude/skills/agent-d3-charting-expert/
├── legibility-decision-tree/
│   └── SKILL.md (180 lines) → decompose to WORKFLOWS.md
├── chart-junk-antipatterns/
│   └── SKILL.md (120 lines) → inline, no decomposition needed
└── usatodaydesign-conventions/
    ├── SKILL.md (200 lines) → decompose to EXAMPLES.md
    └── templates/
        ├── responsive-container.html
        └── color-palette-2026.json
```

Metadata splice into `agents-metadata/agent-d3-charting-expert.json`:
```json
"skills": [
  {
    "name": "legibility-decision-tree",
    "type": "custom",
    "location": ".claude/skills/agent-d3-charting-expert/legibility-decision-tree/SKILL.md",
    "version": "1.0.0",
    "description": "Decision framework for chart type selection based on data structure and audience literacy"
  },
  {
    "name": "chart-junk-antipatterns",
    "type": "custom",
    "location": ".claude/skills/agent-d3-charting-expert/chart-junk-antipatterns/SKILL.md",
    "version": "1.0.0",
    "description": "Antipattern detection and refusal protocol for 3D, dual-axis, and pie-chart requests"
  },
  ...
]
```

Capability patch in template:
```markdown
**Design D3 visualizations for mass-audience clarity** — charts that encode truth 
precisely, render legibly at mobile viewport widths, survive colorblind perception, 
and never sacrifice accuracy for novelty.

Apply `legibility-decision-tree` for deciding chart type from data shape.
Apply `chart-junk-antipatterns` for recognizing and rejecting anti-patterns.
```

### Example 2: Shared Skill

**Scenario**: `agent-llm-critic` owns `anti-patterns-catalog` (materialize first), then `agent-llm-recruiter` references same skill.

**Critic's metadata**:
```json
"skills": [
  {
    "name": "anti-patterns-catalog",
    "type": "custom",
    "location": ".claude/skills/agent-llm-critic/anti-patterns-catalog/SKILL.md",
    "version": "1.0.0",
    "description": "Canonical anti-pattern taxonomy for agent template detection"
  }
]
```

**Recruiter's metadata** (referencing, not owning):
```json
"skills": [
  {
    "name": "anti-patterns-catalog",
    "type": "shared-reference",
    "location": ".claude/skills/agent-llm-critic/anti-patterns-catalog/SKILL.md",
    "version": "1.0.0",
    "description": "Shared anti-pattern catalog consulted during generation"
  }
]
```

No duplicate SKILL.md; both point to canonical owner's location.

---

## 7. The Registration Gap (Your Situation)

When a skill exists as documentation but `/skill-name` doesn't execute:

**Most likely cause**: Metadata registration missing or misconfigured

**Checklist**:

1. ✅ **Skill file exists**: `.claude/skills/{agent-name}/{skill-name}/SKILL.md` present and readable
2. ✅ **YAML frontmatter valid**:
   - `name: {kebab-case-id}` (max 64 chars)
   - `description: {One sentence, 1-1024 chars, action-verb lead}` (critical!)
   - No prohibited fields (anthropic, claude, XML tags)
3. ✅ **Metadata JSON entry present**: `agents-metadata/{agent-name}.json` contains `skills[]` entry with:
   - Name matching SKILL.md frontmatter `name` field
   - Type (`custom` or `shared-reference`)
   - Location pointing to correct `.claude/skills/` path
   - Version string
   - Description field (the semantic classifier)
4. ✅ **Agent is active**: Agent template itself is loaded in Claude Code context (either as system prompt or via `/consult`)
5. ✅ **Description is precise**: Does the description match language a user would actually type? Test against 5 realistic invocation scenarios.

**If step 3 fails** (metadata missing): That's the registration gap. Add the `skills[]` array entry to metadata JSON, and `/skill-name` will activate.

---

## Key Takeaways

1. **Skills are semantic routers**: The `description` field is not for humans; it's Claude's invocation trigger.
2. **Three-layer framework**: Agent templates (personas) + skills (workflows/reference) + commands (interactive workflows).
3. **Progressive disclosure saves tokens**: Only load content when needed; bundled files cost zero tokens until referenced.
4. **Non-interactive synthesis**: `agent-llm-skills-writer` treats context packets as contracts, never asks questions, emits structured BLOCKED reports on failures.
5. **Metadata is the registry**: Skills can exist as files, but they're only discoverable if registered in `agents-metadata/{agent-name}.json` with proper 5-field schema.
6. **Shared skills under canonical owner**: Avoid forking; shared skills live in canonical owner's directory, with referrers pointing via `shared-reference` metadata type.
7. **SKILLS_SPEC conformance**: 6-section schema (What/When/How/Examples/Common Mistakes/Reference) enforced at generation time; decomposition decision at ~150-line threshold weighted by invocation paths.
