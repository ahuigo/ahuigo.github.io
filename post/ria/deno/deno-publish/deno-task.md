---
title: deno task
date: 2022-12-05
private: true
---
# deno task

## 指定deno.json
参考ultrajs/deno.json

    {
      "tasks": {
        "dev": "deno run -A tools/dev.ts", 
      },
      "importMap": "./importMap.dev.json"
    }

deno task/run 之类的命令默认配置文件: `deno.json`, 可手动指定其它配置比如 deno.dev.json

    # 注意deno task 的配置参数 不会传给 deno run
    deno task -c deno.dev.json dev
    deno task --config deno.dev.json dev

    # help
    deno task --help

## 指定importMap
在deno.json 中，可指定importMap

      "importMap": "./importMap.dev.json"