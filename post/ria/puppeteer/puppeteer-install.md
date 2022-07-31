---
title: puppeteer install
date: 2022-06-24
private: true
---

# chrome

## chrome executablePath

> You can browse `chrome://version/` in chrome, and find `executableFilePath`
> set executablePath: '/Applications/Google Chrome.app/...'


## launch chrome
refer to deno's fresh source code:

    const browser = await puppeteer.launch({
        executablePath: "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome",
        headless: false,
        args: ["--start-maximized","--no-sandbox"]
    });
    const page = await browser.newPage();
