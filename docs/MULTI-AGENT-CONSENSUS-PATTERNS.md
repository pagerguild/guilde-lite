# Multi-Agent Consensus Patterns for LLM Workflows

A comprehensive analysis of multi-LLM consensus approaches, including Andrej Karpathy's LLM Council, Mixture-of-Agents (MoA), and practical recommendations for Claude Code subagent workflows.

---

## Table of Contents

1. [LLM Council by Andrej Karpathy](#llm-council-by-andrej-karpathy)
2. [Mixture-of-Agents (MoA) Architecture](#mixture-of-agents-moa-architecture)
3. [Multi-Agent Debate (MAD) Frameworks](#multi-agent-debate-mad-frameworks)
4. [Voting vs Consensus Mechanisms](#voting-vs-consensus-mechanisms)
5. [ReConcile: Confidence-Weighted Consensus](#reconcile-confidence-weighted-consensus)
6. [Practical Implementation Patterns](#practical-implementation-patterns)
7. [Claude Code Subagent Applications](#claude-code-subagent-applications)
8. [Evaluation Metrics and Benchmarks](#evaluation-metrics-and-benchmarks)
9. [Best Practices and Recommendations](#best-practices-and-recommendations)

---

## LLM Council by Andrej Karpathy

**Repository:** [github.com/karpathy/llm-council](https://github.com/karpathy/llm-council)

### Overview

LLM Council is a local web application that enables comparative evaluation of multiple large language models simultaneously. Rather than querying a single LLM, users assemble their preferred models into a "council" that collaboratively addresses complex questions.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      User Query                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 Stage 1: Individual Responses               │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │  GPT-4  │  │ Claude  │  │ Gemini  │  │  Grok   │        │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│            Stage 2: Peer Review (Anonymized)                │
│  Each model ranks other models' responses for accuracy      │
│  and insight WITHOUT knowing model identities               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Stage 3: Chairman Synthesis                    │
│  Designated model synthesizes all responses + reviews       │
│  into unified final answer                                  │
└─────────────────────────────────────────────────────────────┘
```

### Three-Stage Consensus Process

| Stage | Description | Key Feature |
|-------|-------------|-------------|
| **Stage 1** | Individual Responses | Each LLM generates independent response to query |
| **Stage 2** | Peer Review | Models rank others' responses (anonymized to prevent brand bias) |
| **Stage 3** | Synthesis | Chairman model integrates all responses + reviews |

### Council Composition

The configuration supports customization via `backend/config.py`:
- GPT models (via OpenRouter)
- Gemini models
- Claude models
- Grok models
- Any OpenRouter-compatible model

### Key Design Decisions

1. **Anonymized Peer Review**: Models cannot identify which response came from which model, preventing loyalty bias
2. **Hierarchical Consensus**: Chairman serves as final arbiter rather than algorithmic voting
3. **Qualitative Rankings**: Peer review produces rankings, not numerical scores

### Technical Stack

- **Backend**: FastAPI (Python 3.10+)
- **Frontend**: React + Vite
- **API Integration**: Async httpx for concurrent OpenRouter calls
- **Data Persistence**: JSON files in `data/conversations/`

---

## Mixture-of-Agents (MoA) Architecture

**Research Paper:** [arxiv.org/abs/2406.04692](https://arxiv.org/abs/2406.04692) (ICLR 2025 Spotlight)

### Overview

MoA is a layered architecture where each layer comprises multiple LLM agents. Each agent receives outputs from previous layer agents as auxiliary information when generating responses.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        User Query                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Layer 1 (Proposers)                      │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │  LLM A  │  │  LLM B  │  │  LLM C  │  │  LLM D  │        │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘        │
└─────────────────────────────────────────────────────────────┘
                              │ (all responses as context)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Layer 2 (Refiners)                       │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │  LLM E  │  │  LLM F  │  │  LLM G  │  │  LLM H  │        │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Final Layer (Aggregator)                   │
│                    ┌─────────────────┐                      │
│                    │   Aggregator    │                      │
│                    └─────────────────┘                      │
└─────────────────────────────────────────────────────────────┘
```

### Performance Results

| Benchmark | MoA Score | GPT-4 Omni Score |
|-----------|-----------|------------------|
| AlpacaEval 2.0 | **65.1%** | 57.5% |
| MT-Bench | Surpassed | Baseline |
| FLASK | Surpassed | Baseline |

### Self-MoA vs Standard MoA

**Research:** [arxiv.org/abs/2502.00674](https://arxiv.org/abs/2502.00674)

A surprising finding: **Self-MoA** (using only the single top-performing LLM) often outperforms standard MoA that mixes different LLMs.

| Approach | AlpacaEval 2.0 | Average Improvement |
|----------|----------------|---------------------|
| Standard MoA | Baseline | - |
| Self-MoA | +6.6% | +3.8% across benchmarks |

**Key Insight**: MoA performance is highly sensitive to quality. Mixing different LLMs often lowers average quality, negating diversity benefits.

### When to Use Each Approach

| Use Standard MoA When | Use Self-MoA When |
|-----------------------|-------------------|
| Models have complementary expertise | You have one clearly superior model |
| Domain requires diverse perspectives | Quality consistency matters most |
| Tasks benefit from reasoning diversity | Cost optimization is priority |
| Combining specialized + generalist models | Single model covers task domain well |

---

## Multi-Agent Debate (MAD) Frameworks

### Overview

Multiple LLM agents propose answers, debate reasoning, and converge through iterative discussion rounds.

### Standard MAD Architecture

```
Round 0: Independent Response Generation
         ┌─────────┐  ┌─────────┐  ┌─────────┐
         │ Agent A │  │ Agent B │  │ Agent C │
         └────┬────┘  └────┬────┘  └────┬────┘
              │            │            │
              ▼            ▼            ▼
         Response A   Response B   Response C

Round 1: Debate (agents see all responses)
         ┌─────────────────────────────────────┐
         │ Each agent receives all responses   │
         │ and critiques/updates their answer  │
         └─────────────────────────────────────┘

Round 2+: Continue until consensus or max rounds

Final: Majority Vote or Judge Selection
```

### Adaptive Heterogeneous MAD (A-HMAD)

**Research:** [link.springer.com/article/10.1007/s44443-025-00353-3](https://link.springer.com/article/10.1007/s44443-025-00353-3)

Standard debate uses homogeneous agents with simple majority voting. A-HMAD uses heterogeneous agents with adaptive mechanisms.

| Benchmark | Single CoT | Standard MAD | A-HMAD |
|-----------|-----------|--------------|--------|
| GSM8K | 77.0% | 84.0% | **90.2%** |
| Improvement | - | +7.0% | +13.2% |

### Recent Research Findings

**"Debate or Vote: Which Yields Better Decisions?"** ([arxiv.org/html/2508.17536v1](https://arxiv.org/html/2508.17536v1))

Key findings across 7 benchmarks (GSM8K, MMLU, HellaSwag, CommonsenseQA):

1. **Majority Voting alone accounts for most performance gains** typically attributed to MAD
2. **Debate provides marginal gains** only with heterogeneous agents with distinct personas
3. **Voting is substantially more efficient** computationally

**Recommendation**: Default to majority voting; consider debate only with complementary expertise agents.

---

## Voting vs Consensus Mechanisms

### Comparison of Decision Protocols

| Protocol | Description | Best For | Computational Cost |
|----------|-------------|----------|-------------------|
| **Majority Voting** | Simple count of most common answer | Quick decisions, reasoning tasks | Low |
| **Weighted Voting** | Votes weighted by model performance | When model quality varies | Low-Medium |
| **Confidence-Weighted** | Weight by confidence scores | Uncertain responses | Medium |
| **Multi-Round Debate** | Iterative discussion + voting | Complex reasoning | High |
| **Judge Model** | Single arbiter evaluates all | When clear expertise hierarchy | Medium |
| **Consensus Building** | Continue until agreement | High-stakes decisions | Very High |

### Implementation Pattern: Weighted Voting

```python
# Example from tutorial-llm-voting-systems
# https://github.com/stephenc222/tutorial-llm-voting-systems

def weighted_vote(responses: list[dict], weights: dict[str, float]) -> str:
    """
    responses: [{"model": "gpt-4", "answer": "A"}, ...]
    weights: {"gpt-4": 0.4, "claude": 0.35, "gemini": 0.25}
    """
    scores = defaultdict(float)
    for response in responses:
        model = response["model"]
        answer = response["answer"]
        scores[answer] += weights.get(model, 1.0)

    return max(scores, key=scores.get)
```

### PolyCouncil: Rubric-Based Consensus

**Repository:** [github.com/TrentPierce/PolyCouncil](https://github.com/TrentPierce/PolyCouncil)

Four-stage consensus mechanism:

1. **Parallel Execution**: Models answer simultaneously
2. **Cross-Evaluation**: Each model scores others using shared rubric (accuracy, clarity, completeness)
3. **Weighted Voting**: Higher-performing evaluators get greater influence
4. **Democratic Consensus**: Winning response emerges through weighted preferences

---

## ReConcile: Confidence-Weighted Consensus

**Research:** [arxiv.org/abs/2309.13007](https://arxiv.org/abs/2309.13007)

### Architecture

ReConcile implements a "round-table conference" among diverse LLM agents with confidence-weighted voting.

```
┌─────────────────────────────────────────────────────────────┐
│                    Round N Discussion                        │
│                                                              │
│  Discussion Prompt Components:                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ 1. Grouped answers/explanations from previous round    │ │
│  │ 2. Confidence scores from each agent                   │ │
│  │ 3. Answer-rectifying human explanations (few-shot)     │ │
│  └────────────────────────────────────────────────────────┘ │
│                              │                               │
│                              ▼                               │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                      │
│  │ Agent A │  │ Agent B │  │ Agent C │                      │
│  │ conf=85 │  │ conf=72 │  │ conf=91 │                      │
│  └─────────┘  └─────────┘  └─────────┘                      │
│                              │                               │
│                              ▼                               │
│            Confidence-Weighted Final Vote                    │
└─────────────────────────────────────────────────────────────┘
```

### Performance Results

- **Up to 11.4% improvement** over single-agent and prior multi-agent baselines
- **Outperforms GPT-4** on three datasets
- **8% improvement on MATH** with domain-specific model combinations

### Key Success Factor

**Model diversity is critical** - combining different model architectures (API-based, open-source, domain-specific) produces best results.

---

## Practical Implementation Patterns

### Pattern 1: Fan-Out (Parallel Execution)

```
┌─────────────────────────────────────────────────────────────┐
│                    Orchestrator                              │
│                         │                                    │
│     ┌───────────────────┼───────────────────┐               │
│     │                   │                   │               │
│     ▼                   ▼                   ▼               │
│ ┌─────────┐       ┌─────────┐       ┌─────────┐            │
│ │ Agent 1 │       │ Agent 2 │       │ Agent 3 │            │
│ │(Review) │       │(Security)│      │(Perf)   │            │
│ └─────────┘       └─────────┘       └─────────┘            │
│     │                   │                   │               │
│     └───────────────────┼───────────────────┘               │
│                         ▼                                    │
│               Consolidation + Consensus                      │
└─────────────────────────────────────────────────────────────┘
```

**Use Case**: Code review with multiple specialized reviewers

### Pattern 2: Pipeline (Sequential with Dependencies)

```
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐  │
│  │ Planner │ -> │ Coder   │ -> │ Tester  │ -> │Reviewer │  │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘  │
│                                                              │
│  Each stage waits for previous to complete                   │
│  Output files serve as input for next stage                  │
└─────────────────────────────────────────────────────────────┘
```

**Use Case**: Feature development with plan -> implement -> test -> review

### Pattern 3: Map-Reduce (Distributed Processing)

```
┌─────────────────────────────────────────────────────────────┐
│                       Large Task                             │
│                           │                                  │
│              ┌────────────┼────────────┐                    │
│              │            │            │                    │
│              ▼            ▼            ▼                    │
│         ┌────────┐   ┌────────┐   ┌────────┐               │
│   MAP:  │Chunk 1 │   │Chunk 2 │   │Chunk 3 │               │
│         └────────┘   └────────┘   └────────┘               │
│              │            │            │                    │
│              └────────────┼────────────┘                    │
│                           ▼                                  │
│         ┌─────────────────────────────────┐                 │
│ REDUCE: │    Aggregate Results            │                 │
│         └─────────────────────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

**Use Case**: Large codebase migration, documentation generation

### Pattern 4: Consensus Verification

```
┌─────────────────────────────────────────────────────────────┐
│                    Implementation                            │
│                         │                                    │
│                         ▼                                    │
│     ┌─────────────────────────────────────┐                 │
│     │          Verification Layer          │                 │
│     │   ┌─────────┐  ┌─────────┐          │                 │
│     │   │Verifier1│  │Verifier2│          │                 │
│     │   │(Tests)  │  │(Types)  │          │                 │
│     │   └─────────┘  └─────────┘          │                 │
│     │           │          │               │                 │
│     │           ▼          ▼               │                 │
│     │      Consensus Check (≥2/3)          │                 │
│     └─────────────────────────────────────┘                 │
│                         │                                    │
│              ┌──────────┴──────────┐                        │
│              ▼                     ▼                         │
│         [PASS]                [FAIL]                         │
│         Continue              Fix + Retry                    │
└─────────────────────────────────────────────────────────────┘
```

**Use Case**: High-confidence code changes, security-sensitive operations

---

## Claude Code Subagent Applications

### Official Subagent Capabilities

From [Claude Code Documentation](https://code.claude.com/docs/en/sub-agents):

**Subagents provide:**
- Isolated context windows with custom system prompts
- Specific tool access restrictions
- Independent permissions
- Model routing (e.g., Haiku for exploration, Opus for complex reasoning)

**Limitations:**
- Cannot spawn other subagents (no nesting)
- No interactive "thinking" mode
- Results returned only after completion

### Recommended Multi-Agent Workflow Patterns

#### 1. Verification Subagents

```markdown
# System Prompt: Code Verification Agent

You are a verification specialist. Your role is to:
1. Review implementation for correctness
2. Verify it doesn't overfit to specific tests
3. Check for edge cases and error handling
4. Confirm adherence to coding standards

Return a structured report with:
- PASS/FAIL status
- Issues found (if any)
- Confidence score (0-100)
```

**Usage**: Spawn 2-3 verification subagents with different focus areas after implementation.

#### 2. Exploration Subagents (Built-in)

Claude Code's built-in Explore Subagent (v2.0.17) uses Haiku for context-efficient codebase exploration.

**Best Practice**: Use exploration subagents early in conversations to preserve main context.

#### 3. Independent Review Subagents

```python
# Pseudocode for consensus-based review

async def multi_agent_review(code_diff: str) -> ReviewResult:
    reviewers = [
        spawn_subagent("security-reviewer", SECURITY_PROMPT),
        spawn_subagent("performance-reviewer", PERF_PROMPT),
        spawn_subagent("maintainability-reviewer", MAINT_PROMPT),
    ]

    results = await asyncio.gather(*[r.review(code_diff) for r in reviewers])

    # Consensus: require 2/3 approval
    approvals = sum(1 for r in results if r.approved)
    consensus = approvals >= len(reviewers) * 2 / 3

    return ReviewResult(
        approved=consensus,
        concerns=merge_concerns(results),
        confidence=calculate_confidence(results)
    )
```

### Multi-Agent Orchestration Tools

| Tool | Description | URL |
|------|-------------|-----|
| **CC Mirror** | Built-in orchestration with dependency graphs | Hidden in Claude Code |
| **Claude-Flow** | Enterprise agent swarm coordination | [github.com/ruvnet/claude-flow](https://github.com/ruvnet/claude-flow) |
| **CCSwarm** | Rust-native multi-agent with git worktree isolation | [github.com/nwiizo/ccswarm](https://github.com/nwiizo/ccswarm) |
| **Agentic Research Orchestrator** | Gemini + Copilot + Claude consensus | [github.com/weorbitant/claude-code-agentic-research-orchestrator](https://github.com/weorbitant/claude-code-agentic-research-orchestrator) |

### Coordination Best Practices

From [Anthropic Engineering Blog](https://www.anthropic.com/engineering/claude-code-best-practices):

1. **Shared Scratchpads**: Use markdown files or GitHub issues as communication hubs
2. **Git Worktrees**: Run parallel sessions on different branches
3. **Headless Mode**: Use `-p` flag for programmatic orchestration
4. **Dependency Checking**: Ask "Will Agent B need to READ Agent A's output?" to determine parallel vs sequential

---

## Evaluation Metrics and Benchmarks

### Standard Benchmarks for Multi-Agent Systems

| Benchmark | Focus | Tasks | Typical Improvement |
|-----------|-------|-------|---------------------|
| **AlpacaEval 2.0** | Instruction following | General tasks | +5-8% with MoA |
| **MT-Bench** | Multi-turn conversation | Dialog quality | +3-6% with debate |
| **GSM8K** | Math reasoning | Grade school math | +7-13% with A-HMAD |
| **MMLU** | Knowledge breadth | 57 subjects | +2-4% with ensemble |
| **MATH** | Advanced math | Competition problems | +8% with ReConcile |
| **HumanEval** | Code generation | Python coding | +5-10% with verification |

### Evaluation Dimensions

```
┌─────────────────────────────────────────────────────────────┐
│                 Multi-Agent Evaluation Matrix               │
│                                                              │
│  Accuracy     ████████████████████░░░░░  80%                │
│  Consistency  ███████████████░░░░░░░░░░  60%                │
│  Latency      █████████░░░░░░░░░░░░░░░░  40%                │
│  Cost         ████████████░░░░░░░░░░░░░  50%                │
│  Consensus    ██████████████░░░░░░░░░░░  55%                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Key Metrics to Track

1. **Agreement Rate**: Percentage of queries where agents reach consensus
2. **Confidence Calibration**: How well confidence scores predict accuracy
3. **Debate Efficiency**: Rounds needed to reach consensus
4. **Quality Improvement**: Accuracy gain over single-agent baseline
5. **Cost Multiplier**: Additional API calls vs accuracy improvement

---

## Best Practices and Recommendations

### Decision Framework

```
┌─────────────────────────────────────────────────────────────┐
│                  Choose Your Approach                        │
│                                                              │
│  Simple task, single domain?                                 │
│  └─> Single agent (no ensemble)                              │
│                                                              │
│  Need diverse perspectives?                                  │
│  └─> Fan-out with majority voting                            │
│                                                              │
│  Complex reasoning, uncertain answers?                       │
│  └─> Multi-round debate with confidence weighting            │
│                                                              │
│  High-stakes, need verification?                             │
│  └─> Consensus verification (require 2/3 or 3/3 agreement)   │
│                                                              │
│  Specialized expertise needed?                               │
│  └─> Heterogeneous agents with domain routing                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Implementation Recommendations

#### 1. Start Simple, Add Complexity as Needed

```
Level 1: Single agent with self-consistency (sample N times, vote)
Level 2: Parallel agents with majority voting
Level 3: Multi-round debate with confidence weighting
Level 4: Full consensus with verification subagents
```

#### 2. Prioritize Quality Over Diversity

Based on Self-MoA research:
- Using your best model multiple times often beats mixing weaker models
- Add diversity only when models have genuinely complementary strengths

#### 3. Use Anonymization for Peer Review

From LLM Council:
- Hide model identities during evaluation
- Prevents brand loyalty/bias in rankings

#### 4. Implement Confidence Thresholds

```python
# Only report consensus if confidence threshold met
if consensus_confidence >= THRESHOLD:
    return consensus_response
else:
    return "Low confidence - requires human review"
```

#### 5. Design for Failure Modes

Common issues to handle:
- **Over-convergence**: All agents copy wrong majority answer
- **Sycophancy**: Agents agree to avoid conflict
- **Hallucination propagation**: False info spreads through debate
- **Degenerate consensus**: Agents produce bland, uncommitted answers

Mitigations:
- Domain-specialized instructions
- Confidence-based weighting
- External fact-checking
- Diversity incentives in prompts

### Cost-Benefit Analysis

| Approach | Accuracy Gain | Cost Multiplier | Recommended Use Case |
|----------|---------------|-----------------|---------------------|
| Single Agent | Baseline | 1x | Simple tasks |
| Self-Consistency | +5-10% | 3-5x | Medium complexity |
| Majority Voting | +5-15% | Nx (agents) | High-value decisions |
| Multi-Round Debate | +10-20% | 3-10x N | Complex reasoning |
| Full Consensus | +15-25% | 5-20x N | Critical operations |

---

## Summary: Key Takeaways

1. **LLM Council** demonstrates hierarchical consensus with anonymized peer review and chairman synthesis

2. **Mixture-of-Agents** achieves SOTA through layered refinement, but Self-MoA shows quality matters more than diversity

3. **Majority Voting accounts for most gains** attributed to multi-agent debate - start here before adding complexity

4. **ReConcile's confidence-weighted voting** improves consensus by 11%+ - weight opinions by agent certainty

5. **For Claude Code subagents**:
   - Use exploration subagents early to preserve context
   - Deploy verification subagents after implementation
   - Coordinate via shared files, not complex orchestration
   - Require 2/3 consensus for high-stakes changes

6. **The optimal approach depends on task complexity** - match orchestration complexity to task requirements

---

## References and Sources

### Primary Research
- [Mixture-of-Agents (ICLR 2025)](https://arxiv.org/abs/2406.04692)
- [Self-MoA: Rethinking Mixture-of-Agents](https://arxiv.org/abs/2502.00674)
- [ReConcile: Round-Table Conference](https://arxiv.org/abs/2309.13007)
- [Multi-Agent Debate for Factuality](https://composable-models.github.io/llm_debate/)
- [Debate or Vote (Aug 2025)](https://arxiv.org/html/2508.17536v1)

### Implementations
- [LLM Council by Karpathy](https://github.com/karpathy/llm-council)
- [PolyCouncil](https://github.com/TrentPierce/PolyCouncil)
- [Awesome-LLM-Ensemble](https://github.com/junchenzhi/Awesome-LLM-Ensemble)
- [Claude Code Agentic Research Orchestrator](https://github.com/weorbitant/claude-code-agentic-research-orchestrator)

### Claude Code Resources
- [Claude Code Subagent Docs](https://code.claude.com/docs/en/sub-agents)
- [Anthropic Engineering Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Multi-Agent Collaboration Mechanisms Survey](https://arxiv.org/html/2501.06322v1)

---

*Document generated: 2026-01-14*
*For use with Claude Code multi-agent workflow design*
