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

expand_path() {
  case "$1" in
    "~") printf '%s\n' "$HOME" ;;
    "~/"*) printf '%s/%s\n' "$HOME" "${1#\~/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

read_config_value() {
  local config_path="$1"
  local dotted_path="$2"

  [ -f "$config_path" ] || return 0
  python3 - "$config_path" "$dotted_path" <<'PY'
import json
import sys

config_path, dotted_path = sys.argv[1:3]
try:
    with open(config_path, encoding="utf-8") as f:
        value = json.load(f)
    for part in dotted_path.split("."):
        value = value[part]
except Exception:
    sys.exit(0)
if value is None:
    sys.exit(0)
print(value)
PY
}

write_gateway_token() {
  local config_path="$1"
  local token="$2"

  python3 - "$config_path" "$token" <<'PY'
import json
import sys

config_path, token = sys.argv[1:3]
with open(config_path, encoding="utf-8") as f:
    data = json.load(f)
gateway = data.setdefault("gateway", {})
auth = gateway.setdefault("auth", {})
auth["mode"] = "token"
auth["token"] = token
with open(config_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
}

generate_token() {
  python3 - <<'PY'
import secrets
print(secrets.token_hex(24))
PY
}

CONFIG_FILE_RAW="$(openclaw --profile "$PROFILE" config file 2>/dev/null || true)"
CONFIG_FILE=""
EXISTING_TOKEN=""
if [ -n "$CONFIG_FILE_RAW" ]; then
  CONFIG_FILE="$(expand_path "$CONFIG_FILE_RAW")"
  EXISTING_TOKEN="$(read_config_value "$CONFIG_FILE" "gateway.auth.token")"
fi
if [ "$EXISTING_TOKEN" = "__OPENCLAW_REDACTED__" ]; then
  EXISTING_TOKEN=""
fi
GATEWAY_TOKEN="${OPENCLAW_GATEWAY_TOKEN:-$EXISTING_TOKEN}"
if [ -z "$GATEWAY_TOKEN" ]; then
  GATEWAY_TOKEN="$(generate_token)"
fi

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
  --gateway-token "$GATEWAY_TOKEN" \
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
openclaw --profile "$PROFILE" config set agents.defaults.skills '["pst-mail"]' --strict-json >/dev/null
CONFIG_FILE_RAW="$(openclaw --profile "$PROFILE" config file)"
CONFIG_FILE="$(expand_path "$CONFIG_FILE_RAW")"
write_gateway_token "$CONFIG_FILE" "$GATEWAY_TOKEN"
openclaw --profile "$PROFILE" config validate >/dev/null

echo "OpenClaw profile '$PROFILE' is configured with model '$MODEL_REF'"
echo "OpenClaw profile '$PROFILE' is restricted to the pst-mail skill"
