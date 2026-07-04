# Tier Calibration — Canonical Reference

**Purpose**: Single source of truth for `/birth` and `/rebirth` tier calibration numbers — runs × cases per tier, intensity modifiers, adversarial policy. Every other framework doc (`birth.md`, `BIRTH_ARCHITECTURE.md`, `SKILLS_SPEC.md`, `agent-llm-validator.md`) cross-references this file rather than restating numbers inline.

**Why**: On 2026-04-22, a Phase 3.6 context packet stated tier numbers that disagreed with the validator template. The skills-writer flagged the discrepancy. This file prevents that drift.

---

## Canonical Tier Table

| Tier | Label | Phase 5 Runs × Cases | Adversarial Policy | Typical Subagent Count | Typical Wall-Clock |
|---|---|---|---|---|---|
| 1 | Quick | N/A (no validation) | — | ~2 | ~2 min |
| 2 | Standard | 2 runs × 5 cases (optional; `--validate` to force) | none | ~8 | ~6–8 min |
| 3 | Deep | 3 runs × 8 cases (mandatory) | cases included in plan | ~14 | ~12–15 min |
| 4 | Expert | 5 runs × 10 cases (mandatory) | + dedicated adversarial judge pass | ~25+ | ~20–25 min |

---

## Intensity Modifiers

Intensity is orthogonal to tier. A Tier 3 agent can be validated at `standard` intensity (2×5) during a time crunch; a Tier 2 agent can be validated at `smoke` intensity (1×1) retrospectively. The tier determines the agent's complexity and generation workflow; the intensity determines the validation budget for a specific run.

| Intensity | Runs × Cases | Stability Scoring | Use Case |
|---|---|---|---|
| `smoke` | 1 × 1–3 | Not computed at n=1 | Retrospective smoke check on a deployed agent; sanity-test, not regression coverage |
| `standard` | 2 × 5 | Computed per test (0.7 threshold) | Tier 2 birth validation; opt-in `--validate` |
| `deep` | 3 × 8 | Full stability scoring | Tier 3 birth validation (default) |
| `expert` | 5 × 10 + adversarial | Full stability + adversarial judge | Tier 4 birth validation (default) |

`/birth` auto-selects intensity by tier (smoke is opt-in only via `/validate`). `/validate` defaults to `smoke` for retrospective checks.

---

## Adversarial Case Design

- **Tier 2**: No adversarial cases in default validation plan. Adversarial coverage deferred to in-production observation.
- **Tier 3**: Adversarial cases included in the 8-case plan — prompt-injection probes, out-of-scope requests, ambiguous-edge inputs. Not a separate judge pass.
- **Tier 4**: Adversarial cases included in the 10-case plan AND a dedicated adversarial judge pass where the validator specifically scores adversarial resistance with higher rigor than the standard rubric.

---

## Stability Threshold

For any intensity with multiple runs per case (`standard`, `deep`, `expert`): the stability score across runs must be ≥ 0.7 for a test verdict to count as stable. Scores below 0.7 indicate flakiness — a finding about the template, not about model variance. A stable failure (≥ 0.7 of runs fail the same way) is a template defect; a flaky failure (< 0.7 consistency) requires root-cause investigation before being labeled as a template defect.

---

## Factors That Drive Tier Classification

Phase 1 triage auto-classifies tier from the Refined Spec using four factors:

| Factor | Low → High |
|---|---|
| Domain novelty | Well-known → Niche → Emerging/novel |
| Stakes | Playful → Production tool → Safety-critical |
| Expertise depth required | Senior-level → Top-5% expert |
| Capability breadth | Narrow single task → Multi-capability orchestrator |

User override via `--tier` flag always wins.

---

## Cross-References

Every file below should reference this file for tier numbers rather than restating them:

- `.claude/commands/birth.md` — Phase 5 runs × cases, Phase 3 facet counts, subagent-count-by-tier summary
- `.claude/BIRTH_ARCHITECTURE.md` — Tier Characteristics section
- `.claude/SKILLS_SPEC.md` — "Skills for Different Agent Tiers" table
- `agents/agent-llm-validator.md` — Section 3 Capability 1 (test plan derivation with tier calibration); Section 4 Tier Calibration Judgment expertise
