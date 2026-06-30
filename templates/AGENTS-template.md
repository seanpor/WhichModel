# Agent Protocol

> **Read this file first, every session.** It defines how AI agents should work on this project.

---

## Planning & Implementation Protocol

**When asked to perform any work, follow this sequence:**

### Step 1 — Understand the Task
1. Read this file (`AGENTS.md`) in full.
2. Read any existing phase docs or project docs before writing code.
3. Read existing code before writing — understand patterns, conventions, dependencies.

### Step 2 — Write the Plan
1. Create or update a phase doc using the template in `templates/phase-doc-template.md`.
2. Present the plan to the user with a brief summary: *"Here is the plan — please review before I begin."*
3. Optionally invoke `@phase-review` to get a second opinion from a different model.

### Step 3 — Wait for Explicit Approval
Do **not** proceed until the user gives a clear go-ahead (e.g., "looks good", "proceed", "yes"). If changes are requested, update the phase doc and re-present.

### Step 4 — Implement
Only after written approval: write code, write tests, commit often.

---

## Phase Documentation

Phases are numbered sequentially with a brief description:
- `docs/phases/001-project-setup.md`
- `docs/phases/002-core-feature.md`
- `docs/phases/003-auth-integration.md`

### Phase Doc Rules
1. Phase number lives in the FILENAME only (e.g., `# Core Features`, not `# Phase 2: Core Features`).
2. Use the template in `templates/phase-doc-template.md` as a starting point.
3. Each phase doc should be self-contained — someone reading it should understand what to do.
4. When a phase is complete, move it to `docs/phases/complete/` (or mark it in the doc).

### Cross-Model Review
Different models should review work to catch different issues:
- **Phase docs**: The author writes it, a different model reviews via `@phase-review`
- **Code/PRs**: The implementer writes it, a different model reviews via `@pr-review`
- Use the **Tab** key in OpenCode to switch between Plan and Build agents

---

## Git Conventions

### Branching
- Work on feature branches, not directly on `main` (if the project uses git)
- Branch naming: `phase-NNN-brief-description` or `feature/brief-description`
- Commit often after each meaningful chunk

### Commits
- Use conventional commits: `type(scope): brief description`
- Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`
- One logical change per commit

### Pull Requests (Optional — see project needs)
Not all projects use PRs. If the project does:
- Create PR: `gh pr create --base main`
- Invoke `@pr-review` for a second opinion before merging
- Merge: `gh pr merge --squash --delete-branch`

If the project doesn't use PRs (local-only, personal projects):
- Commit directly to `main` or your working branch
- Still use `@pr-review` if you want a code review

---

## Testing Standards

- Write tests for new functionality
- All tests must pass before considering a phase complete
- Use the project's existing test framework and patterns
- Mock external services — never call real APIs in tests
- Test edge cases and error paths, not just happy paths

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

### Verification commands (adapt to project):

```bash
# Build
make build 2>&1 || echo "BUILD FAILED"

# Lint
make lint 2>&1 || echo "LINT FAILED"

# Test
make test 2>&1 || echo "TESTS FAILED"

# Check for uncommitted changes
git status --porcelain
```

**If you cannot run these commands, say so explicitly. Do not assume they pass.**

---

## Documentation Standards

- Update README.md when adding features or changing behavior
- Document non-obvious decisions (why, not just what)
- Keep docs close to the code they describe
- Use changelog fragments (not direct edits to CHANGELOG.md) if the project uses them

---

## Code Style

- Follow existing patterns in the codebase
- Use the project's configured linter/formatter
- Don't add comments unless asked — code should be self-documenting
- Don't add features, refactor, or introduce abstractions beyond what the task requires

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
