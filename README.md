# WhichModel

An attempt to standardize my system of work with agents and models and to contain costs.

## Purpose

This repository contains:
- **Model analysis** — comparison of free vs paid models for coding tasks
- **Cost optimization** — token compression techniques and budget strategies
- **Agent configuration** — OpenCode config files for consistent behavior across projects
- **Workflow templates** — phase docs, PR reviews, verification protocols

## Key Files

| File | Purpose |
|------|---------|
| `model-analysis.md` | Detailed model comparison (pricing, benchmarks, free vs paid) |
| `recommendations.md` | Cost optimization strategies and machine-specific setup |
| `recommendations-economist.md` | Concise PDF-ready recommendations (Economist style) |
| `AGENTS.md` | Global agent protocol for all projects |
| `templates/phase-doc-template.md` | Template for project phase documents |
| `templates/AGENTS-template.md` | Generic agent protocol template |
| `examples/` | Reference examples from specific projects |
| `phases/` | Project phase documents (numbered sequentially) |
| `open-brain/` | Open Brain setup scripts and SQL |

## Phase Documents

| Phase | Title | Status | Description |
|-------|-------|--------|-------------|
| 001 | Open Brain & AI Memory Systems | Draft | Analysis of OB1 and similar projects for productivity improvement |

## Quick Start

### For Chromebook (API only)
```bash
curl -fsSL https://opencode.ai/install | bash
/opencode
/connect  # Select OpenRouter, paste API key
```

### For Desktop (Ollama + API)
```bash
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull qwen2.5-coder:7b
curl -fsSL https://opencode.ai/install | bash
/opencode
/connect  # Select OpenRouter, paste API key
```

### Generate PDF Recommendations
```bash
make pdf    # Generates recommendations.pdf
make lint   # Check spelling and links
```

### Set Up Open Brain (AI Memory Layer)
```bash
cd open-brain
make setup  # Interactive setup script
```

## Cost Strategy

| Usage | Strategy | Monthly Cost |
|-------|----------|--------------|
| **Light** (< 5h/week) | Free models only | $0 |
| **Medium** (5-15h/week) | Free + $10 buffer | $10 |
| **Heavy** (15-30h/week) | Free + $20 paid | $20 |
| **Full-time** (40h+/week) | Free + $50 paid | $50 |

## Tested Free Models (OpenRouter)

**Last tested**: 2026-06-30

| Model | Status | Speed | Notes |
|-------|--------|-------|-------|
| **nvidia/nemotron-3-ultra-550b-a55b:free** | ✅ **WORKS** | 3.5s | Best free model, 1M context |
| **nvidia/nemotron-3-super-120b-a12b:free** | ✅ **WORKS** | 3.2s | Fast, reliable, 1M context |
| **google/gemma-4-26b-a4b-it:free** | ✅ **WORKS** | 5.2s | Google, 262K context |
| deepseek/deepseek-v4-flash:free | ❌ **404** | — | **No longer free!** |
| qwen/qwen3-coder:free | ❌ 429 | — | Rate limited |
| openai/gpt-oss-120b:free | ❌ 429 | — | Rate limited |
| meta-llama/llama-3.3-70b-instruct:free | ❌ 429 | — | Rate limited |
| google/gemma-4-31b-it:free | ❌ 429 | — | Rate limited |

**Recommendation**: Use `nvidia/nemotron-3-ultra-550b-a55b:free` as primary model.

## Paid Models (Budget)

| Model | Input/M | Output/M | Context | Best For |
|-------|---------|----------|---------|----------|
| DeepSeek-V4-Flash | $0.14 | $0.28 | 1M | Cheapest paid |
| MiMo-V2.5 | $0.10 | $0.28 | 1M | Best value |
| Qwen3-Coder-Flash | $0.20 | $0.97 | 1M | Code specialist |
| DeepSeek-V4-Pro | $0.435 | $0.87 | 1M | Frontier quality |
| Gemini 3 Flash Preview | $0.50 | $3.00 | 1M | Google quality |
| Gemini 3.1 Flash Lite | $0.25 | $1.50 | 1M | Cheap Gemini |

## Premium Models

| Model | Input/M | Output/M | Notes |
|-------|---------|----------|-------|
| DeepSeek-V4-Pro-DSpark | $0.435 | $0.87 | Speculative decoding, faster |
| Claude Opus 4.7 | $5.00 | $25.00 | Top-tier reasoning |
| GPT-5.5 | $5.00 | $30.00 | Latest OpenAI |

## Token Compression Techniques

1. **Prompt caching** — 90% savings on repeated context
2. **Context window management** — send only relevant files
3. **Response length control** — set `max_tokens` appropriately
4. **Model cascading** — try free → cheap → premium
5. **Batch similar tasks** — combine multiple fixes into one request
6. **Local pre-processing** — use Ollama for simple tasks

## Agent Configuration

The `opencode.json` config provides:
- **Plan/Build agents**: `nvidia/nemotron-3-ultra-550b-a55b:free` (primary)
- **@phase-review**: Cross-model review with different free model
- **@pr-review**: Code review with build verification
- **@verify**: Runs build/lint/test before approving work
- **@security-review**: Security-focused audit
- **@test-writer**: Writes comprehensive tests
- **@docs-writer**: Generates documentation
- **@debug**: Investigates bugs without modifying code

## License

MIT
