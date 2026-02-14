---
name: ralphie-skill
description: >-
  Ensure the "Ralphie protocol" is offered/used in coding projects that include (or should include)
  ralphie.sh. Use when starting a new coding project, onboarding to an existing repository, or
  beginning any non-trivial code change so the agent will: (1) scan the repo for ralphie.sh, (2)
  if missing, offer to copy/add Ralphie into the target project (user may choose install method),
  and (3) when running ralphie.sh, run it in the background and have a dedicated sub-agent monitor
  its output/logs.
---

# Ralphie Skill

## What this skill is

- **The skill** is installed into the OpenClaw agent workspace so agents can follow a shared Ralphie protocol.
- **`ralphie.sh`** is intended to be **copied into whatever target project** (new or existing) you want to run Ralphie on.
- Ralphie is then run and “babysat” per this skill (background run + monitored logs + prompt liaison).

## Workflow (do this at the start of any coding engagement)

### 1) Detect whether the target repo already has Ralphie

From the target project repo root (or current working directory if unknown), scan for `ralphie.sh`.

- Prefer using the bundled script: `scripts/ralphie_scan.sh`.
- If you do it manually, a safe default is:
  - `find . -maxdepth 5 -name ralphie.sh -not -path '*/.git/*'`

**If found:**
- Record the path.
- Offer to run it (only if it fits the moment; don’t derail tiny one-line tasks).

**If not found:**
- Offer the **Ralphie protocol** (see `references/ralphie_protocol.md`).
- Ask a single confirm question: “Want me to copy/add Ralphie into this project?”

### 2) Add Ralphie to the target project (when missing)

Default to copying a known file into the project (more controllable than piping remote code).

Options:
1. **Preferred (copy from this skill repo):** copy `scripts/ralphie.sh` into the target repo as `./ralphie.sh`.
   - Use `scripts/ralphie_copy.sh --to <project-dir>`
2. **Download into the project:** fetch upstream into `./ralphie.sh`, then optionally inspect.
   - Use `scripts/ralphie_install.sh` (downloads to `./ralphie.sh` by default).
3. **Fast one-liner (user may explicitly choose, less safe):**
   - `curl -fsSL https://raw.githubusercontent.com/sirouk/ralphie/refs/heads/master/ralphie.sh | bash`

### 3) Run Ralphie in the background (when running)

When running `ralphie.sh`, do not block the main agent.

- Prefer `scripts/ralphie_run_bg.sh` which:
  - writes logs under `.ralphie/ralphie.log`
  - writes a PID under `.ralphie/ralphie.pid`

### 4) Monitor Ralphie with a dedicated agent

When `ralphie.sh` is running, spawn a dedicated sub-agent whose only job is to monitor its output and summarize results back.

If Ralphie becomes interactive (first-run setup wizard prompts), use `references/ralphie_prompts.md` to:
- translate prompts into plain English
- recommend safe defaults
- escalate to the user for riskier toggles (YOLO, git autonomy, auto-update, etc.)

**Pattern:**
- Start Ralphie in background.
- Spawn a sub-agent and give it a very narrow task:
  - tail/inspect `.ralphie/ralphie.log`
  - periodically summarize progress
  - report completion + actionable next steps

If you can use OpenClaw sub-agents, do:
- `sessions_spawn` with a task like:
  - “Monitor .ralphie/ralphie.log for completion/errors; summarize every time it changes; stop when it looks finished.”

If sub-agents are unavailable in the environment, fall back to:
- periodic checks of the log file (`tail -n 200 .ralphie/ralphie.log`)

## What to report back to the user

- Whether `ralphie.sh` was found / copied / downloaded
- Where logs are (`.ralphie/ralphie.log`)
- Key findings and concrete recommended actions

## Residual record (rails)

To make Ralphie a true liaison, keep breadcrumbs so you can always get back to a running (or previously-run) Ralphie instance.

Canonical curated log (preferred, for backups):
- `<workspace>/memory/RALPHIE_MEMORY.md`

Machine-readable event stream (best-effort):
- `~/.openclaw/skills/ralphie-skill/runs.jsonl`

The bundled helper scripts (e.g. `scripts/ralphie_copy.sh`) will try to append to both.

Multi-agent note: budget **one extra concurrent agent** for the babysitter/liaison if the environment enforces concurrency limits.

To check this in OpenClaw config, read:
- `agents.defaults.maxConcurrent` (default: 1)

Command:
- `openclaw config get agents.defaults.maxConcurrent --json`

If it’s < 2, offer (with confirmation) to bump it to 2:
- `openclaw config set agents.defaults.maxConcurrent 2 --json`

Bundled helper: `scripts/openclaw_concurrency_check.sh`.

## Secrets / tokens (white gloves)

When Ralphie (or its optional Chutes/Codex/Claude setup) needs tokens:
- Do **not** paste secrets into git repos.
- Prefer OpenClaw’s env/secrets patterns on the *host running OpenClaw*:
  - `~/.openclaw/.env` (global)
  - per-process env vars
  - or config inline `env: { ... }` via `openclaw config set`

Examples:
- `openclaw config set env.CHUTES_API_KEY '"cpk_..."' --json`
- `openclaw config set env.OPENAI_API_KEY '"sk-..."' --json`

If Codex auth is OAuth-based in your OpenClaw setup, prefer the OpenClaw CLI login flow on the machine that will run Ralphie/OpenClaw.

## Resources

- `scripts/ralphie_scan.sh` — detect `ralphie.sh`
- `scripts/ralphie_copy.sh` — copy vendored `ralphie.sh` into a target project + best-effort run tracking
- `scripts/ralphie_install.sh` — download `ralphie.sh` into a target project
- `scripts/ralphie_run_bg.sh` — run `ralphie.sh` in background with pid+log
- `scripts/ralphie.sh` — **vendored upstream copy** (large) for inspection/reference; upstream URL is still the source of truth
- `scripts/bootstrap_ralphie.sh` — install this skill repo into an OpenClaw skills directory (symlink/copy)
- `references/ralphie_protocol.md` — human/agent-facing “Ralphie protocol” framing
- `references/ralphie_prompts.md` — prompt-by-prompt liaison guide + safe defaults
