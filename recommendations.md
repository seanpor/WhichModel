# Recommendations

Last updated: 2026-06-29

## Current Setup

- MiMo Code: $50/month for 38B credits (burns fast — ~21 hours of heavy use)
- OpenRouter: $5 balance, using free models
- Local: 2080 Ti (11GB VRAM) available for Ollama

## Budget Strategy ($30-50/month)

### Primary: Free Models (80% of work)
- **DeepSeek-V4-Flash Free** (`deepseek/deepseek-v4-flash:free`) — bulk coding
- **Nemotron 3 Ultra Free** (`nvidia/nemotron-3-ultra-550b-a55b:free`) — reviews
- **OpenAI GPT-OSS-120B Free** (`openai/gpt-oss-120b:free`) — alternative

### Secondary: Paid Models (15% of work, ~$20/month)
- **DeepSeek-V4-Flash** (`deepseek/deepseek-v4-flash`) — $0.09/$0.18 per MTok
- Use when free models fail or produce bad results

### Tertiary: Premium Models (5% of work, ~$10/month)
- **Qwen3-Coder-Flash** (`qwen/qwen3-coder-flash`) — $0.20/$0.97 per MTok
- Use for critical tasks, complex reasoning

### Reviews (always free)
- **Nemotron 3 Ultra Free** — cross-model review for phase docs and PRs

## Cost Comparison

| Approach | $/month | Hours of heavy use | Notes |
|----------|---------|-------------------|-------|
| MiMo Code ($50/38B) | $50 | ~21.6 hours | Burns fast, opaque credits |
| OpenRouter Free + $20 buffer | $20 | Unlimited (free) + paid | **Best value** |
| OpenRouter DeepSeek-V4-Flash (paid) | $50 | ~31.6 hours | 46% more than MiMo Code |

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

**Switch to OpenRouter.** Use free models for 80% of work, paid DeepSeek-V4-Flash for the rest. You'll get more tokens per dollar and transparent pricing.

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
- Budget strategy (free models for 80%, paid for critical tasks)

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

### Recommendation by Usage

- **Light user** (< 5h/week): Free models only ($0/month)
- **Medium user** (5-15h/week): Free + $10 buffer ($10/month)
- **Heavy user** (15-30h/week): Free + $20 paid ($20/month)
- **Full-time** (40h+/week): Free + $50 paid ($50/month)
- **Power user** (your rate): Free + $100 paid ($100/month)

---

## Token Compression & Cost Reduction

### Quick Wins (Easy, High Impact)

1. **Use free models first** — 80% of tasks succeed with free models
2. **Enable prompt caching** — Keep static content (AGENTS.md, file context) at start of prompt
3. **Send only relevant files** — Use `@file` references, not entire repo
4. **Limit response length** — Set `max_tokens` based on task complexity

### Advanced Techniques

| Technique | Effort | Savings | How |
|-----------|--------|---------|-----|
| **Model cascading** | Medium | 60-80% | Try free → cheap → premium |
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
| 1 | Use free models for 80% of work | Low | 80% |
| 2 | Enable prompt caching | Low | 50-90% |
| 3 | Send only relevant context | Medium | 30-70% |
| 4 | Use model cascading | Medium | 60-80% |
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

### Optimized Workflow (90% Cheaper)

```
1. Free model writes detailed plan (10-20K tokens) → $0
2. Free model critically reviews plan (10-20K tokens) → $0
3. Different free model reviews plan (10-20K tokens) → $0
4. Implementation with free model (20-50K tokens) → $0
5. Free model critically reviews implementation (10-20K tokens) → $0
```

**Total per feature**: 60-130K tokens = $0 (all free models)

**When to escalate to paid models**:
- Complex architecture decisions → DeepSeek-V4-Flash ($0.09/M)
- Critical security features → Qwen3-Coder-Flash ($0.20/M)
- Production deployment → MiMo-V2.5-Pro ($0.43/M)

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

#### 4. Model Cascading (Your Workflow)

**Step 1: Try free model first**
```
"Write a detailed plan for feature X with acceptance criteria for a junior engineer"
```
If quality is good → use it. If not → Step 2.

**Step 2: Try cheap paid model**
```
"Review and improve this plan: [plan content]"
```
If quality is good → use it. If not → Step 3.

**Step 3: Use premium model (rare)**
```
"Critically review this plan for production readiness: [plan content]"
```

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

4. **Test with free model**:
   ```bash
   cd ~/Perso/AgenticEngineering
   opencode
   ```
   Press Tab to switch to Plan agent, type a question

**Daily budget**: $0-5 (mostly free models)

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
| **Optimized (free models)** | $0-10 | Unlimited | ❌ | ❌ |
| **Desktop (local Ollama)** | ~€13 electricity | Unlimited | ✅ | ✅ |
| **Dual machine (optimized)** | €13 + $0-10 | Unlimited | ✅ (Desktop) | Partial |

**Recommendation**: Use free models for 80% of work, local Ollama for offline/privacy, API for complex tasks. Total cost: €15-20/month instead of $100-300.

---

## Free vs Paid Models: Side-by-Side

### Top Free Models

| Model | Code Elo | Coding Idx | Agentic | Context | Best For |
|-------|----------|------------|---------|---------|----------|
| **DeepSeek-V4-Flash Free** | 1257 | 56.2 | 31.1 | 1M | Primary coding |
| Qwen3-Coder-480B Free | 1193 | - | - | 1M | Code-specialized |
| Nemotron 3 Ultra Free | 1174 | 49.3 | 27.4 | 1M | Reviews |
| OpenAI GPT-OSS-120B Free | 1014 | 30.4 | 13.2 | 131K | Alternative |

### Top Paid Models (Under $0.50/M Input)

| Model | Code Elo | Coding Idx | Agentic | Context | $/M (in/out) |
|-------|----------|------------|---------|---------|--------------|
| **MiMo-V2.5-Pro** | 1318 | 60.2 | 29.1 | 1M | $0.43/$0.87 |
| MiMo-V2.5 | 1304 | - | - | 1M | $0.10/$0.28 |
| DeepSeek-V4-Pro | 1289 | 59.4 | 36.4 | 1M | $0.43/$0.87 |
| **DeepSeek-V4-Flash** | 1257 | 56.2 | 31.1 | 1M | $0.09/$0.18 |

### Quality Gap

| Metric | Best Free | Best Paid | Gap |
|--------|-----------|-----------|-----|
| Code Elo | 1257 | 1318 | -4.6% |
| Coding Index | 56.2 | 60.2 | -6.7% |
| Agentic Index | 31.1 | 36.4 | -14.5% |

**Conclusion**: Free models are only 5-15% worse than paid models. For 80% of coding tasks, the difference is negligible.

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

4. **Test with free model**:
   ```bash
   cd ~/Perso/AgenticEngineering
   opencode
   ```
   Press Tab to switch to Plan agent, type a question

#### Recommended Workflow (Chromebook)

| Task | Model | Cost | Why |
|------|-------|------|-----|
| **Primary coding** | DeepSeek-V4-Flash Free | $0 | Fast, reliable, free |
| **Reviews** | Nemotron 3 Ultra Free | $0 | Cross-model review |
| **Critical tasks** | DeepSeek-V4-Flash (paid) | $0.09/M | When free fails |
| **Planning** | DeepSeek-V4-Flash Free | $0 | Read-only planning |

**Daily budget**: $0-5 (mostly free models)

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

#### Recommended Workflow (Desktop)

| Task | Model | Cost | Why |
|------|-------|------|-----|
| **Primary coding** | Ollama Qwen 2.5 Coder 7B | $0 (electricity) | Fast, offline, free |
| **Reviews** | Ollama + Nemotron Free | $0 | Cross-model review |
| **Complex tasks** | DeepSeek-V4-Flash (API) | $0.09/M | Better quality |
| **Critical tasks** | Qwen3-Coder-Flash (API) | $0.20/M | Best value |
| **Planning** | Ollama Qwen 2.5 Coder 7B | $0 | Read-only planning |

**Daily budget**: $0-2 (mostly local, API for complex tasks)

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

## Dual-Machine Strategy

Use both machines for maximum cost efficiency:

| Task | Chromebook | Desktop | Why |
|------|------------|---------|-----|
| **Primary coding** | Free API models | Local Ollama | Chromebook for mobility, Desktop for offline |
| **Reviews** | Nemotron Free (API) | Local + Nemotron Free | Cross-model review |
| **Complex tasks** | DeepSeek-V4-Flash (API) | DeepSeek-V4-Flash (API) | Same API, different machines |
| **Planning** | Free API models | Local Ollama | Both work |
| **Offline work** | ❌ Not possible | ✅ Local models | Desktop advantage |

**Combined cost**: $0-10/month (mostly free/local)

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
| **Chromebook (API only)** | $0-10 | Unlimited (free) | ❌ | ❌ (API) |
| **Desktop (Local only)** | ~€13 electricity | Unlimited | ✅ | ✅ |
| **Desktop (Local + API)** | €13 + $5-10 | Unlimited | ✅ | Partial |
| **Dual machine** | €13 + $0-10 | Unlimited | ✅ (Desktop) | Partial |
| **MiMo Code ($50/38B)** | $50 | ~21.6 hours | ❌ | ❌ |
| **OpenRouter (paid only)** | $50 | ~31.6 hours | ❌ | ❌ |

**Recommendation**: Use Desktop with local Ollama for 80% of work, API for complex tasks. Total cost: ~€15-20/month.
