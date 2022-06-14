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