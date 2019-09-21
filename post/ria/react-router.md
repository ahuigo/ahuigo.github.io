---
title: React router
date: 2019-08-16
private:
---
# React Redirect
https://stackoverflow.com/questions/45089386/what-is-the-best-way-to-redirect-a-page-using-react-router

## Redirect
It should be redered as dom 

    import React from 'react'
    import  { Redirect } from 'react-router-dom'

    const ProtectedComponent = () => {
        if (authFails)
            return <Redirect to='/login'  />
        }
        return <div> My Protected Component </div>
    }

## via props.history push
> 注意不是原生的history.pushState


    myFunction() {
        addSomeStuff()
        this.props.history.push('/path')
    }

In order to have access to history, you can wrap your component with an HOC called `withRouter` when you wrap your component with it, it passes match location and history props. 

If your component is a child of <Route /> component, I mean if it is something like `<Route path='/path' component={myComponent} />` you don't have to wrap your component with `withRouter <Route />` passes match location and history to its child.

## Redirect after clicking some element

    <div onClick={this.props.history.push('/path')}> some stuff </div>

or you can use <Link /> component

    <Link to='/path' > some stuff </Link>