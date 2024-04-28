---
title: Unit Test
date: 2018-10-04
---
# Unit Test
node原生assert

    function sum(...rest) {
        var sum = 0;
        for (let n of rest) {
            sum += n;
        }
        return sum;
    };
    assert.strictEqual(sum(), 0);

## 测试框架
- mocha: 既可以在浏览器、Node.js环境下运行, 支持异步(js天生异步)
- jest: 最全面，零配置

# mocha
是JavaScript的一种单元测试框架，既可以在浏览器环境下运行，也可以在Node.js环境下运行

    $ package.json
    // 正式打包发布时，devDependencies的包不会被包含进来。
    {
        "dependencies": {},
        "devDependencies": {
            "mocha": "3.0.2"
        }
    }

## 测试用例
mocha默认会执行test目录下的所有测试，不要去改变默认目录

    package.json
    test/
        hello-test.js 

这里我们使用mocha默认的BDD-style的测试。describe可以任意嵌套，以便把相关测试看成一组测试
hello-test.js内容如下：

    const assert = require('assert');
    const sum = require('../hello');

    describe('#hello.js', () => {

        describe('#sum()', () => {
            it('sum() should return 0', () => {
                assert.strictEqual(sum(), 0);
            });

            it('sum(1) should return 1', () => {
                assert.strictEqual(sum(1), 1);
            });

            it('sum(1, 2) should return 3', () => {
                assert.strictEqual(sum(1, 2), 3);
            });

            it('sum(1, 2, 3) should return 6', () => {
                assert.strictEqual(sum(1, 2, 3), 6);
            });
        });
    });

## 运行测试

1. $ ./node_modules/mocha/bin/mocha
2. $ npm test
3. vscode

### npm test

    $ cat package.json
    "scripts": {
        "test": "mocha"
    },
    $ npm test

### vscode
我们在VS Code中创建配置文件.vscode/launch.json，然后编写两个配置选项：

    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Test",
                "type": "node",
                "request": "launch",
                "program": "${workspaceRoot}/node_modules/mocha/bin/_mocha",
                "stopOnEntry": false,
                "args": [],
                "cwd": "${workspaceRoot}",
                "preLaunchTask": null,
                "runtimeExecutable": null,
                "runtimeArgs": [
                    "--nolazy"
                ],
                "env": { "NODE_ENV": "test" },
                "sourceMaps": false,
            }
        ]
    }

注意:
1. 第一个配置选项Run是正常执行一个.js文件，
2. 第二个配置选项Test我们填入`_mocha`(不是`mocha`):
    1. `"program": "${workspaceRoot}/node_modules/mocha/bin/_mocha"`，
    2. 并设置env为`"NODE_ENV": "test"`，
3. 这样，就可以在VS Code中打开Debug面板，选择Test，运行，即可在Console面板中看到测试结果

## before/after
mocha提供了before、after、beforeEach和afterEach来实现这些功能。

我们把hello-test.js改为：

    const assert = require('assert');
    const sum = require('../hello');

    describe('#hello.js', () => {
        describe('#sum()', () => {
            before(function () {
                console.log('before:');
            });

            after(function () {
                console.log('after.');
            });

            beforeEach(function () {
                console.log('  beforeEach:');
            });

            afterEach(function () {
                console.log('  afterEach.');
            });
            ...

## http test(supertest) 用例
除了mocha外，我们还需要一个简单而强大的测试模块supertest(request)：

    {
        ...
        "devDependencies": {
            "mocha": "3.0.2",
            "supertest": "3.0.0"
        }
    }

运行npm install后，我们开始编写测试：

    // app-test.js
    const request = require('supertest'),
        app = require('../app');

    describe('#test koa app', () => {

        let server = app.listen(9900);

        describe('#test server', () => {

            it('#test GET /', async () => {
                let res = await request(server)
                    .get('/')                   //构造一个GET请求，发送给koa的应用，然后获得响应
                    .expect('Content-Type', /text\/html/)
                    .expect(200, '<h1>Hello, world!</h1>');
            });

            it('#test GET /path?name=Bob', async () => {
                let res = await request(server)
                    .get('/path?name=Bob')
                    .expect('Content-Type', /text\/html/)
                    .expect(200, '<h1>Hello, Bob!</h1>');
            });
        });
    });