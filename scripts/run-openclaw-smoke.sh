#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=resolve-demo-root.sh
. "$SCRIPT_DIR/resolve-demo-root.sh"
ROOT="$(resolve_demo_root "$SCRIPT_DIR")"
# shellcheck source=openclaw-env.sh
. "$SCRIPT_DIR/openclaw-env.sh"

PROFILE="${OPENCLAW_PROFILE:-openclaw-pst}"
MODEL_REF="${OPENCLAW_MODEL_REF:-ollama/${OPENCLAW_OLLAMA_MODEL:-qwen3.6:27b}}"
SESSION="${OPENCLAW_SMOKE_SESSION:-pst-smoke}"
LOG_FILE="$ROOT/logs/openclaw-smoke.json"

mkdir -p "$ROOT/logs"
openclaw_require_cli

openclaw --profile "$PROFILE" agent \
  --local \
  --session-id "$SESSION" \
  --model "$MODEL_REF" \
  --timeout "${OPENCLAW_AGENT_TIMEOUT:-240}" \
  --message "Use the PST mail service to answer: What folders are in my PST mailbox, and how many emails are in each folder?" \
  --json > "$LOG_FILE"

python3 - "$LOG_FILE" <<'PY'
import json
import sys

path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
texts = [p.get("text", "") for p in data.get("payloads", [])]
text = "\n".join(texts).strip()
print(text)
if "Inbox" not in text or "Sent" not in text:
    raise SystemExit("OpenClaw PST smoke response did not mention expected folders")
PY
