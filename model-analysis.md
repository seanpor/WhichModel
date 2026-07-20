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

> **⚠️ Correction, verified 2026-07-20, then corrected again 2026-07-20 (later):** The first
> pass here found `deepseek/deepseek-v4-flash:free` dead on OpenRouter and concluded that free
> models generally "aren't capable enough" for real work. That conclusion overgeneralised from
> one dead listing to an entire category, and Sean's own production OpenCode config
> (`plan`/`build` both bound to `nvidia/nemotron-3-ultra-550b-a55b:free`, working) is direct
> evidence against it. The corrected view: **the failure mode was a dead or small/weak
> specific model, not "free" as a category.** Large flagship free models — Nemotron 3 Ultra
> 550B (OpenRouter), Big Pickle and `deepseek-v4-flash-free` (OpenCode Zen, verified live via
> direct API call below) — are legitimate primaries. Small free models (Gemma 26B, the
> surviving Llama/Qwen remnants) are not, regardless of price. See
> `phases/phase-002-model-consolidation-token-efficiency.md` for the full correction.

### OpenCode Zen (opencode.ai/zen)

**Re-verified live 2026-07-20** via direct API call to `GET https://opencode.ai/zen/v1/models`
(the endpoint the first pass couldn't find). Confirms five explicitly `-free`-suffixed models
plus Big Pickle:

| Model | ID (live API) | Notes |
|-------|----|-------|
| Big Pickle | `big-pickle` | **Confirmed live**, no `-free` suffix in its ID but free per multiple corroborating sources (promotional, indefinite as of July 2026). **Frontier-tier**: SWE-bench ~72%, 200K context — a genuinely strong coding benchmark, competitive with paid models. Stealth model, possibly GLM mixture. Data may be used for training during the promotional period. |
| DeepSeek V4 Flash Free | `deepseek-v4-flash-free` | **Confirmed live on Zen**, even though the equivalent OpenRouter `:free` listing is dead — different platforms, different provider funding. Data may be used for training. |
| MiMo-V2.5 Free | `mimo-v2.5-free` | **Confirmed live.** Promotional. |
| North Mini Code Free | `north-mini-code-free` | **Confirmed live.** Cohere-based. Data retained. Do NOT submit confidential data. |
| Nemotron 3 Ultra Free | `nemotron-3-ultra-free` | **Confirmed live.** NVIDIA trial. Data logged for improvement. |
| Hunyuan 3 Free | `hy3-free` | **New, not in the original list.** Confirmed live on both Zen and OpenRouter (`tencent/hy3:free`). |

**Unverified, flag before relying on it:** third-party blogs claim Zen's free tier grants
"100 requests/day with access to all Zen models" — i.e. possibly including frontier paid
models like Claude Opus, not just the `-free`-suffixed ones above. The `/models` endpoint
doesn't expose pricing, so this isn't API-verifiable from here. Confirm directly in the Zen
dashboard before treating it as a planning input — if true, it's a materially better offer
than anything else in this document.

### OpenRouter (openrouter.ai)

**Re-verified live 2026-07-20** against `GET https://openrouter.ai/api/v1/models` — 14 `:free`
models currently served (down from the 26 this section originally claimed; many code-focused
models have rotated out). Confirmed-live free models:

| Model | ID | Context | Notes |
|-------|----|---------|-------|
| Nemotron 3 Ultra 550B | `nvidia/nemotron-3-ultra-550b-a55b:free` | 1M | **Confirmed live, confirmed working in production** (Sean's `plan`/`build` agents). Strong general reasoning — viable as a primary, not just for review |
| Nemotron 3 Super 120B | `nvidia/nemotron-3-super-120b-a12b:free` | 1M | **Confirmed live.** Large context |
| Gemma 4 31B | `google/gemma-4-31b-it:free` | 262K | **Confirmed live.** Google, good quality |
| Gemma 4 26B | `google/gemma-4-26b-a4b-it:free` | 262K | **Confirmed live.** Google, efficient |
| Poolside Laguna M.1 | `poolside/laguna-m.1:free` | 262K | **Confirmed live.** Code-focused |
| Poolside Laguna XS 2.1 | `poolside/laguna-xs-2.1:free` | 262K | **Confirmed live**, but ID changed from the `laguna-xs.2:free` this doc originally listed |
| Cohere North Mini Code | `cohere/north-mini-code:free` | 256K | **Confirmed live.** Code-focused |
| OpenAI gpt-oss-20b | `openai/gpt-oss-20b:free` | 131K | **Confirmed live**, but replaces the `gpt-oss-120b:free` this doc originally listed — smaller model, re-evaluate quality before relying on it |
| Tencent Hunyuan 3 | `tencent/hy3:free` | — | **New, confirmed live.** Not previously catalogued |

**No longer served (confirmed dead 2026-07-20):** `deepseek/deepseek-v4-flash:free`,
`qwen/qwen3-coder:free`, `qwen/qwen3-next-80b-a3b-instruct:free`,
`nousresearch/hermes-3-llama-3.1-405b:free`, `meta-llama/llama-3.3-70b-instruct:free`,
`openai/gpt-oss-120b:free`. Do not route work to these IDs — requests will fail or silently
fall back to a different model than intended.

### Kimi / Moonshot — confirmed no free tier anywhere

Checked both platforms 2026-07-20: OpenRouter has 8 Kimi/Moonshot IDs (`kimi-k2` through
`kimi-k3`), all paid, cheapest `moonshotai/kimi-k2.7-code` at $0.85/$3.80 per MTok. OpenCode
Zen lists `kimi-k2.7-code`, `kimi-k2.6`, `kimi-k2.5` — none `-free`-suffixed. If Kimi is
wanted, it's an escalation/paid option, not a free primary candidate.

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
| Large free models (OpenRouter Nemotron 3 Ultra, Zen Big Pickle/DeepSeek Flash Free) | **€0** | Rate-limited by provider (OpenRouter: 20 req/min, 50-1,000/day) | Rate limits and per-task quality, not a blanket capability gap — see revision below (2026-07-20) |
| Ollama local (Qwen 2.5 Coder 7B) | ~€9 electricity | Unlimited | Speed, quality gap |
| Paid escalation tier (as needed, not default) | ~€24-135 | High, quota or usage-bound | Only relevant if the free primary demonstrably falls short — see "Free vs Paid Models" below |

---

## Free vs Paid Models: Side-by-Side Comparison

> **⚠️ Revised 2026-07-20, then corrected again 2026-07-20 (later):** The first revision
> found DeepSeek-V4-Flash Free (1257 elo) and Qwen3-Coder-480B Free (1193 elo) dead on
> OpenRouter and concluded free models generally "aren't capable enough" — an
> overgeneralisation from those two specific deaths. The benchmark table below (elo / coding
> index / agentic index) only covers OpenRouter models with numbers on that specific
> benchmark suite; it does not include OpenCode Zen's Big Pickle, which isn't scored on the
> same suite but reports **SWE-bench ~72%** independently — a strong, frontier-competitive
> figure on a different (also credible) benchmark. Treat the "gap" below as the gap between
> *this specific benchmark's* best-scored free and paid models, not as evidence that free
> models categorically fall short.

### Top Free Models Scored on This Benchmark Suite (OpenRouter, still served as of 2026-07-20)

| Model | Code Elo | Coding Idx | Agentic | Context | $/M (in/out) | Best For |
|-------|----------|------------|---------|---------|--------------|----------|
| **Nemotron 3 Ultra Free** | 1174 | 49.3 | 27.4 | 1M | $0/$0 | Confirmed working as a primary in production (Sean's `plan`/`build` agents) |
| Gemma 4 26B Free | - | 39.3 | 11 | 262K | $0/$0 | Google quality |
| ~~DeepSeek-V4-Flash Free~~ | 1257 | 56.2 | 31.1 | 1M | dead | **No longer served on OpenRouter — do not route here** (still live as `deepseek-v4-flash-free` on OpenCode Zen) |
| ~~Qwen3-Coder-480B Free~~ | 1193 | - | - | 1M | dead | **No longer served — do not route here** |
| ~~OpenAI GPT-OSS-120B Free~~ | 1014 | 30.4 | 13.2 | 131K | dead | Replaced by the smaller `gpt-oss-20b:free`, not re-benchmarked |

**Not on this benchmark suite, but independently strong:** Big Pickle (OpenCode Zen, free,
SWE-bench ~72%, 200K context) — a different eval, not directly comparable to the Elo/Idx/Agentic
columns above, but evidence of frontier-tier capability at zero cost.

### Top Paid Models (Under $0.50/M Input)

| Model | Code Elo | Coding Idx | Agentic | Context | $/M (in/out) | Best For |
|-------|----------|------------|---------|---------|--------------|----------|
| **MiMo-V2.5-Pro** | 1318 | 60.2 | 29.1 | 1M | $0.43/$0.87 | Premium quality |
| MiniMax M3 | 1307 | 58.6 | 35.4 | 1M | $0.30/$1.20 | Best agentic |
| MiMo-V2.5 | 1304 | - | - | 1M | $0.10/$0.28 | Best value |
| DeepSeek-V4-Pro | 1289 | 59.4 | 36.4 | 1M | $0.43/$0.87 | Strong all-round |
| DeepSeek-V4-Flash | 1257 | 56.2 | 31.1 | 1M | $0.09/$0.18 | **Cheapest paid** (the free OpenRouter listing of this same model is dead; a free listing survives on OpenCode Zen) |
| Qwen3-Coder-Flash | - | - | - | 1M | $0.20/$0.97 | Good balance |
| Kimi-K2.7-code | - | - | - | 262K | $0.85/$3.80 | Cheapest Kimi/Moonshot option — no free tier exists for this family on any platform checked |

### Gap on This Benchmark Suite (not a general capability verdict)

| Metric | Best free, this suite (Nemotron 3 Ultra) | Best Paid | Gap |
|--------|-----------|-----------|-----|
| Code Elo | 1174 | 1318 (MiMo-V2.5-Pro) | -144 (10.9% lower) |
| Coding Index | 49.3 | 60.2 (MiMo-V2.5-Pro) | -10.9 (18.1% lower) |
| Agentic Index | 27.4 | 36.4 (DeepSeek-V4-Pro) | -9.0 (24.7% lower) |

**Corrected conclusion (2026-07-20, later)**: A benchmark gap on one suite is not the same
claim as "free models aren't capable enough for real work" — Sean's own production config
demonstrates Nemotron 3 Ultra 550B working as a primary. The right question isn't free-vs-paid,
it's whether *this specific model* performs on *your specific tasks* and whether the
*provider's rate limits* (OpenRouter: 20 req/min, 50-1,000/day) bind at your usage volume.
Track both for two weeks before assuming a paid tier is needed — see
`phases/phase-002-model-consolidation-token-efficiency.md` for the full correction and the
resulting policy.

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

### For Your Usage Pattern (Heavy Coder, Free-Primary-First) — revised 2026-07-20, corrected again 2026-07-20 (later)

**Corrected once more, same day.** The "capability-constrained" framing that replaced the
original free-first strategy was itself wrong — it generalised from one dead model
(`deepseek-v4-flash:free`) to a blanket claim that free models aren't capable enough. Sean's
production config (`plan`/`build` on `nvidia/nemotron-3-ultra-550b-a55b:free`) is direct
evidence otherwise. Current strategy: **a large, confirmed-live free model as primary**
(Nemotron 3 Ultra 550B, or OpenCode Zen's Big Pickle / `deepseek-v4-flash-free`), compressed
aggressively (RTK/Caveman/Ponytail) to stretch rate limits further, with a paid tier reserved
for confirmed rate-limit exhaustion or a specific task the free primary demonstrably can't
handle. Full policy: `phases/phase-002-model-consolidation-token-efficiency.md`.

**Primary Strategy: Large Free Primary + Paid Escalation**

| Task Type | Model | Cost | Why |
|-----------|-------|------|-----|
| **Planning + coding + verification** | A large, confirmed-live free model — Nemotron 3 Ultra 550B (OpenRouter), Big Pickle or `deepseek-v4-flash-free` (OpenCode Zen) | $0 | One model, one session, no cache loss. Verify liveness before committing — free rosters rotate |
| **Escalation (exception only)** | DeepSeek-V4-Pro, Kimi-K2.7-code, or Claude (subscription/API) | $0.435-3.80/MTok, or subscription | Only on confirmed rate-limit exhaustion or a specific task the free primary can't handle — always a fresh session |
| **Reviews** | Nemotron 3 Ultra Free (`nvidia/nemotron-3-ultra-550b-a55b:free`, confirmed live) — a different model from the primary even if the primary is also free | $0 | Cross-model review, its own session |

**Estimated Monthly Cost**: EUR 0 if the free primary covers your workload within rate limits
(the likely case, per your own production evidence) — track rate-limit hits for two weeks to
confirm. EUR 24-135 only for whatever fraction of work genuinely needs paid escalation.

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
