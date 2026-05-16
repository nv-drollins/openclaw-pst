# OpenClaw PST Mail Demo

OpenClaw-only version of the PST mail demo. It keeps the same bundled sample
Outlook `.pst` mailbox and read-only PST REST service, but removes the
NemoClaw/OpenShell sandbox layer.

The default local model is:

```text
ollama/qwen3.6:27b
```

See [PREREQUISITES.md](PREREQUISITES.md) for the clean-instance requirements
ledger.

## Quick Start

Run these commands on the Spark or Ubuntu host:

```bash
git clone https://github.com/nv-drollins/openclaw-pst.git
cd openclaw-pst
chmod +x install.sh scripts/*.sh
./install.sh
```

`install.sh` installs missing host prerequisites, ensures Ollama and
`qwen3.6:27b` are available, starts the PST service, creates a native OpenClaw
profile, starts the OpenClaw gateway, and prints the dashboard URL and token.

Try this prompt in the dashboard:

```text
What folders are in my PST mailbox, and how many emails are in each folder?
```

Other good prompts:

```text
Show me the latest 5 emails in the PST mailbox.
```

```text
Search the PST mailbox for emails with attachment in the subject.
```

```text
Find emails from Saqib in the sample mailbox.
```

## What You Get

- A bundled sample mailbox at `data/Outlook.pst`
- A host-side PST service on port `9003`
- A native OpenClaw workspace with a `pst-mail` skill
- A local Ollama/Qwen model path
- Start, stop, dashboard, prerequisite, and smoke-test scripts

The sample PST is static:

```text
Outlook/Inbox: 6 emails
Outlook/Sent Items: 5 emails
Grand total: 11 emails
```

## Day-2 Commands

Start or repair the full demo:

```bash
./scripts/start-demo.sh
```

Stop the OpenClaw gateway and PST service:

```bash
./scripts/stop-demo.sh
```

Run host-side PST service checks:

```bash
./scripts/run-pst-smoke.sh
```

Run a native OpenClaw agent smoke test:

```bash
./scripts/run-openclaw-smoke.sh
```

Show the dashboard URL and token:

```bash
./scripts/show-dashboard.sh
```

## Configuration

| Variable | Default | Purpose |
|---|---:|---|
| `OPENCLAW_PROFILE` | `openclaw-pst` | Native OpenClaw profile name |
| `OPENCLAW_OLLAMA_MODEL` | `qwen3.6:27b` | Ollama model to pull and use |
| `OPENCLAW_MODEL_REF` | `ollama/${OPENCLAW_OLLAMA_MODEL}` | OpenClaw model id |
| `OPENCLAW_GATEWAY_PORT` | `18789` | Dashboard/gateway port |
| `OPENCLAW_GATEWAY_BIND` | `loopback` | Gateway bind mode; use `lan` only on trusted networks |
| `PST_SERVER_PORT` | `9003` | Local PST REST service port |
| `PST_PATH` | `data/Outlook.pst` | Optional path to a different PST file |

## Notes

This project deliberately does not install or use NemoClaw, OpenShell, Docker,
or vLLM. Native OpenClaw runs on the host and calls the PST service at
`http://127.0.0.1:9003`.
