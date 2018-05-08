# ajax

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
        credentials: "include", # crosee-origin
    }).then(...).then(..).catch(...);

### fetch post

        credentials: "same-origin"
        method: 'POST',
        headers : new Headers(),
        headers: {
            "Content-Type": "multipart/form-data"
        },
        body: new FormData()

## axios
    <script src="https://cdn.jsdelivr.net/npm/axios@0.12.0/dist/axios.min.js"></script>
    axios.get('https://yesno.wtf/api')
          .then(function (response) {
            vm.answer = _.capitalize(response.data.answer)
          })
          .catch(function (error) {
            vm.answer = '错误！API 无法处理。' + error
          })