# LLM Agent Generation Framework

A systematic approach to creating specialized LLM agents that operate at expert-level proficiency.

> **Workflow Update (v2)**: The Parallel Agent Consensus workflow described in this document has been superseded by the **Tiered Generation + Validation** architecture. See [`BIRTH_ARCHITECTURE.md`](./BIRTH_ARCHITECTURE.md) for the current workflow, role decomposition (recruiter / critic / validator), and validation framework. The 7-section template structure in this document is unchanged and remains authoritative — only the generation workflow around it has been redesigned.

> **YAML Frontmatter & Skills**: Every agent template MUST include YAML frontmatter (required fields: `name`, `description`, `tools`, `model`). See [`FRONTMATTER_SPEC.md`](./FRONTMATTER_SPEC.md) for validation rules. Agents can optionally bundle custom skills (workflows, reference materials) — see [`SKILLS_SPEC.md`](./SKILLS_SPEC.md) for when and how to create skills.

## Core Principle
**Agents are cognitive architectures**, not just instruction sets. Each agent template distills domain expertise into decision-making frameworks that LLMs can reliably execute.

## Agent Template Structure

Every agent template contains these components:

### 0. **YAML Frontmatter** (Required for Claude Code Compatibility)
- Must be the first content in the file
- Wrapped in `---` delimiters
- Contains required fields: `name`, `description`, `tools`, `model`
- Format:
```yaml
---
name: [kebab-case-identifier]
description: [Core mission as one transformative sentence]
tools: [Comma-separated list of Claude Code tools the agent needs]
model: [sonnet|opus|haiku - defaults to sonnet]
---
```
- **name**: Kebab-case identifier (e.g., `api-security-reviewer`), used for agent selection
- **description**: Same as Core Mission, answers "what does this agent exist to accomplish?"
- **tools**: Tools the agent needs access to. Common sets:
  - Read-only analysis: `Read, Grep, Glob`
  - Code modification: `Read, Edit, MultiEdit, Grep, Write, Bash`
  - Full access: `Read, Edit, MultiEdit, Grep, Glob, Write, Bash`
- **model**: Which Claude model to use (`sonnet` for most tasks, `opus` for complex reasoning, `haiku` for simple/fast tasks)
- This frontmatter enables Claude Code to display agent name and description in tool selection

### 1. **Position Title**
- Clear, specific role identity
- Should convey specialization (not "Consultant", but "API Security Reviewer")
- 3-6 words max

### 2. **Core Mission**
- One sentence maximum
- Answers: **What does this agent exist to accomplish?**
- Should be transformative, not transactional
- Examples:
  - ✅ "Transform ambiguous requirements into executable specifications"
  - ❌ "Review documents"

### 3. **What You'll Do** (Capabilities/Responsibilities)
- 3-5 major capability areas
- Structured as: **[Action]**: [What it does] [Why it matters]
- Should flow logically from mission
- Each capability must be:
  - Distinct (no overlap with others)
  - Actionable (an LLM can perform it)
  - Measurable (outcomes are observable)

### 4. **Required Expertise**
- Domain knowledge needed to execute the mission
- Thinking patterns and mental models
- NOT generic traits ("attention to detail")
- Specific, hard-won expertise
- Format: **[Expertise Area]**: [What it enables] [Why it matters]
- Minimum 4, maximum 8

### 5. **Success Metrics**
- 3-5 measurable outcomes
- Specific and verifiable (not "high quality")
- Should directly map to mission
- Format: **[What is measured]**: [Specific threshold or standard]
- Example: "Templates adopted in 80%+ of projects within 6 months"

### 6. **The Ideal Candidate** (Behavioral Profile)
- 3-4 paragraphs describing cognitive patterns
- How they think, not what they know
- What they value
- What they refuse to do
- Should feel like a personality sketch

### 7. **Closing Statement**
- One memorable, conceptually rich sentence
- Captures the essence of the role
- Should make the mission *click*

---

## Template Validation Checklist

### Format Compliance
- [ ] YAML frontmatter present with `---` delimiters
- [ ] `name:` field is kebab-case identifier
- [ ] `description:` field matches Core Mission
- [ ] `tools:` field lists required Claude Code tools
- [ ] `model:` field specifies sonnet, opus, or haiku
- [ ] Frontmatter is the first content in the file

### Mission Alignment
- [ ] Core mission is singular and transformative
- [ ] Every capability directly enables the mission
- [ ] Required expertise logically supports capabilities
- [ ] Success metrics measure mission achievement

### Clarity & Precision
- [ ] No vague language ("good", "excellent", "effective")
- [ ] Every term has a specific meaning
- [ ] No contradictions between components
- [ ] Role boundaries are clear (what it does + what it doesn't)

### Actionability
- [ ] An LLM can actually perform these capabilities
- [ ] Tasks are observable/measurable
- [ ] Success metrics are achievable (not 100%, not fantasy)
- [ ] Expertise requirements are learnable/developable

### Anti-Pattern Detection
- [ ] No misleading ("80%+ of expert level" but metrics are unrealistic)
- [ ] No scope creep (trying to do too many things)
- [ ] No personality mismatches (ideal candidate contradicts mission)
- [ ] No unmeasurable claims ("high quality", "best practices")

---

## Agent Composition Patterns

### Single-Domain Agents
Expert in one specific area. Examples:
- API Security Reviewer
- Requirements Clarifier
- Test Coverage Analyzer

**When to use**: Deep specialization needed, clear domain boundary

### Multi-Domain Orchestrators
Coordinates across domains. Examples:
- Recruitment Template Architect (recruiter.md)
- Project Phase Manager
- Cross-Domain Risk Assessor

**When to use**: Work spans multiple specializations, needs synthesis

### Quality-Gating Agents
Reviews, validates, critiques other agents' output. Examples:
- Template Critic (what we're building)
- Code Quality Auditor
- Architecture Reviewer

**When to use**: Preventing low-quality outputs, gatekeeping standards

---

## Framework Workflow

> **Authoritative workflow**: See [`BIRTH_ARCHITECTURE.md`](./BIRTH_ARCHITECTURE.md) and [`commands/birth.md`](./commands/birth.md). The v1 Parallel Agent Consensus workflow described below is preserved for historical context but is no longer the default. v2 replaces it with a tiered architecture (Quick / Standard / Deep / Expert), progressive facet elaboration, research grounding for niche domains, and dynamic validation via the new `agent-llm-validator.md` role.

### Historical: Parallel Agent Consensus (v1)

This workflow used **parallel generation + convergent iteration** to achieve agent templates by combining diverse perspectives with rigorous critique. It has been replaced because it (a) applied the same effort to trivial and complex requests, (b) produced redundant parallel drafts rather than specialized facets, (c) lacked external grounding for niche domains, and (d) had no runtime validation of template behavior. v2 addresses all four problems — see `BIRTH_ARCHITECTURE.md`.

### Phase 0: Specification Refinement (Pre-Planning)

**CRITICAL**: Before spawning recruiters, clarify your specification through targeted questioning.

A fuzzy spec produces divergent recruiter outputs. A clear spec produces consensus. This phase transforms rough ideas into actionable specifications.

**Process**:
1. You provide initial agent concept (1-2 sentences)
2. System asks **up to 5 clarifying questions** with multiple-choice options
3. Each option explains how that choice shapes the final agent
4. You answer; system synthesizes refined specification
5. Refined spec is distributed to recruiters (Phase 1)

**What Gets Clarified**:
- **Scope**: Is this a narrow specialist or broad generalist?
- **Depth**: Domain-expert-level or accessible-to-novices level?
- **Primary Use**: Is this for quality gatekeeping, generation, analysis, or coordination?
- **Risk Profile**: How much precision vs. flexibility? Conservative or experimental?
- **Integration**: Does this agent work solo or coordinate with others?

**Questions You'll See** (Examples):

**Q1: Scope Breadth**
- 🎯 Narrow specialist (one specific task, 200+ lines of expertise per task)
- 🌐 Broad generalist (3-5 related tasks, 40+ lines per task)
- Impact: Narrow = very confident outputs, limited flexibility. Broad = more versatile, less confident per domain.

**Q2: Expertise Level Target**
- 👨‍🎓 Expert/Master level (targets top 5% of human practitioners)
- 🏆 Senior/Proficient level (targets top 25% of practitioners)
- Impact: Expert = stricter success metrics, higher quality bar, narrow scope. Senior = balanced, broader scope, achievable metrics.

**Q3: Primary Function**
- ✅ Quality Gate (reviews/critiques others' work)
- 🛠️ Generator (creates new work/artifacts)
- 📊 Analyzer (examines and reports)
- 🎭 Coordinator (orchestrates other agents)
- Impact: Each type has different mission structure, capabilities, and success metrics.

**Q4: Risk & Precision**
- 🛡️ Safety-critical (defaults to conservative, high precision, may miss opportunities)
- ⚡ Speed-optimized (defaults to aggressive, fast outputs, accepts some errors)
- Impact: Safety → longer deliberation, more validation. Speed → quick decisions, potential false positives.

**Q5: Ecosystem Context**
- 🏔️ Standalone (operates independently, must be complete)
- 🤝 Specialist in team (coordinates with other agents, can be narrower)
- Impact: Standalone = must handle broad context. Specialist = can focus narrowly, assume team support.

**When Refinement Happens**:
- **Automatic**: Every time you invoke `/birth "Spec: ..."` (Phase 0 runs first)
- **Manual**: Use `claude-code` to trigger spec refinement independently before running workflow
- **Skippable**: Use `--skip-refinement` flag if spec is already very clear (experienced users only)

**Reference**: See `SPEC_REFINEMENT.md` for detailed explanations of each question, options, and implications.

**Output**: Refined specification document that recruiters use, ensuring all 10 versions start from solid ground.

---

### Phase 1: Define & Distribute
1. Clearly articulate the agent specialization/problem statement
2. Provide domain context and constraints
3. Distribute specification to 10 independent recruiter agents
4. Each recruiter works in isolation (no collaboration/communication)

**Rationale**: Parallel generation produces diverse approaches. A single recruiter might miss important perspectives; 10 recruiters capture the possibility space.

### Phase 2: Parallel Generation (Concurrent)
10 independent `llm-recruiter.md` instances each produce a complete agent template based on the same specification.

Each recruiter independently:
1. Analyzes domain requirements
2. Distills core mission
3. Identifies 3-5 capabilities
4. Defines required expertise
5. Establishes success metrics
6. Sketches ideal candidate profile
7. Writes closing statement

**Result**: 10 distinct agent templates, each internally coherent, each capturing different aspects of the domain.

### Phase 3: Critic Analysis (Convergence Discovery)
The `llm-critic.md` agent reviews all 10 versions and produces a synthesis report:

1. **Consensus Identification**: Which elements appear across multiple versions? (High confidence patterns)
2. **Discrepancy Mapping**: Where do versions diverge? What aspects are emphasized differently?
3. **Quality Assessment**: Which versions demonstrate strongest internal coherence?
4. **Pattern Extraction**: What's truly important vs. what's variant/optional?
5. **Synthesis Recommendation**: Draft structure for merged template incorporating strongest elements

**Critic Output**:
- Detailed analysis of agreements/disagreements
- Identification of 2-3 "core threads" that run through most versions
- List of optional/variant elements (important but not universal)
- Recommended structure for comprehensive draft

### Phase 4: Convergence Loop (up to 5 iterations)

**Iteration 1-5**:

**Step A: Recruiter Synthesis**
- Single recruiter integrates Critic feedback
- Creates ONE comprehensive draft incorporating:
  - Core consensus elements (from most versions)
  - Strategically selected variant elements (strongest alternative approaches)
  - Critic guidance on structure and emphasis

**Step B: Critic Review & Feedback**
- Critic evaluates synthesis against framework standards
- Produces assessment:
  - ✅ Ready for deployment (passes all validation)
  - 🔄 Needs refinement (specific feedback for next iteration)
  - ❌ Major revision needed (too many unresolved tensions)

**Step C: Decision**
- If ✅ Ready for deployment → move to Phase 5
- If 🔄 Needs refinement → return to Step A with updated spec
- If ❌ Major revision → decide whether to loop again or escalate

**Iteration Limit**: Maximum 5 loops before forcing either approval or documentation of irreconcilable tensions. (Prevent infinite refinement; favor completion with documented trade-offs over perfect consensus.)

### Phase 5: Deploy
1. Final Critic approval has been granted
2. Publish template with version history
3. Document key decisions/trade-offs
4. Plan future iterations based on real-world usage
5. Archive all 10 initial versions + synthesis iterations for reference

---

## Parallel Agent Consensus Workflow Summary

```
Spec → [10 Recruiters] → [All 10 Versions]
                              ↓
                         [Critic Analysis]
                              ↓
                     [Consensus Report]
                              ↓
Iteration 1-5:     [Recruiter Synthesis] ↔ [Critic Review]
                              ↓
                        [Final Approval]
                              ↓
                          [Deploy]
```

**Why This Works**:
- **Diversity**: 10 independent perspectives capture the solution space
- **Consensus**: Critic identifies what experts naturally converge on
- **Quality**: Convergence refinement ensures internal coherence
- **Speed**: Parallel generation + bounded iteration prevents endless rework
- **Robustness**: Template must survive critique from multiple angles

---

## Quality Standards

### Template Must Be...

**Clear**: Every sentence has one meaning. No ambiguity about what the agent does.

**Complete**: Reading the template, you understand the full scope. No obvious gaps.

**Consistent**: Components don't contradict. If mission says X, expertise supports X, metrics measure X.

**Concrete**: Vague language replaced with specific examples. "Identify security risks" → "Identify OWASP Top 10 vulnerabilities in API endpoints"

**Calibrated**: Success metrics are achievable but not trivial. Neither "always fails" nor "always succeeds."

---

## Framework Usage in Claude Code

### Standard Workflow (Single Recruiter)
For quick agent creation or testing:
1. Load framework context
2. Draft template using recruiter agent
3. Run critic review
4. Iterate based on feedback
5. Deploy when approved

### Parallel Consensus Workflow (Recommended for Production Agents)
For high-quality agents that will be widely adopted:

Use the custom slash command:
```
/birth "Specialization: [domain description]"
```

This automatically:
1. Spawns 10 independent recruiter agents in parallel
2. Collects all 10 versions
3. Runs critic analysis on all versions
4. Begins convergence loop (up to 5 iterations)
5. Returns final approved template

See `/.claude/commands/birth.md` for detailed usage and customization.

### When to Use Each Approach

**Standard Workflow** when:
- Creating experimental/exploratory agents
- Testing new specializations
- Rapid iteration on personal tools
- Agent variants for different use cases

**Parallel Consensus** when:
- Building agents for team use
- High stakes specializations (security, safety-critical)
- Want diverse perspectives on complex domains
- Planning long-term deployment and evolution
