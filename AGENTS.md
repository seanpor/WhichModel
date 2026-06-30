# Agentic Engineering

Reusable templates and configurations for AI-assisted software engineering across multiple projects.

---

## How This Works in Real Life

### Global Setup (applies to ALL projects)
Location: `~/.config/opencode/opencode.json`

This config provides:
- **Plan agent** (Tab): DeepSeek-V4-Flash Free — read-only planning
- **Build agent** (Tab): DeepSeek-V4-Flash Free — full implementation
- **@phase-review**: Nemotron 3 Ultra Free — cross-model review
- **@pr-review**: Nemotron 3 Ultra Free — cross-model review
- **@verify**: DeepSeek-V4-Flash Free — build/lint/test verification
- **@security-review**, **@test-writer**, **@docs-writer**, **@debug**: Various free models

These agents work in **every project** automatically. No per-project setup needed.

### Per-Project Override
Create `.opencode/opencode.json` in any project root to override settings:
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
Only specify what you want to change — everything else inherits from global.

### Project-Specific AGENTS.md
Each project can have its own `AGENTS.md` (or `CLAUDE.md` for Claude Code) with project-specific rules. The global agents still work alongside these.

---

## Real-World Project Types

### Type 1: GitHub Project with PRs (e.g., JA4proxy)
- Uses: GitHub, branch protection, PR reviews, CI/CD
- Workflow: Branch → implement → verify → PR → review → merge
- Agents: @verify, @pr-review, @phase-review all active

### Type 2: GitLab Project with Merge Requests
- Uses: GitLab, MR reviews, CI/CD
- Workflow: Branch → implement → verify → MR → review → merge
- Agents: Same as GitHub, but use GitLab commands

### Type 3: Local Git Project (no remote)
- Uses: Local git only, no GitHub/GitLab
- Workflow: Implement → verify → commit locally
- Agents: @verify, @phase-review active; @pr-review optional

### Type 4: Personal Project (no git)
- Uses: Just files, no version control
- Workflow: Implement → verify → done
- Agents: @verify active; others optional

### Type 5: Multi-Agent Parallel Work
- Uses: Multiple agents working simultaneously
- Workflow: File ownership rules, sequential for shared files
- Agents: All agents active, coordination required

---

## Workflow for Each Project Type

### GitHub/GitLab Project (with PRs/MRs)

1. **Plan**: Switch to Plan agent (Tab), write phase doc
2. **Review plan**: Invoke `@phase-review` for second opinion
3. **Get approval**: Wait for user go-ahead
4. **Implement**: Switch to Build agent (Tab), write code
5. **Verify**: Invoke `@verify` to check build/lint/test
6. **Fix if needed**: If @verify reports REJECTED, fix issues
7. **Create PR/MR**: `gh pr create` or `glab mr create`
8. **Review PR**: Invoke `@pr-review` for code review
9. **Merge**: `gh pr merge` or `glab mr merge`

### Local Git Project (no remote)

1. **Plan**: Switch to Plan agent (Tab), write phase doc
2. **Review plan**: Invoke `@phase-review` for second opinion
3. **Get approval**: Wait for user go-ahead
4. **Implement**: Switch to Build agent (Tab), write code
5. **Verify**: Invoke `@verify` to check build/lint/test
6. **Fix if needed**: If @verify reports REJECTED, fix issues
7. **Commit**: `git add . && git commit -m "description"`
8. **Optional review**: Invoke `@pr-review` for code review (even without PR)

### Personal Project (no git)

1. **Plan**: Switch to Plan agent (Tab), write phase doc
2. **Get approval**: Wait for user go-ahead
3. **Implement**: Switch to Build agent (Tab), write code
4. **Verify**: Invoke `@verify` to check build/lint/test
5. **Fix if needed**: If @verify reports REJECTED, fix issues
6. **Done**: No commit needed, just save files

---

## Build/Lint/Test Commands by Language

Each project has its own build system. The agents will detect and use the correct commands:

### JavaScript/TypeScript (npm/yarn/pnpm)
- Build: `npm run build` or `yarn build`
- Lint: `npm run lint` or `yarn lint`
- Test: `npm test` or `yarn test`

### Python (make/poetry/uv)
- Build: `make build` or `poetry build`
- Lint: `make lint` or `ruff check .` or `flake8`
- Test: `make test` or `pytest` or `python -m pytest`

### Go (make/go)
- Build: `make build` or `go build ./...`
- Lint: `make lint` or `golangci-lint run`
- Test: `make test` or `go test ./...`

### Rust (cargo)
- Build: `cargo build`
- Lint: `cargo clippy`
- Test: `cargo test`

### Generic (make)
- Build: `make build`
- Lint: `make lint`
- Test: `make test`

**Important**: The agents will try to detect the correct commands. If they can't, they'll report the failure instead of guessing.

---

## Verification Protocol (CRITICAL)

**NEVER claim work is complete without running verification commands.**

### Before claiming "all good" or "ready for PR":

1. **Run the build**: `make build` (or equivalent)
   - Check exit code (0 = success, non-zero = failure)
   - If it fails, STOP and fix it before continuing

2. **Run the linter**: `make lint` (or equivalent)
   - Check exit code
   - If it fails, STOP and fix it before continuing

3. **Run the tests**: `make test` (or equivalent)
   - Check exit code
   - If it fails, STOP and fix it before continuing

4. **Report actual results**: Copy the exact output, don't summarize

### Verification agents:

- **@verify**: Runs build/lint/test and reports actual results
- **@pr-review**: MUST verify build/lint/test pass before reviewing code
- **@phase-review**: MUST verify build/lint/test pass before approving phase

### Common lies agents tell (DO NOT DO THESE):

- ❌ "All tests pass" (without actually running them)
- ❌ "Build is successful" (without checking exit code)
- ❌ "Linting is clean" (without running the linter)
- ❌ "Ready for PR" (without verification)
- ❌ "Everything looks good" (when there are warnings or errors)

### Correct behavior:

- ✅ Run `make build 2>&1` and check exit code
- ✅ Run `make lint 2>&1` and check exit code
- ✅ Run `make test 2>&1` and check exit code
- ✅ Report exact output including any warnings or errors
- ✅ If ANY step fails, say "BUILD FAILED" or "LINT FAILED" or "TESTS FAILED"

---

## Code Style Guidelines

### General Principles
- Follow existing patterns in the codebase
- Use the project's configured linter/formatter
- Don't add comments unless asked — code should be self-documenting
- Don't add features, refactor, or introduce abstractions beyond what the task requires

### Imports
- Group imports logically (standard library, third-party, local)
- Use absolute imports when possible
- Avoid circular dependencies

### Formatting
- Use consistent indentation (2 or 4 spaces depending on project)
- Limit line length to 80-120 characters
- Use meaningful variable and function names
- Place opening braces on the same line as declarations

### Types
- Use strong typing when available
- Define interfaces for complex objects
- Use type inference when it improves readability

### Naming Conventions
- Use camelCase for variables and functions
- Use PascalCase for classes and types
- Use UPPER_CASE for constants
- Use descriptive names that convey purpose

### Error Handling
- Handle errors explicitly, don't ignore them
- Use specific error types when available
- Log errors with sufficient context for debugging
- Fail fast - don't continue with invalid state

### File Structure
- Organize code into logical modules
- Keep files focused on a single responsibility
- Use index files for module exports
- Maintain consistent directory structure

---

## Multi-Agent Coordination (if applicable)

If multiple agents work on the same project in parallel:

### File Ownership
Each agent should own specific files/directories. Shared files need rules:

| File Type | Rule |
|-----------|------|
| Config files | Only edit keys your task introduces |
| README | Add your section, don't edit others |
| CHANGELOG | Use fragments, don't edit directly |
| Shared source | Coordinate before touching |

### Parallel vs Sequential
- **Parallel-safe:** different directories, read-only exploration, tests + docs for same feature
- **Sequential:** shared hot-path files, config changes, branch merges

---

## Project-Specific Rules

> Add project-specific rules below this line. Everything above is the generic template.

---

## Cursor Rules

If the project has Cursor rules in `.cursor/rules/` or `.cursorrules`, follow them exactly. These rules take precedence over general guidelines.

## Copilot Instructions

If the project has Copilot instructions in `.github/copilot-instructions.md`, follow them exactly. These instructions may contain project-specific conventions or restrictions.
