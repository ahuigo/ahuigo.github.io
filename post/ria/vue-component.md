# 组件

    <div id="app-7">
    <ol>
        <todo-item v-for="item in groceryList" v-bind:todo="item"></todo-item>
    </ol>
    </div>
    <script>
        Vue.component('todo-item', {
            props: ['todo'],
            template: '<li>{{ todo.text }}</li>'
        })
        var app7 = new Vue({
            el: '#app-7',
            data: {
                groceryList: [
                { text: 'Vegetables' },
                { text: 'Cheese' },
                { text: 'Whatever else humans are supposed to eat' }
                ]
            }
        })
    </script>

## 简单组件
组件不能直接引用data全局变量

    // 定义一个被命名为 todo-item 的新组件
    Vue.component('todo-item', {
        template: '<li>这是一个 todo 项</li>'
    })

使用组件：

    <todo-item :title="'中国人'"></todo-item>

## 访问元素、组件

### refs
*refs 相当于id*\
当 ref 和 v-for 一起使用时，获取到的引用会是一个数组
ref 指向comp

    <div id="parent">
        <user-profile ref="profile"></user-profile>
    </div>
    var parent = new Vue({ el: '#parent' })
    // 访问子组件实例
    var child = parent.$refs.profile

ref也可以组件内部的元素

    template: ' <input ref="input" v-on:input="updateValue($event.target.value)"',
    props: ['value'],
    methods: {
        updateValue: function (value) {
            this.$refs.input.value = value.toUpperCase()
        }
    }

`$refs` 只会在组件渲染完成之后生效。
1. 你应该避免在`模板`或`计算属性`中访问 `$refs`

### $root
子组件可以通过$root 修改父组件的变量:

    <div :root="$root" :is="tpl">
    <tpl>
        <input :value="list[1]" @input="$root.$set(list, 1, $event.target.value)"/>
    </tpl>

在子组件内访问$root:

    new Vue({
        data: {foo:1}
    })
    //component
    this.$root.foo
    this.$root.func1

### $parent
$parent 属性可以用来从一个子组件访问父组件的实例. eg. `this.$parent.getMap`: https://jsfiddle.net/chrisvfritz/ttzutdxh/


### 依赖注入(大范围有效的 prop)
深层次的google-map-markers 访问google-map的话

    <google-map>
    <google-map-region v-bind:shape="cityBoundaries">
        <google-map-markers v-bind:places="iceCreamShops"></google-map-markers>
    </google-map-region>
    </google-map>

我们需要hack, 它就会失控。

    var map = this.$parent.map || this.$parent.$parent.map

任意更深层级的组件提供上下文信息时推荐依赖注入, 它用到了两个新的实例选项：provide 和 inject

#### provice
provide 选项允许我们指定我们想要`提供`给`后代`组件的`数据/方法`。在这个例子中，就是 `<google-map>` 内部的 getMap 方法：

    provide: function () {
      return {
        getMap: this.getMap
      }
    }
#### inject
在任何`后代组件`里，我们都可以使用 inject 选项来`接收`指定的我们`想要添加`在这个实例上的`属性`：

    inject: ['getMap']

示例：https://jsfiddle.net/chrisvfritz/tdv8dt3s/ (中间的组件不需要层层传递)

#### 结语
这样的属性共享，是的组件偶合起来，重构困难。

如果你想要共享的这个属性是你的应用特有的，或者如果你想在祖先组件中更新所提供的数据:
1. 你可能需要换用一个像 Vuex 这样真正的状态管理方案了。

## 传值
1. prop 是单向绑定的：
    1. prop 属性不会出现在html DOM(inherits). `非prop`才可以继承
    2. 当父组件的属性变化时，将传导给子组件
2. $emit(event value) 是反向传达到父组件的

### props
todo-item 组件现在接受一个 "prop"，

    Vue.component('todo-item', {
        props: ['todo'],
        template: '<li>{{ todo.text }}\
            <button v-on:click="$emit(\'remove\')">X</button>\
        </li>'
    })

必须显式传入todo: `:todo="value_expression"`, `tode="string"`

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

#### new add prop

    node={name:'xxx'}
    <comp :show="node.show">

新添加的参数不能触发钩子：Vue.set(node, 'show', 1)

#### access props and data
data 只是before render 生成。lmsg 不是响应式的(即使是数组，也是deep-copy)

    props: ['msg'],
    data: function() {
        return {
            lmsg: this.msg,
            // other object attributes
        }
    },
    methods:{
        fun1(){
            console.log{this.lmsg, this.msg, this.$parent.msg}
        }
    }

#### camelCase
HTML 特性是不区分大小写的。所以，当使用的不是字符串模板时，camelCase (驼峰式命名) 的 prop 需要转换为相对应的 kebab-case (短横线分隔式命名)：

    Vue.component('child', {
        // 在 JavaScript 中使用 camelCase
        props: ['myMessage'],
        template: '<span>{{ myMessage }}</span>'
    })
    <!-- 在 HTML 中使用 kebab-case 传值-->
    <child my-message="hello!"></child>

#### 非prop(this.$attrs)
非prop 属性会被inherit 在模板的根元素上, 而prop 会被移除;\
`inheritAttrs: false`时，所有都不被继承

    <child-com1 foo="foo" boo="boo">

    props: ['foo'],
    inheritAttrs: true, //default
    created () {
        console.log(this.$attrs) // { boo: 'boo'} 当inheritAttrs 为true 时,只有boo被继承
    }

子组件可以再把 所有的 $attrs 传给下一层

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
props 传给子组件的值，作为局部变量是不允许直接修改的(为了不影响父组件)。你可以用data/computed 隔离、反传值:
1. 利用data 定义局部变量, 不会影响父组件
2. 定义一个computed 属性，处理 prop 的值并返回：

#### data 局部变量
不需要`<child :value="local_data_count">`传递
1. 组件的 data 选项`必须是一个函数`，
2. 以便每个实例都可以维护「函数返回的数据对象」的彼此独立的数据副本.
3. `this.$data.value`,`this.value` 可以访问：https://codepen.io/ahuigo/pen/yqERxd

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

    <custom-input v-model="searchText">
    <custom-input v-bind:value="searchText" v-on:input="searchText = $event" >
        template: `<span v-on:input="$emit('input', $event.target.value)"  >ahui</span>`

> custom-tag 上的on:event 只能接收子组件 emit 发出的事件

#### checked

    $event.target.checked

#### .sync
sync 简化了父组件修改props 的过程（$emit 还是要手动）

    <comp :foo.sync="bar"></comp>
    #会被扩展为：
    <comp :foo="bar" @update:foo="val => bar = val"></comp>

当子组件需要更新 foo 的值时，它需要显式地触发一个更新事件：

    this.$emit('update:foo', newValue)

当使用一个对象一次性设置多个属性的时候，这个 .sync 修饰符也可以和 v-bind 一起使用：

    <comp v-bind.sync="doc"></comp>

在一个字面量的对象上，例如 `v-bind.sync=”{ title: doc.title }”`，是无法正常工作的，因为在解析一个像这样的复杂表达式的时候，有很多边缘情况需要考虑

### 非父子组件的通信
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
有了slot 后，comp 的template 可以直接写slot 引入了:

    template: '<div class="comp1"><slot></slot></div>' //child 的slot 直接包含站位comp1 的dom

slot 允许对组件占位中的内容重载: js-demo/vue-slot.html:
    https://codepen.io/ahuigo/pen/rrKqJB

1. child 子模板`<slot name="xx">` 会被父模板`slot="xxx"`覆盖
1. child 子模板`<slot>` 会被父模板`<child>`覆盖

slot 也像是普通元素那样使用v-for:

    <slot v-for="text in list" :text="text"></slot>

### slot-scope 传值
见: https://juejin.im/post/5a69ece0f265da3e5a5777ed

`<slot>`是插槽，里面可以有默认值，也可以向他传

    <slot :todo="todo"></slot>

然后, 模板通过slot-scope 获取值

    <child>
      <template slot-scope="{ todo }">
        {{ todo.text }}
      </template>
    </child>

slot-scope 也可以用命名作用域

    <child>
      <template slot-scope="slotProps">
        {{ slotProps.todo.text }}
      </template>
    </child>

## 组合
### 异步组件
你可以在工厂函数中返回一个 Promise

    Vue.component('async-example', function (resolve, reject) {
      setTimeout(function () {
        resolve({
          template: '<div>I am async!</div>'
        })
      }, 1000)
    })

setTimeout 是为了演示用的，如何获取组件取决于你自己。一个推荐的做法是将异步组件和 webpack 的 code-splitting 功能一起配合使用：

    Vue.component('async-webpack-example', function (resolve) {
      // 这个特殊的 `require` 语法将会告诉 webpack
      // 自动将你的构建代码切割成多个包，这些包
      // 会通过 Ajax 请求加载
      require(['./my-async-component'], resolve)
    })

局部异步:

    components: {
        'my-component': () => import('./my-async-component')
    }

#### 处理加载状态
如果想在加载时，显示loading 状态组件, 

    const AsyncComponent = () => ({
      // 需要加载的组件 (应该是一个 `Promise` 对象)
      component: import('./MyComponent.vue'),
      // 异步组件加载时使用的组件
      loading: LoadingComponent,
      // 加载失败时使用的组件
      error: ErrorComponent,
      // 展示加载时组件的延时时间。默认值是 200 (毫秒)
      delay: 200,
      // 如果提供了超时时间且组件加载也超时了，
      // 则使用加载失败时使用的组件。默认值是：`Infinity`
      timeout: 3000
    })


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

## 递归组件
构建一个文件目录树，tree-folder 组件，模板是这样的：

    <p>
        <span>{{ folder.name }}</span>
        <tree-folder-contents :children="folder.children"/>
    </p>

还有一个 tree-folder-contents 组件，模板是这样的：

    <ul>
      <li v-for="child in children">
        <tree-folder v-if="child.children" :folder="child"/>
        <span v-else>{{ child.name }}</span>
      </li>
    </ul>

### 相互依赖
1. Vue 可以处理: A 依赖 B，B 又依赖 A, 
2. 然而，如果你使用一个`模块系统`依赖导入组件(例如 webpack 或 Browserify)，你会遇到一个错误: mounted: template not defined.

需要告诉模糊系统一个点：解析A时， 不需要先解析 B. 
1. tree-folder 组件设为了那个点
2. tree-folder-contents 要等到生命周期钩子 beforeCreate 时去注册它

code:

    beforeCreate: function () {
        this.$options.components.TreeFolderContents = require('./tree-folder-contents.vue').default
    }

或者，在本地注册组件的时候，你可以使用 webpack 的异步 import：

    components: {
      TreeFolderContents: () => import('./tree-folder-contents.vue')
    }

## 动态组件
通过is 改变:

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

### keep-alive(dom 常驻)
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

## 强制更新
你可能还没有留意到`数组或对象`的变更检测注意事项，或者你可能依赖了一个未被 Vue 的响应式系统追踪的状态。

极少数的情况下需要手动强制更新，那么你可以通过 `$forceUpdate` 来做这件事。

## v-once
当组件中包含大量静态内容时，\
你可以在根元素上添加 v-once 特性
1. 以确保这些内容只计算一次然后缓存起来(数据再次变更就不会响应更新了)

code

    Vue.component('terms-of-service', {
        template: '\
            <div v-once>\
                <h1>Terms of Service</h1> ...很多静态内容...\
            </div>\
        '
    })

## 内联模板
当 inline-template 这个组件将会使用其里面的内容作为模板.（代替了`<slot></slot>`）占位符内容就是模板

    <my-component inline-template>
      <div>
        <p>These are compiled as the component's own template.</p>
        <p>Not parent's transclusion content.</p>
      </div>
    </my-component>

## X-Templates(不推荐)
另一个定义模板的方式是在一个 script 元素中x-template

    <script type="text/x-template" id="hello-world-template">
        <p>Hello hello hello</p>
    </script>
    template: '#hello-world-template'

