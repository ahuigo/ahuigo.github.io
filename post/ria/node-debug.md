---
title: Node debug
date: 2018-09-15
---
# Node debug
《Node.js 调试指南》https://github.com/nswbmw/node-in-debugging
## 开源项目测试
每个项目的测试方法都不一样：
1. 有的写的npm run test:unit
2. 有的写在.github/workflows/*
3. 有的用的 mocha、jest
3. 可用 karma.conf.js 来提供测试browser环境：它可以调用`frameworks: ['mocha', 'chai-sinon'],`等

## karma 调试
### karma console.log
这个 karma.conf.js 文件中的代码片段重写了 process.stdout.write 方法，用于定制化输出日志。
如果要打印, 就用它来代替console.log

    process.stdout.write('This is a message\n');

### karma 断点调试
chatgpt　说的(我还没有验证过)：怎么在vscode 中对karma 做断点调试？

karma.conf.js 中开启sourcemap

    preprocessors: {
    '**/*.js': ['sourcemap']
    }

2.vscode

      "type": "chrome",
      "request": "launch",
      "name": "Karma Tests",
      "url": "http://localhost:9876/debug.html",
      "webRoot": "${workspaceFolder}",
      "sourceMaps": true,
      "sourceMapPathOverrides": {
        "webpack:///*": "${webRoot}/*"
      }

3.chrome 安装debugger for chrome 扩展


## mocha 调试

怎么单步调试 `npx tsc -p test/ts/ && npx mocha --require @babel/register test/ts/VNode-test.js `
chatgpt 会告诉你：

    // launch.json
       {
      "type": "node",
      "request": "launch",
      "name": "Mocha Tests",
      "program": "${workspaceFolder}/node_modules/mocha/bin/_mocha",
      "args": [
        "--require",
        "@babel/register",
        "test/ts/VNode-test.js"
      ],
      "console": "integratedTerminal",
      "internalConsoleOptions": "openOnSessionStart"
    }

### mocha vsc插件：
workspac配置setting.json (我没有走通，调试preact 找不到包，它自己是包)

    "mochaExplorer.files": "test/**/*.js",
    "mochaExplorer.require": ["@babel/register"],
    "mochaExplorer.esmLoader": true,
    "mochaExplorer.pkgFile": "./package.json",

