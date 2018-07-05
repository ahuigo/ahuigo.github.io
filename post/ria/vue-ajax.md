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

### fetch post

        credentials: "same-origin"
        method: 'POST',
        headers : new Headers(),
        headers: {
            "Content-Type": "multipart/form-data"
        },
        body: new FormData()

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