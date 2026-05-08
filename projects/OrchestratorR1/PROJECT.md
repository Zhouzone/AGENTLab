# OrchestratorR1 — Project Overview

## Code Repository

**https://github.com/Cayenne226/OrchestratorR1**

## Dataset

**https://huggingface.co/datasets/Cayenne226/OrchestratorR1-data**

## What
LLM trained via RL (PPO/GRPO) to act as an **orchestrator**: emits `<search>Model:query</search>` calls to a heterogeneous agent pool, ingests `<information>` responses, and produces a final `<answer>`. Reward = EM/F1 minus optional API cost.

## Codebase
- Path: `f:/data/code/Router-R1/OrchestratorR1/`
- Built on Router-R1 (NeurIPS 2025) which is built on veRL (Bytedance).
- Key modules:
  - `orchestrator_r1/orchestrator/generation.py` — multi-turn rollout loop
  - `orchestrator_r1/orchestrator/parser.py` — `<search>` / `<answer>` parsing
  - `orchestrator_r1/agent_pool/agent_registry.py` — symbolic name → API endpoint + pricing
  - `training/train.py` — PPO/GRPO orchestration (Ray + FSDP)
  - `eval/eval_orchestrator.py`, `eval/eval_react.py`, `eval/baselines.py`

## Stack
veRL · vLLM · Ray · FSDP · PPO/GRPO · wandb · Hydra

## Datasets
NQ, TriviaQA, PopQA, HotpotQA, 2WikiMultihop, MuSiQue, Bamboogle, GPQA.

## Agent Pool (current)
| Symbol | Backing model | $/1M tok |
|---|---|---|
| Qwen / Llama-8B / Mistral | gpt-4o-mini | 0.15 |
| Llama-70B | gpt-4o | 2.50 |
| Gemma | gemini-2.5-flash | 0.15 |
| Claude | claude-sonnet-4-6 | 3.00 |
| Gemini | gemini-2.5-pro | 1.25 |

## Repo-level Docs (source of truth)
- `RESEARCH_PLAN.md` — full plan
- `FRAMEWORK.md` — architecture
- `COMPARISON.md` — vs Router-R1 / ReAct / Self-Reflection
- `docs/related_work_roadmap.md`
- `docs/intro_draft_aaai2027*.md` — paper draft (frozen until Aug writing sprint)
