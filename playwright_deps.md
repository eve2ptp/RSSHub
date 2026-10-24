Helpful Information

Error Message:
Error: browserType.launch: Executable doesn't exist at /home/mo/.cache/ms-playwright/chromium_headless_shell-1248/chrome-headless-shell-linux64/chrome-headless-shell
╔════════════════════════════════════════════════════════════╗
║ Looks like Playwright was just installed or updated. ║
║ Please run the following command to download new browsers: ║
║ ║
║ pnpm exec playwright install ║
║ ║
║ <3 Patchright Team ║
╚════════════════════════════════════════════════════════════╝

Route: /jable/search/:query

Full Route: /jable/search/みなみ羽琉

Node Version: v24.13.0

Git Hash: 15bc0ff0

Git Date: Sat, 24 Oct 2026 06:18:51 GMT

Fix:

```sh
# system
sudo apt-get update
sudo apt-get install -y libgtk-4-1 libgraphene-1.0-0 libwoff1 libvpx7 libevent-2.1-7 libopus0 gstreamer1.0-libav gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly libflite1 libavif13 libharfbuzz-icu0
npx playwright install --with-deps chromium

# pnpm
pnpm add -D playwright
pnpm exec playwright install chromium
```
