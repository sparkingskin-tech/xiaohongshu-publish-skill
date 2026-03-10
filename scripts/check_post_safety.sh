#!/bin/zsh
set -euo pipefail

if [[ "$#" -lt 1 ]]; then
  echo "Usage: $0 <file> [file...]" >&2
  exit 2
fi

PATTERN='(/Users/|/root/|/home/|@codex|@openclaw|cookie|token|password|passwd|api[_-]?key|ghp_|sk-|AKIA|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|1[3-9][0-9]{9}|web_session|cookies\.json)'

FOUND=0
for file in "$@"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing file: $file" >&2
    continue
  fi

  if rg -n -i "$PATTERN" "$file"; then
    FOUND=1
  fi
done

if [[ "$FOUND" -eq 1 ]]; then
  echo "Safety scan failed: remove flagged content before publishing." >&2
  exit 1
fi

echo "Safety scan passed."
