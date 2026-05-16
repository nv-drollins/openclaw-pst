#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=openclaw-env.sh
. "$SCRIPT_DIR/openclaw-env.sh"

PROFILE="${OPENCLAW_PROFILE:-openclaw-pst}"
PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
BIND="${OPENCLAW_GATEWAY_BIND:-loopback}"

openclaw_require_cli

CONFIG_PORT="$(openclaw --profile "$PROFILE" config get gateway.port 2>/dev/null || true)"
CONFIG_BIND="$(openclaw --profile "$PROFILE" config get gateway.bind 2>/dev/null || true)"
TOKEN="$(openclaw --profile "$PROFILE" config get gateway.auth.token 2>/dev/null || true)"

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

if [ -n "$TOKEN" ]; then
  echo
  echo "Dashboard token:"
  echo "$TOKEN"
fi

if [ "$BIND" = "loopback" ]; then
  echo
  echo "If your browser is on another machine, tunnel it first:"
  echo "  ssh -N -L ${PORT}:127.0.0.1:${PORT} <user>@<spark-ip>"
fi
