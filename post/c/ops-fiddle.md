# fiddle
go:
    https://play.golang.org/
js:
    jsbin.com# 有点老
    jsfiddle
    http://tinkerbin.com/# 实时运行
    http://rendur.com/# 超级轻量级, 不支持分享
httpbin
    requests.post('https://httpbin.org/post', headers={'Content-Type': 'application/json'}, data=json.dumps({'bar':'员'}, ensure_ascii=False).encode('utf-8')).text
css:
    chrome://devtool
    http://cssdesk.com/ 
    http://dabblet.com/

## js fiddle

    try{
        eval(code_str)
    }catch(e){
        console.log(e)
    }