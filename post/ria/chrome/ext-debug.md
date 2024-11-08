---
title: chrome extensions debug
date: 2024-11-04
private: true
---
# deubg extension
## debug workers
1. open `chrome://extensions`
2. click `detail`
3. Inspect views

## debug popup
1. Right click `extension` button
2. click `inspect Popup`

## debug content_scripts
Content scripts' console.log messages are shown in the web page's console instead of the background page's inspector.

  "content_scripts": [
    {
      "matches": ["<all_urls>"],
      "js": ["document_start.js"],
      "run_at": "document_start" 
    },