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

**Conclusion**: MiMo Code is competitive with OpenRouter for cache-heavy work, but OpenRouter is cheaper for fresh work. Use free models on OpenRouter for 80% of work.

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

### OpenCode Zen (opencode.ai/zen)

| Model | Notes |
|-------|-------|
| Big Pickle | Stealth model, possibly GLM mixture. Free "for limited time". Data may be used for training. |
| DeepSeek V4 Flash Free | Promotional. Data may be used for training. |
| MiMo-V2.5 Free | Promotional. |
| North Mini Code Free | Cohere-based. Data retained. Do NOT submit confidential data. |
| Nemotron 3 Ultra Free | NVIDIA trial. Data logged for improvement. |

### OpenRouter (openrouter.ai)

26 free models. Best for coding:

| Model | ID | Size | Context | Notes |
|-------|----|------|---------|-------|
| **DeepSeek-V4-Flash Free** | `deepseek/deepseek-v4-flash:free` | ? | 1M | **Primary recommendation** — fast, reliable, free |
| Qwen3 Coder 480B | `qwen/qwen3-coder:free` | 480B MoE | 1M | Massive, code-specialized (unreliable recently) |
| Nemotron 3 Ultra 550B | `nvidia/nemotron-3-ultra-550b-a55b:free` | 550B MoE | 1M | Strong general reasoning, great for reviews |
| OpenAI gpt-oss-120b | `openai/gpt-oss-120b:free` | 120B | 131K | Decent reasoning, OpenAI-trained |
| Nous Hermes 3 405B | `nousresearch/hermes-3-llama-3.1-405b:free` | 405B | 131K | Good at following complex instructions |
| Meta Llama 3.3 70B | `meta-llama/llama-3.3-70b-instruct:free` | 70B | 131K | Fast, decent for straightforward tasks |
| Poolside Laguna M.1 | `poolside/laguna-m.1:free` | ? | 262K | Code-focused |
| Poolside Laguna XS.2 | `poolside/laguna-xs.2:free` | ? | 262K | Code-focused, smaller |
| Gemma 4 31B | `google/gemma-4-31b-it:free` | 31B | 262K | Google, good quality |
| Gemma 4 26B | `google/gemma-4-26b-a4b-it:free` | 26B MoE | 262K | Google, efficient |
| Nemotron 3 Super 120B | `nvidia/nemotron-3-super-120b-a12b:free` | 120B MoE | 1M | Large context |
| Qwen3 Next 80B | `qwen/qwen3-next-80b-a3b-instruct:free` | 80B MoE | 262K | Qwen family |
| Cohere North Mini Code | `cohere/north-mini-code:free` | ? | 256K | Code-focused |

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
| Free models only (OpenRouter/Zen) | **€0** | Unlimited (rate-limited) | Quality ceiling, privacy |
| Ollama local (Qwen 2.5 Coder 7B) | ~€9 electricity | Unlimited | Speed, quality gap |
| Mixed: free implementer + paid planner | ~€5-15 | High | Smart budget allocation |

---

## Free vs Paid Models: Side-by-Side Comparison

### Top Free Models (OpenRouter)

| Model | Code Elo | Coding Idx | Agentic | Context | $/M (in/out) | Best For |
|-------|----------|------------|---------|---------|--------------|----------|
| **DeepSeek-V4-Flash Free** | 1257 | 56.2 | 31.1 | 1M | $0/$0 | Primary coding (free) |
| Qwen3-Coder-480B Free | 1193 | - | - | 1M | $0/$0 | Code-specialized (unreliable) |
| Nemotron 3 Ultra Free | 1174 | 49.3 | 27.4 | 1M | $0/$0 | Reviews, reasoning |
| OpenAI GPT-OSS-120B Free | 1014 | 30.4 | 13.2 | 131K | $0/$0 | Alternative |
| Gemma 4 26B Free | - | 39.3 | 11 | 262K | $0/$0 | Google quality |

### Top Paid Models (Under $0.50/M Input)

| Model | Code Elo | Coding Idx | Agentic | Context | $/M (in/out) | Best For |
|-------|----------|------------|---------|---------|--------------|----------|
| **MiMo-V2.5-Pro** | 1318 | 60.2 | 29.1 | 1M | $0.43/$0.87 | Premium quality |
| MiniMax M3 | 1307 | 58.6 | 35.4 | 1M | $0.30/$1.20 | Best agentic |
| MiMo-V2.5 | 1304 | - | - | 1M | $0.10/$0.28 | Best value |
| DeepSeek-V4-Pro | 1289 | 59.4 | 36.4 | 1M | $0.43/$0.87 | Strong all-round |
| DeepSeek-V4-Flash | 1257 | 56.2 | 31.1 | 1M | $0.09/$0.18 | **Cheapest paid** |
| Qwen3-Coder-Flash | - | - | - | 1M | $0.20/$0.97 | Good balance |

### Quality Gap: Free vs Paid

| Metric | Best Free | Best Paid | Gap |
|--------|-----------|-----------|-----|
| Code Elo | 1257 (DeepSeek-V4-Flash Free) | 1318 (MiMo-V2.5-Pro) | -61 (4.6% lower) |
| Coding Index | 56.2 (DeepSeek-V4-Flash Free) | 60.2 (MiMo-V2.5-Pro) | -4.0 (6.7% lower) |
| Agentic Index | 31.1 (DeepSeek-V4-Flash Free) | 36.4 (DeepSeek-V4-Pro) | -5.3 (14.5% lower) |

**Conclusion**: Free models are only 5-15% worse than paid models on benchmarks. For 80% of coding tasks, the difference is negligible.

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

### 4. Model Cascading

**Technique**: Use cheaper models first, escalate to expensive models only if needed.

| Step | Model | Cost | When to Use |
|------|-------|------|-------------|
| 1 | Free model (DeepSeek-V4-Flash Free) | $0 | Try first for all tasks |
| 2 | Cheap paid (DeepSeek-V4-Flash) | $0.09/M | If free model fails |
| 3 | Mid-range (Qwen3-Coder-Flash) | $0.20/M | Complex reasoning |
| 4 | Premium (MiMo-V2.5-Pro) | $0.43/M | Critical tasks only |

**Savings**: 80% of tasks succeed with free models → 80% cost reduction.

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

### For Your Usage Pattern (Heavy Coder, Budget-Conscious)

**Primary Strategy: Free Models + Smart Escalation**

| Task Type | Model | Cost | Why |
|-----------|-------|------|-----|
| **80% of work** | DeepSeek-V4-Flash Free | $0 | Fast, reliable, free |
| **15% of work** | DeepSeek-V4-Flash (paid) | $0.09/M | When free fails |
| **5% of work** | Qwen3-Coder-Flash | $0.20/M | Critical tasks |
| **Reviews** | Nemotron 3 Ultra Free | $0 | Cross-model review |

**Estimated Monthly Cost**: $20-30 (vs $300 on MiMo Code at your usage rate)

### Token Compression Checklist

Before each request, ask:
1. ✅ Am I using the smallest model that can handle this task?
2. ✅ Am I sending only necessary context (not entire repo)?
3. ✅ Am I using prompt caching (static content first)?
4. ✅ Am I limiting response length appropriately?
5. ✅ Can I batch multiple tasks into one request?
6. ✅ Can I use local models for simple tasks?

### Cost Reduction Priority

| Priority | Technique | Effort | Savings |
|----------|-----------|--------|---------|
| 1 | Use free models for 80% of work | Low | 80% |
| 2 | Enable prompt caching | Low | 50-90% on repeated context |
| 3 | Send only relevant context | Medium | 30-70% |
| 4 | Use model cascading | Medium | 60-80% |
| 5 | Batch similar tasks | Medium | 40-60% |
| 6 | Local pre-processing | High | 50-70% |
| 7 | Token-efficient prompting | Low | 20-40% |

**Combined Savings**: 90-95% cost reduction is achievable with these techniques.
