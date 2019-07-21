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

## fetch

    data:{
        products:[]
    },
    created(){
        fetch('http://localhost:5001').then(response=>response.json()).then(json=>{
            vm.products=json.products
        })
    }

### fetch with cookie
credential 发送include 时，allow-origin 不能是`*`

    fetch(url, {
        credentials: "same-origin"
        credentials: "include", // send cookie
        mode: 'cors', //"same-origin"
    }).then(...).then(..).catch(...);
    fetch(url).then(async r=> console.log(await r.text()))

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

### response
#### data:

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

## axios
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

## vue-resource
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
