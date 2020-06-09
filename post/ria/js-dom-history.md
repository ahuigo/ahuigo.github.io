---
title: Dom history
date: 2020-01-15
private: true
---
# Dom history push

## pushstate
不刷新页面ajax
http://www.cnblogs.com/xuchengzone/archive/2013/04/18/html5-history-pushstate.html
- help.gitbook.io

Example:

	var stateObj = { foo: "bar" };
	history.pushState(stateObj, title="page 2", "bar2.html");

参数：

    stateObj
        当离开此页时，popstate 会收到e.stateObj
	title
        可能不生效

## replaceState
    history.replaceState(data, title [, url ])
    history.replaceState({page: 1}, 'title 1', '?page=1')

# history event
## change a link
trigger:

    $('#container').on('click', 'a', function(e) {
　　　　window.history.pushState(null, "title", $(this).attr('href'));
　　　　// ajax fetch & render
　　　　e.preventDefault();
　　});

## onpopstate, onhashchange(browser action)
popstate 触发条件：browser.back()或 hashchange
hashchange 触发条件：hashchange

    //window.onpopstate
    window.addEventListener('popstate', function(e) {     
　　　　anchorClick(location.pathname); 	
 　　});

Note: 调用history.pushState/replaceState 不会trigger event

## onlocationchange(custom)
    /* These are the modifications: */
    history.pushState = ( f => function pushState(){
        var ret = f.apply(this, arguments);
        window.dispatchEvent(new Event('pushstate'));
        window.dispatchEvent(new Event('locationchange'));
        return ret;
    })(history.pushState);

    history.replaceState = ( f => function replaceState(){
        var ret = f.apply(this, arguments);
        window.dispatchEvent(new Event('replacestate'));
        window.dispatchEvent(new Event('locationchange'));
        return ret;
    })(history.replaceState);

    window.addEventListener('popstate',()=>{
        window.dispatchEvent(new Event('locationchange'))
    });

现在就可以用了:

    window.addEventListener('locationchange', function(){
        console.log('location changed!');
    })