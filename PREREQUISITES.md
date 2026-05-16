# Clean Instance Prerequisites

This repo is intended to work on a fresh DGX Spark / Ubuntu host. The scripts
track and install host prerequisites where possible.

| Requirement | Why it is needed | Installed by |
|---|---|---|
| Ubuntu with `sudo` | First-time package and service setup | Manual host requirement |
| `git`, `curl`, `ca-certificates`, `lsof`, `python3`, `zstd` | Repo checkout, HTTP checks, service management, PST server, Ollama tar extraction | `scripts/install-host-prereqs.sh` |
| `pst-utils` / `readpst` | Extracts the bundled Outlook `.pst` on ARM and x86 Linux | `scripts/install-host-prereqs.sh` |
| Node.js 22+ and npm | Native OpenClaw CLI runtime | `scripts/install-host-prereqs.sh` via `nvm` if needed |
| OpenClaw CLI | Native agent, gateway, dashboard, model config, and skills | `scripts/install-host-prereqs.sh` via `npm install -g openclaw@latest` |
| Ollama 0.22.1 | Local model runtime on DGX Spark / GB10 | `scripts/install-ollama.sh` |
| `qwen3.6:27b` Ollama model | Default local model for this OpenClaw PST template | `scripts/ensure-model.sh` |
| Browser or SSH tunnel | To open the OpenClaw dashboard from another machine | Manual |

Not required for this OpenClaw-only version:

- NemoClaw
- OpenShell
- Docker
- NVIDIA Container Toolkit
- vLLM
- Hugging Face token
