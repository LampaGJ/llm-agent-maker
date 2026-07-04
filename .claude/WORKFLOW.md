# Agent Generation Workflow - Using Claude Code

How to efficiently create specialized LLM agents using the framework, critic, and Claude Code.

## Quick Start: Create a New Agent

### Step 1: Plan (5-10 minutes)
```
@claude-code
"I want to create an agent for [specialization]. Here's the domain:"
[describe the expertise area, provide context]
```

Expected output:
- Framework reference
- Phase 1 planning (domain analysis)
- TodoWrite with 5-7 subtasks

### Step 2: Draft Template (30-45 minutes)
Use the framework structure:
1. **Position Title** - 3-6 words, specific specialization
2. **Core Mission** - One sentence, transformative
3. **What You'll Do** - 3-5 capabilities with logical flow
4. **Required Expertise** - 4-8 specific, hard-won skills
5. **Success Metrics** - 3-5 measurable, achievable outcomes
6. **The Ideal Candidate** - Behavioral/cognitive sketch (3-4 paragraphs)
7. **Closing Statement** - One memorable sentence

Save as: `agents/llm-[agent-name].md`

### Step 3: Self-Review Against Framework
Before submitting to critic, validate:

**Mission Alignment**
- [ ] Mission is singular (one thing the agent does)
- [ ] Every capability enables the mission
- [ ] Every expertise requirement supports capabilities
- [ ] Success metrics measure mission achievement

**Clarity & Precision**
- [ ] No vague language ("good", "effective", "best practices")
- [ ] No jargon without definition
- [ ] No contradictions between sections
- [ ] Clear role boundaries (what it is + what it isn't)

**Actionability**
- [ ] An LLM can actually perform these capabilities
- [ ] Success metrics are observable
- [ ] Metrics are achievable (not 100%, not fantasy)
- [ ] Required expertise is transferable via prompt/template

**Anti-Patterns**
- [ ] No misleading success metrics
- [ ] No scope creep (trying to be too many things)
- [ ] No personality mismatches
- [ ] No unmeasurable claims

### Step 4: Critic Review
```
@claude-code
[Reference the Critic agent template]
Review this agent template: agents/llm-[agent-name].md
Use the framework standards to assess it.
```

The Critic will:
- Map component connections
- Identify structural misalignments
- Flag vague language
- Challenge unrealistic expectations
- Propose specific improvements
- Suggest rewrites for weak sections

### Step 5: Iterate
Address critic feedback:
- Small fixes: Make edits directly
- Structural issues: Redesign using Critic suggestions
- Unclear missions: Rewrite to be more specific
- Unrealistic metrics: Recalibrate with expert context

### Step 6: Re-Review
```
@claude-code
I've revised the template based on feedback.
[List changes made]
Second pass review?
```

Iterate until Critic confirms:
- ✅ Mission is clear and achievable
- ✅ Components align
- ✅ Language is precise
- ✅ Metrics are measurable
- ✅ Ready for deployment

### Step 7: Validate with LLM
Test the template with actual usage:
```
@claude-code
Test this template by having an instance of llm-[agent-name]
perform a real task in this domain: [task description]
```

Verify:
- Agent understands its role
- Capabilities execute as intended
- Outputs meet success metric standards
- No unexpected failures or misinterpretations

---

## Workflow Patterns

### Fast Track (Single Domain Agent)
1. Plan (10 min) → Draft (45 min) → Self-review (15 min) → Critic (30 min) → Iterate (30 min) → Done
**Total: ~2 hours per agent**

### Complex Track (Multi-Domain Orchestrator)
1. Plan (30 min) → Research (1 hour) → Draft (1 hour) → Self-review (20 min) → Critic (1 hour) → Iterate (1 hour) → Validate (1 hour) → Done
**Total: ~5-6 hours per agent**

### Parallel Development
Create multiple agent drafts → Submit all to Critic in batch → Iterate simultaneously
(Reduces critic bottleneck when building team of agents)

---

## Framework Reference Quick Links

**AGENT_FRAMEWORK.md**
- Agent template structure (required sections)
- Validation checklist (what makes a good agent)
- Anti-pattern catalog (what to avoid)
- Quality standards (clarity, completeness, consistency)

**llm-critic.md**
- What the Critic evaluates
- How to interpret feedback
- What "ready for deployment" looks like

**llm-recruiter.md**
- The original agent template (reference model)
- Example of complete, validated template

---

## Integration Points

### With Your Global Claude Config
The agent generation system complements your existing Claude Code setup:
- Use the framework for *planning* new agents
- Use the Critic for *quality gatekeeping*
- Agents you create become custom tools for your projects
- Over time, build a library of specialized agents

### With MCP Servers
Once you've created specialized agents, they can integrate with:
- **Sequential MCP**: For agents requiring systematic reasoning
- **Playwright MCP**: For agents testing LLM outputs
- **Context7 MCP**: For agents referencing official docs

### With Your Custom Tools
- Critic agent can be called as a review step in any project workflow
- Template drafts can be version-controlled like code
- Agent library becomes a project asset

---

## Common Pitfalls & How to Avoid Them

**Pitfall 1: Mission Creep**
Agent tries to do too many things (Domain expertise + Teaching + Documentation)
→ Solution: Ask "What's the ONE thing this agent exists for?" Focus mission laser-tight.

**Pitfall 2: Vague Expertise**
"Strong analytical skills" "attention to detail" "domain knowledge"
→ Solution: Be specific. "Identifies SQL injection vectors in parameterized queries" not "security expertise"

**Pitfall 3: Unmeasurable Success**
"Provides high-quality outputs" "improves team velocity" "ensures best practices"
→ Solution: Make metrics concrete. "80%+ of generated specs are implementation-ready without revision"

**Pitfall 4: Mismatch Between Mission & Metrics**
Mission: "Clarify ambiguous requirements"
Metrics: "Reduce implementation time by 40%" ← Wrong! That's a downstream effect, not the core mission.
→ Solution: Metrics should measure the mission directly.

**Pitfall 5: Unrealistic Performance**
"Matches human expert performance" or "99.9% accuracy"
→ Solution: Be honest. Templates guide LLMs to good outputs, not perfect ones. Calibrate metrics to reality.

---

## Building Your Agent Team

### Recommended Sequence
1. **Critic** ← You're building this now
2. **Single-domain specialists** (API reviewer, requirements clarifier, etc.)
3. **Multi-domain orchestrators** (project manager, cross-domain analyzer)
4. **Quality-gating agents** (code reviewer, architecture auditor)

### Why This Order?
- Critic first ensures all subsequent agents meet quality standards
- Single-domain agents are simpler (easier to perfect)
- Orchestrators leverage specialists (build on solid foundations)
- Additional quality gates maintain standards as team grows

---

## Measuring Success

A successful agent generation system looks like:

✅ Templates created at a rate of 1-2 per week
✅ 90%+ of templates pass Critic review within 2 iterations
✅ Agents deployed to projects without major rework
✅ Feedback from LLM execution informs framework improvements
✅ Your specialized agent team becomes a competitive advantage
