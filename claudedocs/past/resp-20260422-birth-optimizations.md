# `/birth` Optimization Review — Post-Sextet

**Date**: 2026-04-22
**Context**: After today's Phase 3.6 materialization of 11 unique skills and the Phase 5 smoke-test batch, several rough edges in the `/birth` command surfaced from direct empirical friction — not theory. This review is organized by impact × ease-of-fix and grounded in specific behaviors observed during today's 5 skills-writer invocations + 5 smoke-test executions.

All line references are to `.claude/commands/birth.md` and `.claude/BIRTH_ARCHITECTURE.md` as of 2026-04-22.

---

## Highest-value fixes (high impact × easy implementation)

### 1. Skills-writer output schema drift — observed 5/5 runs

**What happened**: Five separate `agent-llm-skills-writer` invocations today produced five differently-shaped `skills[]` metadata stanzas:

| Agent | Stanza shape (observed) |
|---|---|
| critic | `{name, type, location, version, description, backs_capability, shared_with, canonical_owner, supports_metrics}` |
| recruiter | `{name, type, owner, location, version, usage_mode, description, binds_to_capabilities, binds_to_metrics, consolidation_note}` |
| validator | `{name, path, description, mode, shared, supports_capabilities, aligned_metrics}` *(uses `path`, not `location`)* |
| spec-refiner | `{name, type, location, version, description, supports_capabilities, supports_metrics}` |
| researcher | `{name, path, description, usage, shared, capabilities_served, metrics_served, bundle_files}` *(uses `path`)* |

SKILLS_SPEC.md lines 238–243 specify the canonical shape: `{name, type, location, version, description}` — only 5 fields. The skills-writer invented extras with no schema guidance.

**Fix**: Add an explicit schema block to `agent-llm-skills-writer.md` Section 3 Capability 3, citing SKILLS_SPEC as authoritative. Forbid extras without a named reason. Canonical shape:

```json
{"name": "...", "type": "custom|shared-reference", "location": "...", "version": "1.0.0", "description": "..."}
```

**Impact**: Removes a normalization step from the main context after every Phase 3.6 invocation. Today I normalized 5 stanzas manually (took ~5 min across 5 edits).

**Effort**: 1 edit to the skills-writer template + 1 edit to birth.md Phase 3.6 to reference the canonical shape.

---

### 2. Skills-writer should splice metadata itself, not return stanza text

**What happened**: Skills-writer returns the stanza as text in its response. Main context then manually Edits the JSON to insert it. Five invocations = five manual splices.

Skills-writer already has `Write, Edit` in its tool surface. It could perform the splice atomically — read the target metadata JSON, splice `skills[]`, write back.

**Fix**: Add a deliverable to Section 3 Capability 3: "Splice metadata stanza directly into target file; return `spliced` status + a one-line summary." Skip the stanza-in-response-text handoff.

**Impact**: Removes 5 manual Edits per Phase 3.6. Removes the drift risk where the stanza Claude says matches the stanza it wrote.

**Effort**: Minor skills-writer template edit. Main-context birth.md "actions after skills-writer returns" list (line 390–395) shrinks from 5 items to 3.

---

### 3. Capabilities patch format drift — observed 5/5 runs

**What happened**: Same as #1 but for capability patches. Each of the 5 invocations proposed patches in a different shape:

- Critic: prose `PATCH anchor: ... INSERT after Capability X body paragraph: ...`
- Validator: YAML-ish `PATCH ANCHOR: [capability:X] ANNOTATION: primary_skill = Y`
- Spec-refiner: italic-tag suggestions with placement commentary
- Researcher: full-text replacement of 3 capabilities (nearly a rewrite, not additive)
- Recruiter: structured `capability_patches: [{anchor, patch_type, annotation, skill_ref}]`

The researcher output in particular drifted from "additive annotation" into "rewrite existing capability text" — which the birth.md Phase 3.6 contract line 388 says to avoid ("Capabilities patch proposal — suggested edits... reference each generated skill by name and invocation trigger. Main context applies these edits").

**Fix**: Specify the patch format in birth.md Phase 3.6 verbatim. Minimal additive annotation only: one sentence appended per affected capability, referencing the skill by kebab-case name. No replacement of existing text. Named-anchor targeting (capability lead phrase), not ordinal.

**Impact**: Predictable patch application. Today I applied 3 of 5 manually (critic, spec-refiner, researcher); the other 2 had already-inline mentions.

**Effort**: One paragraph added to Phase 3.6.

---

### 4. Deploy manifest 1-entry-per-file is tedious for skills

**What happened**: Adding 11 SKILL.md files + 1 bundled template to `deploy/manifest.json` required 13 new `items[]` entries. The pattern is mechanical: `.claude/skills/agent-X/skill-Y/**` → `~/.claude/skills/agent-X/skill-Y/**`.

**Fix**: Extend `deploy/deploy.py` with a new item type `"type": "skill-directory"` that recursively copies a skill directory tree. One manifest entry per skill, not per file.

```json
{
  "id": "skill.critic.anti-patterns-catalog",
  "type": "skill-directory",
  "source": ".claude/skills/agent-llm-critic/anti-patterns-catalog/",
  "dest": "~/.claude/skills/agent-llm-critic/anti-patterns-catalog/",
  "rewrites": []
}
```

**Impact**: Each new skill ships with a single manifest entry. Bundled files (WORKFLOWS.md, EXAMPLES.md, ANTI_PATTERNS.md, templates/) auto-deploy.

**Effort**: ~40 lines added to `deploy.py`: recursive walk, per-file hash, per-file state tracking. Medium.

---

### 5. Phase 3.5 should WRITE `skills_planned` to metadata, not defer

**What happened**: Today's Workstream A had to reconstruct skill intents for spec-refiner and researcher from the agent templates because Phase 3.5 was "informal" during their birth — they had skills drafted but no `skills_planned` field in metadata. Critic/recruiter/validator, by contrast, had `skills_planned` populated (probably because their rebirth's Phase 3.5 was done more rigorously).

**Fix**: Make Phase 3.5 a WRITE operation, not just a user-choice capture. When the user answers "multiple skills" with a list of names and intents, main context writes `skills_planned: [...]` to the staging metadata immediately. Phase 3.6 reads it as input.

**Impact**: Eliminates the "drafted but not registered" category. Metadata becomes the single source of truth for planned skills from decision time forward.

**Effort**: One paragraph in birth.md Phase 3.5. Requires staging metadata earlier in the pipeline (currently metadata is written in Phase 7b).

---

## High-value, medium-effort fixes

### 6. Tier calibration: single source of truth

**What happened**: Today the validator template said "Tier 2: 2 runs × 5 cases; Tier 3: 3 runs × 8 cases with adversarial; Tier 4: 5 runs × 10 cases + dedicated adversarial judge pass" (in `agents/agent-llm-validator.md` Section 3 Capability 1). My context packet for B3 initially had different numbers ("Tier 2 = 3 cases × 1 run; Tier 3 = 3 cases × 3 runs"), which the skills-writer flagged as a packet-vs-template discrepancy.

The numbers also appear in:
- `birth.md` Phase 5 lines 541–545 ("Tier 2: 2 runs per test, ~5 test cases...")
- `BIRTH_ARCHITECTURE.md` section "Tier Characteristics"
- `SKILLS_SPEC.md` tier table

**Fix**: Create `.claude/TIER_CALIBRATION.md` as the single source. Every other doc cites it. Skills-writer prompt template references it explicitly.

**Impact**: Prevents the drift I hit today. Avoids skills encoding numbers that contradict the template they support.

**Effort**: One new file + 4 doc edits replacing inline numbers with cross-references.

---

### 7. Retrospective-validation intensity: `--intensity smoke`

**What happened**: Today's Workstream C ran 1-case × 1-run per agent (5 total) as a compressed smoke test. That doesn't match any existing tier's calibration; I had to manually constrain the validator and mark `validation_intensity: "SMOKE"` in metadata to distinguish it.

**Fix**: Formalize a `smoke` intensity below Tier 2:

| Intensity | Runs × Cases | Use case |
|---|---|---|
| smoke | 1 × 1–3 | Retrospective check on deployed agent; no stability scoring |
| standard (T2) | 2 × 5 | Tier 2 births |
| deep (T3) | 3 × 8 | Tier 3 births |
| expert (T4) | 5 × 10 + adversarial | Tier 4 births |

Add `/birth --intensity smoke` flag AND a `/validate` subcommand (see #8).

**Impact**: Sanctions the retrospective-validation pattern today's session invented ad-hoc.

**Effort**: flag parsing + validator plan-mode protocol update + tier-calibration doc entry.

---

### 8. `/validate` subcommand for standalone retrospective Phase 5

**What happened**: Five agents had `validation_runs: 0` and `APPROVED_WITH_NOTES` from a prior session where Phase 5 was skipped for context budget. The pattern "deploy first, validate later" is real and recurring. Today I invoked the validator plus fresh host-agent instances manually.

**Fix**: Add `/validate agent-<name>` subcommand that runs Phases 5a/5b/5c standalone on an already-deployed agent. Optional `--intensity smoke|standard|deep|expert`. Optional `--all-approved-with-notes` to batch across every agent in `agents/` carrying that verdict.

**Impact**: Upgrades "validation backlog" from a manual retrospective chore to a named workflow. Graham's todo.md explicitly asked for this.

**Effort**: New command file `.claude/commands/validate.md`; reuses Phase 5 infrastructure.

---

### 9. Shared-skill canonical-path convention (undocumented today)

**What happened**: Today's critic + recruiter share `anti-patterns-catalog`. I chose critic as the canonical owner and put the SKILL.md under `.claude/skills/agent-llm-critic/anti-patterns-catalog/`. Recruiter's metadata `skills[]` entry for it points to the same location with `"type": "shared-reference"`. This convention was invented on the fly.

**Fix**: Add a "Shared Skills" section to SKILLS_SPEC.md with the rule: canonical owner is the first agent whose Phase 3.6 invocation generates it. Subsequent referrers pass existing-inventory and emit `"type": "shared-reference"` entries pointing to the canonical path. Alternative: a `.claude/skills/shared/<skill-name>/` directory for skills owned by no single agent — but adds a second convention.

**Impact**: Future shared skills don't require ad-hoc orchestrator reasoning.

**Effort**: One SKILLS_SPEC section + mention in birth.md Phase 3.6 Item 6 (existing skill inventory).

---

## Lower-impact but worth noting

### 10. `.claude/working/` vs `.birth-working/` stale references

**What happened**: Already logged in `todo.md` as minor tech debt. Birth architecture docs mention `.claude/working/` in a few places even though the convention has been `.birth-working/` since the sandbox-restriction fix.

**Fix**: `grep -rn "\.claude/working" .claude/` and replace with `.birth-working`.

**Effort**: 5 minutes.

---

### 11. Phase 3.5 + Phase 3.6 could be unified

Phase 3.5 asks the user "any skills? how many?" and Phase 3.6 generates them. Two phases for one decision. Phase 3.6 could start with the same question (single turn of AskUserQuestion), then fan out into generation. Or Phase 3.5 becomes a thin routing decision inside Phase 3.6's orchestration.

Not essential. Current split has pedagogical value (the decision surface is visible in the phase list). But it's extra ceremony.

**Effort**: medium — either rename or fold. Best deferred to a v3 birth if one happens.

---

### 12. Context packet item #1 is the full template verbatim — heavy

For Tier 3 births with 3+ skills, the skills-writer reads the same template once (good: one invocation per host agent, not per skill). But the packet still includes the *full* template text. If the skills-writer only needs Capabilities + Success Metrics + Mission for grounding, Item 1 could be slimmed.

**Fix**: Item 1 = Mission + Capabilities + Success Metrics only (not Persona/Closing/Expertise). Skills-writer Reads the full template if it needs other sections.

**Impact**: Smaller packet, ~40% reduction in packet size for typical agents. Skills-writer still has full access via Read if needed.

**Effort**: Packet-shape change in birth.md Phase 3.6 Item 1 + skills-writer prompt adjustment.

---

### 13. No subagent enum refresh during session

**What happened**: At session start my tool definitions listed only critic/recruiter/validator from the sextet. skills-writer, spec-refiner, researcher were deployed today but not in the enum. I fell back to `general-purpose` with the skills-writer template as persona. Results were lower-quality than the real subagent (different output shapes, less disciplined contract adherence). Graham opened `/agents` dialog and the enum refreshed mid-session, after which the real skills-writer was reachable.

**Fix**: This is a Claude Code harness behavior, not a `/birth` concern — but `/birth` can defend against it. Add a pre-flight check in Phase 3.6: probe whether `agent-llm-skills-writer` is invocable. If not, BLOCK with a clear error ("agent-llm-skills-writer not reachable in this session; try /agents to refresh, or use --foreground"). Fallback to general-purpose is worse than waiting.

**Impact**: Prevents today's low-quality-fallback scenario from recurring silently.

**Effort**: 10-line pre-flight probe + documentation.

---

### 14. `/birth --dry-run` for previewing cost/tier

Currently you can't see what `/birth "..."` would do without actually running it (even `--foreground` starts doing work). A dry-run mode would: run Phase 0 (tier classification), emit projected cost + phase list + questions that would be asked, then stop.

**Impact**: Useful for cost-conscious users; useful for debugging tier-classification.

**Effort**: low — Phase 0 already classifies; skip Phase 1 dispatch.

---

### 15. Phase naming sprawl

Current phases: 0, 0.5, 1, 2, 2.5, 3, 3.5, 3.6, 3.75, 4, 5a/b/c, 6, 7a/b/c/d. That's 14 top-level + 7 sub-phases = 21 distinct phase IDs.

The decimal-insertion pattern (0.5, 2.5, 3.5, 3.6, 3.75) reflects incremental hardening empirically driven by real defects (beat-reporter, news-beat-reporter-rebirth, snapstream-god-emperor). The phases ARE each load-bearing. But the ID system is cracking.

**Fix**: Consider renumbering for a hypothetical v3. Not urgent; phase IDs aren't user-facing in practice.

---

## What today confirmed is working well

- **Split orchestration for validation** — the validator's two-mode (plan / judge) contract with main context owning test execution is the right shape. Today's smoke test used plan mode cleanly; boundary-integrity held (no self-role-play).
- **Non-interactive skills-writer contract** — the 7-item packet + `BLOCKED:`-on-insufficiency is the right discipline. When invoked with good packets, all 5 runs produced conformant SKILL.md artifacts in one pass with zero clarifying questions. The only issue was output-shape drift (#1, #3).
- **Facet contracts for recruiter** — today's monolithic-mode recruiter invocation for the dependency-hygiene auditor produced a clean first-pass-approvable template with correct tool-surface minimalism and model-choice reflex.
- **Evidence-anchoring in critic** — on the deliberately-flawed template, the critic caught every planted defect with quoted evidence; no abstract gripes.
- **Agent-llm-spec-refiner restraint** — on the PR-reviewer rough spec, it correctly suppressed the already-resolved function axis, added exactly one domain-augmentation axis with reasoning, and stopped at 5 questions.

These are not on the fix list; they're working as designed. Mention included for balance.

---

## Priority ranking

**Ship next week**:
1. Skills-writer canonical stanza schema (#1)
2. Skills-writer auto-splices metadata (#2)
3. Canonical capability-patch format (#3)
4. `type: skill-directory` manifest item type (#4)
5. Phase 3.5 writes `skills_planned` eagerly (#5)
6. `.claude/working/` → `.birth-working/` grep-and-fix (#10)

**Next month**:
7. Single source of truth for tier calibration (#6)
8. `smoke` intensity + `/validate` subcommand (#7, #8)
9. Shared-skill canonical-path convention (#9)
10. Skills-writer pre-flight subagent probe (#13)

**Back burner**:
11. Packet size reduction (#12)
12. `--dry-run` mode (#14)
13. Phase 3.5/3.6 unification (#11)
14. Phase ID renumbering (#15)

Items 1–5 + 10 together eliminate most of the manual orchestration friction today's session hit. Item 6 prevents a recurring drift. Items 7–8 formalize the retrospective-validation pattern from today's Workstream C.
