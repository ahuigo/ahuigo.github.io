---
title: deno test mock
date: 2023-01-12
private: true
---
# mock
 deno 提供了以下mock 方法: https://deno.land/manual@v1.29.2/basics/testing/mocking
 
## mock spy
    import { assertSpyCall, assertSpyCalls, spy, } from "https://deno.land/std@0.171.0/testing/mock.ts";
    // 要测试的对象
    import { multiply, square} from "https://deno.land/std@0.171.0/testing/mock_examples/parameter_injection.ts";

    //mock
    const multiplySpy = spy(multiply);
    //注入mock
    assertEquals(square(multiplySpy, 5), 25);
    //断言mock 调用
    assertSpyCall(multiplySpy, 0, { args: [5, 5], returned: 25, });

## mock internal
> 内部方法必须可修改，否则没法mock

如果不能注入mock方法，那么需要修改内方法，执行完毕后再恢复内部方法：

    import { _internals, square, } from "https://deno.land/std@0.171.0/testing/mock_examples/internals_injection.ts";
    const multiplySpy = spy(_internals, "multiply"); // 会mock内部的multiply
    try {
      assertEquals(square(5), 25);  //square 调用mock后的_internals.multiply
    } finally {
      // unwraps the multiply method on the _internals object
      multiplySpy.restore();
    }

### Stubbing
mock 函数的输出, 比如我们想让内部的`randomInt`生成正、负数。

    const randomIntStub = stub(_internals, "randomInt", returnsNext([-3, 3]));

## Faking time
像setInterval 依赖系统时间，导致测试很慢。我们可以mock 它

    // https://deno.land/std@0.171.0/testing/mock_examples/interval_test.ts
    import {
      assertSpyCalls,
      spy,
    } from "https://deno.land/std@0.171.0/testing/mock.ts";
    import { FakeTime } from "https://deno.land/std@0.171.0/testing/time.ts";
    import { secondInterval } from "https://deno.land/std@0.171.0/testing/mock_examples/interval.ts";
    
    Deno.test("secondInterval calls callback every second and stops after being cleared", () => {
      const time = new FakeTime();
    
      try {
        const cb = spy();
        const intervalId = secondInterval(cb);
        assertSpyCalls(cb, 0);
        time.tick(500);
        assertSpyCalls(cb, 0);
        time.tick(500);
        assertSpyCalls(cb, 1);
        time.tick(3500);
        assertSpyCalls(cb, 4);
    
        clearInterval(intervalId);
        time.tick(1000);
        assertSpyCalls(cb, 4);
      } finally {
        time.restore();
      }