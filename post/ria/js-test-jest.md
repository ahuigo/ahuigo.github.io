---
title: jest unittest
date: 2022-06-13
private: true
---
# jest unittest
jest 是最全面，0配置的测试框架

参考js-zfuncs 项目

## test func
    test('test add', async () => {
      function add(a: number, b: number) {
        return a + b;
      }
      expect(add(1, 2)).toBe(2);
    });

## Exception

    test("Test description", () => {
      const t = () => {
        throw new TypeError("UNKNOWN ERROR");
        throw "UNKNOWN ERROR";
      };
      expect(t).toThrow(TypeError);
      expect(t).toThrow("UNKNOWN ERROR");
    });

## 输出 console.log
默认正常是不会输出console.log 的, error时才会输出

method1：

    npm run test -- --silent=false
    npm test -- --silent=false

method2:

    $ vim ./jest.config.js
    module.exports = {
        //...
        verbose: true,
    };


# Test async
refer: https://jestjs.io/docs/asynchronous

### test then

    test('the data is peanut butter', () => {
        return fetchData().then(data => {
            expect(data).toBe('peanut butter');
        });
    },10);

### test catch
Make sure to add `expect.assertions` to verify that a certain number of assertions are called. 
Otherwise, a fulfilled promise would not fail the test.

    test('the fetch fails with an error', () => {
        expect.assertions(2);
        fetchData().catch(e => expect(e).toMatch('error'));
        fetchData().catch(e => expect(e).toMatch('error'));
    },10);


# jest with vscode
vscode 要安装jest 插件。

写完test case 后，jest 插件会提示可以点`click to run tests`的按钮。

如点击 run tests, 会执行：

    cross-env TS_NODE_TRANSPILE_ONLY=yes jest --env=node --passWithNoTests --testLocationInResults --json --useStderr --outputFile /var/folders/w6/gn/T/jest_runner_pmui_501_2.json --testNamePattern test config factory --no-coverage --reporters default --reporters /Users/ahui/.vscode/extensions/orta.vscode-jest-5.2.3/out/reporter.js --colors --watchAll=false --testPathPattern /home/user123/jsproj/src/conf/factory\.test\.ts

如有失败，可查看problems or `Test Results` or `Terminal`
