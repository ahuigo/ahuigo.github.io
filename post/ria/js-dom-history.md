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
trigger:

    $('#container').on('click', 'a', function(e) {
　　　　window.history.pushState(null, "title", $(this).attr('href'));
　　　　// ajax fetch & render
　　　　e.preventDefault();
　　});

## onpushstate(自定义)
listen pushstate:

    (function(history){
        var pushState = history.pushState;
        history.pushState = function(state) {
            if (typeof history.onpushstate == "function") {
                history.onpushstate({state: state});
            }
            return pushState.apply(history, arguments);
        };
    })(window.history);

## onpopstate(custom)
onpopstate 是后退事件

	window.onpopstate = function(event) {
		alert("location: " + document.location + ", state: " + JSON.stringify(event.state));
	};

## onpopstate, onhashchange(browser action)
listen popstate(on user click back only): 

    //window.onpopstate
    window.addEventListener('popstate', function(e) {     
　　　　anchorClick(location.pathname); 	
 　　});

Note:
这popstate/hashchange only triggered by doing a `browser action`
1. history.back() 会trigger popstate/hashchange
2. 调用history.pushState() 本身不会trigger(这个算是bug) 

manully trigger popstate/hashchange

    history.pushState(state, '', url);
    var popStateEvent = new PopStateEvent('popstate', { state: state });
    dispatchEvent(popStateEvent);