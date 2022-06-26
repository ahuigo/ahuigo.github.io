---
title: deno pkg
date: 2022-06-20
private: true
---

# pkg init

A package/project should contain

1. deno.json

## deno.json

    {
        "tasks": {
            "start": "deno run -A --watch=static/,routes/,islands/ --no-check dev.ts"
        },
        "importMap": "./import_map.json"
    }

## import_map.json

    {
        "imports": {
            "$fresh/": "https://raw.githubusercontent.com/lucacasonato/fresh/main/"
            "$fresh/": "../"
        }
    }
