# Quick Start: Building Your 1000x Agent Team

Your agent generation system is now complete. Here's how to use it.

## The System

**Three core agents**:
- `llm-recruiter.md` → Distills expertise into templates
- `llm-critic.md` → Ensures templates are rigorous
- Framework + workflow → Orchestrates the process

**Two approaches**:

### Approach 1: Quick Agent (Single Recruiter)
For fast prototyping, personal tools, or low-stakes experiments.
```
Spec → Recruiter → Draft → Critic → Iterate → Deploy
Time: ~2 hours
```

### Approach 2: Production Agent (Parallel Consensus) ⭐ RECOMMENDED
For team agents, safety-critical specializations, or long-term deployments.
```
Spec → [10 Recruiters in Parallel] → Critic Analysis → [Up to 5 Iterations] → Deploy
Time: ~25 minutes per generation phase
```

---

## How to Build Your First Production Agent

### Step 1: Choose Your Specialization
What expertise do you want to encode?

Examples:
- API security reviewer
- Database schema auditor
- Performance bottleneck analyzer
- Documentation clarity checker
- Accessibility auditor
- Test coverage strategist

### Step 2: Start the Specification Refinement

```bash
/birth "Specialization: [Your rough idea in 1-2 sentences]"
```

**What happens**: The system triggers Phase 0 automatically, asking you **up to 5 clarifying questions** about:
- **Scope**: Narrow specialist or broad generalist?
- **Depth**: Expert level or senior level?
- **Function**: Quality gate, generator, analyzer, or coordinator?
- **Risk**: Safety-critical or speed-optimized?
- **Context**: Standalone or team specialist?

Each question has multiple-choice options explaining how your choice shapes the final agent.

**Example**:
- You say: "API security reviewer"
- System asks: "Just security vulnerabilities (narrow) or security + patterns + reliability (broad)?"
- You choose: Narrow (just vulnerabilities)
- System refines specification based on your answers

### Step 3: Refined Specification → Recruiters

Once you answer the clarifying questions:
1. System synthesizes a **refined specification** incorporating your answers
2. Specification is distributed to **10 independent recruiters** (Phase 1)
3. Each recruiter produces a complete agent template
4. Critic analyzes all 10 and begins synthesis

No additional action needed—the system handles Phase 1-5 automatically.

### Alternative: Skip Refinement (For Experienced Users)

If you already have a very clear specification:
```bash
/birth --skip-refinement "Specialization: [Very detailed spec]"
```

This skips Phase 0 and goes straight to parallel generation (Phase 1). Use only if your spec is already precise and complete.

The system will:
1. **Spawn 10 independent recruiters** (in parallel, ~5 min)
2. **Receive 10 diverse templates** (each valid, capturing different approaches)
3. **Critic analyzes all 10** (~2 min)
4. **Begins convergence loop** (up to 5 iterations, ~2-3 min each)
5. **Returns final approved template** when critic is satisfied

### Step 4: Review the Results

After execution, you'll have:
- **Final approved agent**: `agents/llm-[agent-name].md`
- **Full history**: `agents-metadata/agents-consensus-[agent-name].json`
  - All 10 initial recruiter versions
  - Critic analysis report
  - All synthesis iterations + feedback
  - Key decisions documented

### Step 5: Deploy

Use your new agent immediately:
```bash
@agents/llm-[agent-name].md
```

Or spawn it as a task agent:
```
Task tool → subagent_type: "[agent-name]"
```

---

## Complete Workflow Diagram

```
YOU
"I want an API security reviewer"
       ↓
    PHASE 0: SPECIFICATION REFINEMENT
    ├─ Question 1: Just security (narrow) or security + patterns (broad)?
    │  → You choose: Just security
    ├─ Question 2: Expert level (top 5%) or senior (top 25%)?
    │  → You choose: Expert level
    ├─ Question 3: Quality gate, generator, analyzer, or coordinator?
    │  → You choose: Quality gate
    ├─ Question 4: Safety-critical or speed-optimized?
    │  → You choose: Safety-critical
    ├─ Question 5: Standalone or team specialist?
    │  → You choose: Team specialist
       ↓
    REFINED SPECIFICATION
    "API Security Validator: Narrow expert-level quality gate,
     safety-critical, team specialist. Identifies OWASP Top 10
     vulnerabilities in REST endpoints."
       ↓
    PHASE 1: PARALLEL RECRUITER POOL (10 agents, working independently)
    ├─ Recruiter 1 → Version A
    ├─ Recruiter 2 → Version B
    ├─ Recruiter 3 → Version C
    ├─ ... (7 more, all using same refined spec)
    └─ Recruiter 10 → Version J
       ↓ (all 10 versions)
    PHASE 3: CRITIC ANALYSIS
    ├─ Consensus: Mission, 3 core capabilities, 5 expertise areas
    │  (All 10 recruiters agreed on these)
    ├─ Variants: 2 alternative approaches to capabilities
    │  (5 recruiters emphasized approach A, 5 emphasized approach B)
    ├─ Quality assessment: Versions C, E, H strongest
    └─ Synthesis recommendation: "Start with C as base, integrate E's insight"
       ↓
    PHASE 4: CONVERGENCE LOOP (up to 5 iterations)
    │
    ├─ Iteration 1:
    │  ├─ RECRUITER SYNTHESIS: Integrates consensus + best variants
    │  ├─ CRITIC REVIEW: 🔄 "Refine capability language for clarity"
    │  └─ ACTION: Update synthesis
    │
    ├─ Iteration 2:
    │  ├─ RECRUITER SYNTHESIS: Strengthens language per feedback
    │  ├─ CRITIC REVIEW: 🔄 "Success metrics need better calibration"
    │  └─ ACTION: Recalibrate metrics
    │
    ├─ Iteration 3:
    │  ├─ RECRUITER SYNTHESIS: Tightens success metrics
    │  ├─ CRITIC REVIEW: ✅ "APPROVED - Ready for deployment"
    │  └─ ACTION: Move to Phase 5
    │
    └─ (iterations 4-5 not needed)
       ↓
    PHASE 5: DEPLOY
    ├─ Final agent template: agents/llm-api-security-validator.md
    ├─ Metadata archive: agents-metadata/agents-consensus-api-security-validator.json
    │  ├─ All 10 initial recruiter versions
    │  ├─ All synthesis iterations
    │  ├─ Critic feedback history
    │  └─ Key decision documentation
    └─ Ready to use: @agents/llm-api-security-validator.md
```

---

## Quality Levels

### Level 1: Quick Prototype
Single recruiter, minimal iteration
- Speed: 30 minutes
- Quality: Good for experimentation
- Use when: Testing new domains, personal tools

### Level 2: Standard Agent
Single recruiter, full critic feedback, 2-3 iterations
- Speed: 2 hours
- Quality: Solid, production-ready for most cases
- Use when: Department/team agents, medium stakes

### Level 3: Mission-Critical Agent (Parallel Consensus) ⭐
10 recruiters, full convergence loop, Critic approval
- Speed: 25-30 minutes of elapsed time
- Quality: Maximum confidence, consensus-driven
- Use when: Company-wide agents, safety-critical, long-term deployment

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `AGENT_FRAMEWORK.md` | Theory: template structure, validation, workflow |
| `llm-recruiter.md` | Recruiter agent template (distills expertise) |
| `llm-critic.md` | Critic agent template (ensures quality) |
| `/birth.md` | Slash command: orchestrates parallel workflow |
| `WORKFLOW.md` | Standard single-recruiter workflow details |
| `QUICK_START.md` | This file (you are here) |

---

## Building Your Agent Library

Once you have the system working, follow this sequence:

### Phase 1: Foundation Agents (Week 1-2)
Create core specialists:
- API security auditor
- Code quality reviewer
- Documentation clarity checker

These are the tools you'll use repeatedly.

### Phase 2: Domain Specialists (Week 3-4)
Expand into specific domains:
- Database schema expert
- Frontend component architect
- Infrastructure reliability engineer

### Phase 3: Orchestrators (Week 5+)
Build agents that coordinate multiple specialists:
- Architecture decision maker
- Cross-domain risk assessor
- Project phase manager

### Phase 4: Advanced Agents (Ongoing)
Specialized quality gates and experimental roles:
- Template critic improvements
- Domain-specific safety validators
- Emerging specializations based on usage patterns

---

## Common Questions

**Q: Why 10 recruiters?**
A: 10 captures diversity without overwhelming the critic. Fewer (5) = faster but less comprehensive. More (15+) = more thorough but longer analysis.

**Q: Why max 5 iterations?**
A: Prevents infinite loops. Most agents approve in 2-3 iterations. 5 is generous buffer before forcing approval with documented trade-offs.

**Q: Can I customize the workflow?**
A: Yes! Use `/birth --recruiters 5 --iterations 8 "Spec"` for custom parameters.

**Q: What if Critic keeps rejecting?**
A: Usually means the spec is ambiguous. Rewrite spec more clearly, or check if domain is too broad.

**Q: Can agents evolve after deployment?**
A: Absolutely. Store metadata, gather real-world feedback, run consensus builder again with improved spec.

**Q: Do I need to use parallel consensus?**
A: No. For quick experiments, use standard single-recruiter workflow. Parallel consensus is for high-stakes/team agents.

---

## Your Next Steps

1. **Read AGENT_FRAMEWORK.md** (understand the theory, 10 min)
2. **Review llm-recruiter.md & llm-critic.md** (see agent structure, 10 min)
3. **Pick your first agent specialization** (what expertise to encode, 5 min)
4. **Run `/birth "Specialization: ..."`** (let the system work, 30 min)
5. **Review results & iterate if needed** (polish based on feedback, 10-30 min)
6. **Deploy & use your new agent** (test in real work, ongoing)

---

## The Vision

You're building a team of 1000x developers where each agent:
- Operates at expert-level proficiency in one domain
- Captures hard-won expertise in crystallized form
- Works reliably with other specialists
- Improves through real-world feedback and iteration

The parallel consensus system ensures each agent in your team:
- ✅ Represents diverse perspectives (10 recruiters)
- ✅ Survives rigorous critique (critic validation)
- ✅ Achieves internal coherence (convergence loop)
- ✅ Meets high quality bar (framework standards)

You're not just creating agents—you're building a cognitive architecture that amplifies human expertise.

Get started. Build your first agent. The system does the hard work.
