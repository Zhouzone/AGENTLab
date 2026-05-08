# OrchestratorR1 — Goal

## Target Venue
**AAAI 2027**
- Abstract deadline: early August 2026
- Full paper deadline: mid-August 2026
- Window from today (2026-05-06): ~3 months

> Previously targeted NeurIPS 2026 (May 2026). Switched to AAAI 2027 to allow proper completion of RL training and ablations.

## Research Question
Can a base LLM be trained, via RL, to **orchestrate** multiple specialized agents (heterogeneous LLM routes) and aggregate their outputs into a single high-quality answer — outperforming both single-model baselines and fixed pipelines, while staying cost-aware?

## Hypotheses
1. **H1 — RL > heuristics:** GRPO-trained orchestrator beats Fixed-Pipeline and Direct-* baselines on multi-hop QA + GPQA.
2. **H2 — Cost-aware policy:** A non-zero `cost_coe` produces orchestration policies on the cost/quality Pareto frontier without large accuracy loss.
3. **H3 — Generalization:** Policy trained on NQ + HotpotQA transfers to held-out 2WikiMultihop / MuSiQue / Bamboogle / GPQA.

## Success Criteria
- Beat strongest baseline (Direct-GPT-4o or Fixed-Pipeline) by ≥3 EM on average across QA suite.
- Demonstrate cost-quality Pareto curve via `cost_coe` sweep.
- Provide ablations: SFT-only vs SFT+GRPO, w/ vs w/o cost penalty, max_turns sensitivity.

## Non-Goals
- New base model architecture.
- Beating SOTA on any single dataset in absolute terms.
- Production-grade serving infrastructure.
