#!/bin/zsh
set -euo pipefail

BASE_DIR="/Users/skin/.openclaw/workspace/tools/xiaohongshu-mcp"
BIN="$BASE_DIR/xiaohongshu-mcp-darwin-arm64"
LOG_DIR="$BASE_DIR/logs"
RUN_DIR="$BASE_DIR/run"
LOG_FILE="$LOG_DIR/server.log"
PID_FILE="$RUN_DIR/server.pid"

mkdir -p "$LOG_DIR" "$RUN_DIR"

if [[ ! -x "$BIN" ]]; then
  echo "Missing binary: $BIN" >&2
  exit 1
fi

if [[ -f "$PID_FILE" ]]; then
  OLD_PID="$(cat "$PID_FILE" || true)"
  if [[ -n "${OLD_PID}" ]] && kill -0 "$OLD_PID" 2>/dev/null; then
    echo "xiaohongshu-mcp already running with pid $OLD_PID"
    exit 0
  fi
fi

nohup "$BIN" >"$LOG_FILE" 2>&1 &
echo $! >"$PID_FILE"
echo "Started xiaohongshu-mcp with pid $(cat "$PID_FILE")"
echo "Log: $LOG_FILE"
