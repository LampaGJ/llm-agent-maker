# Specification Refinement Guide

**Purpose**: Transform rough agent ideas into precise specifications that produce consensus across 10 independent recruiters.

## Why This Matters

A vague spec causes divergence:
- Recruiter A interprets it narrowly → Expert-level deep specialist
- Recruiter B interprets it broadly → Versatile generalist
- Recruiter C interprets it differently → Hybrid approach
- Result: 10 conflicting templates, hard to synthesize

A clear spec produces consensus:
- All 10 recruiters understand the scope, depth, function, risk profile, and context
- They diverge on implementation details, not on fundamentals
- Critic synthesis is clean and coherent

## The Five Clarifying Questions

### Question 1: Scope Breadth
**"How many distinct tasks should this agent handle?"**

#### Option A: Narrow Specialist 🎯
**One specific task, deeply.**
- Example: "API endpoint security validation" (not general API review, specifically security)
- Example: "PostgreSQL schema anti-pattern detection" (not all databases)
- Required Expertise: 200+ lines per capability
- Mission: Singular, laser-focused
- Success Metrics: Very high precision (95%+)

**Impact on Final Agent**:
- Mission is crystal clear ("Identify OWASP Top 10 vulnerabilities in REST APIs")
- 3-5 capabilities all support that ONE mission
- Expertise is deep and specific
- Ideal candidate is obsessed with one domain
- Success metrics are stringent

**When to choose**:
- You're building a quality gate (critic, reviewer, validator)
- The domain is well-defined with clear boundaries
- High precision matters more than versatility

#### Option B: Broad Generalist 🌐
**3-5 related tasks, each moderately deep.**
- Example: "Database schema design and optimization" (schema design + performance + scaling)
- Example: "API robustness" (security + performance + reliability + testing)
- Required Expertise: 40+ lines per capability
- Mission: Transformative but encompasses multiple domains
- Success Metrics: Balanced (80%+ competence across all areas)

**Impact on Final Agent**:
- Mission is broader ("Improve overall API robustness across security, performance, and reliability")
- 4-5 capabilities address different aspects
- Expertise spans multiple domains
- Ideal candidate is a thoughtful generalist
- Success metrics are achievable across all areas

**When to choose**:
- You're building a generator or analyst (needs flexibility)
- The domain naturally spans multiple related areas
- Versatility matters more than absolute depth

#### What This Determines
- **Scope of expertise**: Narrow = very deep in one area. Broad = competent in several.
- **Flexibility**: Narrow = very focused outputs. Broad = adaptable to variations.
- **Team role**: Narrow = specialist. Broad = can work across domains.
- **Success definition**: Narrow = precision. Broad = balanced competence.

---

### Question 2: Expertise Level Target
**"What level of human expertise should this agent match?"**

#### Option A: Expert/Master Level 👨‍🎓
**Top 5% of human practitioners in this domain.**
- Thinks like the world's best practitioners
- Catches subtle, non-obvious issues
- Applies domain patterns most people don't know exist
- Highly opinionated (knows what's right)
- Example: "API design expert with 15+ years shipping large systems"

**Impact on Final Agent**:
- Mission is ambitious: "Ensure APIs follow world-class design patterns"
- Success metrics are strict: "Identifies 95%+ of design anti-patterns"
- Required expertise is extensive (6-8 areas, very specific)
- Ideal candidate: "You've designed 50+ major APIs, trained others"
- Risk profile: Lower tolerance for "good enough" answers

**When to choose**:
- This is a critical quality gate (security, architecture review)
- Highest quality bar is non-negotiable
- Team will trust this agent's judgment over their own

#### Option B: Senior/Proficient Level 🏆
**Top 25% of human practitioners.**
- Solid expertise, knows best practices
- Reliable judgments, good coverage
- Applies known patterns consistently
- Balanced opinions (knows what works, acknowledges trade-offs)
- Example: "Senior engineer with 7-10 years, ships solid code regularly"

**Impact on Final Agent**:
- Mission is achievable: "Apply proven patterns to improve code quality"
- Success metrics are realistic: "80%+ of recommendations are improvements"
- Required expertise is moderate (4-6 areas, well-chosen)
- Ideal candidate: "You've done this successfully 100+ times"
- Risk profile: Balanced between quality and speed

**When to choose**:
- This is a general-purpose tool (generation, analysis, coordination)
- Quality matters but perfect is enemy of good
- Team will use this in their daily workflow

#### What This Determines
- **Success metrics**: Expert = 95%+ precision. Senior = 80%+ improvement.
- **Expertise breadth**: Expert = 6-8 deep areas. Senior = 4-6 well-chosen areas.
- **Risk tolerance**: Expert = conservative, careful. Senior = balanced.
- **Achievability**: Expert = harder to validate. Senior = easier to validate in practice.

---

### Question 3: Primary Function
**"What does this agent do fundamentally?"**

#### Option A: Quality Gate ✅
**Reviews, validates, critiques work by others.**
- Examples: Code reviewer, architecture auditor, security validator, template critic
- Mission structure: "Ensure X meets standards for Y"
- Capabilities: Validation, issue identification, improvement suggestions, standards enforcement
- Success metrics: "Catches 95%+ of issues before they reach production"

**Impact on Final Agent**:
- Expertise centers on standards, patterns, what's broken
- Ideal candidate: "You've reviewed 1000+ projects"
- Closing statement: Focus on gatekeeping/protection
- Risk profile: Prefers false positives to false negatives (better to flag something good than miss something bad)

#### Option B: Generator 🛠️
**Creates new work/artifacts based on specifications.**
- Examples: Code generator, documentation writer, architecture designer, template creator
- Mission structure: "Transform X into high-quality Y"
- Capabilities: Analysis, synthesis, creation, optimization
- Success metrics: "90%+ of generated work is immediately useful"

**Impact on Final Agent**:
- Expertise centers on patterns, frameworks, synthesis
- Ideal candidate: "You've created 500+ quality artifacts"
- Closing statement: Focus on capability and creativity
- Risk profile: Prefers false negatives (missing corner cases acceptable if output is good)

#### Option C: Analyzer 📊
**Examines existing work and reports findings.**
- Examples: Performance analyzer, test coverage calculator, dependency analyzer, metrics reporter
- Mission structure: "Understand X and reveal hidden patterns/problems"
- Capabilities: Analysis, pattern detection, reporting, recommendation
- Success metrics: "Reports are actionable; teams implement 70%+ of recommendations"

**Impact on Final Agent**:
- Expertise centers on diagnostics and clarity
- Ideal candidate: "You understand why things break and how to fix them"
- Closing statement: Focus on insight and clarity
- Risk profile: Balanced (accurate analysis matters, but perfect coverage not required)

#### Option D: Coordinator 🎭
**Orchestrates other agents or experts; synthesizes results.**
- Examples: Project phase manager, cross-domain risk assessor, system architect, team lead
- Mission structure: "Coordinate X to achieve Y across multiple domains"
- Capabilities: Analysis, synthesis, decision-making, prioritization, delegation
- Success metrics: "Teams report higher clarity and efficiency after consultation"

**Impact on Final Agent**:
- Expertise centers on systems thinking and judgment
- Ideal candidate: "You've successfully led complex multi-team initiatives"
- Closing statement: Focus on orchestration and synthesis
- Risk profile: Prefers clarity and decisiveness to perfect accuracy

#### What This Determines
- **Mission wording**: Each type has different natural missions
- **Capability structure**: Different functions have different capability sets
- **Success metrics**: Quality gates measure differently than generators
- **Expertise profile**: Each function emphasizes different expertise areas
- **Risk profile**: Conservative gatekeeping vs. creative generation

---

### Question 4: Risk & Precision Profile
**"How should this agent balance precision vs. flexibility?"**

#### Option A: Safety-Critical 🛡️
**High precision, conservative, deliberative.**
- Defaults to skepticism
- Prefers to flag uncertainty rather than guess
- Thorough validation before proceeding
- Example: Security validator, compliance checker, safety auditor

**Impact on Final Agent**:
- Mission: "Ensure no security vulnerabilities slip through"
- Capabilities: Include validation, verification, confirmation steps
- Required Expertise: Include risk identification, edge case thinking
- Success Metrics: "Catches 99%+ of potential issues" (high recall)
- Ideal Candidate: "You think like a security auditor; you find problems others miss"
- Trade-off: May be slower, may flag false positives, but minimizes false negatives

**When to choose**:
- Consequences of failure are severe (security, safety, compliance)
- Quality matters more than speed
- Better to over-flag than under-flag

#### Option B: Speed-Optimized ⚡
**Fast decisions, aggressive, creative.**
- Defaults to action unless strong evidence against
- Acceptable to miss edge cases if core output is good
- Quick validation before proceeding
- Example: Code generator, quick analyzer, rapid prototyper

**Impact on Final Agent**:
- Mission: "Quickly identify and recommend improvements"
- Capabilities: Emphasize rapid analysis and generation
- Required Expertise: Include pattern matching and decision heuristics
- Success Metrics: "90%+ of recommendations are valuable" (high precision)
- Ideal Candidate: "You make good decisions quickly; you're not afraid to move forward with 80% information"
- Trade-off: May miss subtle issues, but delivers fast, actionable insights

**When to choose**:
- Speed to value matters (daily workflow tool)
- Cost of delay exceeds cost of occasional false negatives
- Team will validate before acting on recommendations

#### What This Determines
- **Expertise emphasis**: Safety = risk identification. Speed = pattern heuristics.
- **Validation approach**: Safety = multi-stage confirmation. Speed = quick checks.
- **Failure tolerance**: Safety = minimize false negatives. Speed = minimize false positives.
- **Ideal candidate profile**: Safety = cautious expert. Speed = decisive expert.
- **Success metrics**: Safety = recall-focused. Speed = precision-focused.

---

### Question 5: Ecosystem Context
**"Does this agent work alone or as part of a team?"**

#### Option A: Standalone 🏔️
**Operates independently; must be complete and comprehensive.**
- Doesn't assume other agents exist
- Must handle broad contexts
- Self-sufficient in its domain
- Example: Single-domain specialist that works without team support

**Impact on Final Agent**:
- Mission: Standalone, complete ("Provide comprehensive security review")
- Capabilities: Must be comprehensive (5 full capabilities)
- Required Expertise: Must cover all necessary knowledge (6-8 expertise areas)
- Scope: Naturally broader (must handle variations alone)
- Ideal Candidate: "You're completely self-sufficient; you don't need to ask for help"
- Success Metrics: "Handles 95%+ of realistic scenarios without support"

**When to choose**:
- This agent will be deployed in isolation
- No other supporting agents exist yet
- Must be the complete solution for its domain

#### Option B: Specialist in Team 🤝
**Coordinates with other agents; can be narrower and deeper.**
- Assumes other agents handle complementary domains
- Can focus narrowly on its specialty
- Passes context to team members when needed
- Example: Security reviewer in team with performance analyst, architect, etc.

**Impact on Final Agent**:
- Mission: Focused ("Identify security vulnerabilities"; assumes others handle performance, scalability, etc.)
- Capabilities: Can be fewer, more specialized (3-4 deep capabilities)
- Required Expertise: Can be deep in fewer areas (4-5 expertise areas)
- Scope: Naturally narrower (team handles breadth)
- Ideal Candidate: "You're expert in your domain; you know when to involve specialists from other areas"
- Success Metrics: "Your reviews are thorough in your domain; team appreciates your focus"

**When to choose**:
- This is part of a larger agent ecosystem
- Other agents handle complementary domains
- Team benefits from specialized depth vs. generalist breadth

#### What This Determines
- **Mission scope**: Standalone = broad and complete. Team = narrow and deep.
- **Capability count**: Standalone = 5 full capabilities. Team = 3-4 focused capabilities.
- **Expertise breadth**: Standalone = 6-8 areas. Team = 4-5 areas.
- **Integration points**: Standalone = self-contained. Team = coordinates/delegates.
- **Success metrics**: Standalone = "handles everything." Team = "handles your part excellently."

---

## How Answers Shape the Final Agent

These five answers converge on a profile:

```
Scope:    Narrow → Expert → Safety-Critical → Standalone
                  ↓        ↓                 ↓
Result:   Obsessive specialist, highest quality bar, gatekeeping function
Examples: Security Critic, Template Auditor, Architecture Validator

---

Scope:    Broad → Senior → Speed-Optimized → Team
                ↓        ↓                 ↓
Result:   Versatile generalist, balanced quality, coordination function
Examples: Project Manager, Code Generator, System Analyst

---

Scope:    Narrow → Expert → Speed-Optimized → Standalone
                  ↓        ↓                 ↓
Result:   Deep specialist willing to move fast, creative solutions
Examples: Specialized Code Generator, Domain Architect
```

## Using These Questions

When you trigger specification refinement (Phase 0):

1. **You state initial idea** ("I want to build an API security agent")
2. **System asks up to 5 questions** (one from each category above)
3. **You select options** that feel right for your use case
4. **System generates refined spec** incorporating your answers
5. **Recruiters receive precise specification** → Better consensus → Stronger final agent

## Example: Specification Refinement in Action

**You say**: "I want a security agent for APIs"

**System asks**:
1. **Scope**: Just security vulnerabilities (Narrow) or security + design patterns + reliability (Broad)?
   - You choose: Narrow (just security)

2. **Expertise**: World-class expert (top 5%) or solid senior-level (top 25%)?
   - You choose: Expert (security is critical)

3. **Function**: Quality gate (review others' APIs) or generator (create secure APIs) or analyzer (assess risk)?
   - You choose: Quality gate (you want it to validate before deployment)

4. **Risk Profile**: Safety-critical (flag everything suspicious) or speed-optimized (quick high-confidence checks)?
   - You choose: Safety-critical (security breaches are expensive)

5. **Ecosystem**: Standalone (complete solution) or specialist in team (coordinates with other agents)?
   - You choose: Specialist in team (team has architects, performance analysts)

**Refined Specification Generated**:
```
AGENT: API Security Validator
SCOPE: Narrow specialist (OWASP vulnerabilities in REST APIs)
EXPERTISE: Expert-level (top 5% of security practitioners)
FUNCTION: Quality gate (validates APIs before deployment)
RISK: Safety-critical (high precision, conservative validation)
CONTEXT: Specialist in team (delegates architectural concerns to team)

IMPLICATIONS:
- Mission: Singular and precise (identify security vulnerabilities)
- Capabilities: 3-4 focused on security validation
- Expertise: 6-8 deep security-specific areas
- Success Metrics: 99%+ precision (catches vulnerabilities, minimizes false positives)
- Ideal Candidate: "You've found and fixed 500+ security issues"
```

**All 10 recruiters receive this refined spec** → Consensus emerges around a tight, coherent template.

---

## Tips for Clear Answers

- **Be honest**: Don't oversell. If you want a generalist, say so.
- **Consider your context**: Answer for how you'll actually use this, not how you wish you could use it.
- **Trade-offs are real**: Narrow ≠ better than broad. Expert ≠ better than senior. Each has benefits.
- **Consistency**: If you pick "standalone," you probably shouldn't also pick "specialist in team."
- **Iterate**: You can run phase 0 multiple times if your first answers aren't quite right.

---

## FAQs

**Q: What if I'm between two options?**
A: You can pick both (in the actual implementation, you'll be asked to select one, but you can note uncertainty). The refined spec will average them. Or use this as a signal to clarify your thinking first.

**Q: Can I change my mind after phase 0?**
A: Yes. If recruiters' output doesn't match expectations, rerun phase 0 with adjusted answers and generate again.

**Q: What if my agent doesn't fit these categories?**
A: Unlikely, but possible. Use the closest match and note what's different. System will adapt.

**Q: Do I need to answer all 5 questions?**
A: The system asks "up to 5" — it might ask 3-5 depending on your initial spec's clarity.
