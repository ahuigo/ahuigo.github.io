---
title: deno debug
date: 2022-06-21
private: true
---

# deno debug

https://deno.land/manual/getting_started/debugging_your_code

# vscode debug

how to disable **Skipped by smartStep**

# chrome

## run deno

    deno run --inspect-brk --allow-read --allow-net https://deno.land/std@0.144.0/http/file_server.ts
    Debugger listening on ws://127.0.0.1:9229/ws/1e82c406-85a9-44ab-86b6-7341583480b1

## in chrome

1. open chrome://inspect and click `Inspect` next to target: .js?[sm] You might
   notice that DevTools pauses execution on the first line of constants.ts

2. go to "Sources" pane : type `cmd+p` and open up `file_server.ts` and add
   `a breakpoint` there;

3. you may find `file_server.ts?[sm]`, this is called **source map**
