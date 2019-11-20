---
title: umi router
date: 2019-11-12
private: true
---
# umi router

    {
        path: '/welcome/:id',
        name: 'welcome',
        icon: 'smile',
        component: './Welcome',
    },

# pathinfo 


    // path?id=152
    function Welcome(props){
        props.location.query.id

        //path: '/welcome/:id',
        <!-- props.match.params.id -->
    }