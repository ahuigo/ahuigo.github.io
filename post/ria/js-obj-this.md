---
title: js this
date: 2021-02-23
private: true
---
# js this

    var a= 0
    var obj = {
        a: 1, 
        fn: function(){
            console.log(this.a)
        },
        fn: ()=>{
            console.log(this.a)
        }
    }

    obj.fn()  // 1
    obj.fn.apply(null)  // 0
    obj.fn.apply(undefined) //0

注意，apply 不能改变箭头函数的this

如果不想用apply 改变this：

    obj.fn(...arguments)