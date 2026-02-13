---
name: ralphie-skill
description: Ensure the "Ralphie protocol" is offered/used in coding projects that include (or should include) ralphie.sh. Use when starting a new coding project, onboarding to an existing repository, or beginning any non-trivial code change so the agent will: (1) scan the repo for ralphie.sh, (2) if missing, offer to add/run Ralphie via https://github.com/sirouk/ralphie (user may choose install method), and (3) when running ralphie.sh, run it in the background and have a dedicated sub-agent monitor its output/logs.
---

# Ralphie Skill

## Workflow (do this at the start of any coding engagement)

### 1) Detect whether the repo already has Ralphie

From the repo root (or current working directory if unknown), scan for `ralphie.sh`.

- Prefer using the bundled script: `scripts/ralphie_scan.sh`.
- If you do it manually, a safe default is:
  - `find . -maxdepth 5 -name ralphie.sh -not -path '*/.git/*'`

**If found:**
- Record the path.
- Offer to run it (only if it fits the moment; don’t derail tiny one-line tasks).

**If not found:**
- Offer the **Ralphie protocol** (see `references/ralphie_protocol.md`).
- Ask a single confirm question: “Want me to add Ralphie to this repo and run it?”

### 2) Offer install/run options (when missing)

Default to the safer option (download to file, then run) — but keep the user’s preferred one-liner available.

Options:
1. **Preferred (safer):** download `ralphie.sh` into the repo, inspect, then run.
   - Use `scripts/ralphie_install.sh` (downloads to `./ralphie.sh` by default).
2. **User-provided one-liner (fast, less safe):**
   - `curl -fsSL https://raw.githubusercontent.com/sirouk/ralphie/refs/heads/master/ralphie.sh | bash`

### 3) Run Ralphie in the background (always)

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

- Whether `ralphie.sh` was found or installed
- Where logs are (`.ralphie/ralphie.log`)
- Key findings and concrete recommended actions

## Resources

- `scripts/ralphie_scan.sh` — detect `ralphie.sh`
- `scripts/ralphie_install.sh` — download `ralphie.sh` into the repo
- `scripts/ralphie_run_bg.sh` — run `ralphie.sh` in background with pid+log
- `scripts/ralphie.sh` — **vendored upstream copy** (large) for inspection/reference; upstream URL is still the source of truth
- `scripts/bootstrap_openclaw.sh` — install this skill repo into an OpenClaw skills directory (symlink/copy)
- `references/ralphie_protocol.md` — human/agent-facing “Ralphie protocol” framing
- `references/ralphie_prompts.md` — prompt-by-prompt liaison guide + safe defaults
