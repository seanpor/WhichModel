# Phase 002: Model Strategy Consolidation & Token Efficiency — Survey Findings

**Status**: Draft
**Author**: Claude Fable 5 (Claude Code)
**Date**: 2026-07-19
**Reviewed by**: (pending)

---

## Objective

Maximise programming output while minimising (a) cost and (b) switching between models — a new constraint not reflected in the existing docs. Verify the factual basis of `recommendations-economist.md`, `recommendations.md`, and `model-analysis.md` against live sources, and propose a consolidated model policy plus a ranked token-efficiency stack.

An additional constraint from Sean (2026-07-19): **free models are not capable enough for the real work** — so the strategy must assume a capable *paid* model is the daily driver, which makes per-token efficiency the primary cost lever rather than "use free models for 80%".

## Background

- Measured usage: ~13.5 MTok/hour heavy, ~7.5 MTok/hour medium (from `model-analysis.md`).
- Current subscriptions: Claude Pro (~€24/mo) + Google (~€25/mo), both rate-limited; MiMo Code $50/mo largely abandoned.
- Existing strategy: free models for 80% of work, 3-tier cascade (free → cheap → premium), cross-model review, model rotation every few requests.
- Budget target in existing docs: €15–20/mo.

---

## Survey findings (verified 2026-07-19)

### F1. The primary free model is dead ❌

`deepseek/deepseek-v4-flash:free` on OpenRouter — the primary recommendation in both
`recommendations.md` and `model-analysis.md` — **no longer has a provider behind it**. As of
July 2026 every DeepSeek model on OpenRouter is paid. Paid Flash pricing is confirmed
unchanged at $0.09/$0.18 per MTok.

- https://openrouter.ai/deepseek/deepseek-v4-flash
- https://ofox.ai/blog/deepseek-v4-flash-free-zero-cost-paths-2026/

### F2. OpenRouter free-tier caps bind for agentic work ⚠️

Free variants: **20 requests/minute**, 50 requests/day (lifetime credits < $10) or 1,000/day
($10+ ever purchased). An agentic coding loop makes hundreds of requests per session, so both
the RPM and daily caps are real constraints at Sean's usage rate — free models cannot be a
*primary* even where quality suffices.

- https://openrouter.ai/docs/api_reference/limits

### F3. The four token-efficiency tools are real ✅ (two corrections)

| Tool | Verified | Correction vs `recommendations-economist.md` |
|------|----------|---------------------------------------------|
| **RTK** (`rtk-ai/rtk`) | ✅ ~71.6k stars, 60–90% tool-output compression, single Rust binary, `rtk init -g` | Stars slightly higher than reported; claims hold |
| **Caveman** (`JuliusBrussee/caveman`) | ✅ ~65% output-token cut; OpenCode package exists (`caveman-opencode`) | **Installer changed**: now `npx -y github:JuliusBrussee/caveman`; the `curl … install.sh \| bash` command in the report is stale |
| **Ponytail** (`DietrichGebert/ponytail`) | ✅ ~54% less code (up to 94%), ~20% cheaper, ~27% faster; ships to 16 agents incl. OpenCode | Claims hold |
| **9Router** (`decolua/9router`) | ✅ exists, 3-tier fallback, built-in RTK-style compression | **Star count is ~1.8k, not 19k** as the report claims. Multiple similarly-named npm clones exist (`n9router`, `hn9router`) — typosquat risk; install only `9router` |

### F4. Current Claude API pricing (for the escalation/anchor decision)

Fable 5 $10/$50; Opus 4.8 $5/$25; **Sonnet 5 $3/$15 with introductory $2/$10 through
2026-08-31**; Haiku 4.5 $1/$5 (per MTok). Prompt-cache reads ≈ 0.1× base input price; writes
1.25× (5-min TTL) or 2× (1-h TTL). **Caches are model-scoped: switching models invalidates
the entire cache.**

---

## Analysis

### A1. Two kinds of model switching — only one is expensive

- **Mid-session switching** (cascade escalation, rotation): loses the provider-side prompt
  cache (model-scoped), so the entire accumulated context is re-priced at full input rate on
  the new model; loses conversational context; imposes cognitive overhead. This is the kind
  to eliminate.
- **Role-based switching** (different models bound to plan/build/review agents in OpenCode
  config): each role runs in its own session with its own cache; no human decision per
  request. This kind is free — encode it once in config.

### A2. Two existing recommendations are counterproductive

1. **"Model rotation — rotate between free models every few requests"** is the worst advice
   on both axes: every rotation pays cache-miss price on the full context and resets model
   behaviour. Remove.
2. **Routine 3-tier cascading** institutionalises mid-session switching. Keep escalation as
   an *exception path* (hard-signal failure → one same-model retry → fresh session on the
   escalation model with a written summary), not a default workflow.

### A3. With a paid primary, token efficiency is the budget

Since free models don't meet the capability bar (Sean, F2), the cost model changes: the
question is no longer "how much work can be free" but "how few tokens does the capable model
need". The compression stack (F3) is what makes a capable paid primary affordable — spend the
savings on capability, not on more tokens.

Rough numbers at the heavy rate (13.5 MTok/h, 5 h/day, 22 d/mo), uncached worst case:

| Primary candidate | $/MTok (in/out) | $/h | $/mo worst case | With caching + RTK-class compression |
|---|---|---|---|---|
| DeepSeek V4 Flash | 0.09 / 0.18 | ~1.22 | ~134 | ~35–60 |
| DeepSeek V4 Pro | 0.435 / 0.87 | ~5.90 | ~650 | ~60–150 |
| Claude Sonnet 5 (API, intro) | 2 / 10 | ~27 | n/a | not viable per-token at this volume |

Implication: the higher the capability requirement, the stronger the case for a **flat-rate
subscription** (Claude Pro €24/mo + compression tools to stretch the quota 3–5×) over
per-token API for the primary.

---

## Recommendations

### R1. Two-family, three-role model policy (bound once in OpenCode config)

| Role | Model | Notes |
|------|-------|-------|
| Primary (plan + implement + verify) | **DeepSeek V4 Pro** ($0.435/$0.87) *or* Claude Sonnet via subscription — see R2 | Capability-first; free tier no longer exists in this family anyway |
| Review gate (`@pr-review`, `@phase-review`) | One fixed free model (Nemotron 3 Ultra Free — re-verify it is still served) | Runs in its own session at task boundaries; no cache or switching cost |
| Escalation (exception only) | Same family as primary (DeepSeek family → V4 Pro/frontier; Claude family → Opus 4.8) | Hard-signal failure + one retry first; always a fresh session with summary, never mid-conversation |

Rules: same session = same model, always. New session per task is fine; new *model* is what
costs. No rotation.

### R2. Lane decision (pick one; cancel Google €25/mo either way)

- **Lane A — API-only**: OpenCode + DeepSeek V4 Pro primary via OpenRouter.
  Est. €60–150/mo at heavy rate after caching + compression. Zero subscriptions, no quota
  windows, one bill.
- **Lane B — subscription anchor**: Claude Pro (€24/mo) + Claude Code as primary; compression
  stack to stretch the 5-hour windows; cheap/free API overflow when rate-limited.
  Est. €24–35/mo. Historically Pro's limits bound constantly at this volume — Lane B is only
  viable if RTK/Caveman/Ponytail deliver a meaningful fraction of their claimed savings.
- Running both lanes simultaneously (the status quo) is the one clearly wrong answer:
  double subscriptions, double switching.

Given the capability constraint, **Lane B is now the better default** (flat-rate access to a
frontier-quality model), with Lane A as the fallback if Pro's quota still binds after the
compression stack is installed.

### R3. Token-efficiency stack, ranked for a paid-primary workflow

1. **Prompt-caching discipline** (free, biggest lever): stable static prefix (AGENTS.md, tool
   defs first, byte-identical between requests), no mid-session model changes, volatile
   content last.
2. **RTK** — 60–90% off tool-output *input* tokens; input dominates agentic sessions.
   `rtk init -g`.
3. **Ponytail** — ~54% less generated code: cuts *output* tokens (the expensive ones, 2–5×
   input price) and compounds by shrinking all future re-reads of that code.
4. **Caveman** — ~65% off output prose. Install via `npx -y github:JuliusBrussee/caveman`
   (not the stale curl command). Caveat: with a capable paid model, explanations are
   sometimes what you're paying for — use `/caveman lite` or toggle off for design
   discussions.
5. **Session/context hygiene** (already documented): `@file` references, diff-based edits,
   batching related fixes, fresh session per task, `max_tokens` caps by task type.
6. **9Router — optional**: under a fixed two-model policy its routing value shrinks, and its
   built-in compression is redundant next to RTK. If installed, use only the `9router`
   npm package (typosquat clones exist). Do not cite 19k stars.

### R4. Doc corrections (pending approval — this phase doc is the plan)

- `recommendations.md` + `model-analysis.md`: remove/annotate `deepseek-v4-flash:free` as
  dead; re-verify the free-model tables against the live OpenRouter list.
- `recommendations-economist.md`: remove the "Model rotation" paragraph; reframe cascading
  as exception-path; fix the Caveman install command; correct 9Router star count; add the
  switching/caching analysis (A1) and the lane decision (R2).
- Run `make lint` after editing `recommendations-economist.md`; regenerate PDF with
  `make pdf`.

---

## Verification plan

- [ ] Re-check the live OpenRouter model list for surviving free models suitable for the
      review role (`curl -s https://openrouter.ai/api/v1/models` filter `:free`).
- [ ] Confirm Nemotron 3 Ultra Free is still served before hardcoding it in config.
- [ ] After doc edits: `make lint` (exit 0) and `make pdf`.
- [ ] Trial Lane B for two weeks with RTK + Ponytail installed; log rate-limit hits vs the
      pre-compression baseline before deciding the lane permanently.

## Sources

- https://openrouter.ai/docs/api_reference/limits — free-tier rate limits
- https://openrouter.ai/deepseek/deepseek-v4-flash — paid Flash pricing
- https://ofox.ai/blog/deepseek-v4-flash-free-zero-cost-paths-2026/ — dead `:free` listing
- https://github.com/rtk-ai/rtk — RTK
- https://github.com/juliusbrussee/caveman — Caveman (see README for current installer)
- https://github.com/DietrichGebert/ponytail — Ponytail
- https://github.com/decolua/9router — 9Router (~1.8k stars)
- Claude API pricing and prompt-cache economics: Anthropic docs via claude-api skill,
  2026-07-19 (Sonnet 5 intro pricing runs through 2026-08-31)
