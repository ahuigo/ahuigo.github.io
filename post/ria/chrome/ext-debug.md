---
title: Chrome Extensions Debug
date: 2024-11-04
private: true
---
# Load Extension
Extension that you download from web store is packaged up as `.crx`. For development, chrome gives a quick way to loading up your working directory for testing

1. Visit `chrome://extensions`
2. Ensure that the `Developer mode`
3. Click `Load unpacked extension`

## Storage Location for Packed Extensions
Navigate to chrome://version/ and look for **Profile Path**, it is your default directory where all the `extensions, apps, themes` are stored.

    # Mac OSX
    ~/Library/Application\ Support/Google/Chrome/Default/Extensions

# Debug Extension

# debug
## Debug Background && Debug workers
重新cmd+r 加载extension, 清除缓存、dns、重启浏览器.. 
1. open `chrome://extensions`
2. click `detail`
3. `Inspect views`

注意排除其它扩展的干扰，可以使用`incognito` 模式

## Debug Popup
1. Right click `extension` button
2. click `inspect popup`

## Debug Content Scripts
Content scripts' console.log messages are shown in the web page's console instead of the background page's inspector.

  "content_scripts": [
    {
      "matches": ["<all_urls>"],
      "js": ["document_start.js"],
      "run_at": "document_start" 
    },
`