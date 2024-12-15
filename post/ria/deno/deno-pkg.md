---
title: deno pkg
date: 2024-03-31
private: true
---
# deno pkg
## deno add
    deno add jsr:@std/path
    deno add npm:react
    deno add npm:ahooks
    deno add jsr:@std/path jsr:@std/assert npm:chalk 
## deno dependency
pkg guideline:

1. 每个pkg import时，建议使用: pkg@v2 类似golang的 semver 规范