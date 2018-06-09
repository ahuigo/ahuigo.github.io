# ajax
- fetch: 可能有兼容性问题
- axios：需要外部资源
- $http
- vue-resource

## fetch

    data:{
        products:[]
    },
    created(){
        fetch('http://localhost:5001').then(response=>response.json()).then(json=>{
            this.products=json.products
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
            vm.answer = '错误！API 无法处理。' + error
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