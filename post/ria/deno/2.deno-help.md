---
title: deno help
date: 2022-07-11
private: true
---
# demo subcommand

    deno help
    deno run
    deno test

# deno help
3 methods: 

    # Using the subcommand.
    deno help

    # Using the short flag -- outputs the same as above.
    deno -h

    # Using the long flag -- outputs more detailed help text where available.
    deno --help

## help subcommand: 

    deno help bundle
    deno bundle -h
    deno bundle --help

# deno doc
    $ deno doc add.ts
    function add(x: number, y: number): number
        Adds x and y. @param {number} x @param {number} y @returns {number} Sum of x and y