# debug pwa
## demo 
    js-lib/pwa
## error info
In Chrome, F12 and see 
1. `Application->Mannifest` for error message
1. `Application->Service-worker` for error message

## no show install actions?
possible reasons:
1. no service worker
1. no icons

## open chrome dev tool alongside window
1. access https url like: https://pwa.app/
2. press: `alt+cmd+i` or `F12` 
3. click `to open this link choose an app` in browser's input url bar

## debug service worker
https://www.chromium.org/blink/serviceworker/service-worker-faq/

A: From a page on the same origin, go to `Developer Tools > Application > Service Workers`

You can also use **chrome://inspect/#service-workers** to find all running service workers.

To poke around at the internals (usually only Chromium developers should need this), visit chrome://serviceworker-internals .