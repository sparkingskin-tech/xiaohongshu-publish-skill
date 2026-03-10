#!/bin/zsh
set -euo pipefail

OUT_DIR="/Users/skin/.openclaw/workspace/tmp"
OUT_PNG="${1:-$OUT_DIR/xhs_login_qr.png}"
OUT_TXT="${2:-$OUT_DIR/xhs_login_qr.txt}"

mkdir -p "$OUT_DIR"

RAW_OUTPUT="$(
  mcporter call \
    --http-url http://127.0.0.1:18060/mcp \
    --allow-http \
    --tool get_login_qrcode \
    --output json
)"

if [[ "$RAW_OUTPUT" == *'"error"'* ]] || [[ "$RAW_OUTPUT" == *"appears offline"* ]]; then
  echo "$RAW_OUTPUT" >&2
  exit 1
fi

PARSED_JSON="$(
  RAW_OUTPUT_ENV="$RAW_OUTPUT" node <<'EOF'
const vm = require('node:vm');

const input = (process.env.RAW_OUTPUT_ENV || '').trim();

function parsePayload(text) {
  try {
    return JSON.parse(text);
  } catch {}
  return vm.runInNewContext(`(${text})`);
}

const payload = parsePayload(input);
if (!payload || !Array.isArray(payload.content)) {
  throw new Error('Unexpected get_login_qrcode payload');
}

const textItem = payload.content.find((item) => item && item.type === 'text');
const imageItem = payload.content.find((item) => item && item.type === 'image' && typeof item.data === 'string');

if (!imageItem) {
  throw new Error('QR image data missing from payload');
}

process.stdout.write(JSON.stringify({
  text: textItem?.text || '',
  mimeType: imageItem.mimeType || '',
  data: imageItem.data,
}));
EOF
)"

QR_TEXT="$(printf '%s' "$PARSED_JSON" | jq -r '.text')"
QR_MIME="$(printf '%s' "$PARSED_JSON" | jq -r '.mimeType')"
QR_DATA="$(printf '%s' "$PARSED_JSON" | jq -r '.data')"

if [[ "$QR_MIME" != "image/png" ]]; then
  echo "Unexpected QR mime type: $QR_MIME" >&2
  exit 1
fi

if [[ "$QR_DATA" != iVBOR* ]]; then
  echo "QR payload does not look like PNG base64." >&2
  exit 1
fi

printf '%s' "$QR_DATA" | base64 -d > "$OUT_PNG"
printf '%s\n' "$QR_TEXT" > "$OUT_TXT"

FILE_DESC="$(file -b "$OUT_PNG")"
if [[ "$FILE_DESC" != PNG* ]]; then
  echo "Decoded QR file is not a valid PNG: $FILE_DESC" >&2
  exit 1
fi

printf 'QR_TEXT=%s\n' "$QR_TEXT"
printf 'QR_PNG=%s\n' "$OUT_PNG"
printf 'QR_TEXT_FILE=%s\n' "$OUT_TXT"
