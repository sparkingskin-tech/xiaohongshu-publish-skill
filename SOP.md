# XiaoHongShu Publish SOP

This SOP is for running XiaoHongShu publishing safely on this Mac with local `xiaohongshu-mcp`.

## 1) Preconditions

- Local tools available: `mcporter`, `jq`, `node`, `rg`
- Skill scripts exist in this repo `scripts/`
- User has explicitly asked to publish (or to run a dry run)

## 2) Install / Start MCP

Install binaries (if missing):

```bash
bash scripts/install_xhs_mcp.sh
```

Start local server:

```bash
bash scripts/start_xhs_mcp.sh
```

Quick health checks:

```bash
lsof -nP -iTCP:18060
mcporter call --http-url http://127.0.0.1:18060/mcp --allow-http --tool check_login_status --output json
```

## 3) Login QR Flow (Required if not logged in)

Generate a valid PNG QR code:

```bash
bash scripts/fetch_login_qr_png.sh
```

Expected outputs:

- `QR_PNG=/Users/skin/.openclaw/workspace/tmp/xhs_login_qr.png`
- `QR_TEXT_FILE=/Users/skin/.openclaw/workspace/tmp/xhs_login_qr.txt`

Delivery rule:

- Send the PNG directly via `message` tool (`media`/`path`/`filePath`)
- Do not send base64 text
- Do not use online QR generators for this payload

## 4) Confirmation Gate 1 (After Topic Selection)

After topic research is completed and before copy production starts, get explicit user confirmation on:

- Selected topic direction
- Target audience angle
- Expected style and tone

Only proceed to copy/image production after this confirmation.

## 5) Confirmation Gate 2 (After Copy + Images)

Before calling `publish_content`, confirm all:

1. Final title/content is approved
2. Final images are approved and exist
3. Tags are approved
4. Human manual check is complete (user checks sensitive information manually at this stage)
5. User explicitly says to publish now

## 6) Publish

Prepare `/tmp/xhs_publish_args.json` with fields:

- `title`
- `content`
- `images` (absolute local paths)
- `tags` (optional)

Publish:

```bash
mcporter call --http-url http://127.0.0.1:18060/mcp --allow-http --tool publish_content --args "$(cat /tmp/xhs_publish_args.json)" --output json
```

## 7) Dry Run Rules

For dry run, do all checks except the final publish call.

- Never call `publish_content`
- Must return: completed checks, issues, and final pre-publish checklist

## 8) Troubleshooting

- `ECONNREFUSED 127.0.0.1:18060`: MCP server not running or exited
- `Unknown model: minimax/MiniMax-VL-01` on image tool: use `message` tool to deliver PNG instead of `image` tool
- QR scans fail: regenerate QR with `scripts/fetch_login_qr_png.sh`; use latest file only
- Publish success without post ID: report success and optionally verify on homepage
