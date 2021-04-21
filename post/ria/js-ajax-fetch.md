---
title: 新一代ajax api--fetch、axios
date: 2018-
private:
---
# 新一代ajax api--fetch、axios
- fetch: 底层，相当于xhr 升级版, 原生
    1. https://developer.mozilla.org/zh-CN/docs/Web/API/Fetch_API/Using_Fetch
- axios：非原生, 支持并发
- vue-resource: vue 提供的，只提供基本的功能

## ajax 请求类型
不同的请求头，会被解析为不同的变量(以php 为例)
1. `application/x-www-form-urlencode` 才会传`$_POST`, 
2. `enctype="multipart/form-data"` 则包括`POST+FILES`
3. `Content-Type:text/plain:json + POST `只会传`RAW_POST_DATA` ,

	$GLOBALS['HTTP_RAW_POST_DATA'] or $HTTP_RAW_POST_DATA; # 这个在php7中被废弃了
    file_get_contents('php://input'); # 不是php://stdin

Detect Ajax(php 为例)：

	$_SERVER['HTTP_X_REQUESTED_WITH']
	$_SERVER['HTTP_ACCEPT'] === 'application/json';

## isAjax
    fetch(url, {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
    )
# fetch
## request
        fetch('http://localhost:5001').then(response=>response.json()).then(json=>{
            vm.products=json.products
        })

with query

    var url = new URL('https://sl.se')
    var params = {lat:35.696233, long:139.570431} // or:
    url.search = new URLSearchParams(params).toString();
    fetch(url)

### fetch post

    options:
        credentials: "include"
        method: 'POST',
        headers : new Headers(),
        headers: {
            'X-requested-with': 'XMLHttpRequest',
            "Accept": "application/json", 
            //'content-type':'application/x-www-form-urlencode', 
        },
        body: new FormData() //不能是object!!!!!

body: 不能是 object, 只能是: (是`body` 不是`data`)

    formData, // 默认multipart/form-data 不要自己算boundary
    input.files[0], // 默认multipart/form-data 不要自己算boundary

    JSON.stringify(data); //默认： text/plain

example

    fetch(url, {
        method: 'POST',
        headers: {
            'X-requested-with': 'XMLHttpRequest',
            "Accept": "application/json", 
        },
        credentials: "include",
        body:  JSON.stringify({a:1}),
    })

### cors
默认(跨域名)是不发送cookie的：

    credentials: "same-origin"

为了让浏览器发送包含凭据Cookie 的请求（即跨域源），要:

    credentials : "include"

当设置成include时，服务器返回的`Access-Control-Allow-Origin` 不能为`*`



#### cors with cookie
credential 发送include cookie时，allow-origin 不能是`*`

    fetch(url, {
        credentials: "include", // send cookie, use "omit" if not send cookie
        mode: 'cors', //or "same-origin"
                //credentials: "same-origin" //default
    }).then(...).then(..).catch(...);
    fetch(url).then(async r=> console.log(await r.text()))

注意:
1. 最新的chrome 对于https网站, 跨域名ajax请求，即使加了`credentials:"include"` 也不能发送cookie. 除非设置: `Set-Cookie: flavor=choco; SameSite=None; Secure`
2. 跨子域名，不受影响

### headers
#### x-www-urlencode
如果想发送  application/x-www-form-urlencoded
可以用手动拼body

    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
      },
      body: Object.entries(params).map((key, value) => {
                return encodeURIComponent(key) + '=' + encodeURIComponent(value);
            }).join('&'),
    })

或者用 URLSearchParams:

    const searchParams = new URLSearchParams();
    for (const prop in params) {
      searchParams.set(prop, params[prop]);
    }
    fetch(url, {
        method: 'POST',
        body: searchParams
    })

### cancel request
参考： https://github.com/umijs/umi-request#use-cancel-token

    const controller = new AbortController()
    const signal = controller.signal

    /*
    // Register a listenr.
    signal.addEventListener("abort", () => {
        console.log("aborted!")
    })
    */


    function beginFetching() {
        console.log('Now fetching');
        var url= "https://httpbin.org/delay/3";
        fetch(url, {
                method: 'get',
                signal: signal,
            }) .then(function(response) {
                console.log(`Fetch complete. (Not aborted)`);
            }).catch(function(err) {
                console.error(` Err: ${err}`);
            });
    }


    function abortFetching() {
        console.log('Now aborting');
        // Abort.
        controller.abort()
    }


## response
### data
json(), text(), blob(), arrayBuffer()

    response.json().then
    response.text().then(function (text) {
        // do something with the text response 
    });

    fetch('/api/clipboard/header?get=1', {
        method:'POST',
        headers:{'content-type':'application/x-www-form-urlencoded'}, 
        body:'a=1',
    }).then(
        async r=>await r.text()
    ).then(txt=>console.log(txt))

async function with in `then`:

    .then(async r => await r.json())
    .then(data=>console.log(data))

### status code

    r.status===200 
    r.ok //true if staus range 200-299
    then(r=>if(r.ok) ..)

# axios
    <script src="https://cdn.bootcss.com/axios/0.18.0/axios.min.js"></script>
    axios.defaults.withCredentials=true;//让ajax携带cookie

    axios.get('https://yesno.wtf/api')
          .then(function (response) {
            vm.answer = _.capitalize(response.data.answer)
          })
          .catch(function (error) {
            error.response.status
            vm.answer = '错误！API 无法处理。' + error.response.data 
          })

# vue-resource
get:

    <script src="https://cdn.jsdelivr.net/vue.resource/1.0.3/vue-resource.min.js"></script>
    var vm = new Vue({
        created: function () {
            this.init();
        },
        methods: {
            init: function () {
                var that = this;
                that.$resource('/api/todos').get().then(function (resp) {
                    resp.json().then(function (result) {
                        that.todos = result.todos;
                    });
                }, function (resp) {
                    alert('error');
                });
            }
        }


post:

    that.$resource('/api/todos').save(todo).then(function (resp) {

也可以全局或局部引用：

    this.$http Vue.http
    this.$http.get('/message').then((response) {}
