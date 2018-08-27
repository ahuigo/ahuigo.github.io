---
date: 2018-08-27
category: ops
---
# 各种语言的fiddle
> 几行代码写的js fiddle(加入到标签就可以)：
https://gist.github.com/ahuigo/ea584caed67ffcfdc55b332e7ff1b45d

各种语言的fiddle
1. go:
    https://play.golang.org/
2. js:
    jsbin.com 有点老了
    jsfiddle
    http://tinkerbin.com/# 实时运行
    http://codepen.io/ 实时
    http://rendur.com/# 超级轻量级, 不支持分享
2. css:
    chrome://devtool
    http://cssdesk.com/ 
    http://dabblet.com/
2. httpbin
    requests.post('https://httpbin.org/post', headers={'Content-Type': 'application/json'}, data=json.dumps({'bar':'员'}, ensure_ascii=False).encode('utf-8')).text

2. web project:
    https://codesandbox.io/s/o29j95wx9

## js inner fiddle
有时我们想再自己的静态博客中执行代码，可以直接用

    try{
        eval(code_str)
    }catch(e){
        console.log(e)
    }