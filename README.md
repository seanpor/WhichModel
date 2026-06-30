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
| `AGENTS.md` | Global agent protocol for all projects |
| `templates/phase-doc-template.md` | Template for project phase documents |
| `templates/AGENTS-template.md` | Generic agent protocol template |
| `examples/` | Reference examples from specific projects |

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

## Cost Strategy

| Usage | Strategy | Monthly Cost |
|-------|----------|--------------|
| **Light** (< 5h/week) | Free models only | $0 |
| **Medium** (5-15h/week) | Free + $10 buffer | $10 |
| **Heavy** (15-30h/week) | Free + $20 paid | $20 |
| **Full-time** (40h+/week) | Free + $50 paid | $50 |

## Models Covered

### Free Models (OpenRouter)
- DeepSeek-V4-Flash Free (primary)
- Nemotron 3 Ultra Free (reviews)
- OpenAI GPT-OSS-120B Free (alternative)

### Paid Models (Budget)
- DeepSeek-V4-Flash ($0.09/$0.18 per MTok)
- MiMo-V2.5 ($0.10/$0.28 per MTok)
- Qwen3-Coder-Flash ($0.20/$0.97 per MTok)

### Premium Models
- DeepSeek-V4-Pro ($0.435/$0.87 per MTok)
- DeepSeek-V4-Pro-DSpark (speculative decoding, same price)
- Claude Opus 4.7 ($5/$25 per MTok)

## Token Compression Techniques

1. **Prompt caching** — 90% savings on repeated context
2. **Context window management** — send only relevant files
3. **Response length control** — set `max_tokens` appropriately
4. **Model cascading** — try free → cheap → premium
5. **Batch similar tasks** — combine multiple fixes into one request
6. **Local pre-processing** — use Ollama for simple tasks

## License

MIT
