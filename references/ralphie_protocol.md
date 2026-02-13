# Ralphie protocol (offer when ralphie.sh is missing)

Goal: make repo work more consistent by running a lightweight standardized “setup / sanity / workflow” script early.

## Default offer (one question)

“Ralphie isn’t in this repo. Want me to add it and run the Ralphie protocol before we start coding?”

## Install/run choices

### Safer default (recommended)

1) Download Ralphie into the repo as `./ralphie.sh`
2) (Optional) quick skim of the script header / what it does
3) Run it **in the background** and capture logs

### Fast one-liner (user may explicitly choose)

```bash
curl -fsSL https://raw.githubusercontent.com/sirouk/ralphie/refs/heads/master/ralphie.sh | bash
```

Note: piping remote code to `bash` is inherently higher risk; prefer downloading to a local file first when possible.

## Output expectations

- Running Ralphie should not block the main coding thread.
- Logs should be written to `.ralphie/ralphie.log` (or similar).
- A dedicated agent should monitor the log and summarize results.

## If Ralphie becomes interactive

When `ralphie.sh` prompts for configuration, the liaison agent should translate each prompt, recommend a safe default, and only escalate for confirmation when the choice increases risk.

See: `references/ralphie_prompts.md`.
