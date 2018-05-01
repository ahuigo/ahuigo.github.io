# 组件

## 简单组件
组件不能直接引用data全局变量

    // 定义一个被命名为 todo-item 的新组件
    Vue.component('todo-item', {
        template: '<li>这是一个 todo 项</li>'
    })

使用组件：

    <todo-item :title="'中国人'"></todo-item>

## refs
refs 相当于id, 
2. 当 ref 和 v-for 一起使用时，获取到的引用会是一个数组

    <div id="parent">
        <user-profile ref="profile"></user-profile>
    </div>
    var parent = new Vue({ el: '#parent' })
    // 访问子组件实例
    var child = parent.$refs.profile

也可以是组件元素

    template: ' <input ref="input" v-on:input="updateValue($event.target.value)"',
    props: ['value'],
    methods: {
        updateValue: function (value) {
            this.$refs.input.value = value.toUpperCase()
        }
    }

## 传值
1. prop 是单向绑定的：
    1. prop 属性会从html DOM 属性移除
    2. 当父组件的属性变化时，将传导给子组件，
2. $emit(event value) 是反向的

### props
todo-item 组件现在接受一个 "prop"，

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
    <!-- 在 HTML 中使用 kebab-case 传值-->
    <child my-message="hello!"></child>

#### 非prop
非prop 属性会被inherit 在模板的根元素上, 而prop 会被移除, 除非:

    <child-com1 foo="foo" boo="boo">
    props: ['foo'],
    inheritAttrs: false
    created () {
        console.log(this.$attrs) // { boo: 'boo'} 仅当inheritAttrs 为false 时
    }

子组件可以再把$attrs 传给下一层: 限inheritAttrs: false,

    <child-com2 v-bind="$attrs">

除了$attrs, 父作用域中通过 v-on 监听的事件可以在 子组件中通过 `v-on="$listeners"` 传递下去

#### 占位属性与模板本身属性 
DOM 决定的
1. 一般，传递给组件的值会覆盖组件本身设定的值
1. 但是class 与style 来说, 会合并

    <op is="tpl" class="cls1 cls2" type="text"></op>
    <tpl>
        <input type="radio" class="cls3"> # 实际type="text", class="cls1 cls2 cls3"
    </tpl>

#### props 验证

    Vue.component('example', {
    props: {
        // 基础类型检测 (`null` 指允许任何类型)
        propA: Number,
        // 可能是多种类型
        propB: [String, Number],
        // 必传且是字符串
        propC: {
        type: String,
        required: true
        },
        // 数值且有默认值
        propD: {
        type: Number,
        default: 100
        },
        // 数组/对象的默认值应当由一个工厂函数返回
        propE: {
        type: Object,
        default: function () {
            return { message: 'hello' }
        }
        },
        // 自定义验证函数
        propF: {
        validator: function (value) {
            return value > 10
        }
        }
    }
    })

### 创建副本
props 传给子组件的值，作为局部变量是不允许直接修改的(为了不影响父组件)。你可以:
1. 利用data 定义局部变量
2. 定义一个computed 属性，处理 prop 的值并返回：

#### data 局部变量
1. 组件的 data 选项必须是一个函数，
2. 以便每个实例都可以维护「函数返回的数据对象」的彼此独立的数据副本.

    // 定义一个新的组件，名称为 button-counter
    Vue.component('button-counter', {
        props: ['count', 'list'],
        data: function () {
            return {
                //count: 0,
                count: this.count, //创建副本
                mutableList: JSON.parse(JSON.stringify(this.list)); //创建副本
            }
        },
        template: '<button v-on:click="count++">你点击了 {{ count }} 次。</button>'
    })

data 本身是组件局部变量，但是可以对象共享(引用传值):

    data: function () {
        return global_obj; #相同的对象
    },

#### computed 副本
这个data是属于组件本身的，单向传值时内外组件应该隔离：

    props: ['size'],
    computed: {
        normalizedSize: function () {
            return this.size.trim().toLowerCase()
        }
    }

每次set 后，自动触发get()

    normalizedSize:{
        get:function(){
            return this.size
        },
        set:function(new_val){
            this.size='ahui' //test
        },
    },

### event 反向传值（内外耦合）
子组件可以通过event 向父组件传值:
1. event handler 必须作用于组件`占位tag`本身，或者`is`修饰的节点`tag`:
2. 所有事件input,change, 必须显式的用$emit 向上传传递

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

#### checked

    $event.target.checked

#### .sync
sync 简化了父组件修改props 的过程

    <comp :foo.sync="bar"></comp>
    #会被扩展为：
    <comp :foo="bar" @update:foo="val => bar = val"></comp>

当子组件需要更新 foo 的值时，它需要显式地触发一个更新事件：

    this.$emit('update:foo', newValue)

当使用一个对象一次性设置多个属性的时候，这个 .sync 修饰符也可以和 v-bind 一起使用：

    <comp v-bind.sync="{ foo: 1, bar: 2 }"></comp>

#### root
子组件可以通过$root 修改父组件的变量:

    props=['root']
    <div :root="$root" :is="tpl">
    <tpl>
        <input :value="list[1]" @input="$root.$set(list, 1, $event.target.value)"/>
    </tpl>

#### 非父子组件的通信
有时候，非父子关系的两个组件之间也需要通信。在简单的场景下，可以使用一个空的 Vue 实例作为事件总线：

    var bus = new Vue()

    // 触发组件 A 中的事件
    bus.$emit('id-selected', 1)

    // 在组件 B 创建的钩子中监听事件
    bus.$on('id-selected', function (id) {
    // ...
    })


### 双向绑定
1. vue2 props 是局部变量，不能使用v-model 直接修改，除非是按引用传值: `v-model="list[1]"`
2. 如果是非引用传值，则可以利用computed set-get实现双绑定
3. 或者利用watch 实现双绑定

后两种都需要父组件接收$event 事件向父组件传递

#### computed: set-get:
每次set 后，computed 会自动触发get()

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

#### watch:set-get

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
## slot, 插槽
slot 允许对组件占位中的内容重载: js-demo/vue-slot.html:
    https://codepen.io/anon/pen/JvRbqo

### slot-scope 传值

    <child :list="[1,2,3]">
        <div slot-scope="props">
            <div>{{ props.text }}</div>
        </div>
    </child>

    template: child
        <div>
            <slot text="hello from child"></slot>
        </div>

slot 也像是普通元素那样使用v-for:

    <slot v-for="text in list" :text="text"></slot>

## 组合
### 异步组件
你可以在工厂函数中返回一个 Promise，所以当使用 webpack 2 + ES2015 的语法时可以这样：

    Vue.component(
        'async-webpack-example',
            // 该 `import` 函数返回一个 `Promise` 对象。
            () => import('./my-async-component')
    )

### 组件命名
这意味着 PascalCase 是最通用的声明约定而 kebab-case 是最通用的使用约定。

    components: {
    'kebab-cased-component': { /* ... */ },
    camelCasedComponent: { /* ... */ },
    PascalCasedComponent: { /* ... */ }
    }
    <kebab-cased-component></kebab-cased-component>

    <camel-cased-component></camel-cased-component>
    <camelCasedComponent></camelCasedComponent>

    <pascal-cased-component></pascal-cased-component>
    <pascalCasedComponent></pascalCasedComponent>
    <PascalCasedComponent></PascalCasedComponent>

### 全局组件
全局组件可以用于之后创建的所有Vue 根实例、子组件的内部

    Vue.component('my-component-name', {
    // ... options ...
    })

### 局部组件

    var Child = {
        template: '<div>A child component!</div>'
    }
    new Vue({
        components: {
            'my-component': Child
        }
    })

注意局部注册的组件在其子组件中不可用。如果你希望 ComponentA 在 ComponentB 中可用，则你需要这样写：

    var ComponentA = { /* ... */ }
    var ComponentB = {
        components: {
            'component-a': ComponentA
        },
        // ...
    }

或者如果你通过 Babel 和 webpack 使用 ES2015 模块，那么代码看起来更像：

    import ComponentA from './ComponentA.vue'

    export default {
        components: {
            ComponentA
        },
    }

## 动态组件

    <script src="https://unpkg.com/vue"></script>
    <div id="app">
        <button
            v-for="tab in tabs"
            v-bind:key="tab"
            v-bind:class="['tab-button', { active: currentTab === tab }]"
            v-on:click="currentTab = tab"
        >{{ tab }}</button>

        <component
            v-bind:is="currentTab"
            class="tab"
        ></component>
    </div>

### keep-alive
如果把切换出去的组件保留在内存中，可以保留它的状态或避免重新渲染。比如表单数据

    <keep-alive>
    <component :is="currentView">
        <!-- 非活动组件将被缓存！ -->
    </component>
    </keep-alive>

### 静态 v-html:

    <div class="blog-post">
        <h3>{{ post.title }}</h3>
        <div v-html="post.content"></div>
    </div>


# tpl
## v-once
尽管在 Vue 中渲染 HTML 很快，不过当组件中包含大量静态内容时，可以考虑使用 v-once 将渲染结果缓存起来，就像这样：

    Vue.component('terms-of-service', {
    template: '\
        <div v-once>\
        <h1>Terms of Service</h1>\
        ...很多静态内容...\
        </div>\
    '
    })

