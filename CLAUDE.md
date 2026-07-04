# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **agent nursery** — where specialized LLM agent templates are *born, iterated, and graduated*. It distills domain expertise into cognitive architectures through parallel consensus, then promotes the finished agent to where it actually runs.

### The nursery model (read this first)

This repo is a birthplace, not a permanent home. Agents gestate here; their grown selves live elsewhere.

- **Gestation is git-tracked.** Every iteration of an agent-in-progress is captured in git history. Git — not the working tree — is the durable archive. Nothing born here is ever truly lost.
- **The grown self lives at user (or project) level.** A finished agent is promoted to `~/.claude/agents/agent-[name].md` (or a project's `.claude/agents/`). That is the live, authoritative copy.
- **On conflict, the grown self wins.** If a user-level agent and its nursery ancestor disagree, the user-level (promoted) version is authoritative — it is the more-mature descendant. Pull *from* user level when reconciling, don't overwrite it.
- **Production files are discarded once promoted.** After an agent graduates, its `agents/*.md` + `agents-metadata/*.json` in the nursery are disposable — `git rm` them; history preserves the lineage. The working tree holds only agents currently in gestation.
- **Recruitment is gated on metadata.** An agent is *not certified as recruited* until its `agents-metadata/<name>.json` exists and validates against `.claude/METADATA_SCHEMA.md`. `recruit.sh` enforces this via `scripts/validate-metadata.mjs` and blocks promotion of any agent with missing/incomplete metadata.

The *machinery* (`/birth`, `/recruit`, `/rebirth`, `/forming`, `/consult`) lives as **user-level** skills/commands in `~/.claude/` — see "Commands" below. This repo supplies the framework docs those commands read, the birthing workspace they write to, and the recruitment gate they must honor.

### Repository topology — two remotes, two roles

- `origin` → **github.com/LampaGJ/llm-agent-maker-archive** (PRIVATE). Full development history — the durable archive the nursery model depends on. All day-to-day work, branches, and graduation commits go here.
- `public` → **github.com/LampaGJ/llm-agent-maker** (PUBLIC, MIT). Fresh-history snapshots only. Its `main` descends from the local orphan branch `public-main`, which shares **no history** with `master`.

**Never push `master` (or any archive branch) to `public`.** That would publish the entire private history, including business-specific gestation artifacts. To publish an update, snapshot the current tree onto the orphan branch:

```bash
git checkout public-main
git checkout master -- .
git commit -m "Publish: <what changed>"
git push public public-main:main
git checkout master
```

## Architecture

### Core Components

**Pipeline Agents** (in `.claude/agents/`):
- `agent-llm-spec-refiner.md` - Converts axis-ambiguous specs into Phase 1-ready Refined Specifications
- `agent-llm-researcher.md` - Produces primary-source-grounded Domain Briefs (Tier 3+)
- `agent-llm-recruiter.md` - Generates templates under facet-mode contracts
- `agent-llm-critic.md` - Audits drafts against structural, semantic, and 2026-discipline rubrics
- `agent-llm-validator.md` - Derives test plans from Success Metrics and judges runtime outputs
- `agent-llm-skills-writer.md` - Synthesizes agent-owned SKILL.md artifacts from birth-pipeline context
- `agent-team-maker.md` - Analyzes requests and composes agent teams

**Framework Documentation** (in `.claude/`):
- `BIRTH_ARCHITECTURE.md` - The v2 tiered pipeline: why it replaced parallel consensus, phase-by-phase hardening history
- `TIER_CALIBRATION.md` - Canonical tier table (Quick / Standard / Deep / Expert) and validation intensities
- `AGENT_FRAMEWORK.md` - Template structure, validation checklist, workflow phases
- `SPEC_REFINEMENT.md` - The 5 clarifying questions (scope, depth, function, risk, context)
- `METADATA_SCHEMA.md` - Registry schema the recruitment gate enforces
- `SKILLS_SPEC.md` / `FRONTMATTER_SPEC.md` - Agent-owned skill structure; required template frontmatter
- `WORKFLOW.md`, `QUICK_START.md`, `SYSTEM_OVERVIEW.md`, `INTEGRATION.md` - Orientation and legacy workflow docs

### Workflow Phases (Birth v2 — tiered)

`/birth` auto-classifies each request into one of four tiers (Quick / Standard / Deep / Expert) and calibrates effort accordingly — see `.claude/TIER_CALIBRATION.md`. The v1 "10 parallel recruiters + consensus" workflow is retired (rationale in `.claude/BIRTH_ARCHITECTURE.md`). The v2 spine:

1. **Phase 0**: Specification refinement - the 5 clarifying questions
2. **Phase 1**: Tier triage - auto-classification with user override
3. **Phase 2 / 2.5** (Tier 3+): Domain research → primary-source claim verification
4. **Phase 3 / 3.5-3.75**: Facet-mode generation → optional skills generation → principle-reconciliation sweep
5. **Phase 4**: Static critique (evidence-anchored verdicts)
6. **Phase 5**: Dynamic validation - test subagents run the template; failures produce surgical repair prescriptions
7. **Phase 7**: Frontmatter validation, then deploy to `agents/agent-[name].md` + registry metadata

## Commands

The birthing commands live at **user level** (`~/.claude/commands/`), not in this repo — so they are available from any project. This repo intentionally has no `.claude/commands/` of its own (stale copies were causing duplicate skill registration).

### Create Production Agent (Recommended)
```bash
/birth "Specialization: [your rough idea]"
```
Orchestrates the full parallel consensus workflow (~25-30 minutes), writing gestation artifacts into this nursery.

### Recruit Generated Agents
```bash
./recruit.sh
```
Interactive promotion of agents from `agents/` to `~/.claude/agents/`. **Gated:** an agent is blocked from recruitment until valid `agents-metadata/<name>.json` exists (see the nursery model above). After promotion, the nursery copy is disposable.

## Agent Template Structure — Two Schemas, One Dispatcher

Phase 0 question #3 ("Function") routes the template through one of two schemas. Mixing them in a single template is a hard failure caught by the auditor.

### Consultative archetype → Recruiting-brief schema (7 sections)

Use when the agent's success criterion is the user understanding something, receiving a judgment, or being mentored. Examples: mentors, coaches, read-only analysts, strategists, critics, curators.

1. **Position Title** - 3-6 words, specific specialization
2. **Core Mission** - One transformative sentence
3. **What You'll Do** - 3-5 capabilities with logical flow
4. **Required Expertise** - 4-8 specific, hard-won skills
5. **Success Metrics** - 3-5 measurable, achievable outcomes
6. **The Ideal Candidate** - Behavioral/cognitive sketch (3-4 paragraphs)
7. **Closing Statement** - One memorable sentence

Governed by the `facet-contracts` skill.

### Operational archetype → Operating-manual schema (Viticci pattern)

Use when the agent's success criterion is a specific deliverable existing at a specific path or a verification check returning green. Examples: generators (produce files), orchestrators (dispatch work + verify), implementers (write code/config), pipeline-tool specialists (CI gates), file-producing architects.

1. **Position Title**
2. **Core Mission** - one sentence
3. **Invariants** - non-negotiable rules; "trust X as authority"; "only use X from allowlist"; "never invent"
4. **What You Never Do** - explicit anti-patterns with reasoning; ≥5 entries; each begins "Never X" and has a why
5. **Workflow** - numbered, mandatory; Step 0 precondition; terminal verification gate with positive-verification checks
6. **Bounded Fix Loops** - quantified iteration caps; same-error escalation triggers; per-error-class caps
7. **Bounded Research Budget** - specific call count; phase scope; two-option exhaustion behavior
8. **Validation Gates + Verbatim Escalation Script** - ≥3 gates; verbatim quoted script with concrete labeled options ending "Which would you like?"
9. **Closing Protocol** - numbered list of concrete deliverables; no prose

Governed by the `viticci-operating-discipline` skill.

### Dispatch criteria

| Question | Consultative | Operational |
|---|---|---|
| What does "done" mean? | User understands / received judgment | File exists at path / verification check is green |
| Does it produce a file? | No (or only a written report read by the user) | Yes (code, config, diagram, script, contract) |
| Does it dispatch other agents? | No | May (orchestrator subtype) |
| Does it run validation loops? | No | Yes |
| Bash with `ls/grep/cat` only? | Likely consultative | — |
| Bash with `npm install`, `gh pr create`, `pact-broker can-i-deploy`? | — | Likely operational |

Ambiguous borderline rule: if the agent's deliverable is acted on by a downstream consumer, use operational schema. The verification gate ensures the deliverable is in the expected shape; the escalation script catches ambiguity before it ships.

## The 5 Clarifying Questions (Phase 0)

When refining specifications, the system asks:
1. **Scope**: Narrow specialist (1 task deep) vs broad generalist (3-5 tasks)
2. **Depth**: Expert level (top 5%) vs senior level (top 25%)
3. **Function**: Quality gate, generator, analyzer, or coordinator → **also determines archetype dispatch** (quality-gate/generator/coordinator → operational; analyzer → typically consultative unless it ships structured artifacts)
4. **Risk**: Safety-critical (conservative) vs speed-optimized (aggressive)
5. **Context**: Standalone (complete) vs team specialist (focused)

## Quality Standards

Templates must be:
- **Clear**: No ambiguous sentences
- **Complete**: No obvious gaps
- **Consistent**: Components don't contradict each other
- **Concrete**: Specific examples, not vague language
- **Calibrated**: Achievable but non-trivial success metrics

### Anti-Patterns to Avoid
- Vague language: "good", "effective", "best practices"
- Unmeasurable metrics: "high quality", "stakeholder satisfaction"
- Scope creep: Agent trying to do too many things
- Fantasy metrics: 100% accuracy or unrealistic performance claims
- Mission/metrics mismatch: Metrics don't measure the core mission
- **Invented tool names**: `Architecture-Diagram-Generator`, `Run-Segmentation-Query`, bare MCP names without `mcp__<server>__` prefix. The canonical Claude Code tool list is `Read, Write, Edit, MultiEdit, Bash, Grep, Glob, Task, WebFetch, WebSearch, TodoWrite, NotebookEdit` plus prefixed MCP tools. Anything else is fictional and the agent has no real access.
- **Schema mixing (operational archetype only)**: a Success Metrics section inside an operational template; recruiting-brief Ideal Candidate alongside Viticci Invariants; prose Closing Statement instead of structured Closing Protocol.
- **Unbounded fix loops** (operational archetype only): "keep iterating until it works." Caps and same-error escalation triggers are mandatory.
- **Paraphrase escalation** (operational archetype only): "Tell the user what you found and ask what they want" instead of a verbatim quoted script with concrete options and a "Which would you like?" close.
- **Self-assertion verification** (operational archetype only): "Confirm the work is complete" instead of "`ls -la <path>` returns success."

## Output Locations

**Gestation (transient — cleared on graduation, preserved in git):**
- `agents/` - Agents currently in gestation (`.md`). Empty is the healthy steady state.
- `agents-metadata/` - Metadata for gestating agents (`.json`). The recruitment gate validates these.
- `.claude/skills/agent-[name]/{skill}/` - Agent-owned skills, namespaced under the agent

**Live install — the grown self (user level; authoritative on conflict):**
- `~/.claude/agents/agent-[name].md` - flat (no subdirectories)
- `~/.claude/skills/{skill-name}/SKILL.md` - **flattened, NOT nested**. Claude Code discovers skills one level deep, so each agent-owned skill is copied UP from `.claude/skills/agent-[name]/{skill}/` to `~/.claude/skills/{skill}/`. A skill left nested under `~/.claude/skills/agent-[name]/` is present-but-undiscoverable. Skill names are global once flat — check for collisions before copying.

**Working data** (stays at project root):
- `.birth-working/[agent-name]/` - Recruiter versions, critic analysis, synthesis iterations (sandbox-safe for background Task subagents)

## Naming Conventions

All agent output files MUST use the `agent-` prefix:
- Templates: `agents/agent-[name].md`
- Metadata: `agents-metadata/agent-[name].json`

**Examples**:
- `agents/agent-agentic-loop-architect.md` → `agents-metadata/agent-agentic-loop-architect.json`
- `agents/agent-security-auditor.md` → `agents-metadata/agent-security-auditor.json`

**Rules**:
- Metadata filenames MUST match their markdown siblings exactly
- **ALWAYS** use `agent-` prefix for generated agents
- Pipeline agents in `.claude/agents/` use the `agent-llm-` prefix (e.g. `agent-llm-recruiter.md`)

## Process Rules

1. **Recruitment gate — metadata before certification**: An agent is not certified as recruited until valid `agents-metadata/<name>.json` exists (per `.claude/METADATA_SCHEMA.md`). `recruit.sh` runs `scripts/validate-metadata.mjs` and blocks promotion otherwise. Never hand-wave an agent to user level without its registered, schema-valid metadata.
2. **Discard on graduation**: Once an agent is promoted to user/project level, `git rm` its `agents/*.md` + `agents-metadata/*.json` from the working tree. Git history is the archive; the tree holds only in-gestation agents.
3. **Follow metadata schema**: See `.claude/METADATA_SCHEMA.md` for required fields, naming conventions, and the validation checklist the gate enforces.
4. **Consensus working data stays at project root**: Intermediate artifacts (recruiter versions, critic feedback) live at `.birth-working/[agent-name]/` — NOT inside `.claude/`, because background Task subagents are sandbox-restricted from writing to `.claude/` paths.
5. **Agents directory is templates only**: No metadata, no working files — just the `.md` templates of agents still gestating.
