---
date: 2018-05-15
title: Vue 的模板系统
---
# 属性合并
对于class/style 来说，它们会合并, 这是dom 自己决定的，不是vue 控制的

    <div is="tpl" class="cls1 cls2" :class="cls" :title="'title'"></div>

为了防止Render 冲突，外部的动态Render 应该放到Vue 后。参考这个例子：https://codepen.io/ahuigo/pen/dqPgJQ?

# 值的绑定
    new Vue({
        el: '#app',
        data: {
            message: 'hello',
            seen: true
        }
    })

## bind, 单向绑定
### bind text

    <h1>{{user.name}}</h1>
    //equal to
    <h1 v-text="user.name"></h1>

### v-html: literal

    <span v-html="rawHtml"></span>
    <pre v-pre>rawHTML</pre>

### bind attribute

    <span v-bind:title="message">
    <!-- 传递真正的数值( 1 不是变量) -->
    <comp v-bind:some-prop="1"></comp>

    <!-- 简写 -->
    <a :href="url"> ... </a>

bind bool attribute:
由于disabled/checked 本身是bool型，如果 isDisabled 的值为 null, undefined 或 false，`disabled 属性`不会被包含在渲染后的 `<button>` 元素中。

   <button :disabled="isDisabled">Button</button>

### bind all:

    <div v-bind="all">
    等价于
    <div v-bind:x1="all.x1">
    <div v-bind:x2="all.x2">


## v-model(双向)
Notice: v-model 不会设置name, `new FormData(formobj)` 不能取值

        <p>{{ message }}</p>
        <input v-model="message">
        <input :value="message" @input="message=$event.target.value">

        v-model.message="message" 等价

list 应该用$set 修改:

    <input :value="list[1]" @input="$root.$set(list, 1, $event.target.value)">

in select 

        <select v-model="selectedVal">
            <option disabled value="">请选择</option>
            <option>A</option>
            <option>B</option>
        </select>

type

    <input type="number" v-model.number="product.num">

### select

    <select v-model="selected">
    <option v-for="option in options" v-bind:value="option.value">
        {{ option.text }}
    </option>
    </select>
    <span>Selected: {{ selected }}</span>

### .lazy
    <!-- 在触发 "change" 事件后同步，而不是在触发 "input" 事件后更新 -->
    <input v-model.lazy="msg" >

### .number
如果想要将用户的输入，自动转换为 Number 类型

    <input v-model.number="age" type="number">

### .trim
如果想要将用户的输入，自动过滤掉首尾空格，可以在 v-model 之后添加一个 trim 修饰符，来处理输入值：

    <input v-model.trim="msg">

## javascript
任何js 表达式:

    {{ message.split('').reverse().join('') }}

每个绑定都只能包含单个表达式，所以以下示例都无法运行：

    <!-- 这是语句，不是表达式 -->
    {{ var a = 1 }}
    <!-- 流控制也无法运行，请使用三元表达式 -->
    {{ if (ok) { return message } }}

## template 会被去掉

    # template 会被去掉
    <template v-if="ok"> <h1>标题</h1> </template>

## 指令
### v-if:

    <div v-if="type === 'A'"> A </div>
    <div v-else-if="type === 'C'"> C </div>
    <div v-else> 非 A/B/C </div>

#### 使用key 控制可复用
使用key 以后，这些 input 将会在每次切换时从头重新渲染。（默认将保留输入值）

    <template v-if="loginType === 'username'">
        <label>用户名</label>
      <input placeholder="Enter your username" key="username-input">
    </template>
    <template v-else>
      <input placeholder="Enter your email address" key="email-input">
    </template>

### v-show
show 控制display, 类似if
具有 v-show 的元素会始终渲染并保留在 DOM 中

    <h1 v-show="ok">Hello!</h1>

v-if 是“真实”的条件渲染，因为它会确保条件块(conditional block)在切换的过程中，完整地销毁(destroy)和重新创建(re-create)条

v-if 也是惰性的：如果在初始渲染时条件为假，则什么也不做——直到条件第一次变为真时，才会开始渲染条件块。

### for:

    <li v-for="todo in todos"> </li>
    <span v-for="n in 10">range(10): {{ n }}</span>

for with if:

    <li v-for="todo in todos" v-if="!todo.isComplete">

for with index:

    <ul id="example-2">
        <li v-for="(item, index) in items">
            {{ parentMessage }} - {{ index }} - {{ item.message }}
        </li>
    </ul>
    var example2 = new Vue({
        el: '#example-2',
        data: {
            parentMessage: 'Parent',
            items: [
            { message: 'Foo' },
            { message: 'Bar' }
            ]
        }
    })

for with object

    <div v-for="value in object">
    <div v-for="(value, key) in object">
    <div v-for="(value, key, index) in object">

#### key
v-for 它默认用“就地复用”策略。如果数据项的顺序被改变，Vue 将不会移动 DOM 元素来匹配数据项的顺序

为了便于 Vue 跟踪每个节点的身份，从而重新复用(reuse)和重新排序(reorder)现有元素，你需要为每项提供唯一的 key 属性，

    <div v-for="item in items" :key="item.id">

#### 删除数据
1. 删除事件
    2. <button v-on:click="$emit('remove')">X</button>\
    2. v-on:remove="func" 由func 执行数据删除
2. o.pop(index)

### 简写

    <!-- 完整语法 -->
    <a v-bind:href="url"> ... </a>

    <!-- 简写 -->
    <a :href="url"> ... </a>

v-on 简写

    <!-- 完整语法 -->
    <a v-on:click="doSomething"> ... </a>

    <!-- 简写 -->
    <a @click="doSomething"> ... </a>


# computed

    {{reverseMessage}}
    {{reverseMessage}}
    console.log(vm.reversedMessage) // => 'olleH'

    data: {
        message: 'Hello'
    },
    computed: {
        // 一个 computed 属性的 getter 函数
        reversedMessage: function () {
            return this.message.split('').reverse().join('')
        }
    }

## computed 缓存 vs method 方法
vm.computed
vm.method() 会执行多次

## computed setter
computed 属性默认只设置 getter 函数，不过在需要时，还可以提供 setter 函数：

    // ...
    computed: {
        fullName: {
            // 默认getter 函数
            get: function () {
                return this.firstName + ' ' + this.lastName
            },
            // setter 函数
            set: function (newValue) {
                var names = newValue.split(' ')
                this.firstName = names[0]
                this.lastName = names[names.length - 1]
            }
        }
    }


# css
## class
class 只有两个值: true or false

### class 单值对象
active 这个 class 的存在与否，取决于 isActive 这个 data 属性的 truthy 值

    <div v-bind:class="{ active: isActive }"></div>

### class 对象
直接传classObject:

    <div v-bind:class="classObject"></div>
    data: {
        classObject: {
            active: true,
            'text-danger': false
        }
    }

也可以用computed、methods 返回对象

    computed: {
        classObject: function () {
            return {
            active: this.isActive && !this.error,
            'text-danger': this.error && this.error.type === 'fatal'
            }
        }
    }

### 数组语法(传className)
我们可以向 v-bind:class 传入一个数组，来与 class 列表对应：

    <div v-bind:class="[activeClass, errorClass]"></div>
    data: {
        activeClass: 'active',
        errorClass: 'text-danger'
    }
    会被渲染为：

    <div class="active text-danger"></div>

判断：

    <div v-bind:class="[isActive ? activeClass : '', errorClass]"></div>

### 组件追加

    Vue.component('my-component', {
        template: '<p class="foo bar">Hi</p>'
    })

然后，在调用组件时，再添加一些 class：

    <my-component class="baz boo"></my-component>

那么，最终渲染的 HTML 就是：

    <p class="foo bar baz boo">Hi</p>

同样，class 绑定也是如此：

    <my-component v-bind:class="{ active: isActive }"></my-component>

## style

    <div v-bind:style="{ color: activeColor, fontSize: fontSize + 'px' }"></div>
    data: {
        activeColor: 'red',
        fontSize: 30
    }

通常，一个比较好的做法是，直接与 data 中的 style 对象绑定，这样模板看起来更清晰：

    <div v-bind:style="styleObject"></div>
    data: {
        styleObject: {
            color: 'red',
            fontSize: '13px'
        }
    }

或者数组:

    <div v-bind:style="[baseStyles, overridingStyles]"></div>
    data:{
        baseStyles:{...}
    }

