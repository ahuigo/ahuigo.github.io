---
title: webspider
date: 2018-10-04
---
# webspider
Python 3网络爬虫开发实战 
https://germey.gitbooks.io/python3webspider/1.2.2-Selenium%E7%9A%84%E5%AE%89%E8%A3%85.html

# Puppeteer
Puppeteer 是 Google Chrome 团队官方的无界面（Headless）Chrome 工具。正因为这个官方声明，许多业内自动化测试库都已经停止维护，包括 PhantomJS。Selenium. Chrome 作为浏览器市场的领头羊，Chrome Headless 必将成为 web 应用 自动化测试 的行业标杆。 

## Usage
Puppeteer 与 Chrome Headless —— 从入门到爬虫
https://github.com/csbun/thal

## install

    PUPPETEER_DOWNLOAD_HOST=https://storage.googleapis.com.cnpmjs.org npm i --save puppeteer

## browser
    const puppeteer = require('puppeteer');
    const browser = await puppeteer.launch({headless: true});

## page

    const page = await browser.newPage();
    await page.goto('https://github.com');
    await page.waitFor(2*1000);
    await page.screenshot({path: 'screenshots/github.png'});

    page = browser.pages()[0]

## selector

    name = await page.evaluate((name,password) => {
        return document.querySelector(name).value();
    }, '#name', '#password');
    

## listener

### add
    log = console.log
    page.on('request', request => {
        ['xhr','fetch'].includes(request.resourceType())
        // do something
    });
    listener = page.on('response', response => {
        const isXhr = ['xhr','fetch'].includes(response.request().resourceType())
        if (isXhr){
            log(response.url());
            //response.text().then(log)
        }
    })

### remove 
    page.removeAllListeners()
    page.removeListener(listener)
