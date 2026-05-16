#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=openclaw-env.sh
. "$SCRIPT_DIR/openclaw-env.sh"

PROFILE="${OPENCLAW_PROFILE:-openclaw-pst}"
PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
BIND="${OPENCLAW_GATEWAY_BIND:-loopback}"
SHOW_TOKEN=1

usage() {
  cat <<EOF
Usage: $0 [--show-token] [--no-token]

Prints the native OpenClaw dashboard URL. By default it also prints the local
gateway token needed to sign in.

Options:
  --show-token  Print the dashboard token. Accepted for compatibility.
  --no-token    Do not print the token.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --show-token) SHOW_TOKEN=1 ;;
    --no-token) SHOW_TOKEN=0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

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

CONFIG_PORT="$(openclaw --profile "$PROFILE" config get gateway.port 2>/dev/null || true)"
CONFIG_BIND="$(openclaw --profile "$PROFILE" config get gateway.bind 2>/dev/null || true)"
CONFIG_FILE_RAW="$(openclaw --profile "$PROFILE" config file 2>/dev/null || true)"
CONFIG_FILE=""
TOKEN=""
if [ -n "$CONFIG_FILE_RAW" ]; then
  CONFIG_FILE="$(expand_path "$CONFIG_FILE_RAW")"
  TOKEN="$(read_config_value "$CONFIG_FILE" "gateway.auth.token")"
fi

if [ -z "$TOKEN" ] || [ "$TOKEN" = "__OPENCLAW_REDACTED__" ]; then
  TOKEN="$(openclaw --profile "$PROFILE" config get gateway.auth.token 2>/dev/null || true)"
fi

if [ -n "$CONFIG_PORT" ]; then
  PORT="$CONFIG_PORT"
fi
if [ -n "$CONFIG_BIND" ]; then
  BIND="$CONFIG_BIND"
fi

if [ "$BIND" = "loopback" ]; then
  URL="http://127.0.0.1:${PORT}/"
else
  HOST_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
  URL="http://${HOST_IP:-127.0.0.1}:${PORT}/"
fi

echo "Dashboard URL:"
echo "$URL"

if [ "$SHOW_TOKEN" -eq 1 ] && [ -n "$TOKEN" ]; then
  echo
  echo "Dashboard token:"
  if [ "$TOKEN" = "__OPENCLAW_REDACTED__" ]; then
    echo "Token is redacted in the OpenClaw config. Repair it with:"
    echo "  ./scripts/setup-openclaw.sh"
    echo "  ./scripts/stop-demo.sh && ./scripts/start-demo.sh --no-install"
  else
    echo "$TOKEN"
  fi
fi

if [ "$BIND" = "loopback" ]; then
  echo
  echo "If your browser is on another machine, tunnel it first:"
  echo "  ssh -N -L ${PORT}:127.0.0.1:${PORT} <user>@<spark-ip>"
fi
