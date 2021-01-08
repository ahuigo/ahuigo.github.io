---
title: puppeteer login
date: 2020-12-29
private: true
---
# puppeteer login example
https://www.codota.com/code/javascript/functions/puppeteer/Page/click

```ts
(async () => {
 const browser = await puppeteer.launch({ headless: true })
 const page = await browser.newPage()
 await page.goto('https://github.com/login', { waitUntil: 'networkidle2' })
 await page.type('#login_field', process.env.GITHUB_USER)
 await page.type('#password', process.env.GITHUB_PWD)
 await page.type('input[placeholder="Enter a title"]', 'title')
//  document.querySelector('input[placeholder="Enter a title"]')
//  document.querySelector('input[placeholder="Enter a title"][type="text"]')
 await page.click('[name="commit"]')
//  await page.waitForNavigation()
 await page.waitForSelector('h4.cart-items-header')
 await page.screenshot({ path: screenshot })
 browser.close()
 console.log('See screenshot: ' + screenshot)
})()
```

# wait request

## Wait for the element to appear in DOM.
wait until the element is found and will throw an error otherwise.

    await page.waitFor('.CL1');
    await page.waitForSelector('.vss');

## waitUntil 
e.g.

    await page.goto(url, {waitUntil: 'networkidle2'});
    await page.waitForNavigation({ waitUntil: 'networkidle0' });

1. load - consider navigation to be finished when the load event is fired.
1. domcontentloaded - consider navigation to be finished when the DOMContentLoaded event is fired.
1. networkidle0 - consider navigation to be finished when there are no more than 0 network connections for at least 500 ms.
1. networkidle2 - consider navigation to be finished when there are no more than 2 network connections for at least 500 ms.

# selector
right click and click Copy > Copy selector

## selector with XPATH(innerText)

    const [button] = await page.$x("//button[contains(., 'Button text')]");
    if (button) {
        await button.click();
    }

复杂一点的XPath:  父子

    const [button] = await page.$x("//div[@class='elements']/button[contains(., 'Button text')]");

复杂一点的XPath: 所有子孙

    const [link] = await page.$x('//*[@class="elements"]//a[text()="Button text"]');
    el && (await el.click());


## selector handler
Instead of

    await page.evaluate(() => document.querySelector('#my-sweet-id').innerText)
    await page.evaluate(() => document.querySelector('#my-sweet-id').innerHTML)

You can use page.$eval:

    await page.$eval('#my-sweet-id', e => e.innerText);
    await page.$eval('#my-sweet-id', e => e.innerHTML);

## get selector via $

    const element = await page.$(".scrape");

# dom evaluate
## page.evaluate

    const element = await page.$(".scrape");
    const text = await page.evaluate(element => element.textContent, element);

# open page
## open post page
how do POST request in puppeteer?

    // Create browser instance, and give it a first tab
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    // Allows you to intercept a request; must appear before
    // your first page.goto()
    await page.setRequestInterception(true);

    // Request intercept handler... will be triggered with 
    // each page.goto() statement
    page.on('request', interceptedRequest => {

        // Here, is where you change the request method and 
        // add your post data
        var data = {
            'method': 'POST',
            'postData': 'paramFoo=valueBar&paramThis=valueThat'
        };

        // Request modified... finish sending! 
        interceptedRequest.continue(data);
    });

    // Navigate, trigger the intercept, and resolve the response
    const response = await page.goto('https://www.example.com/search');     
    const responseBody = await response.text();
    console.log(responseBody);

    // Close the browser - done! 
    await browser.close();