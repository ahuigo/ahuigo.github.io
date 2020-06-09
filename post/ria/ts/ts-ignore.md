---
title: TS ignore type when import module
date: 2020-01-14
---
# TS ignore
对于tsline来说用 `/* tslint:disable-next-line */`

如果想让tsc 忽略下一行的错误

    // @ts-ignore
    import Brush from "@antv/g2-brush";

    // @ts-ignore: Unreachable code error
    console.log("hello");

## tsx ignore

    {/*
    // @ts-ignore */}
    <MyOtherComponent prop={123} />

    <Comp
        // @ts-ignore
        badProp={1}
    />
    <Comp
        // @ts-expect-error
        badProp={1}
    />