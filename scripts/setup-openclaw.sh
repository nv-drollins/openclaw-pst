#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=resolve-demo-root.sh
. "$SCRIPT_DIR/resolve-demo-root.sh"
ROOT="$(resolve_demo_root "$SCRIPT_DIR")"
# shellcheck source=openclaw-env.sh
. "$SCRIPT_DIR/openclaw-env.sh"

PROFILE="${OPENCLAW_PROFILE:-openclaw-pst}"
OLLAMA_MODEL="${OPENCLAW_OLLAMA_MODEL:-qwen3.6:27b}"
MODEL_REF="${OPENCLAW_MODEL_REF:-ollama/${OLLAMA_MODEL}}"
PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
BIND="${OPENCLAW_GATEWAY_BIND:-loopback}"

openclaw_require_cli

echo "Configuring native OpenClaw profile '$PROFILE'"
openclaw --profile "$PROFILE" onboard \
  --non-interactive \
  --accept-risk \
  --mode local \
  --workspace "$ROOT" \
  --auth-choice ollama \
  --gateway-port "$PORT" \
  --gateway-bind "$BIND" \
  --gateway-auth token \
  --skip-bootstrap \
  --skip-channels \
  --skip-daemon \
  --skip-health \
  --skip-search \
  --skip-skills \
  --skip-ui \
  --no-install-daemon \
  --json >/dev/null

openclaw --profile "$PROFILE" models set "$MODEL_REF"
openclaw --profile "$PROFILE" config validate >/dev/null

echo "OpenClaw profile '$PROFILE' is configured with model '$MODEL_REF'"
