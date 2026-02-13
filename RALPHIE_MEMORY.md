# RALPHIE_MEMORY.md (ralphie-skill)

This file defines the **residual record** convention for the `ralphie-skill`.

Goal: when Ralphie is copied into a project and/or running (possibly on a remote machine), keep a durable breadcrumb trail so the primary agent (and any liaison babysitter agent) can quickly answer:

- Where was Ralphie deployed?
- Where are its logs?
- How do I re-attach / check status?
- What choices were made during setup (YOLO, git autonomy, notify channel, etc.)?

## Where the canonical memory lives

**Canonical location (preferred):** the primary agent workspace memory directory.

Example (Chris’s workspace):

- `<workspace>/memory/RALPHIE_MEMORY.md`

This is intentionally placed next to `MEMORY.md` and daily `memory/YYYY-MM-DD.md` notes so existing backup routines (e.g. Clawboard bootstrap’s memory backup) pick it up automatically.

## Format

Use **Markdown** for human readability + easy review in PRs.

When an exact machine-readable record is helpful, also append a JSONL line to:

- `~/.openclaw/skills/ralphie-skill/runs.jsonl`

(Markdown is the “curated” log; JSONL is the “event stream”.)

## Entry template (append-only)

Add a new section per deployment/run:

```markdown
## <YYYY-MM-DD HH:MM TZ> — <project-name> (<local|ssh|tunnel>)

- **Project dir:** /abs/path/to/repo
- **Host:** local | <ssh-host> | <tailscale-name> | <ip>
- **How Ralphie was added:** copy | download | one-liner
- **ralphie.sh path:** ./ralphie.sh
- **Run mode:** background
- **Log path:** ./.ralphie/ralphie.log
- **PID file:** ./.ralphie/ralphie.pid
- **Session / babysitter:** <sessionKey or notes>
- **Setup choices (if changed from safe defaults):**
  - Engine: auto|codex|claude|ask
  - YOLO: on|off
  - Git autonomy: on|off
  - Build approval: upfront|on_ready
  - Notify: none|terminal|telegram|discord
  - Auto-update: on|off
- **Notes / outcome:**
```

## Multi-agent rail

If the environment limits concurrent agents, budget at least:
- **Primary agent** (doing the work)
- **One extra liaison/babysitter agent** (monitoring logs + translating prompts)

If only one agent is available, fall back to periodic manual log checks.
