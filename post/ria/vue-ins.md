# vue instance
    // 此对象将会添加到 Vue 实例上
    data = {a:1}
    var vm = new Vue({
        data: data
    })

## vue attr

    vm.$el === document.getElementById('app') // => true
    vm.$data=== vm._data === data

    # render 使用的是this.attr, 而不是data.attr
    this.message == data.message

### watch attr

    // $watch 是一个实例方法
    vm.$watch('a', function (newValue, oldValue) {
       // 此回调函数将在 `vm.a` 改变后调用
    })

定义时：

    data: {
        a: 'Foo',
    },
    watch: {
        a : function (val) {
            //当a改变时
            console.log(val)
        },


### data attr
两者相互绑定:

    vm.a=222
    vm.a == vm._data.a // => true
    vm.$data===vm._data == data

为防止修改属性用Object.freeze:

    var obj = {
      foo: 'bar'
    }
    Object.freeze(obj)

    new Vue({
        el: '#app',
        data: obj
    })

实例化后新加的属性，不会影响data. 也就不会触发任何视图更新

    vm.new_b = 123
    vm.new_b == vm._data.new_b; //false

### add/modify attr

#### 变化数组方法(Mutation Methods)
Vue 将观察数组(observed array)的变化数组方法(mutation method)包裹起来，以便在调用这些方法时，也能够触发视图更新:

    # example1.items.push({ message: 'Baz' })。
    push()
    pop()
    shift()
    unshift()
    splice()
    sort()
    reverse()

#### 替换一个数组(Replacing an Array)
还有非变化数组方法(non-mutating method)，例如 filter(), concat() 和 slice()，
1. 这些方法都不会直接修改操作原始数组，而是返回一个新数组。

    items.filter(function (item) {
        return item.message.match(/Foo/)
    })

这不会导致 Vue 丢弃现有 DOM 并重新渲染(re-render)整个列表:
1. Vue 实现了一些智能启发式方法(smart heuristic)来最大化 DOM 元素重用(reuse)

#### del
    Vue.delete(this.selectedRows, key)
    vm.$delete(this.selectedRows, key)

#### set 新属性, 注意事项(Caveats)
由于 JavaScript 的限制，Vue 有时无法触发重新render(reactiveSetter)

数组:
1. 当你使用索引直接设置一项时，例如 vm.items[indexOfItem] = newValue, 可用下面的方法代替
    1. Vue.set(vm.items, indexOfItem, newValue)
    2. vm.$set(vm.items, indexOfItem, newValue)

2. 当你修改数组长度时，例如 vm.items.length = newLength, 可用：
    1. vm.items.splice(indexOfItem, 1, newValue) // Array.prototype.splice

对象userProfile已经存在时, 添加非root level属性：
1. vm.userProfile.age = 27, 变为:
    2. Vue.set(vm.userProfile, 'age', 27)
    2. vm.$set(vm.userProfile, 'age', 27)
2. 合并属性，使用: Object.assign() 或 _.extend() 方法。
    1. vm.user=Object.assign(dict1,dict2,...)
    1. vm.user=Object.assign({age4:27},{age2:2, age3:3})

#### Object Change Detection Caveats
受现代 Javascript 的限制， Vue 无法检测到对象属性的添加或删除。例如：

    data: {
        a: 1
    }
    vm.b = 2
    // `vm.b` 不是响应的


## 实例生命周期钩子函数
每个 Vue 实例在被创建之前，都要经过一系列的初始化过程 
1. 设置数据观察(set up data observation)、
2. 编译模板(compile the template)、
3. 在 DOM 挂载实例(mount the instance to the DOM)，
4. 以及在数据变化时更新 DOM(update the DOM when data change)。
5. 在这个过程中，Vue 实例还会调用执行一些生命周期钩子函数，这样用户能够在特定阶段添加自己的代码。

### created hook
实例创建后:

    new Vue({
    data: {
        a: 1
    },
    created: function () {
        // `this` 指向 vm 实例
        console.log('a is: ' + this.a)
    }
    })

其它的钩子，会在实例生命周期的不同阶段调用，如 mounted、updated 和 destroyed, 所有hook this指向app