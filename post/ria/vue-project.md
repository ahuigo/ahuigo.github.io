# 自定义指令
类似 v-model 和 v-show, 举个聚焦输入框的例子，如下：

    <input v-focus>

全局

    // 注册一个全局自定义指令 `v-focus`
    Vue.directive('focus', {
      // 当被绑定的元素插入到 DOM 中时……
      inserted: function (el) {
        // 聚焦元素
        el.focus()
      }
    })

局部

    directives: {
      focus: {
        inserted: function (el) {
          el.focus()
        }
      }
    }

## directive hooks
一个指令定义对象可以提供如下几个钩子函数 (均为可选)：

bind：只调用一次，指令`第一次绑定`到元素时调用。在这里可以进行一次性的初始化设置。
inserted：被绑定元素`插入`父节点时调用 (仅保证父节点存在，但不一定已被插入文档中)。
update：所在组件的 VNode `更新`时调用，但是可能发生在其子 VNode 更新之前。指令的值可能发生了改变，也可能没有。
componentUpdated：指令所在组件的 VNode 及其子 VNode `全部更新`后调用。
unbind：只调用一次，指令与元素解绑时调用。

## hooks参数
接下来我们来看一下钩子函数的参数 (即 el、binding、vnode 和 oldVnode)。

    el：指令所`绑定的元素`，可以用来直接操作 DOM 。
    binding：一个对象，包含以下属性：
        name：指令名，不包括 v- 前缀。
        value：指令的绑定值，例如：v-my-directive="1 + 1" 中，绑定值为 2。
        oldValue：指令绑定的前一个值，仅在 update 和 componentUpdated 钩子中可用。无论值是否改变都可用。
        expression：字符串形式的指令表达式。例如 v-my-directive="1 + 1" 中，表达式为 "1 + 1"。
        arg：传给指令的参数，可选。例如 v-my-directive:foo 中，参数为 "foo"。
        modifiers：一个包含修饰符的对象。例如：v-my-directive.foo.bar 中，修饰符对象为 { foo: true, bar: true }。
    vnode：Vue 编译生成的虚拟节点
    oldVnode：上一个虚拟节点，仅在 update 和 componentUpdated 钩子中可用。

## bind
    <div id="hook-arguments-example" v-demo:foo.a.b="message"></div>

    Vue.directive('demo', {
      bind: function (el, binding, vnode) {
        var s = JSON.stringify
        el.innerHTML =
          'name: '       + s(binding.name) + '<br>' +
          'value: '      + s(binding.value) + '<br>' +
          'expression: ' + s(binding.expression) + '<br>' +
          'argument: '   + s(binding.arg) + '<br>' +
          'modifiers: '  + s(binding.modifiers) + '<br>' +
          'vnode keys: ' + Object.keys(vnode).join(', ')
      }
    })

## 简写
在很多时候，你可能想在 bind 和 update 时触发相同行为，而不关心其它的钩子。比如这样写:

    Vue.directive('color-swatch', function (el, binding) {
        el.style.backgroundColor = binding.value
    })

# Render & JSX
Render 用于支持template 编程

    <anchored-heading :level="1">Hello world!</anchored-heading>

    Vue.component('anchored-heading', {
      render: function (createElement) {
        return createElement(
          'h' + this.level,   // tag name 标签名称
          this.$slots.default // 子组件中的阵列[<slot></slot>]
        )
      },
      props: {
        level: {
          type: Number,
          required: true
        }
      }
    })

## createElement(Virtual Dom)
createElement 不是创建原生dom, 而是Vnode

    // @returns {VNode}
    createElement(
      // {String | Object | Function| Async}
      'div',
    
      // {Object}。可选参数。
      // 一个包含模板相关属性的数据对象 这样，您可以在 template 中使用这些属性
      createElement('a', {
        attrs: {href: 'http://weibo.cn'},
        domProps: { value: self.value },
      }),
    
      // {String | Array}
      // 子节点 (VNodes)，由 `createElement()` 构建而成，
      // 或使用字符串来生成“文本节点”。可选参数。
      [
        '先写一些文字',
        createElement('h1', '一则头条'),
        createElement(MyComponent, {
          props: {
            someProp: 'foobar'
          }
        })
      ]
    )
    
### vnode 必须唯一
组件树中的所有 VNodes 必须是唯一的。这意味着，下面的 render function 是无效的：

    render: function (createElement) {
      var pVNode = createElement('p', 'hi')
      return createElement('div', [
        // 错误-重复的 id(pVNodes)
        pVNode, pVNode
      ])
    }

可以用createElement 创建不同的对象

    Array.apply(null, { length: 20 }).map(function () {
      return createElement('p', 'hi')
    })

### JavaScript 代替模板功能

    <ul v-if="items.length">
      <li v-for="item in items">{{ item.name }}</li>
    </ul>
    <p v-else>No items found.</p>

这些都会在 render 函数中被 JavaScript 的 if/else 和 map 重写：

    props: ['items'],
    render: function (createElement) {
      if (this.items.length) {
        return createElement('ul', this.items.map(function (item) {
          return createElement('li', item.name)
        }))
      } else {
        return createElement('p', 'No items found.')
      }
    }

### on, domProps
custom v-model:

    <custom-input :label="label" v-on:input="label=$event"> </custom-input>

    Vue.component('custom-input', { 
      render: function (createElement) {
        var self = this
        props: ['label', ],

        //template: 
        return createElement('input', {
          domProps: {
            value: self.label
          },
          on: {
            input: function (event) {
              self.$emit('input', event.target.value)
            }
          }
        })
      },
    });

### 事件修饰符
件 & 按键修饰符
对于 .passive、.capture 和 .once事件修饰符, Vue 提供了相应的前缀可以用于 on：

    Modifier(s)	Prefix
    .passive	&
    .capture	!
    .once	~
    .once.capture	~!

例如:

    on: {
      '!click': this.doThisInCapturingMode,
      '~keyup': this.doThisOnce,
      '~!mouseover': this.doThisOnceInCapturingMode
    }


### slot获取
你可以从 this.$slots 获取 VNodes 列表中的静态内容：

    render: function (createElement) {
        // `<div><slot></slot></div>`
        return createElement('div', this.$slots.default)
    }

还可以从 this.$scopedSlots 中获得能用作函数的作用域插槽(传值)

    props: ['message'],
    render: function (createElement) {
      // `<div><slot :text="message"></slot></div>`
      return createElement('div', [
        this.$scopedSlots.default({ text: this.message })
      ])
    }

#### $slots.default
    slots().default
    slots().foo 具名slot

## 函数式组件
函数式组件模板可以这样声明：

    <template functional>
    </template>

一个 函数式组件是无状态的, 无this实例

    Vue.component('my-component', {
      functional: true,
      props: {
        // ...
      },
      // 提供第二个参数作为上下文
      render: function (createElement, context) {
        return createElement('button', context.data, context.children)
      }
    })

在添加 functional=true 之后: 
1. this.$slots.default 更新为 context.children
2. this.level 更新为 context.props.level。
3. 非prop(data.attrs)、事件(listeners=data.on)，更新为 context.data

所以我们可以使用 data.attrs 传递任何 HTML 特性，也可以使用 listeners (即 data.on 的别名) 传递任何事件监听器。

    <template functional>
      <button
        class="btn btn-primary"
        v-bind="data.attrs"
        v-on="listeners"
      >
      </button>
    </template>

# 插件
vue-router/vue-touch/....

Vue.js 的插件应当有一个公开方法 install 。这个方法的第一个参数是 Vue 构造器，第二个参数是一个可选的选项对象：

    MyPlugin.install = function (Vue, options) {
      // 1. 添加全局方法或属性
      Vue.myGlobalMethod = function () {
        // 逻辑...
      }

      // 2. 添加全局资源
      Vue.directive('my-directive', {
        bind (el, binding, vnode, oldVnode) {
          // 逻辑...
        }
        ...
      })

      // 3. 注入组件
      Vue.mixin({
        created: function () {
          // 逻辑...
        }
        ...
      })

      // 4. 添加实例方法
      Vue.prototype.$myMethod = function (methodOptions) {
        // 逻辑...
      }
    }

## 使用插件

    // 调用 `MyPlugin.install(Vue)`
    Vue.use(MyPlugin)
    Vue.use(MyPlugin, { someOption: true })

    Vue.use(require('vue-router'))

# router

    path: '/post/:id'
         this.$route.params.id
    path: '/post/*'
        this.$route.params[0]

# 过滤器

    {{ message | capitalize | filterB }}
    <div v-bind:id="rawId | formatId"></div>

创建全局或组件过滤器

    Vue.filter('capitalize', function (value) {...})

    filters: {
      capitalize: function (value) {
        if (!value) return ''
        value = value.toString()
        return value.charAt(0).toUpperCase() + value.slice(1)
      }
    }

## 过滤器接受参数

    {{ message | filterA('arg2', arg3) }}

# 状态管理
这种有调试噩梦

    const sourceOfTruth = {}

    const vmA = new Vue({
      data: sourceOfTruth
    })

    const vmB = new Vue({
      data: sourceOfTruth
    })

我们用集中式状态管理store 模式：
更容易地理解哪种类型的 mutation 将会发生，以及它们是如何被触发. (Vuex 封装的更完善)

    var store = {
      debug: true,
      state: {
        message: 'Hello!'
      },
      setMessageAction (newValue) {
        if (this.debug) console.log('setMessageAction triggered with', newValue)
        this.state.message = newValue
      },
      clearMessageAction () {
        if (this.debug) console.log('clearMessageAction triggered')
        this.state.message = ''
      }
    }

    var vmA = new Vue({
      data: {
        privateState: {},
        sharedState: store.state
      }
    })

    var vmB = new Vue({
      data: {
        privateState: {},
        sharedState: store.state
      }
    })

# Single Vue 组件
https://codesandbox.io/s/o29j95wx9
