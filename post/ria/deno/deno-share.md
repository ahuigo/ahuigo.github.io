---
title: 下一代前端框架介绍（ultra/fresh/alephjs）
date: 2022-12-06
private: true
---
# 下一代Deno前端框架介绍

## 现有node 框架的问题
![](/img/deno/2022-12-07-15-35-01.png)

## deno 的优点
与node 相比
1. 没有`node_modules`坑
2. 拥抱web标准(大趋势):
    - 支持标准化的importMap, esm 等
    - TC39 工作组
3. 原生支持ts/js/tsx
    - 完善ts类型系统支持
    - 不需要其它的转译工具, 不需要考虑复杂的编译配置
    - 制作包、运行包非常方便
    - 源代码极其干净、易读

4. 易于调试: 
    - 最接近原始代码
    - 没有async 调试的坑(react/umijs)
5. 提供原生的安全性: 包括网络、目录的读写控制

缺点:

1. 生态: 对npm 兼容不完善
2. 版本控制: 分两种 import_map与deps.ts, (前者是web标准).
    1. 不支持子包的import_map 如果要打包, 需要将依赖写到deps.ts

## node_module/npm 的替代
node_modules 替代
1. importMap - 相当于 web 版的package.json 
2. deps.ts - 定义子包自己的依赖关系

importMap.json

```
$ cat import_map.json 
{
  "imports": {
    "$fresh/": "file:///Users/ahui/www/fresh/",
    "preact": "https://esm.sh/preact@10.10.6",
    "preact/": "https://esm.sh/preact@10.10.6/",
    "preact-render-to-string": "https://esm.sh/preact-render-to-string@5.2.2?external=preact",
    "twind": "https://esm.sh/twind@0.16.17",
    "twind/": "https://esm.sh/twind@0.16.17/",
    "$/": "./",
    "$std/": "https://deno.land/std@0.150.0/"
  }
}
```

管理包 trex 工具（相当于npm/yarn）https://github.com/crewdevio/Trex

![](/img/deno/trex.png)

## 使用npm 包
两种方式
1. 使用esm.sh 转换
2. 使用npm 命名空间

```
// main.ts
import express from "npm:express@^4.18";
const app = express();

app.get("/", function (req, res) {
  res.send("Hello World");
});

app.listen(3000);
console.log("listening on http://localhost:3000/");
```
# freshjs 框架
## 框架特点
1. 支持island
2. 接近零开销构建
3. 0配置


## 框架结构
![](/img/fresh-island.png)

fresh 框架代码入口:
```
fresh/dev.ts: 

    import { start } from "$fresh/server.ts";
    import manifest from './fresh.gen.ts'

    await start(manifest);
        // fresh/server/mod.ts:
        const ctx = await ServerContext.fromManifest(routes, opts);
        await serve(ctx.handler(), opts);
            //std/http
            const server = new Server({
                port: options.port ?? 8000,
                handler,
            });
            return await server.listenAndServe();

```
![](/img/deno/fresh-code.png)

## 路由
洋葱路由
```
// routes/_middleware.ts
export const handler = [
  timing,
  logging,
];

async function timing(
  _req: Request,
  ctx: MiddlewareHandlerContext,
): Promise<Response> {
  const start = performance.now();
  const res = await ctx.next();
  const end = performance.now();
  const dur = (end - start).toFixed(1);
  res.headers.set("Server-Timing", `handler;dur=${dur}`);
  return res;
}

async function logging(
  req: Request,
  ctx: MiddlewareHandlerContext,
): Promise<Response> {
  const res = await ctx.next();
  console.log(`${req.method} ${req.url} ${res.status}`);
  return res;
}
```

## web 组件
web 组件有两种引入方式, 都使用标准的import 语法
1. 在server 端引入 
1. 在client 端引入 

对tsx组件来说，deno会自动转义为ts。

```
/** @jsx h */
import { h } from "preact";

export default function ({ name }: { name: string }) {
  return (
    <div class="flex-1 bg-gray-100">
        <h1>Hi! {name}. </h1>
        <div>This a react component from url!</div>
    </div>
  );
}
```
### 引入web组件的css
web组件相关的css有3种方案

1.使用全局的css(类似antd的做法)

2.使用标准的[css module 隔离](http://m:4500/?p=f~post~ria~deno~css-module#3.4.insert%20components%20styles)



## 代码调试
### chrome 调试server 端
启动调试端口

    deno run --inspect-brk --allow-read --allow-net https://deno.land/std@0.144.0/http/file_server.ts
    Debugger listening on ws://127.0.0.1:9229/ws/1e82c406-85a9-44ab-86b6-7341583480b1

开始chrome 调试:
1. open `chrome://inspect` and click `Inspect` next to target: `.js?[sm]` You might
2. go to "Sources" pane : type `cmd+p` and open up `file_server.ts` and add
   `a breakpoint` there;

3. you may find `file_server.ts?[sm]`, this is called **source map**


### vscode 调试server端
vscode 调试配置 launch.json

```
  "configurations": [
    {
      "request": "launch",
      "name": "run",
      "type": "pwa-node",
      "program": "${workspaceFolder}/examples/counter/main.ts",
      "cwd": "${workspaceFolder}",
      "runtimeExecutable": "deno",
      "runtimeArgs": [
        "run",
        "--inspect",
        "--inspect-brk",
        "-A"
      ],
      "smartStep": false,
      "attachSimplePort": 9229
    },
```

### chrome 调试tsx转译后代码

## 其它框架
https://momenta.feishu.cn/wiki/wikcndfi3kAImIkf0YjsDlyhThf
