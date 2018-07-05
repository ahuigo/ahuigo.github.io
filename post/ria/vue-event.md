# event(v-on:event)
使用 $on(eventName) 监听事件
使用 $emit(eventName, optionalPayload) 触发事件

## event type
1. click,remove,keyup.enter

### v-on(@)
event: click,input,change, keyup.enter,blur...

    <button v-on:click="reverseMessage">reverse_message</button>
    methods: {
        reverseMessage: function (e) {
            this.message = this.message.split('').reverse().join('')
        }
    }

    <dt contenteditable="true" v-on:blur="update(t, 'name', $event)">{{ t.name }}</dt>


组件emit 还支持自定义: remove....

v-model 是基于input

    <input v-model="message">
    <input :value="message" @input="message=$event.target.value">

#### v-on:keyup.enter
回车按下后：

    <input v-on:keyup.enter="addNewTodo">

## modifier
`.prevent` 修饰符告诉 v-on 指令，在触发事件后调用 `event.preventDefault()`：
1. .capture 先捕获(再处理内部元素)
1. .stop 停止事件冒泡
1. .prevent 阻止默认action
2. .self
2. .once


    <!-- 停止点击事件冒泡 -->
    <a v-on:click.stop="doThis"></a>

    <!-- 提交事件不再重新载入页面 -->
    <form v-on:submit.prevent="onSubmit"></form>

    <!-- 修饰符可以链式调用 -->
    <a v-on:click.stop.prevent="doThat"></a>

    <!-- 只有修饰符 -->
    <form v-on:submit.prevent></form>

    <!-- 内部元素触发的事件先在此处处理，然后才交给内部元素进行处理 -->
    <div v-on:click.capture="doThis">...</div>

    <!-- 只有在 event.target 是元素自身时，才触发处理函数。 -->
    <div v-on:click.self="doThat">...</div>

.passive修饰符，对应 addEventListener 的 passive 选项。

    <!-- 滚动事件的默认行为（滚动）将立即发生， -->
    <!-- 而不是等待 `onScroll` 完成后才发生， -->
    <!-- 以防在滚动事件的处理程序中含有 `event.preventDefault()` 调用 -->
    <div v-on:scroll.passive="onScroll">...</div>

### modifier 顺序的影响
使用修饰符时的顺序会产生一些影响，因为相关的代码会以相同的顺序生成。所以，
1. 使用 v-on:click.prevent.self 会阻止所有点击，
2. 而 v-on:click.self.prevent 只阻止元素自身的点击。

### 按键修饰符(Key Modifiers)
在监听键盘事件时，我们经常需要查找常用按键对应的 code 值。Vue 可以在 v-on 上添加按键修饰符，用于监听按键事件：

    <!-- 只在 `keyCode` 是 13 时，调用 `vm.submit()` -->
    <input v-on:keyup.13="submit">
    <input @keyup.13="submit">

记住所有 keyCode 是非常麻烦的事，所以 Vue 提供一些最常用按键的别名：

    .enter
    .tab
    .delete (捕获“删除”和“退格”按键)
    .esc
    .space
    .up
    .down
    .left
    .right
    .page-down $event.key === 'PageDown'

辅助键:

    .ctrl
    .alt
    .shift
    .meta

    <!-- Alt + C -->
    <input @keyup.alt.67="clear">

    <!-- Ctrl + Click -->
    <div @click.ctrl="doSomething">做一些操作</div>

.exact 修饰符可以控制触发事件所需的系统辅助按键的准确组合。
注意：mac下click.ctrl 相当是click.right

    <!-- 如果 Alt 键或 Shift 键与  Ctrl 键同时按下，也会触发事件 -->
    <button @click.ctrl="onClick">A</button>

    <!-- 只在 Ctrl 按键按下，其他按键未按下时，触发事件 -->
    <button @click.ctrl.exact="onCtrlClick">A</button>

    <!-- 只在系统辅助按键按下时，触发事件 -->
    <button @click.exact="onClick">A</button>

#### 鼠标按键修饰符(Mouse Button Modifiers)

    click.left
    click.right
    click.middle

## handler
普通表达式

    v-on:click="counter+=1"

methods(不带参数):

    <button v-on:click="greet">Greet</button>
    methods: {
        greet: function (event) {
            // `event` 是原始 DOM 事件对象
            alert(event.target.tagName)
        }
    }

methods(带参数):

    <button v-on:click="greet('hello', $event)">


