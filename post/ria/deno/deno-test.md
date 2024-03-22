---
title: deno test
date: 2023-01-12
private: true
---
# deno test
> Refer: https://deno.land/manual@v1.29.2/basics/testing

    import { assertEquals } from "https://deno.land/std@0.171.0/testing/asserts.ts";

    // Compact form: name and function
    Deno.test("hello world #1", () => {
        const x = 1 + 2;
        assertEquals(x, 3);
    });

## assert

    assert("hello", msg="")
    assertEquals(x, 3, msg?:string);
    assertExists(actual, msg?:string)
    assertArrayIncludes(actual, expected, msg="")
    assertMatch(actual:string, regex:string)
    assertThrows(fn)
    assertRejects(fn)

## Writing Tests

    / Compact form: name and function
    Deno.test("hello world #1", () => {
      const x = 1 + 2;
      assertEquals(x, 3);
    });

    // Compact form: named function.
    Deno.test(function helloWorld3() {
      const x = 1 + 2;
      assertEquals(x, 3);
    });

    // Longer form: test definition.
    Deno.test({
      name: "hello world #2",
      fn: () => {
        const x = 1 + 2;
        assertEquals(x, 3);
      },
    });

## run test

    # Run all tests in the current directory and all sub-directories
    deno test

    # Run all tests in the util directory
    deno test util/

    # Run just my_test.ts
    deno test my_test.ts

    # Run test modules in parallel
    deno test --parallel

for help:

    deno help test

### filter test

    deno test --filter "/test-*\d/" tests/

### failing test
    deno test --fail-fast

### run test with args
Pass additional arguments to the test file

    deno test my_test.ts -- -e --foo --bar

### config test: include

    //deno.json
    "test": {
      "files": {
        "include": ["src/","lib/a.test.ts"],
        "exclude": ["src/testdata/"]
      }
    }

## test debug with vscode
以fresh 为例

        {
            "request": "launch",
            "name": "Launch Program",
            "type": "node",
            "program": "${workspaceFolder}/main.ts",
            "cwd": "${workspaceFolder}",
            "runtimeExecutable": "/opt/homebrew/bin/deno",
            "runtimeArgs": [
                "run",
                "--inspect-wait",
                "--allow-all"
            ],
            "attachSimplePort": 9229
        }


# Test Coverage
https://deno.land/manual@v1.29.2/basics/testing/coverage

    deno test --coverage=cov_profile
    deno coverage cov_profile

# Test Sanitizers
## Sanitize resource
资源默认是要回收的，除非这样：

    Deno.test({
      name: "leaky resource test",
      async fn() {
        await Deno.open("hello.txt");
      },
      sanitizeResources: false,
    });

## Sanitize exit
The exit sanitizer which ensures that tested code doesn't call `Deno.exit()`. 如果想让Deno.exit生效，则需要关闭 sanitizeExit

    Deno.test({
      name: "false success",
      fn() {
        Deno.exit(0);
      },
      sanitizeExit: false,
    });

    // This test never runs, because the process exits during "false success" test
    Deno.test({
      name: "failing test",
      fn() {
        throw new Error("this test fails");
      },
    });

## sanitizeOps
**Check** that the number of async completed ops after the test is the same as number of dispatched ops. Defaults to true.
