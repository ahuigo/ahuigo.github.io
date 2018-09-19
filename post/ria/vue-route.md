# vue router 笔记

    routes: [
        { path: '/', component: Hello }, // No props, no nothing
        { path: '/hello/:name', component: Hello, props: true }, // Pass route.params to props
        { path: '/static', component: Hello, props: { name: 'world' }}, // static values
        { path: '/dynamic?q=1', component: Hello, props: (route) => ({ query: route.query.q }) }, // custom: 
        { path: '/attrs', component: Hello, props: { name: 'attrs' }}