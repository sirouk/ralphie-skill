# Ralphie prompts + how to answer (and implications)

This doc is meant for an **agent acting as a liaison** while `ralphie.sh` runs.

Rule of thumb:
- If the user *explicitly* wants autonomy → lean **YES** to autonomy toggles.
- If the user is unsure / this is a shared or prod repo / stakes are unclear → lean **NO** (safer) and keep the run informative.

## First-time setup wizard prompts

When `ralphie.sh` runs interactively in a repo without prior config, it collects a durable config (written under the repo’s `.ralphie/` directory).

### 1) Project name
Prompt: `Project name`
- Default: repo directory name.
- Implication: used in notifications/log labeling only.
- Safe default: accept.

### 2) Project type
Prompt: `Project type (new/existing)`
- Default: auto-detected; otherwise `existing`.
- Implication: influences the tone/assumptions of generated specs/prompts.
- Safe default: accept detection.

### 3) One-line vision
Prompt: `One-line project vision`
- Default differs for new vs existing.
- Implication: becomes a north-star line in generated prompt files; affects planning.
- Safe default: keep it short and accurate.

### 4) Core principles (3)
Prompts:
- `Core principle #1` (default: `Correctness first`)
- `Core principle #2` (default: `Keep changes reviewable`)
- `Core principle #3` (default: `Prefer simple solutions`)

Implication: these get embedded into the prompt scaffolding and “constitution” so the loop keeps re-centering on them.

Safe defaults: keep the defaults unless the user has known house style.

### 5) Default engine
Prompt: `Pick engine number`
Choices:
1) auto (recommended)
2) codex
3) claude
4) ask (prompt on each run)

Implication: determines which CLI (`codex` or `claude`) Ralphie tries to drive.

Safe default:
- Choose **auto** unless the user explicitly prefers one.
- Choose **ask** if you expect frequent switching.

### 6) YOLO mode
Prompt: `Enable YOLO mode for autonomous command execution?`
- Meaning: allows the loop to execute commands more freely (less human gating).
- Implication: higher risk (can run destructive commands if the agent makes a mistake).

Safe default:
- For unknown repos / high-stakes work: **NO**.
- For low-stakes prototypes / user explicitly wants autonomy: **YES**.

### 7) Git autonomy
Prompt: `Enable Git autonomy (commit/push in loop)?`
- Meaning: allows automated commits (and possibly pushes) as part of the loop.
- Implication: can create noisy histories or push unwanted changes.

Safe default:
- **NO** unless user explicitly wants it.
- If enabled, prefer “commit but don’t push” patterns if the script/repo policy allows.

### 8) Build approval policy
Prompt: `Build approval policy (upfront/on_ready)`
- `upfront`: asks *before* the prepare phase to capture “auto-continue into build” permission.
- `on_ready`: asks once prepare phase has produced a plan / readiness.

Implication:
- `upfront` is convenient but requires the human to trust the process early.
- `on_ready` is safer: you can review prepare output first.

Safe default: **on_ready** unless the user asks for hands-off.

### 9) Human notify channel
Prompt: `Human notify channel (none/terminal/telegram/discord)`
- `terminal`: prints warnings/notifications to stdout.
- `telegram`: requires `TELEGRAM_BOT_TOKEN` + `TELEGRAM_CHAT_ID`.
- `discord`: requires `DISCORD_WEBHOOK_URL`.

Implication: affects how Ralphie pings the human when it needs approval / hits an error.

Safe default: `terminal`.

### 10) GitHub issue integration
Prompt: `Enable GitHub issue integration?`
Then: `GitHub repo (owner/name)`

Implication: allows Ralphie to read/create/update GitHub issues (depending on how it’s configured and available auth).

Safe default: **NO** unless the user asks for it and auth is already set up.

### 11) Stack summary
Prompt: `Stack summary`
- Default: auto-detected.

Implication: becomes part of prompt scaffolding.

Safe default: accept detection; tweak if it missed something important.

### 12) Model overrides
Prompts:
- `Default Codex model override (blank keeps codex default)`
- `Default Claude model override (blank keeps claude default)`

Implication: pins models for consistency/cost control.

Safe default: blank (unless user requested a specific model).

### 13) Auto-update
Prompts:
- `Enable ralphie.sh auto-update from upstream on each run?`
- `Auto-update URL` (optional)

Implication:
- **Pros:** always gets latest fixes/features.
- **Cons:** behavior can change between runs; harder to reproduce.

Safe default:
- If you care about reproducibility: **NO** (or keep URL pinned and only update intentionally).
- If you want latest behavior and accept churn: **YES**.

## Optional binary bootstrap prompts (during setup)

Ralphie may offer:
- `Install/update Node.js toolchain now?` (nvm + latest node + npm)
- `Run Chutes Codex installer now?` (downloads and runs `https://chutes.ai/chutes_codex_env.sh`)
- `Run Chutes Claude Code installer now?` (downloads and runs `https://chutes.ai/chutes_claude_code_env.sh`)

White-glove note: if any of these flows require API keys/tokens, prefer setting them via OpenClaw host env/secrets (e.g. `~/.openclaw/.env` or `openclaw config set env.* ...`) rather than pasting them into prompts or committing them to a repo.

Implication: these run remote scripts. They’re convenient but you should treat them like any remote installer.

Safe default:
- If the tools are already installed: answer **NO**.
- If missing and the user asked for a full bootstrap: answer **YES** (or do it manually with inspection).

## If you are the liaison agent

Your job isn’t to guess what the human wants; it’s to:
1) translate each prompt into plain English,
2) suggest a safe default,
3) ask for confirmation when the choice increases risk.

When in doubt, choose:
- YOLO: **off**
- Git autonomy: **off**
- Approval: **on_ready**
- Notify: **terminal**
- GitHub issues: **off**
