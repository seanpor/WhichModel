# Recommendations

Last updated: 2026-07-20, corrected twice same day (see notes below; original analysis 2026-06-29)

> **⚠️ Correction, verified 2026-07-20:** The "80% free" budget strategy this document
> originally opened with relied on `deepseek/deepseek-v4-flash:free`, which is **no longer
> served by any provider on OpenRouter** (confirmed via the live `GET /v1/models` API — 14
> `:free` models currently served, DeepSeek not among them).
>
> **⚠️ Corrected again, same day (later):** The first correction went further and concluded
> free models generally "aren't capable enough" for this workload — that was an
> overgeneralisation from one dead model to an entire category. Sean's own production OpenCode
> config runs `plan`/`build` on `nvidia/nemotron-3-ultra-550b-a55b:free`, working. Large
> flagship free models (that one, plus OpenCode Zen's Big Pickle — SWE-bench ~72%, and
> `deepseek-v4-flash-free`, which is still live on Zen even though the equivalent OpenRouter
> listing died) are legitimate primaries. The document below reflects this: **free-first
> primary, paid only as a confirmed-need escalation**, not the reverse. Full policy and
> rationale: `phases/phase-002-model-consolidation-token-efficiency.md`.

## Current Setup

- MiMo Code: $50/month for 38B credits (burns fast — ~21 hours of heavy use)
- OpenRouter: $5 balance
- Local: 2080 Ti (11GB VRAM) available for Ollama

## Budget Strategy — revised twice (was "Free Models (80% of work)")

### Primary: a large, confirmed-live free model
- **Nemotron 3 Ultra 550B** (`nvidia/nemotron-3-ultra-550b-a55b:free`, OpenRouter) — already confirmed working in production
- Or OpenCode Zen's **Big Pickle** (`big-pickle`) or **DeepSeek V4 Flash Free** (`deepseek-v4-flash-free`) — both confirmed live via direct API check 2026-07-20
- Same model for planning, coding, and verification, in one session — never switched mid-conversation (prompt caches are model-scoped; a switch re-prices the whole context)
- Verify liveness before committing — free rosters rotate; `deepseek/deepseek-v4-flash:free` on OpenRouter is the cautionary example

### Escalation (exception only, on confirmed rate-limit exhaustion or a specific task failure — not a routine tier)
- **DeepSeek-V4-Pro** (`deepseek/deepseek-v4-pro`) — $0.435/$0.87 per MTok, or **Kimi-K2.7-code** — $0.85/$3.80 per MTok, or a Claude subscription/API tier for frontier reasoning
- Triggered only by a build/lint/test failure after one same-model retry, or by hitting OpenRouter's free-tier caps (20 req/min, 50-1,000/day) — always in a fresh session

### Reviews (free, own session — no cache to lose here)
- **Nemotron 3 Ultra Free** (`nvidia/nemotron-3-ultra-550b-a55b:free`, confirmed live 2026-07-20) — cross-model review for phase docs and PRs, a different model from the primary even when the primary is also free

## Cost Comparison

| Approach | $/month | Hours of heavy use | Notes |
|----------|---------|-------------------|-------|
| MiMo Code ($50/38B) | $50 | ~21.6 hours | Burns fast, opaque credits |
| Free primary (Nemotron 3 Ultra 550B, or Zen's Big Pickle/DeepSeek Flash Free) | $0 | Rate-limited by provider, not by quality | Track rate-limit hits for two weeks before assuming you need to pay for anything |
| OpenRouter DeepSeek-V4-Pro (paid escalation, as-needed) | ~$60-150 at full usage | Usage-scaled | Only for the fraction of work the free primary can't cover |
| Claude Pro (subscription escalation, as-needed) | ~€24-35 | Quota-bound, stretched by compression stack | Only relevant if you specifically want frontier Claude-tier reasoning |

## MiMo Code Credit-to-Token Conversion

| Model | Input (Cache Hit) | Input (Cache Miss) | Output |
|-------|-------------------|-------------------|--------|
| MiMo-V2.5 | 2 credits/token | 100 credits/token | 200 credits/token |
| MiMo-V2.5-Pro | 2.5 credits/token | 300 credits/token | 600 credits/token |

Effective cost per MTok (MiMo Code $50/38B):
- MiMo-V2.5 cache miss input: $0.1316/MTok (31% MORE than OpenRouter)
- MiMo-V2.5 output: $0.2632/MTok (6% cheaper than OpenRouter)
- Cache hits: $0.003/MTok (incredibly cheap)

## Recommendation

**Confirm your free primary is a large, currently-live model — it likely already is.** Keep
paid tiers (subscription or API) as an escalation reserve, not a default lane. Never switch
models inside a session. See `recommendations-economist.md` → "Picking a primary" for the
full reasoning.

**Keep MiMo Code** only for cache-heavy repeated work (if you have credits left).

---

## Real-World Usage Across Multiple Projects

### How the Global Config Works

The global config at `~/.config/opencode/opencode.json` applies to **every project** automatically. When you `cd` into any project and run `opencode`, it uses the global agents unless overridden.

### Per-Project Overrides

Create `.opencode/opencode.json` in any project root to customize:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "build": {
      "model": "openrouter/deepseek/deepseek-v4-flash"
    }
  }
}
```

### Project Types and Workflows

| Project Type | Git | PRs | Verification | Agents Used |
|--------------|-----|-----|--------------|-------------|
| GitHub (e.g., JA4proxy) | Yes | Yes (branch protection) | @verify, @pr-review, @phase-review | All |
| GitLab | Yes | Yes (merge requests) | @verify, @pr-review, @phase-review | All |
| Local git (no remote) | Yes | No | @verify, @phase-review | Most |
| Personal (no git) | No | No | @verify | Minimal |
| Multi-agent parallel | Yes | Optional | All | All + coordination |

### Adapting to Each Project

1. **GitHub/GitLab projects**: Use full workflow (plan → implement → verify → PR → review → merge)
2. **Local git projects**: Skip PR step, commit directly after verification
3. **Personal projects**: Just implement and verify, no git needed
4. **Multi-agent projects**: Add file ownership rules to project-specific AGENTS.md

### What Stays the Same Everywhere

- Global agents (plan, build, @verify, @pr-review, etc.) work in all projects
- Verification protocol (must run build/lint/test before claiming success)
- Cross-model review (different models for writing vs reviewing)
- Budget strategy (fixed capable primary, free model for review only, escalate on hard failure)

---

## Token Usage Rates (Quick Reference)

### Your Usage Rate
- **4.4B credits in 2.5 hours** = 1.76B credits/hour
- **~13.5 MTok/hour** (MiMo-V2.5 standard, mixed input/output)
- **~$1.77/hour** on MiMo Code
- **~$1.22/hour** on OpenRouter DeepSeek-V4-Flash (paid)

### How Long Budgets Last (at your rate)

| Budget | MiMo Code | OpenRouter (paid) | OpenRouter (free) |
|--------|-----------|-------------------|-------------------|
| $20/month | ~11 hours | ~16 hours | Unlimited |
| $50/month | ~21.6 hours | ~31.6 hours | Unlimited |
| $100/month | ~43 hours | ~63 hours | Unlimited |

### Cost Per Hour

| Model | $/hour | $/day (5h) | $/month (22 days) |
|-------|--------|------------|-------------------|
| MiMo Code | $1.77 | $8.85 | $194.70 |
| DeepSeek-V4-Flash (paid) | $1.22 | $6.10 | $134.20 |
| Free models | $0.00 | $0.00 | $0.00 |

### Recommendation by Usage — revised 2026-07-20, corrected again same day

A large free model (Nemotron 3 Ultra 550B, Big Pickle) is a legitimate primary at every usage
tier — see the correction at the top of this document. The real variable is whether the
provider's rate limits bind at your volume, which is a thing to measure, not assume:

- **Light user** (< 5h/week): Free primary comfortably covers this; OpenRouter's caps (20 req/min, 50-1,000/day) are very unlikely to bind.
- **Medium user** (5-15h/week): Same — likely still fine on a free primary.
- **Heavy user** (15-30h/week): Track rate-limit hits for two weeks; may need a paid escalation tier for part of the month if caps bind.
- **Full-time / Power user** (your rate, 40h+/week): Most likely to hit provider rate limits. If it does bind, a paid escalation tier (DeepSeek-V4-Pro via API, or a Claude subscription) covers the overflow — see "Picking a primary" in `recommendations-economist.md`. Don't assume this in advance; confirm it first.

---

## Token Compression & Cost Reduction

### Quick Wins (Easy, High Impact)

1. **Never switch models mid-session** — caches are model-scoped; a switch re-prices your entire accumulated context
2. **Enable prompt caching** — Keep static content (AGENTS.md, file context) at start of prompt
3. **Send only relevant files** — Use `@file` references, not entire repo
4. **Limit response length** — Set `max_tokens` based on task complexity

### Advanced Techniques

| Technique | Effort | Savings | How |
|-----------|--------|---------|-----|
| **Escalation on hard failure** | Medium | Keeps escalation rare | Retry once same model, then fresh session on next model up — never cascade routinely |
| **Batch similar tasks** | Medium | 40-60% | Combine multiple fixes into one request |
| **Local pre-processing** | High | 50-70% | Use Ollama for simple tasks |
| **Token-efficient prompts** | Low | 20-40% | Be concise, specific |
| **Context window management** | Medium | 30-70% | Only send relevant context |

### Prompt Caching Savings

| Provider | Cache Hit Discount | Min Tokens | Best For |
|----------|-------------------|------------|----------|
| Anthropic (Claude) | 90% cheaper | 1024-4096 | Long conversations |
| OpenAI (GPT) | Up to 90% cheaper | 1024 | Automatic |
| DeepSeek | 90% cheaper | Unknown | Budget coding |

**Example**: 10K token system prompt + 1K new tokens per request:
- Without caching: $0.00099/request
- With caching: $0.0001/request
- **Savings**: 90%

### Cost Reduction Priority

| Priority | Technique | Effort | Savings |
|----------|-----------|--------|---------|
| 1 | Never switch models mid-session (caches are model-scoped) | Low | Avoids repeated full-context re-pricing |
| 2 | Enable prompt caching | Low | 50-90% |
| 3 | Send only relevant context | Medium | 30-70% |
| 4 | Escalate on hard failure only, never cascade routinely | Medium | Keeps escalation rare |
| 5 | Batch similar tasks | Medium | 40-60% |

**Combined Savings**: 90-95% cost reduction is achievable.

---

## Your Workflow Optimization

### Current Workflow (Expensive)

```
1. Big model writes detailed plan (10-20K tokens)
2. Same model critically reviews plan (10-20K tokens)
3. Another powerful model reviews plan (10-20K tokens)
4. Implementation (sometimes with cheaper model)
5. Critical review by powerful model (10-20K tokens)
```

**Total per feature**: 50-100K tokens = $5-20 per feature (at premium model rates)

### Optimized Workflow — revised 2026-07-20, corrected again same day (was "90% Cheaper" on all-free models)

The original all-free version relied specifically on `deepseek-v4-flash:free` (now dead on
OpenRouter — but a similar model, `deepseek-v4-flash-free`, is still live on OpenCode Zen).
The intermediate correction wrongly concluded free models generally aren't capable enough for
planning and implementation — Sean's own production config disproves that. Corrected version:
still mostly free, on a large confirmed-live model, with compression stacked on top:

```
1. Free primary (Nemotron 3 Ultra 550B, or Zen's Big Pickle) writes detailed plan (10-20K tokens) — same session throughout
2. Free review-gate model (Nemotron 3 Ultra Free — a different model) reviews the plan, in its own session → $0
3. Free primary implements (20-50K tokens), same session as the plan
4. Free review-gate model reviews the implementation, own session → $0
```

**Total per feature**: 50-90K tokens on the free primary, reduced 50-90% by RTK/Caveman/Ponytail;
everything above costs $0.

**Escalation (exception only, on confirmed rate-limit exhaustion or a specific task the free primary can't handle — not a routine step)**:
- DeepSeek-V4-Pro ($0.435/$0.87 per MTok) for architecture or security work the free primary struggled with
- Frontier tier for the hardest problems: MiMo-V2.5-Pro ($0.43/$0.87 per MTok), Kimi-K2.7-code ($0.85/$3.80 per MTok, no free tier exists for Kimi), or Claude Opus 4.8
- Always a fresh session, never a live switch — see "Escalation, not cascading" in `recommendations-economist.md`

### Token Compression Setup

#### 1. Prompt Caching (Automatic)

**How to enable**: Just use the models normally — caching is automatic on most providers.

| Provider | How to Enable | Cache Hit Savings |
|----------|---------------|-------------------|
| OpenRouter | Automatic | 90% cheaper |
| OpenAI | Automatic | 90% cheaper |
| Anthropic | Add `cache_control` parameter | 90% cheaper |
| DeepSeek | Automatic | 90% cheaper |

**What gets cached**:
- System prompts (AGENTS.md)
- Tool definitions
- File context that doesn't change
- Conversation history

**What doesn't get cached**:
- New user messages
- New file content
- Changing context

#### 2. Context Window Management

**Before each request, ask**:
- ❌ Am I sending the entire repo? → Send only relevant files
- ❌ Am I sending unchanged files? → Use `@file` for specific files
- ❌ Am I sending verbose context? → Be concise

**Example**:
```
# Bad (10K tokens)
"Here's my entire codebase: [paste 50 files]"

# Good (2K tokens)
"Fix the bug in @src/auth/login.ts line 42. The issue is [brief description]."
```

#### 3. Response Length Control

**Set `max_tokens` based on task**:

| Task | max_tokens | Why |
|------|------------|-----|
| Simple fix | 500 | Short response |
| Code review | 1000 | Medium response |
| Feature plan | 2000 | Detailed response |
| Complex refactor | 4000 | Full response |

**How to set in OpenCode**:
```json
{
  "agent": {
    "build": {
      "max_tokens": 2000
    }
  }
}
```

#### 4. Escalation on Hard Failure — revised 2026-07-20 (was "Model Cascading")

**Step 1: Primary model does the work, one session**
```
"Write a detailed plan for feature X with acceptance criteria for a junior engineer"
```
Implement and verify in the same session. Free review-gate model checks the plan and the
diff in its own separate session — no cache lost, because nothing was cached for it.

**Step 2: On a hard failure (build/lint/test), retry once on the same model**
Most failures are one-off mistakes, not a capability gap — don't escalate on the first failure.

**Step 3: If the retry also fails, escalate — fresh session, same model family**
```
"Previous attempt on [primary model] failed with: [error]. Tried: [what was tried].
Continue from here."
```
Escalating mid-conversation instead of in a fresh session throws away the prompt cache on
the entire accumulated context — always start fresh.

#### 5. Batch Similar Tasks

**Instead of**:
- Request 1: "Fix bug in login.ts"
- Request 2: "Fix bug in register.ts"
- Request 3: "Fix bug in reset-password.ts"

**Do this**:
- Single request: "Fix these 3 bugs: login.ts line 42, register.ts line 15, reset-password.ts line 28"

**Savings**: 40-60% fewer tokens

#### 6. Local Pre-processing (Desktop Only)

**For simple tasks, use Ollama**:
```bash
ollama run qwen2.5-coder:7b "Fix the syntax error in this code: [paste code]"
```

**Best for**:
- Code formatting
- Simple refactors
- Bug fixes
- Test generation

**Not good for**:
- Complex architecture
- Multi-file changes
- Critical decisions

---

## Token Compression Checklist

Before each request, check:

- [ ] Am I using the cheapest model that can handle this task?
- [ ] Am I sending only necessary context (not entire repo)?
- [ ] Am I using prompt caching (static content first)?
- [ ] Am I limiting response length appropriately?
- [ ] Can I batch multiple tasks into one request?
- [ ] Can I use local models for simple tasks?

**If all checked**: You're optimizing for cost. If not, you're overpaying.

---

## Setup Instructions

### Chromebook (API Only)

1. **Install OpenCode** (if not already):
   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

2. **Configure OpenRouter API key**:
   ```bash
   /connect
   ```
   Select OpenRouter, paste key from openrouter.ai/keys

3. **Verify config** (already done):
   ```bash
   cat ~/.config/opencode/opencode.json
   ```

4. **Test with your configured primary model**:
   ```bash
   cd ~/Perso/AgenticEngineering
   opencode
   ```
   Press Tab to switch to Plan agent, type a question

**Daily budget**: $0 if your free primary (Nemotron 3 Ultra 550B, or Zen's Big Pickle) covers the day within rate limits — the likely case; escalate to paid only if you hit a specific limit or task failure, see "Picking a primary" in `recommendations-economist.md`

### i9-9900K / 2080 Ti Desktop

1. **Install Ollama** (if not already):
   ```bash
   curl -fsSL https://ollama.ai/install.sh | sh
   ```

2. **Pull coding models** (fits in 11GB VRAM):
   ```bash
   # Best for coding (7B, ~5GB VRAM)
   ollama pull qwen2.5-coder:7b
   
   # Alternative (7B, fast)
   ollama pull codestral:7b
   
   # Larger model (12B, ~8GB VRAM, slower but better)
   ollama pull gemma2:12b
   ```

3. **Install OpenCode** (if not already):
   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

4. **Configure OpenRouter API key** (for fallback):
   ```bash
   /connect
   ```
   Select OpenRouter, paste key

5. **Add Ollama to OpenCode config** (optional):
   Create `~/.config/opencode/opencode.json`:
   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "provider": {
       "ollama": {
         "npm": "@ai-sdk/openai-compatible",
         "name": "Ollama (local)",
         "options": {
           "baseURL": "http://localhost:11434/v1"
         },
         "models": {
           "qwen2.5-coder:7b": {
             "name": "Qwen 2.5 Coder 7B (local)"
           }
         }
       }
     }
   }
   ```

**Daily budget**: $0-2 (mostly local, API for complex tasks)

---

## Cost Comparison Summary

| Setup | Monthly Cost | Tokens | Offline | Privacy |
|-------|-------------|--------|---------|---------|
| **Your current workflow** | $100-300 | Limited | ❌ | ❌ |
| **Free primary (Nemotron 3 Ultra 550B, or Zen's Big Pickle/DeepSeek Flash Free)** | €0 | Rate-limited by provider, not by quality | ❌ | ❌ |
| **Paid escalation reserve (as-needed, subscription or API)** | €24-135, only for the fraction that needs it | Usage-scaled | ❌ | ❌ |
| **Desktop (local Ollama)** | ~€13 electricity | Unlimited | ✅ | ✅ |
| **Dual machine (optimized)** | €13 + escalation cost if any | Unlimited | ✅ (Desktop) | Partial |

**Recommendation (revised 2026-07-20, corrected again same day)**: A large free model is a
legitimate primary (see `recommendations-economist.md` → "Picking a primary") — compress
aggressively with RTK/Caveman/Ponytail to stretch rate limits, track rate-limit hits for two
weeks, and reserve a paid tier for whatever fraction of work the free primary can't handle.

---

## Free vs Paid Models: Side-by-Side

> **⚠️ Revised 2026-07-20:** DeepSeek-V4-Flash Free and Qwen3-Coder-480B Free — the top two
> rows below — are confirmed dead on OpenRouter. Nemotron 3 Ultra Free is now the strongest
> surviving free model. See `model-analysis.md` for the full re-verification.

### Top Free Models (still served as of 2026-07-20)

| Model | Code Elo | Coding Idx | Agentic | Context | Best For |
|-------|----------|------------|---------|---------|----------|
| **Nemotron 3 Ultra Free** | 1174 | 49.3 | 27.4 | 1M | Now the strongest surviving free model — review-gate role |
| ~~DeepSeek-V4-Flash Free~~ | 1257 | 56.2 | 31.1 | dead | **No longer served — do not route here** |
| ~~Qwen3-Coder-480B Free~~ | 1193 | - | - | dead | **No longer served — do not route here** |
| ~~OpenAI GPT-OSS-120B Free~~ | 1014 | 30.4 | 13.2 | dead | Replaced by smaller `gpt-oss-20b:free`, not re-benchmarked |

### Top Paid Models (Under $0.50/M Input)

| Model | Code Elo | Coding Idx | Agentic | Context | $/M (in/out) |
|-------|----------|------------|---------|---------|--------------|
| **MiMo-V2.5-Pro** | 1318 | 60.2 | 29.1 | 1M | $0.43/$0.87 |
| MiMo-V2.5 | 1304 | - | - | 1M | $0.10/$0.28 |
| DeepSeek-V4-Pro | 1289 | 59.4 | 36.4 | 1M | $0.43/$0.87 |
| **DeepSeek-V4-Flash** | 1257 | 56.2 | 31.1 | 1M | $0.09/$0.18 (the free listing of this same model is dead) |

### Quality Gap, recalculated against surviving free models

| Metric | Best surviving free (Nemotron) | Best Paid | Gap |
|--------|-----------|-----------|-----|
| Code Elo | 1174 | 1318 | -10.9% |
| Coding Index | 49.3 | 60.2 | -18.1% |
| Agentic Index | 27.4 | 36.4 | -24.7% |

**Revised conclusion**: With the strongest free coding models gone, the gap widened from the
originally-reported 5-15% to roughly 11-25%, worst on the agentic metric that matters most for
coding-agent work — consistent with the direct observation that free models aren't capable
enough for this workload. Free models remain useful for cross-model review, not as a primary.

---

## Machine-Specific Setup Instructions

### Chromebook (Current Machine)

**Hardware**: ChromeOS with Linux container (penguin)
**Limitations**: No local GPU, limited storage, no Ollama
**Best for**: API-based coding with free/paid models

#### Setup

1. **Install OpenCode** (if not already):
   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

2. **Configure OpenRouter API key**:
   ```bash
   /connect
   ```
   Select OpenRouter, paste key from openrouter.ai/keys

3. **Verify config** (already done):
   ```bash
   cat ~/.config/opencode/opencode.json
   ```

4. **Test with your configured primary model**:
   ```bash
   cd ~/Perso/AgenticEngineering
   opencode
   ```
   Press Tab to switch to Plan agent, type a question

#### Recommended Workflow (Chromebook) — revised 2026-07-20, corrected again same day

| Task | Model | Cost | Why |
|------|-------|------|-----|
| **Primary coding + planning** | Nemotron 3 Ultra 550B (`nvidia/nemotron-3-ultra-550b-a55b:free`) | $0 | Same model for both, one session, no cache loss — confirmed working in production |
| **Reviews** | Nemotron 3 Ultra Free (own session, different from the primary session) | $0 | Cross-model review |
| **Escalation** | DeepSeek-V4-Pro or similar, paid | ~$0.44/$0.87 per MTok | Only on confirmed rate-limit exhaustion or a task the free primary can't handle — fresh session |

**Daily budget**: $0 in the common case — free models are a legitimate primary here (see the
correction at the top of this document); escalate to paid only as needed

#### Chromebook Limitations

- **No local models**: Cannot run Ollama (no GPU)
- **No offline coding**: Requires internet for API calls
- **Storage limited**: Keep projects lean, use git

---

### i9-9900K / 2080 Ti Desktop

**Hardware**: Intel i9-9900K (5GHz), NVIDIA 2080 Ti (11GB VRAM), 32GB+ RAM
**Capabilities**: Local Ollama, fast inference, offline coding
**Best for**: Local models + API fallback

#### Setup

1. **Install Ollama**:
   ```bash
   curl -fsSL https://ollama.ai/install.sh | sh
   ```

2. **Pull coding models** (fits in 11GB VRAM):
   ```bash
   # Best for coding (7B, ~5GB VRAM)
   ollama pull qwen2.5-coder:7b
   
   # Alternative (7B, fast)
   ollama pull codestral:7b
   
   # Larger model (12B, ~8GB VRAM, slower but better)
   ollama pull gemma2:12b
   ```

3. **Install OpenCode**:
   ```bash
   curl -fsSL https://opencode.ai/install | bash
   ```

4. **Configure OpenRouter API key**:
   ```bash
   /connect
   ```
   Select OpenRouter, paste key

5. **Add Ollama to OpenCode config** (optional):
   Create `~/.config/opencode/opencode.json`:
   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "provider": {
       "ollama": {
         "npm": "@ai-sdk/openai-compatible",
         "name": "Ollama (local)",
         "options": {
           "baseURL": "http://localhost:11434/v1"
         },
         "models": {
           "qwen2.5-coder:7b": {
             "name": "Qwen 2.5 Coder 7B (local)"
           }
         }
       }
     }
   }
   ```

#### Recommended Workflow (Desktop) — revised 2026-07-20, corrected again same day

Local 7B-class models are further from frontier capability than the large free *cloud* models
(see the `-20-30% vs Opus` gap in the Local Ollama table below) — that comparison is about
local vs cloud, not free vs paid, and still holds. Use local models only for the narrow
offline/simple tasks they're actually good at; use a large free cloud model for real coding.

| Task | Model | Cost | Why |
|------|-------|------|-----|
| **Primary coding + planning** | Nemotron 3 Ultra 550B (cloud, `nvidia/nemotron-3-ultra-550b-a55b:free`) | $0 | One model, one session — confirmed working in production |
| **Simple/offline formatting, boilerplate** | Ollama Qwen 2.5 Coder 7B | $0 (electricity) | Fast, offline — bounded to tasks that don't need frontier quality |
| **Reviews** | Nemotron 3 Ultra Free (own session, different from the primary session) | $0 | Cross-model review |
| **Escalation** | DeepSeek-V4-Pro or similar, paid | ~$0.44/$0.87 per MTok | Only on confirmed rate-limit exhaustion or a task the free primary can't handle — fresh session |

**Daily budget**: $0, plus electricity (~€0.60/day) for local tasks; paid escalation only as needed

#### Desktop Advantages

- **Offline coding**: Local models work without internet
- **No rate limits**: Run as many requests as you want
- **No privacy concerns**: Code never leaves your machine
- **Fast inference**: 30-50 tokens/sec on 2080 Ti
- **Free**: Only electricity cost (~€0.075/hour)

#### Desktop Model Recommendations (11GB VRAM)

| Model | VRAM | Speed | Quality | Best For |
|-------|------|-------|---------|----------|
| **Qwen 2.5 Coder 7B** | ~5 GB | 30-50 t/s | Good | Primary coding |
| Codestral 7B | ~5 GB | 35-55 t/s | Good | Alternative |
| Gemma 2 12B | ~8 GB | 20-35 t/s | Better | Complex tasks |
| DeepSeek Coder V2 Lite 16B | ~10 GB | 15-25 t/s | Best | Quality tasks |

**Note**: 32B+ models won't fit in 11GB VRAM.

#### Desktop Electricity Cost

- **GPU under load**: ~250W
- **Cost**: ~€0.30/kWh (Europe)
- **Per hour**: ~€0.075
- **Per day (8h)**: ~€0.60
- **Per month (22 days)**: ~€13.20

**Comparison**: Local models cost ~€13/month vs $20-30/month for API (at your usage rate).

---

## Dual-Machine Strategy — revised 2026-07-20, corrected again same day

Use both machines against the same free primary model, so switching machines never means
switching models mid-workflow:

| Task | Chromebook | Desktop | Why |
|------|------------|---------|-----|
| **Primary coding + planning** | Nemotron 3 Ultra 550B (API, free) | Same (API, free) | Same model on both — no behavioural drift when you switch machines, confirmed working in production |
| **Reviews** | Nemotron 3 Ultra Free (API), own session | Same, own session | Cross-model review, either machine |
| **Simple/offline tasks** | Not possible — no local GPU | Local Ollama (Qwen 2.5 Coder 7B) | Desktop-only advantage; bounded to tasks that don't need frontier quality |
| **Escalation** | DeepSeek-V4-Pro or similar, paid | Same | Only on confirmed rate-limit exhaustion or a task the free primary can't handle — fresh session |

**Combined cost**: $0 for the primary and review roles, plus ~€13/month desktop electricity if
using local Ollama for simple tasks, plus whatever paid escalation you actually end up using
(track it — don't assume it in advance).

---

## Quick Start Guide

### Chromebook (5 minutes)

```bash
# 1. Install OpenCode
curl -fsSL https://opencode.ai/install | bash

# 2. Add OpenRouter API key
/opencode
/connect
# Select OpenRouter, paste key

# 3. Start coding
cd ~/your-project
opencode
# Press Tab to switch agents, type your request
```

### Desktop (10 minutes)

```bash
# 1. Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# 2. Pull coding model
ollama pull qwen2.5-coder:7b

# 3. Install OpenCode
curl -fsSL https://opencode.ai/install | bash

# 4. Add OpenRouter API key (for fallback)
/opencode
/connect
# Select OpenRouter, paste key

# 5. Start coding
cd ~/your-project
opencode
# Press Tab to switch agents, type your request
```

---

## Cost Comparison Summary

| Setup | Monthly Cost | Tokens | Offline | Privacy |
|-------|-------------|--------|---------|---------|
| **Chromebook (large free cloud primary, e.g. Nemotron 3 Ultra 550B)** | €0, escalation only as needed | Rate-limited by provider | ❌ | ❌ (API) |
| **Desktop (Local only)** | ~€13 electricity | Unlimited, quality-capped | ✅ | ✅ |
| **Desktop (Local + free cloud primary)** | €13 + escalation cost if any | Unlimited | ✅ | Partial |
| **Dual machine** | €13 + escalation cost if any | Unlimited | ✅ (Desktop) | Partial |
| **Paid escalation reserve (subscription or API)** | €24-135, only for the fraction that needs it | Usage-scaled | ❌ | ❌ |

**Recommendation (revised 2026-07-20, corrected again same day)**: Local Ollama models
(7B-class on an 11GB card) are further from frontier capability than the large free *cloud*
models — see the `-20-30% vs Opus` gap in the Local Ollama table above — so treat local models
as a formatting/simple-refactor helper, not a primary. A large free cloud model (Nemotron 3
Ultra 550B, OpenCode Zen's Big Pickle) is the primary; reserve paid tiers for confirmed
rate-limit exhaustion or a specific task the free primary can't handle.
