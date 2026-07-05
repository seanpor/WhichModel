# Open Brain: Persistent Memory for AI Tools

**A detailed setup guide for Open Brain, the memory layer that eliminates context reloading.**

*July 2026*

---

Context reloading is the single largest source of waste in AI-assisted coding. Every new session re-explains project structure, conventions, and recent decisions. Open Brain solves this.

## What it is

Open Brain is an open-source system that gives every AI tool you use the same persistent memory. One database with vector search, one protocol (MCP), any client (Claude, ChatGPT, Cursor, OpenCode).

**Repository:** [github.com/NateBJones-Projects/OB1](https://github.com/NateBJones-Projects/OB1)

## How it works

You store "thoughts"—notes, decisions, context, code patterns—in a database. Each thought gets a vector embedding. When you ask an AI to "search my thoughts for the auth architecture", it performs semantic search and returns relevant memories. No re-explaining. No wasted tokens.

## Option A: Cloud setup (45 minutes)

Uses Supabase and OpenRouter. Free tier covers personal use.

**Step 1: Create a Supabase project.**
Go to [supabase.com](https://supabase.com), create a project named `open-brain`. Note your project URL and service role key.

**Step 2: Create the database.**
In Supabase SQL Editor, run these three scripts in order:
- `open-brain/01-create-table.sql` — creates the thoughts table with vector indexes
- `open-brain/02-search-function.sql` — semantic search function
- `open-brain/03-security.sql` — deduplication and row-level security

**Step 3: Get an OpenRouter key.**
Go to [openrouter.ai/keys](https://openrouter.ai/keys), create a key. Add $5 in credits (lasts months).

**Step 4: Deploy the MCP server.**
```bash
cd open-brain
make setup
```
The script prompts for your Supabase URL, service role key, OpenRouter key, and a generated access key. It deploys the MCP server as a Supabase Edge Function.

**Step 5: Connect your AI tools.**
The setup script outputs an MCP Connection URL. Use it:

- **Claude Desktop:** Settings → Connectors → Add custom connector → paste URL
- **OpenCode:** Add to `~/.config/opencode/opencode.json`:
  ```json
  {
    "mcp": {
      "open-brain": {
        "url": "https://YOUR_PROJECT.supabase.co/functions/v1/open-brain-mcp?key=YOUR_KEY"
      }
    }
  }
  ```
- **ChatGPT:** Settings → Apps & Connectors → Developer mode → Create → paste URL

## Option B: Offline setup (15 minutes)

Runs entirely on your machine. No cloud, no API keys, no latency. Requires Docker and Ollama.

**Step 1: Install prerequisites.**
```bash
# Ollama (if not installed)
curl -fsSL https://ollama.ai/install.sh | sh

# Pull embedding model (768-dimensional vectors, ~270MB)
ollama pull nomic-embed-text
```

**Step 2: Start the stack.**
```bash
cd open-brain-local
make setup   # Creates config, builds containers
make start   # Launches PostgreSQL + MCP server
```

**Step 3: Connect your AI tools.**
Add to `~/.config/opencode/opencode.json`:
```json
{
  "mcp": {
    "open-brain": {
      "url": "http://localhost:8000?key=YOUR_ACCESS_KEY"
    }
  }
}
```
The access key is in `open-brain-local/.env` (generated during setup).

**What runs where:**

| Component | Port | What it does |
|-----------|------|-------------|
| PostgreSQL + pgvector | 5432 | Stores thoughts with vector indexes |
| MCP server | 8000 | Handles AI tool requests |
| Ollama | 11434 | Generates embeddings locally |

**Resource usage:** ~500MB RAM for PostgreSQL, ~300MB for MCP server, ~1GB for Ollama with nomic-embed-text loaded. Fits comfortably alongside development tools.

## Daily usage

Once connected, any AI tool can read and write to your brain:

- **Capture:** "Remember this: the auth service uses JWT with 15-minute expiry and refresh tokens in httpOnly cookies."
- **Search:** "What do I know about the auth architecture?"
- **Review:** "Show me all thoughts about database migrations."

The AI calls the MCP tools automatically. You do not need to think about it.

## What to store

- **Architectural decisions:** Why you chose PostgreSQL over MongoDB, why JWT over sessions.
- **Code patterns:** Your preferred error handling, your naming conventions, your test structure.
- **Debugging notes:** What caused the last three production incidents and how you fixed them.
- **Project context:** What each service does, how they connect, what the deployment pipeline looks like.

## The compounding effect

Week 1: You store 50 thoughts. The AI can answer questions about your project without re-reading code.

Week 4: You have 200 thoughts. New sessions start with the AI already knowing your conventions, your architecture, your recent decisions.

Week 12: You have 500 thoughts. The AI catches mistakes before you make them. "You tried this approach three months ago. It failed because of X."

## Cloud vs offline

| Factor | Cloud (Supabase) | Offline (Docker + Ollama) |
|--------|-----------------|--------------------------|
| Setup time | 45 minutes | 15 minutes |
| Cost | $0-5/month | €0.075/hour electricity |
| Latency | 50-200ms | <10ms |
| Privacy | Data in Supabase cloud | Data on your machine |
| Offline access | No | Yes |
| Multi-device | Yes | No (unless you sync) |
| Embedding quality | OpenAI text-embedding-3-small (1536d) | nomic-embed-text (768d) |

**Recommendation:** Use offline for privacy-sensitive work and development. Use cloud if you need multi-device access or higher-quality embeddings.
