---
title: Node argv
date: 2019-06-25
private:
---
# Node argv

    #!/usr/bin/env node
    // print process.argv
    process.argv.forEach(function (val, index, array) {
        console.log(index + ': ' + val);
    });

This will generate:

    $ ./test.js one two=three four
    0: node
    1: /Users/mjr/work/node/test.js
    2: one
    3: two=three
    4: four