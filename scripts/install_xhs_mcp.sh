#!/bin/zsh
set -euo pipefail

INSTALL_DIR="/Users/skin/.openclaw/workspace/tools/xiaohongshu-mcp"
TMP_TAR="/tmp/xiaohongshu-mcp-darwin-arm64.tar.gz"
TAG_URL="https://github.com/xpzouying/xiaohongshu-mcp/releases/latest/download/xiaohongshu-mcp-darwin-arm64.tar.gz"

mkdir -p "$INSTALL_DIR"
curl -L --max-time 120 -A "Mozilla/5.0" "$TAG_URL" -o "$TMP_TAR"
tar xzf "$TMP_TAR" -C "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/xiaohongshu-mcp-darwin-arm64" "$INSTALL_DIR/xiaohongshu-login-darwin-arm64"
echo "Installed xiaohongshu-mcp to $INSTALL_DIR"
