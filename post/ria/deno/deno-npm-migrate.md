---
title: deno npm migrate
date: 2022-08-15
private: true
---
# deno npm migrate
Some packages do not have own types, but you can specify their types:
## import npm

    // @deno-types="npm:@types/express@^4.17"
    import express from "npm:express@^4.17";

# node migrate
## import node
https://docs.deno.com/runtime/manual/node/node_specifiers

    import { readFileSync } from "node:fs";

    console.log(readFileSync("deno.json", { encoding: "utf8" }));

## process.env.NODE_ENV

    Deno.env.get('HOME')

## typeof window !== 'undefined'
typeof window.location !== 'undefined'
