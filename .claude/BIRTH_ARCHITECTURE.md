# Birth Architecture — Tiered, Validated Agent Generation

**Status**: v2 (replaces parallel-consensus workflow)
**Last Updated**: 2026-04-08
**Authoritative Documents**: `~/.claude/commands/birth.md` (workflow — lives at user level), `.claude/AGENT_FRAMEWORK.md` (template structure)

---

## Why v2 Exists

The v1 workflow applied a single process to every agent generation request: spawn N (default 5) recruiters in parallel, have them each write a complete template, run a critic, synthesize, loop. This approach had four structural problems that v2 addresses.

### Problem 1: Effort Mismatch

A trivial agent ("Git commit message linter") received the same 5-recruiter parallel treatment as a safety-critical agent ("HIPAA-compliant triage auditor"). The first case was massively over-served; the second was under-served because consensus among 5 generalists can't reach expert-level depth on novel domains.

**v2 solution**: Four tiers (Quick / Standard / Deep / Expert) with effort calibrated to domain novelty, stakes, expertise depth, and capability breadth. Auto-classification with user override.

### Problem 2: Redundancy Masquerading as Consensus

Five recruiters producing five full templates means ~80% of the work is duplicated on the content everyone agreed on, and ~20% is the actual variance. The critic then has to read all 1000+ lines to find the 200 that matter. "Consensus" ended up reflecting what the training data says most loudly, not what the domain actually needs.

**v2 solution**: Replace parallel redundancy with **role-specialized facet generation**. Instead of 5 recruiters each writing full templates, 6 specialized subagents each write one narrow section of one template. Each facet prompt is sharper (because it's narrower), and there's no wasted duplication.

### Problem 3: No External Grounding

Recruiters only had their training data. For niche domains (agentic observability, D3 for mass audiences), the output was generic because the training corpus is generic. Five recruiters drawing from the same general pool produced five slightly different generic templates, and their consensus was no better than any individual.

**v2 solution**: **Research phase** at Tier 3+. A dedicated research subagent uses WebSearch and WebFetch to produce a Domain Brief — authoritative references, insider vocabulary, concrete examples of expert deliverables, common anti-patterns. The brief is injected into every generation-phase subagent's context.

**v2.1 hardening (Phase 2.5 — Claim Verification)**: Research subagents produce high-value grounding material but are also vulnerable to a subtle class of confabulation — *cross-wiring* between real facts. The failure mode surfaced during the rebirth of `agent-news-beat-reporter-rebirth`: a research subagent claimed that "Aaron Rupar's clip of the Trump/Carroll deposition mixup was cited five times in Trump's defamation suit against ABC News." Verification against the actual complaint text (SDFL 1:24-cv-21050, obtained via CourtListener's RECAP archive) revealed that Rupar IS cited exactly 5 times in the complaint (paragraphs 58-65) AND Rupar DID clip the Carroll deposition mixup — but the 5 citations are about a completely different Rupar thread (his 5-post thread of the March 2024 Stephanopoulos-Mace interview, not the May 2023 Carroll clip). Every component of the claim was real; only the relation between them was fabricated. Static critique wouldn't catch this. Dynamic validation wouldn't catch this. Only primary-source verification against the cited URLs can resolve it. Phase 2.5 exists to run this verification automatically at Tier 3+ before the contaminated brief reaches generation.

**v2.2 hardening (Phase 3.5-3.6 — Skills Generation)**: Agent templates can be bundled with custom skills — domain-specific workflows, reference materials, procedural knowledge, and anti-patterns. Skills use progressive disclosure: metadata loads always, core instructions load when triggered, bundled files load on-demand via reference links. Phase 3.5 asks whether the agent needs skills; Phase 3.6 generates them if yes. Skills are registered in metadata JSON and live in `.claude/skills/{agent-name}/`. See SKILLS_SPEC.md for complete structure and decision criteria.

**v2.3 hardening (Phase 3.75 — Principle-Reconciliation Pass)**: The research phase sometimes introduces a new epistemological principle (e.g., Rosen's "citizens not audiences," Tufte's lie-factor discipline, WCAG 2.1 AA as a hard gate) that was not present in the pre-research refined spec. The facet generators correctly apply the new principle to any new content they write — but inherited legacy elements (from the refined spec, or in `/rebirth` from the original template) may contradict the new principle and go unnoticed because the static critic evaluates each element in isolation without systematically re-checking legacy content against the newly-introduced axis. The empirical case: the v1.0.0 `agent-news-beat-reporter-rebirth` correctly applied Rosen's "citizens not audiences" principle to refuse the Torabi view-count loop (new addition from research) but left the original template's "Mixpanel as velocity clock not popularity meter" rule intact because it looked fine in isolation. A user reviewing the deployment asked "Mixpanel may not be the proper source of urgency" — and indeed it wasn't, because velocity is still an audience-derived metric, just a finer-grained one. The v1.0.1 patch removed Mixpanel from the scoring pipeline entirely. Phase 3.75 exists to run this principle-vs-legacy sweep prospectively: it derives a testable predicate from each new principle, applies the predicate to every element of the assembled draft, and flags contaminations for surgical correction before the draft reaches Phase 4 (Static Critique). It is mandatory in `/rebirth` and automatic in any `/birth` where the research phase introduced a new principle that post-dates the refined spec.

**v2.4 hardening (Phase 7 — Frontmatter Validation)**: Every agent template must have YAML frontmatter with four required fields: `name` (kebab-case), `description` (one transformative sentence), `tools` (comma-separated), `model` (sonnet/opus/haiku). Phase 7 validates all frontmatter before writing to `agents/`, rejects invalid templates with specific error messages, and prevents commits that violate frontmatter spec via pre-commit hook. See FRONTMATTER_SPEC.md for complete validation rules and examples.

### Problem 4: Static Review Only, No Runtime Validation

The v1 critic checked structural quality (framework compliance, anti-patterns, clarity) but never ran the template. A template could be internally coherent, well-written, and still produce garbage when an LLM actually tried to use it. There was no equivalent of "unit tests" for agent templates.

**v2 solution**: **Dynamic validation**. A new `agent-llm-validator.md` agent spawns subagents with the template as system prompt, submits realistic test cases, and judges outputs against rubrics derived from the template's own Success Metrics. Validation failures produce surgical repair prescriptions (not full rewrites).

---

## Skills Integration & Validation Strategy

### Skills Flow (Phases 3.5-3.6)

Skills are optional enhancements that bundle domain-specific workflows, reference materials, and procedural knowledge alongside agent templates. The `/birth` workflow asks whether each agent needs skills after template generation completes:

- **Phase 3.5** (Skills Definition): Ask user whether agent needs custom skills (no / 1 skill / multiple skills)
- **Phase 3.6** (Skills Generation): If yes, spawn skill generators to produce SKILL.md + bundled files
- **Phase 7** (Deploy): Register skills in metadata JSON with proper versioning

Skills are recommended for Tier 3-4 agents (niche domains) and optional for Tier 1-2. Each skill follows SKILLS_SPEC.md structure: SKILL.md (required) + WORKFLOWS.md, EXAMPLES.md, ANTI_PATTERNS.md, templates/ (as needed). All skills live in `.claude/skills/{agent-name}/` with cross-references in agents-metadata JSON.

### Frontmatter Validation Strategy (Phase 7)

Every agent template must have YAML frontmatter with four required fields:
- `name`: Kebab-case identifier matching filename
- `description`: One transformative sentence (same as core mission)
- `tools`: Comma-separated string (not YAML array)
- `model`: One of `sonnet`, `opus`, `haiku`

**Validation flow**:
1. **Phase 7a — Parse**: Extract frontmatter from assembled template
2. **Phase 7b — Validate**: Check all 4 required fields present and correctly formatted
3. **Phase 7c — Reject if invalid**: Report specific validation failures, ask user to fix spec
4. **Phase 7d — Write only if valid**: Template only written to `agents/` if validation passes
5. **Phase 7e — Metadata generation**: Include `frontmatter_validated_at` timestamp in metadata JSON

**Validation script**: `.claude/scripts/validate-frontmatter.sh` can be run manually to scan all agents and report compliance issues with remediation suggestions.

**Pre-commit hook**: `.git/hooks/pre-commit` automatically validates all agent files before allowing commits, preventing invalid frontmatter from reaching version control.

See FRONTMATTER_SPEC.md for complete validation rules, examples, and common mistakes.

---

## The Four Tiers

### Tier Selection Factors

| Factor | Low → High Signals |
|---|---|
| **Domain novelty** | Well-known → Niche → Emerging/novel |
| **Stakes** | Playful → Production tool → Safety-critical |
| **Expertise depth** | Senior-level → Top-5% expert |
| **Capability breadth** | Narrow single task → Multi-capability orchestrator |

Auto-classification maps these to tiers. Users can always override with `--tier [level]`.

### Tier Characteristics

**Tier 1 — Quick** (~2 min, ~2 subagent calls)
- Monolithic generation (single recruiter call)
- Main-context static critique (no subagent roundtrip)
- No validation
- For: familiar domains, experimental agents, variants of existing agents
- Reference example: "Git commit message linter"

**Tier 2 — Standard** (~6-8 min, ~8 subagent calls)
- Progressive elaboration via facet mode (Mission → Capabilities+Expertise → Metrics+Persona → Closing)
- Parallel facet execution at Stages B and C (single message, multiple Task calls)
- Subagent static critique
- Optional validation with `--validate` flag
- For: typical production agents with known domains
- Reference example: "B2B SaaS marketing orchestrator"

**Tier 3 — Deep** (~12-15 min, ~14 subagent calls)
- Research phase produces Domain Brief
- Progressive elaboration with brief injected into every facet prompt
- Adversarial critic (attacks weakest claims)
- Mandatory validation with 3 runs per test case
- For: niche or novel domains where training data alone produces generic outputs
- Reference example: "D3 charting expert for USA Today legibility"

**Tier 4 — Expert** (~20-25 min, ~25+ subagent calls)
- Research phase
- **Three distinct architectural philosophies** generated in parallel (not redundant drafts — genuinely different approaches)
- Synthesis with extended thinking
- Adversarial critic + standard critic
- Mandatory validation with 5 runs per test case + adversarial judge
- For: safety-critical, high-stakes, emerging domains
- Reference example: "HIPAA-compliant emergency room triage decision auditor"

---

## Role Decomposition: Three Agent Files

### `agent-llm-recruiter.md` — Generator

**Role**: Produce agent template content. Works in three modes:

- **Monolithic mode** (Tier 1): Full template in one call
- **Facet mode** (Tier 2+): Single section per call, enabling progressive elaboration
- **Repair mode** (Phase 6): Surgical revision of one specific failing section

The recruiter's instructions include explicit rules for each mode — particularly that facet and repair mode must return ONLY the requested content without preamble, frontmatter (unless mission facet), or adjacent sections.

### `agent-llm-critic.md` — Static Reviewer

**Role**: Unchanged from v1. Framework compliance, anti-pattern detection, clarity auditing, mission-metric alignment, actionability verification. Produces pass/fail verdict with specific evidence per finding.

The critic is deliberately **static** — it reads the template as a text artifact, not by running it. This is a strength, not a weakness: static analysis is cheap, mechanical, and catches 70% of structural issues before expensive validation happens. The validator handles the other 30%.

### `agent-llm-validator.md` — Dynamic Tester (NEW)

**Role**: Runtime validation of agent templates.

Four responsibilities:
1. **Test plan derivation** — Convert the template's Success Metrics into executable test cases (happy-path, rejection, adversarial)
2. **Test execution** — Spawn subagents with the template as system prompt, submit test inputs, collect outputs
3. **Output judgment** — Evaluate outputs against rubrics with quoted evidence, no subjective scoring
4. **Failure diagnosis and repair prescription** — Trace failures to specific template sections, propose surgical edits

The validator's key insight: the template's own Success Metrics section IS the rubric. If a metric says "90%+ of charts include source attribution," the validator mechanically checks attribution presence across runs. If the rubric can't be mechanically applied, the metric was fantasy and the validator escalates.

See `.claude/agents/agent-llm-validator.md` for the full specification.

---

## The Validation Framework

### Core Insight

An agent template is a **system prompt** that will be used as context for some future LLM invocation. Validation means treating the template as code and running it against inputs:

```
Template → [spawn subagent with template as system prompt]
        → [submit test input]
        → [collect output]
        → [judge output against template's own Success Metrics]
        → [pass/fail with evidence]
```

No external ground truth is needed — the template must pass its own stated criteria, or the criteria were unmeasurable to begin with.

### Three Test Case Categories

**Happy-path tests** (1 per capability)
- Give the agent a well-formed request in its core domain
- Verify the claimed capability actually produces the claimed output
- Example for D3 charting expert: "Here's quarterly revenue data, make a chart for USA Today" → does the output include D3 code AND a design memo?

**Rejection tests** (1 per implicit anti-capability)
- Give the agent a bad input its expertise should recognize
- Verify the agent pushes back instead of complying
- Example for D3 charting expert: "Make me a 3D pie chart with 12 slices" → does the agent refuse and propose an alternative, or does it comply and produce a terrible chart?
- These are derived from the Expertise section — if the template claims "deep knowledge of chart-junk antipatterns," there must be tests that prove it

**Adversarial tests** (1-3 per tier)
- Give the agent a vague, incomplete, or edge-case input
- Verify the agent stays specific and useful rather than drifting into generic advice
- Example: "Visualize this data" with no intent stated → does it ask the right questions or pick a defensible default?

### Judgment Rules

- **Every verdict cites evidence**: pass or fail, the validator must quote the specific text from the output and name the specific criterion
- **No subjective language**: "feels good," "seems clear," "looks professional" are code smells — if the only way to express a verdict is subjective, the rubric was never a rubric
- **Multi-run stability**: At Tier 3+, each test runs multiple times; a single failure might be noise, a majority failure is a defect
- **Failure diagnosis is surgical**: "Capability #3 lacks explicit rejection criteria" is actionable; "template is too vague" is not

### Repair Prescriptions

When a test fails, the validator produces a repair prescription that names:
- **The failing section** (Mission, Capabilities, Expertise, Metrics, Persona)
- **The specific edit** that would fix the failure
- **The constraint** (which sections must not be affected)

The recruiter (in repair mode) then performs only that specific edit. Multiple repairs can run in parallel if they target different sections. After all repairs, the template re-enters validation — we never skip validation just because repairs were surgical.

Repair loops are bounded at 3 iterations. If the same section fails repair twice, the root cause is deeper than the failing section, and the user is asked to revise the spec.

### Split Orchestration: Why the Validator Doesn't Spawn Tests

The naive design would have the validator subagent do everything: derive the test plan, spawn test subagents via Task, collect outputs, judge them, diagnose failures, prescribe repairs. This design **fails in the Claude Code harness** because Task subagents cannot recursively spawn fresh sub-subagents via Task — recursive Task access isn't exposed to subagents. A validator trying to execute tests itself either falls back to self-role-play simulation (one instance pretending to be a fresh instance, which loses the statistical independence that makes multi-run validation meaningful) or cannot execute tests at all.

The fix is **split orchestration**. The validator is invoked twice via Task:

1. **Plan mode**: Validator reads the template, derives a structured test plan, returns it as markdown.
2. **Main context executes**: Main context parses the test plan, spawns parallel Task calls for each test case × runs-per-test, collects the outputs into a bundle.
3. **Judge mode**: Validator receives the test plan + collected outputs, judges each output against the plan's pass criteria with quoted evidence, produces failure diagnoses and repair prescriptions.

Main context is the only place where Task can recursively spawn fresh instances, so main context owns execution. The validator focuses on the semantic work that actually requires domain expertise: what tests to derive, how to judge outputs, where failures point.

This split was discovered empirically during the birth of `agent-d3-legibility-charting-expert` at Tier 3. The first attempt used a single-invocation validator, which fell back to self-role-play simulation. The simulation still produced useful findings (it caught a real runtime non-determinism defect static review missed), but flagged itself as less rigorous than fresh-instance spawning. The split-orchestration pattern preserves the rigor without requiring the harness to expose recursive Task access.

**Implementation consequence**: The validator's tools list does NOT include Task. It uses Read, Grep, Glob, Write only. This is intentional — if Task were listed, someone might mistakenly think the validator should spawn its own test runs, reintroducing the old anti-pattern.

---

## Progressive Elaboration vs Parallel Redundancy

### Why Facets Are Better Than Parallel Recruiters

**v1 approach**: 5 recruiters × full template = ~5000 lines generated, ~4000 redundant, 1 synthesis round needed to collapse

**v2 approach**: 6 facet calls × one section each = ~1000 lines generated, 0 redundancy, no synthesis step needed

The tokens saved are real, but the bigger win is **specificity**. A facet prompt for "Success Metrics only" can include detailed guidance on what makes metrics measurable, common calibration mistakes, and specific thresholds to avoid — guidance that would be noise in a monolithic prompt.

### Why Stages Matter

Progressive elaboration locks each section before moving to the next:
- Mission locked → Capabilities can be written with confidence they'll align
- Capabilities locked → Metrics can be written knowing what they must measure
- Metrics locked → Persona can be written without contradicting the rubric

Each stage is cheap (~1-2 subagent calls). Early rejection is cheap: if the Mission is wrong, we haven't wasted effort on Capabilities. In v1, a bad Mission meant 5 recruiters wasted effort on 5 full templates before the critic caught it.

### Parallelism Within Stages

Stages B and C fire multiple facet calls in parallel via a single message with multiple Task invocations. This preserves wall-clock speed while eliminating redundancy. The Capability Designer and Expertise Designer can work simultaneously because they share the same upstream context (locked Mission) and their outputs don't depend on each other.

---

## Why Sandbox Write Restrictions Shaped the Architecture

Background Task subagents in Claude Code are sandbox-restricted from writing to `.claude/` paths. This surfaced in v1 births when the background orchestrator tried to create `.claude/working/[agent-name]/` and got permission errors.

v2 handles this three ways:

1. **Working directory lives at `.birth-working/`** in the project root, not `.claude/working/`. This is sandbox-safe.
2. **Main context owns critical writes** where possible. Background orchestrators write intermediate artifacts; main context writes final outputs.
3. **Subagents return content as text** in their response, not by writing files. Main context collects the text and handles I/O. This is especially important in foreground mode, where subagents return full drafts inline.

This constraint actually improved the architecture: the stricter separation between content generation (subagents) and filesystem I/O (main or orchestrator context) made the data flow clearer and more debuggable.

---

## Cost vs Quality Trade-offs

| Tier | Approx. Subagent Calls | Wall Clock | Cost Driver | Quality Ceiling |
|---|---|---|---|---|
| Quick | 2 | ~2 min | Monolithic generation | Limited by single recruiter's knowledge |
| Standard | ~8 | ~6-8 min | Progressive elaboration | Higher than Quick due to specialized facets; limited on niche domains |
| Deep | ~14 | ~12-15 min | Research phase + validation | Much higher on niche domains; validation catches runtime failures |
| Expert | ~25+ | ~20-25 min | Multi-philosophy parallel + adversarial validation | Highest achievable; practical limit of LLM-guided template generation |

**Key principle**: higher tiers aren't just more expensive — they produce different *kinds* of quality. Quick gets you a coherent template; Deep gets you a grounded, tested template; Expert gets you a template that has survived adversarial criticism from multiple philosophical directions.

The wrong tier in either direction is waste:
- Quick for a safety-critical agent = dangerously under-served
- Expert for a commit message linter = absurdly over-served

Auto-classification exists to prevent both mistakes, and the user override exists for when auto-classification gets it wrong.

---

## Framework Learning: Validation as Feedback Loop

Every validation run produces data. Across many runs, patterns emerge:

- Templates with Success Metrics above 95% fail validation 80% of the time → Framework rule: cap metric thresholds at 95% unless justified
- Capabilities starting with "Understand" fail adversarial tests more than those starting with "Produce" → Framework rule: prefer action verbs
- Templates without explicit rejection criteria in Expertise fail rejection tests → Framework rule: generator agents must include rejection criteria

The working directory at `.birth-working/` is preserved precisely to enable this learning. Over time, validation-report analysis can surface new framework rules empirically, and the `AGENT_FRAMEWORK.md` document can evolve from static principles to empirically validated rules.

This is the deepest reason for the architecture: each template built is not just a deliverable but a data point. The system gets smarter by being used.

---

## Migration Notes (v1 → v2)

### For Existing Templates

Templates built under v1 are fully compatible with v2 — the 7-section structure is unchanged. Only the generation workflow is different. No migration needed.

### For Working Directories

v1 working directories at `.claude/working/agent-[name]/` are preserved as historical artifacts. New v2 runs write to `.birth-working/agent-[name]/`. Both paths coexist.

### For the `/birth` Command

v2 `/birth` parses v1 flags (`/birth 5 "Spec: ..."`, `--recruiters N`, `--iterations N`) for backward compatibility, but ignores them with a warning, recommending the new tier-based flags. The v1 command documentation is preserved in git history.

### For Users

- Simple case: just use `/birth "Spec: ..."` and let auto-classification pick the tier
- Explicit case: use `--tier quick|standard|deep|expert` to force a level
- Debugging: use `--foreground` to see every phase in main context
- Validation skepticism: use `--no-validate` to skip (not recommended above Tier 2)

---

## Open Questions and Future Work

- **Test case reuse across similar agents**: Can validation test plans for agent category X (e.g., all charting agents) share a common test suite? Potentially yes via a test library, but not yet implemented.
- **Validator self-validation**: Who validates the validator? Currently, the validator is trusted because its outputs are evidence-quoted and traceable. A meta-validator could audit the validator's own judgment quality.
- **Human-in-the-loop at Tier 4**: Expert-tier agents could benefit from optional human review after validation before deployment. Not yet implemented.
- **Stability across model versions**: Templates may behave differently on Sonnet vs. Opus. Should validation be run across models? Currently no, but worth considering for safety-critical agents.
- **Framework rule extraction automation**: The "framework learning" story depends on a human (or future agent) reading validation reports and distilling patterns. This could be automated by a dedicated "framework-evolver" agent that periodically analyzes the `.birth-working/` archive.

---

## Summary

v2 replaces "more recruiters" with "smarter effort." The three axes of improvement — tiered effort, specialized facets, research grounding, and dynamic validation — address the four structural problems of v1. The role decomposition into recruiter (generator, multi-mode), critic (static reviewer), and validator (dynamic tester) gives each agent a clear mandate. The tiered workflow ensures cost matches stakes. The validation framework catches runtime failures that static review cannot. And the entire system preserves its working artifacts to enable framework-level learning over time.

The goal is not just better individual templates — it's a self-improving template-generation system that gets smarter with every run.
