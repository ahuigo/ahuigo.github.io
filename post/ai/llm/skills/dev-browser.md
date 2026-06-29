---
name: dev-browser
description: Interacting with web browsers, allowing you to read, create, edit, import, search, and download content from various web sources. Supports headless browsing, connecting to running Chrome instances.
---
# dev-browser

## Installation

```
npm install -g dev-browser
dev-browser install    # installs Playwright + Chromium(如果只用--connect模式可不安装)
```

## Using dev-browser
After installing, you can use cli `dev-browser --help` to see a full LLM usage guide with examples and API reference. 

它支持两种模式: 
- connect模式: 连接现有的Chrome实例，如果连接不上提醒用户先开启`chrome://inspect/#remote-debugging`
- Standalone: 启动隔离的实例

请优先尝试`--connect`模式，这样对用户更友好（复用已经登录的cookie）

```
# Connect to your running Chrome (enable at chrome://inspect/#remote-debugging)
dev-browser --connect <<'EOF'
const tabs = await browser.listPages();
console.log(JSON.stringify(tabs, null, 2));
EOF

# Launch a headless browser and run a script
dev-browser --headless <<'EOF'
const page = await browser.newPage();//Note: newPage(url)中传url会被忽略
await page.goto("https://baidu.com", { waitUntil: "domcontentloaded" });
console.log(await page.title());
EOF

```

## 截图时必须减小图大小: 请使用jpeg + quality(15)+scale(css)
```
dev-browser --connect <<'EOF'
const page = await browser.newPage();
await page.goto("https://bing.com", { waitUntil: "domcontentloaded" });
await page.waitForTimeout(3000);
await page.screenshot({ path: "bing_compact.jpg", type: "jpeg", quality: 15, fullPage: true, scale: "css" });
console.log("Screenshot saved");
EOF
```
