---
title: ts 模板字符串
date: 2023-03-21
private: true
---
# ts 字符串
## 模板字符串
    type EventName<T extends string> = `${T}Changed`;
    type Concat<S1 extends string, S2 extends string> = `${S1}${S2}`;
    type ToString<T extends string | number | boolean | bigint> = `${T}`;
    type T0 = EventName<'foo'>;  // 'fooChanged'
    type T1 = EventName<'foo' | 'bar' | 'baz'>;  // 'fooChanged' | 'barChanged' | 'bazChanged'
    type T2 = Concat<'Hello', 'World'>;  // 'HelloWorld'
    type T3 = `${'top' | 'bottom'}-${'left' | 'right'}`;  // 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right'
    type T4 = ToString<'abc' | 42 | true | -1234n>;  // 'abc' | '42' | 'true' | '-1234'

## 模板字符串与infer
一般是与条件语句结合，使用infer获取源字符串中自己需要的部分,
规则类似regex

    type MatchPair<S extends string> = S extends `[${infer A},${infer B}]` ? [A, B] : unknown;

    type T20 = MatchPair<'[1,2]'>;  // ['1', '2']
    type T21 = MatchPair<'[foo,bar]'>;  // ['foo', 'bar']
    type T22 = MatchPair<' [1,2]'>;  // unknown
    type T23 = MatchPair<'[123]'>;  // unknown
    type T24 = MatchPair<'[1,2,3,4]'>;  // ['1', '2,3,4']

    type FirstTwoAndRest<S extends string> = S extends `${infer A}${infer B}${infer R}` ? [`${A}${B}`, R] : unknown;

    type T25 = FirstTwoAndRest<'abcde'>;  // ['ab', 'cde']
    type T26 = FirstTwoAndRest<'ab'>;  // ['ab', '']
    type T27 = FirstTwoAndRest<'a'>;  // unknown


# Reference 
- 作者：度123 链接：https://juejin.cn/post/7000560464786620423