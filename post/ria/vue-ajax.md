# ajax
- fetch: 可能有兼容性问题, 底层，xhr 升级, 原生
    1. https://developer.mozilla.org/zh-CN/docs/Web/API/Fetch_API/Using_Fetch
- axios：promise, 需要外部资源, 支持并发
- vue-resource
- $http 

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

    fetch(url, {
        credentials: "same-origin"
        credentials: "include", // crosee-origin
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
        body: new FormData() //不是data!!!!!

body type: 不能是 object, 只能是

    formData, // 默认 multipart/form-data
    JSON.stringify(data); //默认： text/plain

#### x-www-urlencode

    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
      },
      body: Object.keys(params).map((key) => {
                return encodeURIComponent(key) + '=' + encodeURIComponent(params[key]);
            }).join('&'),
    })

also:

    const searchParams = new URLSearchParams();
    for (const prop in params) {
      searchParams.set(prop, params[prop]);
    }

### response

    response.json().then
    response.text().then(function (text) {
        // do something with the text response 
    });

e.g. 
    .then(async r => await r.json())
    .then(data=>console.log(data))

## this.$http

    this.$http.get('/message').then((response) {}

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