---
date: 2018-08-27
category: ops
title: 各种语言的fiddle
---
# 各种语言的fiddle
各种语言的fiddle
1. js:
    https://ahuigo.github.io/a/demo/fiddle/fiddle.html # 加上`data:text/html,`前缀，放到chrome 的书签就行
    http://jsbin.com 有点老了
    http://jsfiddle.com
    http://tinkerbin.com/# 实时运行
    http://codepen.io/ 实时, 支持embed 嵌入
    http://rendur.com/# 超级轻量级, 不支持分享

2. clang:
   1. https://www.jdoodle.com/c-online-compiler

3. go:
    https://play.golang.org/

4. python:
    https://pyfiddle.io/
    http://pythonfiddle.com/

5. httpbin
    requests.post('https://httpbin.org/post', headers={'Content-Type': 'application/json'}, data=json.dumps({'bar':'员'}, ensure_ascii=False).encode('utf-8')).text

6. svg:
    https://c.runoob.com/more/svgeditor/

8. web project:
    https://codesandbox.io/s/o29j95wx9

9. css:
    chrome://devtool
    http://cssdesk.com/ 
    http://dabblet.com/


## js inner fiddle
有时我们想再自己的静态博客中执行代码，可以直接用

    try{
        eval(code_str)
    }catch(e){
        console.log(e)
    }