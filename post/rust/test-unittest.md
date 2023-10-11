---
title: rust unittest
date: 2023-10-04
private: true
---
# rust unittest
## 测试的规则：
参考：src/unittest
1. 文件本身要用 mod.ts声明要导出的文件, 比如`mod foo`
1. main.rs 要声明使用mod：`mod unittest;`
1. 函数名`test_xxx`开头(不是强制), 且标识`#[test]`
1. 文件建议用`xxx_test.rs`结尾(不是强制)

注意，mod.rs 除了mod声明外，文件本身也可定义函数`fn foo()`，以及`fn test_foo()`

## 执行测试
Usage: 

    cargo test [OPTIONS] [TESTNAME] [-- [args]...]
    Arguments:
        OPTIONS
            --package 和 --bin 可省略
        [TESTNAME]  
            If specified, only run tests containing this string in their names
            指定要测试的mod（使用rust namespace path）
        [args]...   Arguments for the test binary

示例:

    cargo test --package myrustlib --bin myrustlib unittest::foo_test::tests --  --nocapture
    cargo test unittest::foo_test::tests -- --nocapture

args说明：`cargo test -- --help`

    --nocapture
        相当于go test 的 -v, 它会打印输出
    --show-output   
        Show captured stdout of **successful** tests

    