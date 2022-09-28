---
title: react dom api
date: 2022-09-29
private: true
---
# api
## vnode = createElement(Com, props)

> React.createElement 就是Preact.h
> React 叫vnode 为element

vnode is also named as element:

    vnode = <Component {...props}>
    vnode = h(Component, props)
    vnode = React.createElement(Component, props, ...children) // children is vnode or primitive values(like strings or numbers, React will wrap it with TEXT_ELEMENT)
    vnode = React.createElement("h1", {style:{color:"green"}}, "submit")
         = {
            type: "h1",
            props: {
                style: {color:"green"},
                children: "submit",
            },
        }

### 使用自定义的createElement
告诉Babel or Deno 使用其它的自定义 createElement: https://pomb.us/build-your-own-react/

    /** @jsx Didact.createElement */
    const element = (
    <div id="foo">
        <a>bar</a>
        <b />
    </div>
    )

在fresh 常看到

    /** @jsx h */
    import { h } from "preact";

## render vnode/element
    ReactDOM.render(<h1 {...props}>title</h1>, container=document.getElementById('root'))

使用 render 转为 vanilla JS，生成真正的node dom

    const node = document.createElement(element.type)
    node["style"] = element.props.style

    const text = document.createTextNode("")
    text["nodeValue"] = element.props.children

    node.appendChild(text)
    container.appendChild(node)

render 内部

    function render(element, container) {
      const dom = element.type == "TEXT_ELEMENT"
        ? document.createTextNode("")
        : document.createElement(element.type)

      // props
      const isProperty = key => key !== "children"
      Object.keys(element.props)
         .filter(isProperty)
         .forEach(name => {
         dom[name] = element.props[name]
         })
    
      // children​
      element.props.children.forEach(child =>
        render(child, dom)
      )
    ​
      container.appendChild(dom)
    }
​

## CloneElement
element 就是vnode

    newVnode = React.cloneElement( element, props, [...children] )
    # 等同于：
    newVnode = <element.type {...element.props} {...props}>{children}</element.type>

可以利用它来实现 `Form.Field` 给children 元素增加`defaultValue, setValue`
    React.cloneElement(
      element,
      [props],
      [...children]
    )

# dom 类型
> https://stackoverflow.com/questions/58123398/when-to-use-jsx-element-vs-reactnode-vs-reactelement 解释得很清楚
## ReactElement
A ReactElement is an object with a type and props.

    interface ReactElement<P = any, T extends string | JSXElementConstructor<any> = string | JSXElementConstructor<any>> {
        type: T;
        props: P;
        key: Key | null;
    }

## JSX.Element
JSX.Element is a ReactElement, with the generic type for props and type being any. 

    declare global {
        namespace JSX {
            interface Element extends React.ReactElement<any, any> { }
        }
    }

By example:

    <p> // <- ReactElement = JSX.Element
        <Custom> // <- ReactElement = JSX.Element
            {true && "test"} // <- ReactNode
        </Custom>
    </p>

## ReactNode(超集)
A ReactNode is a ReactElement, a ReactFragment, a string, a number or an array of ReactNodes, or null, or undefined, or a boolean:

    type ReactText = string | number;
    type ReactChild = ReactElement | ReactText;

    interface ReactNodeArray extends Array<ReactNode> {}
    type ReactFragment = {} | ReactNodeArray;

    type ReactNode = ReactChild | ReactFragment | ReactPortal | boolean | null | undefined;

# References
https://pomb.us/build-your-own-react/