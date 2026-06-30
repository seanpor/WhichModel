# JA4proxy Agent Protocol

This document defines the mandatory operational standards for AI agents working on the JA4proxy project. Adherence to these rules ensures architectural consistency, security, and a high-quality handoff for human developers.

---

## Mandatory Planning & Concurrency Protocol — Read First

**When asked to perform any work, the agent MUST follow this sequence to prevent overlapping work with other parallel agents.**

### Step 1 — Claim the Task (Remote-Branch Lease)
Before writing any code or plans, ensure no other agent already owns the task. **The remote branch is the lock — creating it is the atomic claim.**
1. Sync: `git checkout main && git pull origin main --rebase`.
2. Check `docs/phases/manifest.yaml`. If the phase is `IN_PROGRESS`, **STOP** — another agent owns it.
3. Check for an existing lease: `git ls-remote --heads origin 'phase-XX*'`. If any branch matches, **STOP** — someone is already on it.
4. Claim it: create `phase-XX-<desc>` and push it immediately (an empty commit, `git commit --allow-empty`, is fine). The push **is** the claim — if two agents race, git rejects the loser's push, serialising them for free with no CI cost.
5. Mark ownership in your first real commit by setting that phase's status to `IN_PROGRESS` in the manifest (human/agent visibility). Do **not** open a separate status-only PR — that burns a full CI run to flip one line.

### Step 2 — Write the Plan
1. Create the phase document at `docs/phases/PHASE_XX.md` using the standard template: Goal, Scope, Implementation plan, Test strategy, Acceptance criteria, Out of scope.
2. Present the plan to the user with a brief summary: *"Here is the plan — please review before I begin."*

### Step 3 — Wait for explicit approval
Do **not** proceed until the user gives a clear go-ahead (e.g., "looks good", "proceed", "yes"). If changes are requested, update `PHASE_XX.md` and re-present.

### Step 4 — Implement
Only after written approval: create your feature branch, write code, write tests, and follow the Phase Close-Out Checklist.

---

## Container-Strict Execution (No Host Python)

**Virtual environments on the host are strictly forbidden.** The host runs Python 3.10, but production targets Python 3.14.* (the test/tools images are pinned to `python:3.14`). Running tests, linters, or scripts on the host leads to severe version-skew bugs and polluted state.

- **Rule 1:** NEVER create a virtual environment (e.g., `uv venv`, `python -m venv`) on the host.
- **Rule 2:** NEVER run `pip install`, `pytest`, `ruff`, or `mypy` directly on the host machine.
- **Rule 3:** Run Python through the **`make` targets** — they execute inside the pinned `ja4proxy-tools` image (`Dockerfile.tools`, Python 3.14) via `docker run`, building it on demand. This is the canonical, CI-identical path.
  - *Wrong:* `python3 -m pytest tests/`
  - *Right:* `make test` (Go native + Python in-container) · `make test-unit` · `make test-chaos` · `make lint` · `make sync`
  - Need an ad-hoc command? `docker run --rm -v "$PWD":/src -w /src ja4proxy-tools pytest <args>` (this is what `$(TOOLS_RUN)` expands to).
- **Rule 4:** The full multi-service integration stack (`deploy/docker/docker-compose.test.yml`) is for integration/chaos tests that need Redis + the Go proxy; drive it with `docker compose exec <service> …`, not for unit/lint runs.
- **Note on Go:** Go tests run **natively** (`go test ./...`) — Go has no venv fragility, so the container rule is Python-only.

---

## Tool Usage & Communication

- **Bash Tool:** Under **opencode**, omit the `description` field — it currently triggers a validation error there. Under **Claude Code** the `description` field is supported and *should* be used (it surfaces intent in the permission prompt).
- **High-Signal Output:** Adopt a Senior Engineer persona. Be concise, direct, and technical. Avoid conversational filler.
- **Efficiency:** Parallelize independent searches (`Grep`, `Glob`) and file reads.

---

## Roadmap & Task Management

The project uses a **Manifest-Driven Roadmap**.
- **Single source of truth:** `docs/phases/manifest.yaml`.
- **Validation:** Run `make lint-phases` (which wraps Docker execution) to catch broken action_plan paths and stale status values. Must exit 0 before close-out.

### Phase Documentation Rules
**Rule 1:** Phase number lives in the FILENAME only (e.g., `# Core Features`, not `# Phase 22: Core Features`).
**Rule 2:** Status lives in `docs/phases/manifest.yaml` only. Do NOT include a `Status:` line in phase doc files.
**Rule 3:** To rename/renumber, rename the file, update the `action_plan:` path in the manifest, and run `make lint-phases`.
**Rule 4:** When a phase reaches a terminal status (`COMPLETE`, `CANCELLED`), move it to the corresponding subfolder (`docs/phases/complete/`) and update the manifest path in the exact same commit.

---

## Git & Version Control

- **Pre-Flight Synchronization:** `git checkout main && git pull origin main --rebase`.
- **Strict Branch Naming:** Format: `phase-<number>-<brief-description>` (e.g., `phase-131-tls-fuzzing`). Use hyphens throughout — never `phase_131`.
- **Atomic Commits:** One commit per phase or logical sub-task. Use `type(scope): brief description`.

> ### Branch protection is ENFORCED on `main`
>
> `main` is branch-protected with **`enforce_admins: on`**, so the rule binds
> *everyone*, admins included. A direct `git push origin main` is rejected.
>
> **Merging.** Land work with `gh pr merge --auto --squash --delete-branch`.
>
> **Emergency override:** temporarily lift admin enforcement, land the fix, then re-enable it immediately:
> ```bash
> gh api -X DELETE repos/seanpor/JA4proxy/branches/main/protection/enforce_admins
> # land the emergency fix
> gh api -X PATCH  repos/seanpor/JA4proxy/branches/main/protection/enforce_admins
> ```

---

## Testing, Linting & Validation (TDD)

- **Zero-Tolerance Policy:** No skipped tests without explicit approval. Zero warnings, zero errors in linters.
- **Approved Exception Workflow:** Present justification, get user approval, log in `docs/security/EXCEPTIONS.md`.

### Pre-PR gate: `make preflight` (mandatory)
Before opening **any** PR, run **`make preflight`** locally and get it 100% green.
It runs the full required-check set — `make lint`, then `make scan`, then `make test`.

---

## Go Proxy (the production runtime)

The proxy is **Go-only** (`cmd/ja4pd`, `internal/`). Python remains only for services that are not the proxy — the Management API, analytics, and supporting tooling.

- **Go tests run on the host** — `go test ./...` has no virtualenv fragility, so the container rule is Python-only, not Go.

---

## Security Bug Hunt Workflow

When executing a bug hunt phase:

### Log findings BEFORE fixing
1. **Register the finding** — `python3 scripts/findings_register.py add ...`
2. **Fix the code** and write regression tests.
3. **Update the finding** — set `status: FIXED`, populate `regression_test`.

### Critical review (mandatory for security work)
After completing a bug hunt phase, spawn **parallel expert reviewers**:
- **Security expert** — findings accuracy, CVSS vectors, fix completeness
- **Concurrency expert** — race conditions, goroutine leaks, deadlock potential
- **Code quality expert** — style, patterns, test quality

All three must APPROVE before merging.
