# skills
## browser
dev-browser
    优点：本地可控、免费、轻量、会话持久、Claude 生态无缝
    缺点：无反爬、无 CAPTCHA、仅本地、不适合高并发
browserbase
    优点：企业级稳定、强反爬、自动 CAPTCHA、云端托管、无需运维
    缺点：商业付费、闭源、依赖第三方、成本随用量上升
browser-use
    优点：开源免费、AI 智能、视觉理解、自主纠错、社区活跃
    缺点：本地资源占用、需配置 LLM、复杂任务可能出错、生产需优化

## dev-browser
- 默认：Standalone（隔离）
- connect模式: 先开启chrome://inspect/#remote-debugging 

```
npm install -g dev-browser
dev-browser install    # installs Playwright + Chromium(optional)
```
### Using with AI agents
After installing, just tell your agent to run dev-browser --help — the help output includes a full LLM usage guide with examples and API reference. No plugin or skill installation needed.

    # Launch a headless browser and run a script
    dev-browser --headless <<'EOF'
    const page = await browser.getPage("main");// 不用newPage() 避免重新创建
    await page.goto("https://example.com", { waitUntil: "domcontentloaded" });
    console.log(await page.title());
    EOF

    # Connect to your running Chrome (enable at chrome://inspect/#remote-debugging)
    dev-browser --connect <<'EOF'
    const tabs = await browser.listPages();
    console.log(JSON.stringify(tabs, null, 2));
    EOF

vi CLAUDE.md:
```
# access browser
dev-browser --help — the help output includes a full LLM usage guide with examples and API reference. 
```

## agnes-skill image/video
这个描述了agnes 文生image/video 的脚本（调用modelagnes-image-2.1-flash, agnes-video-v2.0）

> 帮我安装这个 Skill 在当前项目。https://github.com/Yacey/agnes-ai-generation-skill

使用 Anthropic 兼容 API 格式时，在请求体中添加 thinking 字段(enabled|adaptive):https://agnes-ai.com/zh-Hans/docs/agnes-20-flash
```
  env:{ "CLAUDE_CODE_EXTRA_BODY": "{\"thinking\":{\"type\":\"adaptive\",\"budget_tokens\": 2048}}", }
```