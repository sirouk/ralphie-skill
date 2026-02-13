# ralphie-skill

OpenClaw skill that makes the agent a **Ralphie liaison** for coding projects.

When starting work in a repo (new or existing), the skill guides the agent to:
- scan for `ralphie.sh`
- offer to **copy** it into the target project if missing (or download upstream)
- run it **in the background** (non-blocking)
- monitor logs via a dedicated sub-agent
- translate any interactive prompts and recommend safe defaults

## What’s in this repo

- `SKILL.md` — the skill instructions OpenClaw loads
- `scripts/ralphie.sh` — vendored upstream copy (for inspection/reference)
- `scripts/bootstrap_openclaw.sh` — installs this repo as an OpenClaw skill (symlink or copy)
- `scripts/ralphie_scan.sh` / `scripts/ralphie_copy.sh` / `scripts/ralphie_install.sh` / `scripts/ralphie_run_bg.sh` — helper scripts
- `references/ralphie_protocol.md` — protocol framing
- `references/ralphie_prompts.md` — prompt-by-prompt liaison guide + implications

## Install

### Option A (recommended): run the bootstrap installer

From the repo root:

```bash
bash scripts/bootstrap_openclaw.sh
```

By default this installs via **symlink** into your OpenClaw workspace’s `skills/` directory (auto-detected from `~/.openclaw/openclaw.json`).

Useful flags:

```bash
bash scripts/bootstrap_openclaw.sh --copy
bash scripts/bootstrap_openclaw.sh --dir ~/.openclaw/skills
```

The script also attempts to verify discovery via:

```bash
openclaw skills list
```

### Option B: package as a `.skill`

This repo can be zipped into a `.skill` file (a zip with a `.skill` extension) containing:

- `SKILL.md`
- `scripts/`
- `references/`

## Upstream Ralphie

Upstream script source:

- https://github.com/sirouk/ralphie
- One-liner (less safe, for convenience):

```bash
curl -fsSL https://raw.githubusercontent.com/sirouk/ralphie/refs/heads/master/ralphie.sh | bash
```
