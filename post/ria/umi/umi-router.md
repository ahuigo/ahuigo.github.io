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

## redirect

    import router from 'umi/router';
    <a onClick={() => router.push('/profileadvanced?id=' + item.id)}> 查看详情</a>,

# pathinfo 

    // path?id=152
    function Welcome(props){
        props.location.query.id

        //path: '/welcome/:id',
        <!-- props.match.params.id -->
    }
