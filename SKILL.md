---
name: xiaohongshu-publish
description: >
  Publish or dry-run XiaoHongShu posts on this Mac. Use when the user asks to
  publish to 小红书, asks for a 小红书发布 dry run, asks to scan a XiaoHongShu
  login QR code, or asks to review a XiaoHongShu draft for sensitive
  information before publishing.
---

# XiaoHongShu Publish

Use this skill for XiaoHongShu publish tasks.

## Fixed Paths

Use these exact helper scripts when they exist:

- Install script: `/Users/skin/.openclaw/workspace/skills/xiaohongshu-publish/scripts/install_xhs_mcp.sh`
- Start script: `/Users/skin/.openclaw/workspace/skills/xiaohongshu-publish/scripts/start_xhs_mcp.sh`
- Safety scan: `/Users/skin/.openclaw/workspace/skills/xiaohongshu-publish/scripts/check_post_safety.sh`
- QR fetch script: `/Users/skin/.openclaw/workspace/skills/xiaohongshu-publish/scripts/fetch_login_qr_png.sh`

Preferred binary location:

- `/Users/skin/.openclaw/workspace/tools/xiaohongshu-mcp/xiaohongshu-mcp-darwin-arm64`
- `/Users/skin/.openclaw/workspace/tools/xiaohongshu-mcp/xiaohongshu-login-darwin-arm64`

Accepted fallback runtime location on this Mac:

- `/private/tmp/xiaohongshu-mcp-darwin-arm64`
- `/private/tmp/xiaohongshu-login-darwin-arm64`

## Core Rules

Before any real publish:

1. Confirm the user explicitly wants to publish.
2. Check draft text and editable image sources for:
   - absolute filesystem paths
   - cookies, tokens, passwords, api keys
   - phone numbers, emails, credentials
   - internal markers like `@codex` and `@openclaw`
   - internal project details that should not be public
3. Remove or rewrite any flagged content.
4. Show the cleaned version or summarize what was cleaned.
5. Ask for final confirmation.

## Dry Run Standard

If the user asks for a dry run:

- Do not call `publish_content`.
- Do verify the local scripts, service path, login flow, and safety workflow.
- Do report:
  - completed checks
  - issues found
  - what would be cleaned
  - what confirmation would be required before real publishing

For dry runs, classify findings precisely:

- If helper scripts exist but the preferred install dir is empty, say `preferred install dir missing` instead of `tool missing`.
- If port `18060` is listening and `lsof` shows the binary under `/private/tmp`, say `service is running from fallback tmp location`.
- If `mcporter` cannot connect because of transport or sandbox restrictions, say `login status could not be verified from this environment`.
- Only say `not installed` if neither helper scripts nor any known binary location exists.

## Local Publish Path

Typical local flow:

1. Check whether the helper scripts above exist.
2. Check whether either the preferred binary location or the `/private/tmp` fallback binary exists.
3. Check whether local port `18060` is already listening with `lsof -nP -iTCP:18060`.
4. If the port is not listening and the start script exists, use the start script.
5. If needed, get a login QR code with the QR fetch script above.
6. Check login with `check_login_status`.
7. Review draft safety with the safety scan script.
8. On real publish only, call `publish_content`.

Treat these as valid evidence that the local service exists:

- `lsof -nP -iTCP:18060` shows a listening process
- `lsof -p <pid>` shows `/private/tmp/xiaohongshu-mcp-darwin-arm64` or the preferred install path
- `curl -i http://127.0.0.1:18060/mcp` returns an HTTP response, even if it is not `200`

Do not conclude the service is absent from a failed `mcporter` call alone.

## Login QR Code

Always use the QR fetch script, not ad-hoc decoding:

```bash
bash /Users/skin/.openclaw/workspace/skills/xiaohongshu-publish/scripts/fetch_login_qr_png.sh
```

The script writes:

- PNG image: `/Users/skin/.openclaw/workspace/tmp/xhs_login_qr.png`
- text note: `/Users/skin/.openclaw/workspace/tmp/xhs_login_qr.txt`

After running it:

1. Quote or paraphrase the expiry text from the text file.
2. Send the PNG file to the user's chat with the `message` tool using `media`, `path`, or `filePath`.
3. Ask the user to scan it with the XiaoHongShu app.

Do not:

- take base64 from a rendered plain-text transcript
- send the base64 string to an online QR generator
- tell the user to scan a URL that encodes the base64 text
- use `/tmp` as the final image path when you need to display the QR in chat
- prefer the `image` tool for user delivery when `message` can send the PNG directly

Only trust the `image.data` field from the actual `get_login_qrcode` payload.

## Safety Scan

Use:

```bash
bash /Users/skin/.openclaw/workspace/skills/xiaohongshu-publish/scripts/check_post_safety.sh /path/to/draft.md /path/to/source.svg
```

Flag and clean:

- absolute filesystem paths
- cookies, tokens, passwords, api keys
- phone numbers, emails, credentials
- internal markers like `@codex` and `@openclaw`
- internal project details that should not be public

If the scan passes, say no cleanup is required. If the scan fails, report exactly what categories would need cleanup before real publishing.

## Useful Commands

```bash
lsof -nP -iTCP:18060
bash /Users/skin/.openclaw/workspace/skills/xiaohongshu-publish/scripts/fetch_login_qr_png.sh
mcporter call --http-url http://127.0.0.1:18060/mcp --allow-http --tool check_login_status --output json
mcporter call --http-url http://127.0.0.1:18060/mcp --allow-http --tool get_login_qrcode --output json
mcporter call --http-url http://127.0.0.1:18060/mcp --allow-http --tool publish_content --args "$(cat /tmp/xhs_publish_args.json)" --output json
```
