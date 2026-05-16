#!/usr/bin/env bash
set -euo pipefail

PORT="${PST_SERVER_PORT:-9003}"

echo "Host PST health:"
curl -fsS "http://127.0.0.1:$PORT/health"
echo

echo "Folder counts:"
curl -fsS "http://127.0.0.1:$PORT/folders"
echo

echo "Subject search for 'attachment':"
curl -fsS "http://127.0.0.1:$PORT/emails/search_subject?keyword=attachment&max_results=2"
echo
