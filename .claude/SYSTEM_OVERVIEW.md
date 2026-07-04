# Agent Generation System - Complete Overview

Your system for building a 1000x developer dream team is now complete and optimized.

---

## The Problem You're Solving

Building specialized LLM agents requires:
1. **Capturing expertise** (What do experts know? How do they think?)
2. **Distilling into templates** (How do you encode that expertise?)
3. **Ensuring quality** (Does the template actually work?)
4. **Iterating intelligently** (How do you improve without endless loops?)

**The naive approach**: One person writes one template → critique → iterate
**Time**: 2+ hours per agent. **Quality**: Depends on author's clarity. **Coverage**: Misses alternative approaches.

**Your approach**: Clear spec → 10 diverse templates → synthesis → bounded iteration → deployment
**Time**: 25-30 minutes per agent. **Quality**: Consensus-driven, multiple perspectives. **Coverage**: Comprehensive.

---

## The System Components

### Three Core Agents

**1. Recruiter** (`llm-recruiter.md`)
- **Role**: Master Agent Template Architect
- **Does**: Distills expertise into crystallized agent templates
- **Deployed**: 10 instances in parallel during Phase 1
- **Output**: Complete agent template with all 7 sections

**2. Critic** (`llm-critic.md`)
- **Role**: Template Quality Auditor
- **Does**: Reviews templates for rigor, clarity, actionability
- **Deployed**: Once during Phase 3 (analysis), once per iteration (Phases 4)
- **Output**: Synthesis report, quality assessment, feedback for improvement

**3. Framework** (system architecture + documentation)
- **Does**: Defines template structure, validation standards, workflow phases
- **Output**: Ensures all agents follow consistent quality standards

### Supporting Documentation

| File | Purpose |
|------|---------|
| `AGENT_FRAMEWORK.md` | Template structure, validation, Phase 0-5 workflow |
| `SPEC_REFINEMENT.md` | The 5 clarifying questions with detailed explanations |
| `WORKFLOW.md` | Standard single-recruiter workflow (for quick prototypes) |
| `QUICK_START.md` | Entry point: how to build your first agent |
| `SYSTEM_OVERVIEW.md` | This file (high-level architecture) |

### Automation

**Slash Command** (`/.claude/commands/birth.md`)
```bash
/birth "Specialization: [your rough idea]"
```
Orchestrates the entire workflow automatically:
- Phase 0: Asks clarifying questions
- Phase 1: Spawns 10 recruiters in parallel
- Phase 3: Critic analyzes all 10
- Phase 4: Convergence loop (up to 5 iterations)
- Phase 5: Deploys final agent

---

## The Innovation: Phase 0 (Specification Refinement)

**Why it matters**: A fuzzy spec produces divergent recruiter outputs. A clear spec produces consensus.

**How it works**: Before spawning recruiters, the system asks you **up to 5 clarifying questions**:

1. **Scope**: Narrow specialist (1 task deep) or broad generalist (3-5 tasks)?
2. **Depth**: Expert level (top 5%) or senior level (top 25%)?
3. **Function**: Quality gate, generator, analyzer, or coordinator?
4. **Risk**: Safety-critical (conservative) or speed-optimized (aggressive)?
5. **Context**: Standalone (complete) or team specialist (focused)?

**Impact**: Each answer shapes the final agent's mission, capabilities, expertise areas, success metrics, and ideal candidate profile.

**Example**:
```
You: "API security reviewer"
     ↓
System asks 5 questions
     ↓
You answer: Narrow, expert, quality gate, safety-critical, team specialist
     ↓
Refined spec: "Narrow expert-level quality gate for identifying OWASP
vulnerabilities in REST APIs. Safety-critical (conservative). Team specialist
(assumes architects handle design patterns)."
     ↓
All 10 recruiters receive SAME refined spec → High consensus
```

---

## The Five Phases

### Phase 0: Specification Refinement
- **Input**: Your rough idea (1-2 sentences)
- **Process**: Ask clarifying questions
- **Output**: Refined specification document
- **Impact**: Dramatically improves consensus across 10 recruiters

### Phase 1: Parallel Generation
- **Input**: Refined specification
- **Process**: 10 independent recruiters each produce complete template
- **Output**: 10 distinct agent templates
- **Impact**: Captures diverse approaches to same problem

### Phase 2: (Internal)
- Collect all 10 versions
- Prepare for critic analysis

### Phase 3: Critic Analysis
- **Input**: 10 recruiter versions
- **Process**: Identify consensus, variants, quality assessment
- **Output**: Synthesis report with recommendations
- **Impact**: Reveals what experts naturally agree on

### Phase 4: Convergence Loop (up to 5 iterations)
- **Iteration N**:
  1. Single recruiter synthesizes feedback → creates improved draft
  2. Critic reviews draft → provides feedback or approves
  3. If approved: move to Phase 5; if feedback: loop again
- **Output**: Increasingly refined template
- **Impact**: Ensures quality without infinite loops

### Phase 5: Deploy
- **Input**: Critic-approved template
- **Process**: Archive versions, generate metadata
- **Output**: Deployed agent in `agents/llm-[name].md`
- **Impact**: Ready for immediate use in projects

---

## Workflow Diagram

```
ROUGH IDEA
"I want a security reviewer"
         ↓
    [PHASE 0] CLARIFY SPEC
    - Is this narrow or broad? → Narrow
    - What expertise level? → Expert
    - What function? → Quality gate
    - Risk profile? → Safety-critical
    - Standalone or team? → Team specialist
         ↓
    REFINED SPEC
    "Narrow expert security validator, quality gate, safety-critical, team specialist"
         ↓
    [PHASE 1] RECRUIT PARALLEL
    Recruiter 1 ──┐
    Recruiter 2 ──┤
    Recruiter 3 ──┤ (all in parallel)
    ... (7 more)  │
    Recruiter 10 ──┘
         ↓
    10 VERSIONS GENERATED
         ↓
    [PHASE 3] CRITIC ANALYZES
    - What do all 10 agree on? (Consensus)
    - Where do they differ? (Variants)
    - Which are best? (Quality assessment)
         ↓
    SYNTHESIS REPORT
    "7 versions emphasized narrow focus (good).
     8 versions included OWASP expertise (must-have).
     3 different approaches to success metrics (choose strongest)."
         ↓
    [PHASE 4] CONVERGE (Loop up to 5x)
    Recruiter ──┐
    Synthesis 1 ──→ Critic Review: 🔄 "Refine language"
                ──→ Recruiter Update
                ↓
    Synthesis 2 ──→ Critic Review: ✅ "APPROVED"
         ↓
    [PHASE 5] DEPLOY
    Final Agent: agents/llm-security-validator.md
    Archive: agents-metadata/agents-consensus-security-validator.json
         ↓
    READY TO USE
```

---

## Quality Guarantees

**What Phase 0 ensures**:
- Spec clarity prevents recruiter divergence
- All 10 recruiters interpret scope/depth/function consistently
- Consensus emerges naturally, not artificially

**What Parallel Generation ensures**:
- Multiple perspectives on the same problem
- Captures solution space, not single author's bias
- Diversity strengthens final template

**What Critic Analysis ensures**:
- Identifies what's truly important (consensus patterns)
- Separates core requirements from optional approaches
- Quality assessment prevents weak templates from advancing

**What Convergence Loop ensures**:
- Template is refined until it meets framework standards
- Bounded iteration prevents infinite loops
- Final agent is internally coherent and actionable

---

## How to Use This System

### Quick Start (5 minutes)
```bash
1. Read QUICK_START.md
2. Pick your agent specialization
3. Run: /birth "Specialization: [your idea]"
4. Answer 5 clarifying questions
5. Wait 25-30 minutes
6. Review final approved agent
```

### Deep Dive (1 hour)
```bash
1. Read AGENT_FRAMEWORK.md (understand the phases)
2. Read SPEC_REFINEMENT.md (understand the 5 questions)
3. Read QUICK_START.md (see the flow)
4. Read SYSTEM_OVERVIEW.md (where you are now)
5. Create your first agent
```

### Reference During Development
```bash
- AGENT_FRAMEWORK.md: How template structure works
- SPEC_REFINEMENT.md: What each question means
- QUICK_START.md: Step-by-step walkthrough
```

---

## Common Patterns

### Pattern 1: Standalone Specialist
```
Scope: Narrow
Depth: Expert
Function: Quality Gate
Risk: Safety-Critical
Context: Standalone

Result: Obsessive specialist, highest quality bar
Examples: Security Critic, Template Auditor, Architecture Validator
```

### Pattern 2: Team Generalist
```
Scope: Broad
Depth: Senior
Function: Generator
Risk: Speed-Optimized
Context: Team Specialist

Result: Versatile collaborator, balanced quality, fast output
Examples: Code Generator, Project Manager, Quick Analyzer
```

### Pattern 3: Deep Coordinator
```
Scope: Broad
Depth: Expert
Function: Coordinator
Risk: Safety-Critical
Context: Standalone

Result: Expert synthesizer, comprehensive perspective
Examples: Architecture Decision Maker, Cross-Domain Risk Assessor
```

---

## Success Metrics for the System

✅ **Efficiency**: 25-30 minutes from idea to deployed agent (vs. 2+ hours single-recruiter)

✅ **Quality**: Final agents pass all framework validation checks (mission alignment, clarity, actionability, anti-pattern detection)

✅ **Consensus**: 6+ out of 10 recruiters naturally agree on core elements (indicates clear spec)

✅ **Convergence**: Final approval achieved in ≤3 iterations (indicates good spec + quality synthesis)

✅ **Adoption**: Teams use deployed agents in real workflows without major rework

---

## Building Your Agent Library

**Month 1**: Foundation (Core quality gates)
- API security validator
- Code quality reviewer
- Documentation auditor

**Month 2**: Domain specialists (Expertise-specific)
- Database schema expert
- Frontend architect
- Backend reliability engineer

**Month 3**: Orchestrators (Coordination & synthesis)
- Project phase manager
- Cross-domain risk assessor
- Architecture decision maker

**Month 4+**: Advanced & experimental
- Domain-specific safety validators
- Emerging specializations based on feedback
- Agent evolution cycles (rerun consensus workflow with improved specs)

---

## The Vision

You're building a cognitive architecture where:

- **Each agent** is a distilled expert operating at 80%+ of human expert level
- **Each agent** captures hard-won expertise in a crystallized, reproducible form
- **Each agent** is validated through rigorous critique before deployment
- **Each agent** works reliably in isolation or as part of a coordinated team

Over time, your agent library becomes:
- A competitive advantage (proprietary expertise encoded)
- A knowledge base (documentation of expert patterns)
- A training tool (learning how experts think)
- A force multiplier (enables teams to work at expert level)

This is how you build your 1000x developer dream team.

---

## Next Steps

1. **Read QUICK_START.md** now
2. **Pick a specialization** you care about
3. **Run `/birth "Specialization: [your idea]"`**
4. **Answer the 5 clarifying questions**
5. **Watch the system work**
6. **Deploy and use your first agent**

The system is ready. Build.
