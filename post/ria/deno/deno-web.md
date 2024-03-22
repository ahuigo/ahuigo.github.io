---
title: deno web Runtime
date: 2024-03-13
private: true
---
# deno web Runtime
https://docs.deno.com/runtime/manual/runtime/location_api

    // deno run --location https://example.com/path main.ts
    console.log(location.href);//ok
    location.pathname = "./foo"; // error: Uncaught NotSupportedError