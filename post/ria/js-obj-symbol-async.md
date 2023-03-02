---
title: symbol iterator
date: 2023-03-01
private: true
---
# symbol iterator
    const iterable1 = {};

    iterable1[Symbol.iterator] = function* () {
        yield 1;
        yield 2;
        yield 3;
    };

    console.log([...iterable1]);
    // Expected output: Array [1, 2, 3]

# Symbol.asyncIterator
这个magic方法可以实现

    const delayedResponses = {
      delays: [500, 1300, 3500],

      wait(delay) {
        return new Promise(resolve => {
          setTimeout(resolve, delay);
        });
      },

      async *[Symbol.asyncIterator]() {
        for (const delay of this.delays) {
          await this.wait(delay);
          yield `Delayed response for ${delay} milliseconds`;
        }
      },
    };

    for await (const response of delayedResponses) {
        console.log(response);
    }