#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=resolve-demo-root.sh
. "$SCRIPT_DIR/resolve-demo-root.sh"
ROOT="$(resolve_demo_root "$SCRIPT_DIR")"

stop_pid_file() {
  local label="$1" file="$2"
  if [ -f "$file" ]; then
    pid="$(cat "$file" 2>/dev/null || true)"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      echo "Stopping $label pid $pid"
      kill "$pid" 2>/dev/null || true
    fi
    rm -f "$file"
  fi
}

stop_pid_file "OpenClaw gateway" "$ROOT/logs/openclaw-gateway.pid"
stop_pid_file "PST server" "$ROOT/logs/pst-server.pid"

echo "OpenClaw PST demo stopped. Ollama is left running."
