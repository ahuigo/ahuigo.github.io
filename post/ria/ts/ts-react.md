---
title: ts react 泛型组件
date: 2020-06-08
private: true
---
# ts react generic泛型组件
Refer: https://www.cnblogs.com/Wayou/p/react_typescript_generic_components.html

    interface Props<T> {
        content: T;
    }
    function Foo<T>(props: Props<T>) {
        return <div> {props.content}</div>;
    }

使用

    <Foo content={42}></Foo>
    <Foo<string> content={"hello"}></Foo>