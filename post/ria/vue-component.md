# 组件

## 静态的
组件不能直接引用data全局变量

    // 定义一个被命名为 todo-item 的新组件
    Vue.component('todo-item', {
        template: '<li>这是一个 todo 项</li>'
    })

使用组件：

    <todo-item :title="'中国人'"></todo-item>

## 传值

### props
1. prop 是单向绑定的：当父组件的属性变化时，将传导给子组件，但是不会反过来。

todo-item 组件现在接受一个 "prop"，

    //里面接受删除: click="$emit(event_name)"
    Vue.component('todo-item', {
        props: ['todo'],
        template: '<li>{{ todo.text }}\
            <button v-on:click="$emit(\'remove\')">X</button>\
        </li>'
    })

传入todo: `:todo="value_expression"`

    <todo-item todo="{text:'haha1'}"></todo-item> # 传字符串
    <todo-item v-bind:todo="{text:'haha2'}"></todo-item> # 传对象dict

    <todo-item
      v-for="item in groceryList"
      v-bind:todo="item"
      v-bind:key="item.id">
    </todo-item>

`<todo-item>` 与`<tag is="todo-item">` 完全等价:

    <li
      is="todo-item"
      v-for="(todo, key) in todos"
      v-bind:key="todo.id"
      v-on:remove="todos.splice(index, 1)"
    >没有组件时的默认值</li>

#### camelCase
HTML 特性是不区分大小写的。所以，当使用的不是字符串模板时，camelCase (驼峰式命名) 的 prop 需要转换为相对应的 kebab-case (短横线分隔式命名)：

    Vue.component('child', {
    // 在 JavaScript 中使用 camelCase
    props: ['myMessage'],
    template: '<span>{{ myMessage }}</span>'
    })
    <!-- 在 HTML 中使用 kebab-case -->
    <child my-message="hello!"></child>

#### via data
组件的 data 选项必须是一个函数，以便每个实例都可以维护「函数返回的数据对象」的彼此独立的数据副本：

    // 定义一个新的组件，名称为 button-counter
    Vue.component('button-counter', {
        data: function () {
            return {
                count: 0
            }
        },
        template: '<button v-on:click="count++">你点击了 {{ count }} 次。</button>'
    })

相同的副本:

        data: function () {
            return global_obj; #相同的对象
        },

#### 单向传值(json解耦)
这个data是属于组件本身的，单向传值时内外组件应该隔离：

    props: ['list'],
    data: function () {
        return {
            mutableList: JSON.parse(this.list); //内外变量解偶, 否则可以实现双向绑定
        }
    }

#### multiple props
如果你想把一个对象的所有属性作为 prop 进行传递，可以使用不带任何参数的 v-bind (即用 v-bind 而不是 v-bind:prop-name)。
例如，已知一个 todo 对象：

    todo: {
        text: 'Learn Vue',
        isComplete: false
    }
然后：

    <todo-item v-bind="todo"></todo-item>

将等价于：

    <todo-item
        v-bind:text="todo.text"
        v-bind:is-complete="todo.isComplete"
    ></todo-item>

### event 反向传值（内外耦合）
有些功能可能恰好与 props 相反, 子组件可以通过event 向父组件传值:
1. envent handler 必须作用于组件`tag`本身，或者`is`修饰的节点`tag`:

    <div :style="{fontSize:sss+'em'}">
        <div is="button-counter" v-on:enlarge-text1="sss+=1"></div>
    </div>
    button-counter:
        template: '<span v-on:click="$emit(\'enlarge-text1\')"  >ahui</span>'

event:custom 发送/接收一个值, 

        template: '<span v-on:click="$emit(\'enlarge-text1\', 3)"  >ahui</span>'
        <div is="button-counter" v-on:enlarge-text1="sss+=$event"></div>

event:input 发送$event.target.value +接收:

    <custom-input v-bind:value="searchText" v-on:input="searchText = $event" >
        template: `<span v-on:input="$emit('input', $event.target.value)"  >ahui</span>`

> custom-tag 上的on:event 只能接收子组件 emit 发出的事件

### 双向绑定
1. vue2 props 传值是按我引用传值的, 本身支持双向绑定，但是有警告
2. 如果是非引用传值，则可以利用computed set-get实现双绑定
3. 或者利用watch 实现双绑定

后两种都需要父组件接收$event 事件: prop 向下传递，事件向父组件传递

#### computed: set-get:

    <div id="app">
        {{list}}
        <input v-model="list">
        <div is="form-input" :list="list" @input="list=$event"></div>
    </div>

    Vue.component("form-input", {
        template: `<input v-model="fieldModelValue"/>`,
        props: ['list'],
        computed: {
            fieldModelValue: {
                get() {
                    return this.list;
                },
                set(newValue) {
                    this.$emit('input', newValue);
                }
            }
        }
    })
    new Vue({
        data:{
            list:"[1,2,3]"
        },
        el:'#app',
    })

#### via watch

    Vue.component("switchbtn", {
        props: ["result"],
        data: function () {
            return {
                myResult: this.result
            };
        },
        watch: {
            result(val) {
                this.myResult = val;
            },
            myResult(val){
                this.$emit("change",val);
            }
        }

## 组合
### 全局组件
全局组件可以用于之后创建的所有Vue 根实例、子组件的内部

    Vue.component('my-component-name', {
    // ... options ...
    })

### 动态组件

    var Child = {
    template: '<div>A child component!</div>'
    }

    new Vue({
    // ...
    components: {
        // <my-component> 将只在父组件模板中可用
        'my-component': Child
    }
    })

#### v-html:

    <div class="blog-post">
        <h3>{{ post.title }}</h3>
        <div v-html="post.content"></div>
    </div>

# Application, 组件应用

## tab

    <script src="https://unpkg.com/vue"></script>
    <div id="dynamic-component-demo" class="demo">
    <button
        v-for="tab in tabs"
        v-bind:key="tab"
        v-bind:class="['tab-button', { active: currentTab === tab }]"
        v-on:click="currentTab = tab"
    >{{ tab }}</button>

    <component
        v-bind:is="currentTabComponent"
        class="tab"
    ></component>
    </div>