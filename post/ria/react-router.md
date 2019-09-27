---
title: React router
date: 2019-08-16
private:
---
# React Redirect
https://reacttraining.com/react-router/web/guides/basic-components

## Redirect Dom
It should be redered as dom 

    import React from 'react'
    import  { Redirect } from 'react-router-dom'

    const ProtectedComponent = () => {
        if (authFails)
            return <Redirect to='/login'  />
        }
        return <div> My Protected Component </div>
    }

default page

    <Redirect from="/" to="/invoices/dashboard" />

## via props.history push
> 注意不是原生的history.pushState


    myFunction() {
        addSomeStuff()
        this.props.history.push('/path')
    }

In order to have access to history, you can wrap your component with an HOC called `withRouter` when you wrap your component with it, it passes match location and history props. 

If your component is a child of <Route /> component, I mean if it is something like `<Route path='/path' component={myComponent} />` you don't have to wrap your component with `withRouter <Route />` passes match location and history to its child.

## Link
you can use <Link /> component

    <Link to='/path' > some stuff </Link>

# Router
react 提供了两种 Router: HashRouter, BrowserRouter

## Route

    import React from "react";
    import { BrowserRouter as Router, Route, Link } from "react-router-dom";

    function Index() {
      return <h2>Index</h2>;
    }

    function About() {
      return <h2>About</h2>;
    }

    export default function App() {
      return (
        <Router>
              <ul>
                <li> <Link to="/">Home</Link> </li>
                <li> <Link to="/about/">About</Link> </li>
              </ul>

            <Route path="/" exact component={Index} />
            <Route path="/about" exact component={About} />
        </Router>
      );
    }

如果查看源码react-router/esm/react-router.js 中的matchPath中的regexp 会发现

对于上面的例子，加`exact` 时，使用完全匹配. 


    /^\/?$/i
    /^\/about(\/)?$/i

如果不加exact, 会使用最左匹配. 

    /^\//i
    /^\/about(\/|$)/i

如果无path:

    // when location = { pathname: '/about' }
    <Route path='/about' component={About}/> // renders <About/>
    <Route path='/contact' component={Contact}/> // renders null
    <Route component={Always}/> // renders <Always/>

## Route match与嵌套
我们需要参数:

    match.path 如：/topics/:id
    match.url 如：/topics/id1
    match.params.id 

e.g.

    <Route path="/topics" component={Topics} />
    function Topics({ match }) {
        return (
        <div>
            <ul>
                <li>
                <Link to={`${match.url}/id1`}>Components</Link>
                </li>
                <li>
                <Link to={`${match.url}/id2`}>Props v. State</Link>
                </li>
            </ul>

            <Route path={`${match.path}/:id`} component={Topic} />
        </div>
        )
    }
    function Topic({ match }) {
        return <h3>Requested Param: {match.params.id}</h3>;
    }

## Route Rendering Props
Route 有3种props: component, render, and children(很少用). 
> props are some router specific things that look like { match, location, history }.

注意:
1.You should not use the component prop with an inline function to pass in-scope variables because you will get **undesired component unmounts/remounts**.(性能问题)
2.Use render for inline function instead.

      {/* these are good */}
      <Route path="/about"
        render={props => <About {...props} extra={someVariable} />}
      />
      {/* do not do this */}
      <Route path="/contact"
        component={props => <Contact {...props} extra={someVariable} />}
      />

## NavLink
The `<NavLink>` is a special type of `<Link>` that can style itself as “active” when its to prop matches the current location.

    <NavLink to="/react" activeClassName="hurray hurray2"> React </NavLink>

# Code Split
 `@babel/plugin-syntax-dynamic-import`: allows Babel to parse **dynamic imports** 
so webpack  bundle code as a code split. 

    //Your .babelrc should look something like this:
    {
        "presets": ["@babel/preset-react"],
        "plugins": ["@babel/plugin-syntax-dynamic-import"]
    }

`loadable-components` is 类似React.lazy 用于dynamic import:

    import loadable from '@loadable/component'
    import Loading from "./Loading";

    const LoadableComponent = loadable(() => import('./Dashboard'), {
        fallback: Loading,
    })

    export default class LoadableDashboard extends React.Component {
        render() {
            return <LoadableComponent />;
        }
    }