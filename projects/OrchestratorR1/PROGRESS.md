# OrchestratorR1 — Progress

> **Live status doc.** Update when tasks complete or blockers change. Last updated: 2026-05-06.
> Target: **AAAI 2027** — Abstract early Aug, Full paper mid-Aug 2026.

## Snapshot
- **Done:** 7 / 33 (added B5 ReAct, B6 Self-Reflection — 2026-05-08)
- **In progress:** agentlab git sync
- **Blocked by:** A100 access (user has 3060 Laptop only)

## 3-Month Plan (May → Aug 2026)

### Phase 1 — May 2026: Unblock + finish CPU/API-only work
| ID | Task | Status | Notes |
|---|---|---|---|
| T1.1–T1.4, T1.7 | Data prep (all datasets) | ✅ done | parquet ready |
| B1 | Direct-GPT-4o baseline | ✅ done | QA + GPQA |
| B2 | Direct-Strong baseline | ✅ done | |
| B3 | Direct-Cheap baseline | ✅ done | |
| B4 | Fixed-Pipeline baseline | ✅ done | |
| B5 | ReAct baseline (`eval_react.py`) | ✅ done | EM=0.199 F1=0.308 avg_turns=4.3 avg_cost=$0.00070 (3000 QA) |
| B6 | Self-Reflection baseline | ✅ done | EM=0.323 F1=0.445 avg_turns=5.0 avg_cost=$0.00553 (3000 QA) |
| B7 | Conductor / Router-R1 reference data | ⬜ todo | |
| INF1 | Secure A100 access (cloud / lab cluster) | 🔴 blocker | unblocks Phase 2 |
| W1 | Re-scope writing for AAAI format (7+2 pages) | 🟡 deferred | start in late Jul |

### Phase 2 — Jun–Jul 2026: Core training + ablations
- SFT warmup on `data/sft_warmup.jsonl` (7B, QLoRA + DDP fallback if needed)
- GRPO main training on QA suite
- Ablations: cost_coe ∈ {0, 0.01, 0.1}, max_turns ∈ {2, 4, 6}, SFT-only vs SFT+GRPO
- Held-out eval: 2Wiki / MuSiQue / Bamboogle / GPQA
- Cost-quality Pareto plot

### Phase 3 — Early Aug 2026: Writing sprint
- Adapt `intro_draft_aaai2027*.md` to AAAI 7+2 page format
- Method, experiments, related work polish
- Submit abstract → submit full paper

## Active Blockers
1. **A100 access** — every training task downstream depends on this. Action: investigate cloud (RunPod / Vast / Lambda) vs lab cluster reservation.

## Recent Changes (from git)
- Switched 7B LoRA → QLoRA (4-bit) + DDP to fix OOM on 3090
- FSDP → FULL_SHARD (ZeRO-3) attempt for 7B LoRA OOM mitigation
- H200 7B training mode configured (a6d568d)

## QA Baseline Summary (3000 samples, 2026-05-08)

| Method | EM | F1 | AvgCost | AvgTurns |
|--------|----|----|---------|----------|
| Direct-GPT-4o | **0.367** | **0.474** | $0.00041 | 1.0 |
| Self-Reflection (GPT-4o ×5) | 0.323 | 0.445 | $0.00553 | 5.0 |
| Direct-Strong | 0.182 | 0.332 | $0.00038 | 1.0 |
| Direct-Cheap | 0.192 | 0.317 | $0.00001 | 1.0 |
| ReAct (Qwen2.5-7B) | 0.199 | 0.308 | $0.00070 | 4.3 |
| Fixed-Pipeline | 0.046 | 0.227 | $0.00255 | 5.1 |

Key takeaways:
- Self-Reflection costs **13× more** than Direct-GPT-4o yet scores 4.4 EM lower → single-model reflection not worth the cost
- ReAct (7B) uses 4.3 turns but still underperforms Direct-GPT-4o → tool-use alone insufficient without orchestration training
- OrchestratorR1 target: beat Direct-GPT-4o (EM>0.367) at comparable or lower cost

## Decisions Log
- **2026-05-06:** Re-targeted NeurIPS 2026 → **AAAI 2027**. Reason: training still blocked on A100; rushing for May 6 deadline would mean shipping incomplete experiments. Aug deadline gives 3 months for full RL training + ablations.
- **2026-05-06:** Writing frozen until late July. Existing `intro_draft_aaai2027*.md` not rewritten in AAAI style yet.
