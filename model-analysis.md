# AI Model Cost/Speed/Quality Analysis

Last updated: 2026-06-29

## Context

Heavy coding usage — 4.4B MiMo credits in half a day. Current subscriptions (Claude Pro €20/mo, Google €25/mo) hit rate limits constantly. Need to maximize coding output while minimizing cost.

Strategy: **planner + implementer** pattern — capable model writes the plan, cheaper/free model implements it.

---

## MiMo Code Credit-to-Token Conversion (Critical for Cost Analysis)

MiMo Code uses a credit system, not direct token pricing. $50/month for 38B credits.

| Model | Input (Cache Hit) | Input (Cache Miss) | Output |
|-------|-------------------|-------------------|--------|
| MiMo-V2.5 | 2 credits/token | 100 credits/token | 200 credits/token |
| MiMo-V2.5-Pro | 2.5 credits/token | 300 credits/token | 600 credits/token |

Effective cost per MTok (MiMo Code $50/38B):
- MiMo-V2.5 cache miss input: **$0.1316/MTok** (31% MORE than OpenRouter)
- MiMo-V2.5 output: **$0.2632/MTok** (6% cheaper than OpenRouter)
- Cache hits: **$0.003/MTok** (incredibly cheap)
- MiMo-V2.5-Pro cache miss input: **$0.3947/MTok** (8% cheaper than OpenRouter)
- MiMo-V2.5-Pro output: **$0.7895/MTok** (9% cheaper than OpenRouter)

**Burn rate**: ~13.5 MTok/hour at heavy usage = ~$1.77/hour = ~21.6 hours for 38B credits = **4-5 working days**

**Conclusion**: MiMo Code is competitive with OpenRouter for cache-heavy work, but OpenRouter is cheaper for fresh work. Revised 2026-07-20: route the primary workload to a fixed paid model on OpenRouter (see "Free vs Paid Models" below for why free is no longer viable here), not to free models.

---

## Token Usage Rates (for Budget Planning)

### Typical Token Consumption by Activity

| Activity | Tokens/hour | Notes |
|----------|-------------|-------|
| **Light coding** (simple edits, small files) | 2-5 MTok | Minimal context, short responses |
| **Medium coding** (new features, refactoring) | 5-10 MTok | Moderate context, longer responses |
| **Heavy coding** (complex features, debugging) | 10-20 MTok | Large context, detailed responses |
| **Agent-heavy** (multi-file, planning, reviews) | 15-25 MTok | Lots of tool calls, context loading |
| **Your usage** (4.4B credits / 2.5 hours) | ~13.5 MTok | MiMo-V2.5 standard, mixed input/output |

### How Long Different Budgets Last

**At heavy usage rate (13.5 MTok/hour):**

| Budget | Provider | Model | Hours of use | Working days (5h/day) |
|--------|----------|-------|--------------|----------------------|
| $50/month | MiMo Code | MiMo-V2.5 | ~21.6 hours | ~4.3 days |
| $50/month | OpenRouter | DeepSeek-V4-Flash (paid) | ~31.6 hours | ~6.3 days |
| $50/month | OpenRouter | MiMo-V2.5 | ~24 hours | ~4.8 days |
| $20/month | OpenRouter | Free models | Unlimited | Unlimited |
| $20/month | OpenRouter | DeepSeek-V4-Flash (paid) | ~12.7 hours | ~2.5 days |

**At medium usage rate (7.5 MTok/hour):**

| Budget | Provider | Model | Hours of use | Working days (5h/day) |
|--------|----------|-------|--------------|----------------------|
| $50/month | MiMo Code | MiMo-V2.5 | ~39 hours | ~7.8 days |
| $50/month | OpenRouter | DeepSeek-V4-Flash (paid) | ~57 hours | ~11.4 days |
| $20/month | OpenRouter | Free models | Unlimited | Unlimited |
| $20/month | OpenRouter | DeepSeek-V4-Flash (paid) | ~22.9 hours | ~4.6 days |

### Cost Per Hour by Model

**At heavy usage (13.5 MTok/hour):**

| Model | $/hour | $/day (5h) | $/month (22 days) |
|-------|--------|------------|-------------------|
| MiMo Code ($50/38B) | $1.77 | $8.85 | $194.70 |
| DeepSeek-V4-Flash (OpenRouter) | $1.22 | $6.10 | $134.20 |
| MiMo-V2.5 (OpenRouter) | $1.62 | $8.10 | $178.20 |
| Qwen3-Coder-Flash (OpenRouter) | $2.57 | $12.85 | $282.70 |
| Free models (OpenRouter) | $0.00 | $0.00 | $0.00 |

### Recommendation by Usage Pattern

| Usage Pattern | Recommended Strategy | Monthly Cost |
|---------------|---------------------|--------------|
| **Light user** (< 5h/week) | Free models only | $0 |
| **Medium user** (5-15h/week) | Free models + $10 buffer | $10 |
| **Heavy user** (15-30h/week) | Free models + $20 paid | $20 |
| **Full-time** (40h+/week) | Free models + $50 paid | $50 |
| **Power user** (your rate) | Free models + $100 paid | $100 |

**Note**: Free models have rate limits (50 reqs/day on OpenRouter free plan). For heavy usage, consider OpenRouter pay-as-you-go ($10+ balance) for 1000 reqs/day on free models.

---

## Free Models Available (No Cost)

> **⚠️ Correction, verified 2026-07-20:** `deepseek/deepseek-v4-flash:free` — the primary
> recommendation throughout the original version of this document — is **no longer served by
> any provider on OpenRouter**. Confirmed by fetching the live OpenRouter model list
> (`GET /v1/models`, 14 `:free` models returned, DeepSeek not among them). Roughly half of the
> other free models named below have also rotated out since this doc was first written — see
> the corrected table. **Given Sean's stated constraint that free models aren't capable enough
> for his real work, treat this whole section as a source for the review-gate role only, not
> as a primary-model candidate.**

### OpenCode Zen (opencode.ai/zen)

*Not independently re-verified — OpenCode Zen has no public model-list API to check against
(unlike OpenRouter). Given the OpenRouter finding above, treat "DeepSeek V4 Flash Free" here
with the same skepticism until confirmed live in the OpenCode Zen dashboard.*

| Model | Notes |
|-------|-------|
| Big Pickle | Stealth model, possibly GLM mixture. Free "for limited time". Data may be used for training. |
| DeepSeek V4 Flash Free | **Unverified — likely dead, see correction above.** Data may be used for training. |
| MiMo-V2.5 Free | Promotional. |
| North Mini Code Free | Cohere-based. Data retained. Do NOT submit confidential data. |
| Nemotron 3 Ultra Free | NVIDIA trial. Data logged for improvement. |

### OpenRouter (openrouter.ai)

**Re-verified live 2026-07-20** against `GET https://openrouter.ai/api/v1/models` — 14 `:free`
models currently served (down from the 26 this section originally claimed; many code-focused
models have rotated out). Confirmed-live free models, best for coding/review:

| Model | ID | Context | Notes |
|-------|----|---------|-------|
| Nemotron 3 Ultra 550B | `nvidia/nemotron-3-ultra-550b-a55b:free` | 1M | **Confirmed live.** Strong general reasoning — recommended for the review-gate role |
| Nemotron 3 Super 120B | `nvidia/nemotron-3-super-120b-a12b:free` | 1M | **Confirmed live.** Large context |
| Gemma 4 31B | `google/gemma-4-31b-it:free` | 262K | **Confirmed live.** Google, good quality |
| Gemma 4 26B | `google/gemma-4-26b-a4b-it:free` | 262K | **Confirmed live.** Google, efficient |
| Poolside Laguna M.1 | `poolside/laguna-m.1:free` | 262K | **Confirmed live.** Code-focused |
| Poolside Laguna XS 2.1 | `poolside/laguna-xs-2.1:free` | 262K | **Confirmed live**, but ID changed from the `laguna-xs.2:free` this doc originally listed |
| Cohere North Mini Code | `cohere/north-mini-code:free` | 256K | **Confirmed live.** Code-focused |
| OpenAI gpt-oss-20b | `openai/gpt-oss-20b:free` | 131K | **Confirmed live**, but replaces the `gpt-oss-120b:free` this doc originally listed — smaller model, re-evaluate quality before relying on it |

**No longer served (confirmed dead 2026-07-20):** `deepseek/deepseek-v4-flash:free`,
`qwen/qwen3-coder:free`, `qwen/qwen3-next-80b-a3b-instruct:free`,
`nousresearch/hermes-3-llama-3.1-405b:free`, `meta-llama/llama-3.3-70b-instruct:free`,
`openai/gpt-oss-120b:free`. Do not route work to these IDs — requests will fail or silently
fall back to a different model than intended.

---

## Paid Models — API Pricing (per 1M tokens)

### Tier 1 — Premium (Best quality, expensive)

| Model | Input $ | Output $ | Notes |
|-------|---------|----------|-------|
| Claude Opus 4.8 | $5.00 | $25.00 | Top-tier reasoning. 35% token inflation vs older Claude. |
| GPT 5.5 | $5.00 | $30.00 | Latest OpenAI flagship |
| GPT 5.5 Pro | $30.00 | $180.00 | Extreme cost |
| Claude Fable 5 | $10.00 | $50.00 | Newest Claude |

### Tier 2 — Mid-range

| Model | Input $ | Output $ | Notes |
|-------|---------|----------|-------|
| Claude Sonnet 4.6 | $3.00 | $15.00 | Good balance |
| GPT 5.4 | $2.50 | $15.00 | Strong |
| Gemini 3.1 Pro | $2.00 | $12.00 | Google's best |
| Qwen3.7 Max | $2.50 | $7.50 | Strong value |
| DeepSeek V4 Pro | $1.74 | $3.48 | 10x cheaper than Claude |
| GPT 5.3 Codex | $1.75 | $14.00 | Coding specialist |

### Tier 3 — Budget

| Model | Input $ | Output $ | Notes |
|-------|---------|----------|-------|
| Claude Haiku 4.5 | $1.00 | $5.00 | Fast Claude |
| GPT 5.1 | $1.07 | $8.50 | Good value |
| GPT 5.1 Codex | $1.07 | $8.50 | Coding variant |
| GPT 5.4 Mini | $0.75 | $4.50 | Budget OpenAI |
| Qwen3.7 Plus | $0.40 | $1.60 | Very cheap |
| Qwen3.5 Plus | $0.20 | $1.20 | Cheapest Qwen |

### Tier 4 — Ultra-cheap

| Model | Input $ | Output $ | Notes |
|-------|---------|----------|-------|
| GPT 5.1 Codex Mini | $0.25 | $2.00 | Budget coding |
| GPT 5.4 Nano | $0.20 | $1.25 | Cheapest OpenAI |
| DeepSeek V4 Flash | $0.14 | $0.28 | **Cheapest paid API** |
| GPT 5 Nano | $0.05 | $0.40 | Practically free |

---

## DeepSeek DSpark (Released June 2026)

**DSpark** is DeepSeek-V4-Pro with an additional **speculative decoding module** attached for faster inference.

### What is DSpark?

- **Not a new model** — same checkpoint as DeepSeek-V4-Pro with a speculative decoding module
- **Faster inference** — speculative decoding generates multiple tokens in parallel
- **Open-source** — MIT license, available on HuggingFace
- **Released**: Last weekend (June 2026)

### DSpark Specs

| Spec | Value |
|------|-------|
| **Model** | DeepSeek-V4-Pro-DSpark |
| **Total Params** | 1.6T |
| **Active Params** | 49B |
| **Context Length** | 1M tokens |
| **Precision** | FP4 + FP8 Mixed |
| **License** | MIT |

### DSpark Performance

From the HuggingFace model card, DSpark achieves **frontier-level performance**:

| Benchmark | DSpark (V4-Pro Max) | Claude Opus 4.6 | GPT-5.4 | Gemini 3.1 Pro |
|-----------|---------------------|-----------------|---------|----------------|
| **LiveCodeBench** | **93.5** | 88.8 | — | 91.7 |
| **Codeforces** | **3206** | — | 3168 | 3052 |
| **SWE Verified** | 80.6 | **80.8** | — | 80.6 |
| **GPQA Diamond** | 90.1 | 91.3 | 93.0 | **94.3** |

### DSpark for Your Workflow

**Pros**:
- **Fast inference** — speculative decoding speeds up generation
- **Top-tier coding** — 93.5 on LiveCodeBench, 3206 Codeforces rating
- **Open-source** — can run locally if you have the hardware
- **1M context** — handles large codebases

**Cons**:
- **Massive model** — 1.6T total params, needs serious hardware
- **Not on OpenRouter yet** — need to check availability
- **Same pricing as V4-Pro** — $0.435/$0.87 per MTok

### How to Use DSpark

**Via API** (if available on OpenRouter):
```bash
# Check if available
curl -s https://openrouter.ai/api/v1/models | python3 -c "import sys,json; d=json.load(sys.stdin); print([m['id'] for m in d['data'] if 'dspark' in m['id'].lower()])"
```

**Locally** (if you have the hardware):
```bash
# Install vLLM
pip install vllm

# Serve DSpark
vllm serve "deepseek-ai/DeepSeek-V4-Pro-DSpark"

# Or use Docker
docker run --gpus all -p 8000:8000 vllm/vllm-openai serve deepseek-ai/DeepSeek-V4-Pro-DSpark
```

**Note**: DSpark needs ~889GB of model weights (BF16) — won't fit on a 2080 Ti. Use API or cloud GPU.

### DSpark vs Other Models

| Model | Params | Context | $/M (in/out) | Code Elo | Best For |
|-------|--------|---------|--------------|----------|----------|
| **DSpark** | 1.6T | 1M | $0.435/$0.87 | ~1340 | Fast frontier coding |
| DeepSeek-V4-Pro | 1.6T | 1M | $0.435/$0.87 | 1289 | Standard frontier |
| Claude Opus 4.7 | ? | 1M | $5/$25 | 1338 | Premium reasoning |
| MiMo-V2.5-Pro | 1T | 1M | $0.43/$0.87 | 1318 | Budget premium |

**Conclusion**: DSpark is DeepSeek's answer to frontier models with faster inference. If it's available on OpenRouter, it could be a cost-effective alternative to Claude Opus for coding tasks.

---

## Subscription Plans

| Plan | Cost (EUR/mo) | What you get | Notes |
|------|--------------|--------------|-------|
| Claude Pro | ~€24 | Claude Code, moderate usage | 5-hour rate limits |
| Claude Max 5x | ~€120 | 5x Pro usage | Still rate-limited |
| Claude Max 20x | ~€240 | 20x Pro usage | For heavy users |
| Google | ~€25 | Gemini access | Token-limited |
| OpenRouter Free | €0 | 25+ free models, 50 reqs/day | Rate-limited |
| OpenRouter Pay-as-you-go | $5+ | 400+ models, no rate limits | 5.5% platform fee |
| OpenCode Zen | $20+ | Curated models, no markup | 4.4% card fee |

---

## Local Ollama on 2080 Ti (11GB VRAM)

| Model | Params | VRAM (Q4) | Speed | Quality vs API |
|-------|--------|-----------|-------|----------------|
| Qwen 2.5 Coder 7B | 7B | ~5 GB | ~30-50 t/s | -20-30% vs Opus |
| DeepSeek Coder V2 Lite | 16B | ~10 GB (Q3) | ~15-25 t/s | -15-25% vs Opus |
| Codestral Mamba 7B | 7B | ~5 GB | ~35-55 t/s | -25-35% vs Opus |
| Gemma 3 12B | 12B | ~8 GB | ~20-35 t/s | -20-30% vs Opus |

Electricity: ~250W × €0.30/kWh = ~€0.075/hour → €9-27/month depending on usage.

32B+ models **won't fit** on 11GB VRAM.

---

## Trade-off Summary

| Approach | Monthly Cost | Effective Tokens | Bottleneck |
|----------|-------------|-----------------|------------|
| Claude Pro + Google (subscriptions) | ~€45 | Very limited | 5-hour rate limits |
| Zen pay-as-you-go (mixed) | ~€20-40 | Much more | Budget-based |
| Free models only (OpenRouter/Zen) | **€0** | Unlimited (rate-limited) | Quality ceiling confirmed too low for Sean's work (2026-07-20), plus privacy |
| Ollama local (Qwen 2.5 Coder 7B) | ~€9 electricity | Unlimited | Speed, quality gap |
| Subscription-anchored (recommended) | ~€24-35 | High, quota-bound | Rate limits, mitigated by compression stack |

---

## Free vs Paid Models: Side-by-Side Comparison

> **⚠️ Revised 2026-07-20:** The two strongest free models this comparison originally relied
> on — DeepSeek-V4-Flash Free (1257 elo) and Qwen3-Coder-480B Free (1193 elo) — are both
> confirmed dead on OpenRouter (see correction above). The benchmark numbers below are the
> figures originally recorded for each model and have not been independently re-run; they are
> kept only to show relative standing among models still actually served. Nemotron 3 Ultra
> Free is now the strongest surviving free coding model.

### Top Free Models (OpenRouter, still served as of 2026-07-20)

| Model | Code Elo | Coding Idx | Agentic | Context | $/M (in/out) | Best For |
|-------|----------|------------|---------|---------|--------------|----------|
| **Nemotron 3 Ultra Free** | 1174 | 49.3 | 27.4 | 1M | $0/$0 | Now the strongest surviving free model — review-gate role |
| Gemma 4 26B Free | - | 39.3 | 11 | 262K | $0/$0 | Google quality |
| ~~DeepSeek-V4-Flash Free~~ | 1257 | 56.2 | 31.1 | 1M | dead | **No longer served — do not route here** |
| ~~Qwen3-Coder-480B Free~~ | 1193 | - | - | 1M | dead | **No longer served — do not route here** |
| ~~OpenAI GPT-OSS-120B Free~~ | 1014 | 30.4 | 13.2 | 131K | dead | Replaced by the smaller `gpt-oss-20b:free`, not re-benchmarked |

### Top Paid Models (Under $0.50/M Input)

| Model | Code Elo | Coding Idx | Agentic | Context | $/M (in/out) | Best For |
|-------|----------|------------|---------|---------|--------------|----------|
| **MiMo-V2.5-Pro** | 1318 | 60.2 | 29.1 | 1M | $0.43/$0.87 | Premium quality |
| MiniMax M3 | 1307 | 58.6 | 35.4 | 1M | $0.30/$1.20 | Best agentic |
| MiMo-V2.5 | 1304 | - | - | 1M | $0.10/$0.28 | Best value |
| DeepSeek-V4-Pro | 1289 | 59.4 | 36.4 | 1M | $0.43/$0.87 | Strong all-round |
| DeepSeek-V4-Flash | 1257 | 56.2 | 31.1 | 1M | $0.09/$0.18 | **Cheapest paid** (the free listing of this same model is dead) |
| Qwen3-Coder-Flash | - | - | - | 1M | $0.20/$0.97 | Good balance |

### Quality Gap: Free vs Paid, recalculated against surviving models

| Metric | Best surviving free (Nemotron 3 Ultra) | Best Paid | Gap |
|--------|-----------|-----------|-----|
| Code Elo | 1174 | 1318 (MiMo-V2.5-Pro) | -144 (10.9% lower) |
| Coding Index | 49.3 | 60.2 (MiMo-V2.5-Pro) | -10.9 (18.1% lower) |
| Agentic Index | 27.4 | 36.4 (DeepSeek-V4-Pro) | -9.0 (24.7% lower) |

**Revised conclusion**: With the two strongest free coding models gone, the gap between the
best surviving free model and paid models widened from the originally-reported 5-15% to
roughly 11-25% — and is largest on the agentic-index metric that matters most for coding-agent
work. This matches Sean's direct observation that current free models aren't capable enough
for his work. Free models remain useful for a bounded role — cross-model review, where a
different architecture catching bugs matters more than raw capability — but are no longer a
credible primary-model candidate at this usage level. See
`phases/phase-002-model-consolidation-token-efficiency.md` for the resulting model policy.

---

## Token Compression & Cost Reduction Techniques

### 1. Prompt Caching (Automatic)

**How it works**: Identical prompt prefixes are cached and reused across requests.

| Provider | Cache Hit Discount | Cache Write Cost | Min Tokens |
|----------|-------------------|------------------|------------|
| Anthropic (Claude) | 90% cheaper | 25% more | 1024-4096 |
| OpenAI (GPT) | Up to 90% cheaper | Free (automatic) | 1024 |
| DeepSeek | 90% cheaper | Free | Unknown |

**Savings**: If you reuse the same system prompt/context, you only pay for new tokens each request.

**Example**: 10K token system prompt + 1K new tokens per request:
- Without caching: 11K tokens × $0.09/M = $0.00099 per request
- With caching: 10K cached ($0.001/M) + 1K new ($0.09/M) = $0.00001 + $0.00009 = $0.0001 per request
- **Savings**: 90%

### 2. Context Window Management

**Technique**: Only send relevant context, not entire codebase.

| Approach | Tokens Used | Quality | Cost |
|----------|-------------|---------|------|
| Send entire repo | 100K+ | High context | $$$$ |
| Send relevant files only | 10-30K | Good context | $$ |
| Send file summaries | 5-10K | Moderate context | $ |
| Send code snippets only | 2-5K | Lower context | ¢ |

**Best practice**: Use `@file` references to include only relevant files, not entire directories.

### 3. Response Length Control

**Technique**: Limit `max_tokens` to avoid verbose responses.

| Setting | Tokens Used | Quality | Cost |
|---------|-------------|---------|------|
| max_tokens: 4096 | Full response | Complete | $$$ |
| max_tokens: 2048 | Truncated | Good | $$ |
| max_tokens: 1024 | Concise | Adequate | $ |

**Best practice**: Set `max_tokens` based on task complexity. Simple edits don't need 4K token responses.

### 4. Escalation on Hard Failure (revised 2026-07-20 — was "Model Cascading")

**Technique**: Stay on one primary model for the whole session; escalate only on a hard
failure (build/lint/test), and only in a fresh session — never mid-conversation. See
"Correction" note above: the free-first step this technique originally described relied on
`deepseek-v4-flash:free`, which is dead, and mid-session cascading discards the prompt cache
on every hop (caches are model-scoped). Treat this as an exception path, not a routine ladder.

| Step | Model | Cost | When to Use |
|------|-------|------|-------------|
| 1 | Primary paid model (e.g. DeepSeek-V4-Flash) | $0.09/$0.18 per MTok | Every task, one fixed session |
| 2 | Same model, retry once | same | On hard failure — most failures are one-off mistakes |
| 3 | Escalation model, same family (e.g. DeepSeek-V4-Pro) | $0.435/$0.87 per MTok | Fresh session, only if the retry also fails |
| 4 | Frontier model (e.g. MiMo-V2.5-Pro, or Claude Opus) | higher | Rare — hardest problems only |

**Savings**: comes from avoiding repeated full-context re-pricing on model switches, not from
routing most work to $0 models.

### 5. Batch Processing

**Technique**: Group similar tasks into single requests.

| Approach | Requests | Tokens | Cost |
|----------|----------|--------|------|
| Individual requests | 10 | 10 × 1K = 10K | $$$ |
| Batched request | 1 | 1 × 3K = 3K | $ |

**Example**: Instead of 10 separate "fix this bug" requests, send one "fix these 10 bugs" request.

### 6. Local Pre-processing

**Technique**: Use local models (Ollama) for simple tasks, API for complex tasks.

| Task | Model | Cost | Speed |
|------|-------|------|-------|
| Code formatting | Local (Ollama) | $0 | Fast |
| Simple refactors | Local (Ollama) | $0 | Fast |
| Complex features | API (DeepSeek-V4-Flash) | $0.09/M | Moderate |
| Architecture decisions | API (MiMo-V2.5-Pro) | $0.43/M | Slower |

**Savings**: 50-70% of tasks can be handled locally for free.

### 7. Token-Efficient Prompting

**Technique**: Write concise prompts that use fewer tokens.

| Prompt Style | Tokens | Quality | Cost |
|--------------|--------|---------|------|
| Verbose explanation | 500 | High | $$ |
| Concise instructions | 200 | High | $ |
| Code-only prompt | 100 | Moderate | ¢ |

**Best practice**: Be specific and concise. "Fix the bug in line 42" uses fewer tokens than "There seems to be an issue with the function on line 42, could you please investigate and fix it?"

### 8. Caching Strategies for Coding Agents

| Strategy | Implementation | Savings |
|----------|---------------|---------|
| **System prompt caching** | Keep AGENTS.md/static instructions at start of prompt | 50-90% on repeated context |
| **File context caching** | Cache file contents that don't change between requests | 30-70% on file reads |
| **Tool definition caching** | Cache tool/function definitions | 10-30% on tool-heavy prompts |
| **Conversation history** | Use automatic caching for multi-turn conversations | 50-80% on long sessions |

---

## Improved Recommendations

### For Your Usage Pattern (Heavy Coder, Capability-Constrained) — revised 2026-07-20

**The free-first strategy below is superseded.** `deepseek-v4-flash:free` is dead, and Sean has
separately confirmed that surviving free models aren't capable enough for his actual work (the
widened quality gap in the section above supports this). Current strategy: one fixed capable
primary model, compressed aggressively (RTK/Caveman/Ponytail), with a free model reserved for
the review-gate role only. Full policy: `phases/phase-002-model-consolidation-token-efficiency.md`.

**Primary Strategy: Fixed Paid Primary + Free Review Gate**

| Task Type | Model | Cost | Why |
|-----------|-------|------|-----|
| **Planning + coding + verification** | Your chosen primary (Claude via subscription, or DeepSeek-V4-Pro via API — see the lane decision in `recommendations-economist.md`) | subscription or $0.435/$0.87 per MTok | One model, one session, no cache loss |
| **Escalation (exception only)** | Next model up in the same family | higher | Hard-signal failure + one same-model retry first, in a fresh session |
| **Reviews** | Nemotron 3 Ultra Free (`nvidia/nemotron-3-ultra-550b-a55b:free`, confirmed live) | $0 | Cross-model review, its own session |

**Estimated Monthly Cost**: EUR 24-35 (subscription-anchored lane) or EUR 55-135 (API-only
lane, before compression savings) — see `recommendations-economist.md` for the full lane
comparison.

### Token Compression Checklist

Before each request, ask:
1. ✅ Am I staying on my primary model for this whole session (no mid-session switching)?
2. ✅ Am I sending only necessary context (not entire repo)?
3. ✅ Am I using prompt caching (static content first, byte-identical between requests)?
4. ✅ Am I limiting response length appropriately?
5. ✅ Can I batch multiple tasks into one request?
6. ✅ Can I use local models for simple tasks?

### Cost Reduction Priority

| Priority | Technique | Effort | Savings |
|----------|-----------|--------|---------|
| 1 | Never switch models mid-session (caches are model-scoped) | Low | Avoids repeated full-context re-pricing |
| 2 | Enable prompt caching | Low | 50-90% on repeated context |
| 3 | Send only relevant context | Medium | 30-70% |
| 4 | Escalate on hard failure only, never cascade routinely | Medium | Avoids the switching cost above, escalation stays rare |
| 5 | Batch similar tasks | Medium | 40-60% |
| 6 | Local pre-processing | High | 50-70% |
| 7 | Token-efficient prompting | Low | 20-40% |

**Combined Savings**: RTK, Caveman, and Ponytail together claim roughly 50-90% off different
token categories (tool-output input, agent-output prose, code volume respectively); realistic
combined session-level savings are lower than the naive product of the three because they
compress overlapping content. Treat 90-95% as the tools' own upper-bound marketing claim, not
a verified combined figure.
