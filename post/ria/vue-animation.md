---
title: transition
date: 2018-10-04
---
# transition
https://cn.vuejs.org/v2/guide/transitions.html

## 单元素、组件过渡
添加元素、组件的进入/离开过渡, 下列情形
1. 条件渲染 (使用 v-if)
1. 条件展示 (使用 v-show: display)
1. 动态组件
1. 组件根节点

添加 fade：

    <div id="demo">
      <button v-on:click="show = !show">
        Toggle
      </button>
      <transition name="fade">
        <p v-if="show">hello</p>
      </transition>
    </div>

css 

    .fade-enter-active, .fade-leave-active {
      transition: opacity .5s;
    }
    .fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
      opacity: 0;
    }

当插入或删除包含在 transition 组件中的元素时，Vue 将会做以下处理：

1. 自动嗅探目标元素是否应用了 CSS 过渡或动画，如果是，在恰当的时机添加/删除 CSS 类名。
2. 如果过渡组件提供了 JavaScript 钩子函数，这些钩子函数将在恰当的时机被调用。
2. 如果没有找到 JavaScript 钩子并且也没有检测到 CSS 过渡/动画，DOM 操作 (插入/删除) 在下一帧中立即执行

### 过渡类名
在进入/离开的过渡中，会有 6 个 class 切换。

    v-enter: 
        v-enter：定义进入过渡的开始状态。插入完成的下一帧移除
        v-enter-active：定义进入过渡生效时的状态。过渡/动画完成之后移除
        v-enter-to: 定义进入过渡的结束状态。在过渡/动画完成之后移除。

    v-leave: 
        v-leave: 定义离开过渡的开始状态。过渡被触发时立刻生效，下一帧被移除
        v-leave-active：在过渡/动画完成之后移除
        v-leave-to: 在过渡/动画完成之后移除

类名前缀
1. 如果你使用一个没有名字的 `<transition>`，则 `v-` 是这些类名的默认前缀。
2. 如果你使用了 <transition name="fade-x">，那么 `v-enter` 会替换为 `fade-x-enter`(见上面的例子)

### css 过渡
常用的过渡都是使用 CSS 过渡。

    <div id="example-1">
      <button @click="show = !show">
        Toggle render
      </button>
      <transition name="slide-fade">
        <p v-if="show">hello</p>
      </transition>
    </div>

css

    .slide-fade-enter-active {
      transition: all .3s ease;
    }
    .slide-fade-leave-active {
      transition: all .8s cubic-bezier(1.0, 0.5, 0.8, 1.0);
    }
    /* 进入前，和离开后的状态一样的 */ {
    .slide-fade-enter, .slide-fade-leave-to
      transform: translateX(10px);
      opacity: 0;
    }

### css animation
CSS 动画用法同 CSS 过渡，区别是在动画中 v-enter 类名在节点插入 DOM 后不会立即删除，而是在 animationend 事件触发时删除。

    <div id="example-2">
      <button @click="show = !show">Toggle show</button>
      <transition name="bounce">
        <p v-if="show">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris facilisis enim libero, at lacinia diam fermentum id. Pellentesque habitant morbi tristique senectus et netus.</p>
      </transition>
    </div>

    .bounce-enter-active {
      animation: bounce-in .5s;
    }
    .bounce-leave-active {
      animation: bounce-in .5s reverse;
    }
    @keyframes bounce-in {
      0% {
        transform: scale(0);
      }
      50% {
        transform: scale(1.5);
      }
      100% {
        transform: scale(1);
      }
    }

### 自定义类名
适合第三方Animate.css 自定义类名

    <link href="https://cdn.jsdelivr.net/npm/animate.css">
    <transition
        name="custom-classes-transition"
        enter-active-class="animated tada"
        leave-active-class="animated bounceOutRight"
    >

### 同时使用过渡和动画
Vue 为了知道过渡的完成，必须设置相应的事件监听器。如果你使用其中任何一种: transitionend 或 animationend，Vue 能自动识别类型并设置监听。

如果你给同一个元素同时设置两种过渡动效，比如 animation 很快的被触发并完成了，而 transition 效果还没结束。在这种情况中，你就需要使用 type 特性并设置 animation 或 transition 来明确声明你需要 Vue 监听的类型。

### 显性的过渡持续时间
1. 默认情况下，Vue 会等待其在过渡效果的根元素的第一个 transitionend 或 animationend 事件。
然而，如果一些`内部元素`相比于过渡效果的根元素`有延迟`的或`更长的过渡效果`。就需要加durationms()

    <transition :duration="1000">...</transition>

你也可以定制进入和移出的持续时间：

    <transition :duration="{ enter: 500, leave: 800 }">...</transition>

### JavaScript 钩子
可以在属性中声明 JavaScript 钩子

    <transition
      v-on:before-enter="beforeEnter"
      v-on:enter="enter"
      v-on:after-enter="afterEnter"
      v-on:enter-cancelled="enterCancelled"

      v-on:before-leave="beforeLeave"
      v-on:leave="leave"
      v-on:after-leave="afterLeave"
      v-on:leave-cancelled="leaveCancelled"
    >
    </transition>

    methods: {
        beforeEnter: function (el) {
            // ...
        },

## 初始渲染的过渡
可以通过 appear 特性设置节点在初始渲染的过渡

    <transition appear>
    </transition>

这里默认和进入/离开过渡一样，同样也可以自定义 CSS 类名、过渡钩子hooks

    <transition appear 
        appear-class="custom-appear-class"
        appear-to-class="custom-appear-to-class" (2.1.8+)
        appear-active-class="custom-appear-active-class"
    >

## 多个元素过渡
当有相同标签名的元素切换时，需要通过 key 特性设置唯一的值来标记以让 Vue 区分它们，否则 Vue 为了效率只会替换相同标签内部的内容。

    <transition>
      <button v-if="isEditing" key="save">
        Save
      </button>
      <button v-else key="edit">
        Edit
      </button>
    </transition>

    <transition>
      <button v-bind:key="isEditing">
        {{ isEditing ? 'Save' : 'Edit' }}
      </button>
    </transition>

## 多元素过渡模式
比如 “on” 按钮和 “off” 按钮的过渡中，一个离开过渡的时候另一个开始进入过渡。为避免进入和离开同时发生。

1. in-out：新元素先进行过渡，完成之后当前元素过渡离开。
2. out-in：当前元素先进行过渡，完成之后新元素过渡进入。

用 out-in 重写之前的开关按钮过渡：

    <transition name="fade" mode="out-in">
        <!-- ... the buttons ... -->
    </transition>

## 多个组件的过渡
多个组件的过渡简单很多 - 我们不需要使用 key 特性。相反，我们只需要使用动态组件：

    <transition name="component-fade" mode="out-in">
      <component v-bind:is="view"></component>
    </transition>

## 列表过渡
同时渲染整个列表，比如使用 v-for 在这种场景中，使用 `<transition-group>` 组件

1. 过渡模式不可用，因为我们不再相互切换特有的元素。
2. 不同`<transition>`，你需要选定tag：默认`tag="span"`
3. 内部元素 总是需要 提供唯一的 key 属性值。

其他都一样, 示例 列表的进入-离开过渡
https://cn.vuejs.org/v2/guide/transitions.html#列表的进入-离开过渡

### 列表的排序过渡
transition-group 组件还有一个特殊之处。
1. 不仅可以进入和离开动画，还可以通过`v-move`改变定位，它会在元素的改变定位(eg.shuffle)的过程中应用。
2. 像之前的类名一样，可以通过 name 属性来自定义前缀，也可以通过 move-class 属性手动设置。

e.g.

    <div id="flip-list-demo" class="demo">
      <button v-on:click="shuffle">Shuffle</button>
      <transition-group name="flip-list" tag="ul">
        <li v-for="item in items" v-bind:key="item">
          {{ item }}
        </li>
      </transition-group>
    </div>

    new Vue({
      el: '#flip-list-demo',
      data: { items: [1,2,3,4,5,6,7,8,9] },
      methods: {
        shuffle: function () {
          this.items = _.shuffle(this.items)
        }
      }
    })

    .flip-list-move {
      transition: transform 1s;
    }

### 列表的交错过渡
通过 data 属性与 JavaScript hooks 通信 ，就可以实现列表的交错过渡：

## 可复用的过渡
你需要做的就是将 `<transition> 或者 <transition-group>` 作为根组件，然后将任何子组件放置在其中就可以了

    Vue.component('my-special-transition', {
      template: '\
        <transition\
          name="very-special-transition"\
          mode="out-in"\
          v-on:before-enter="beforeEnter"\
          v-on:after-enter="afterEnter"\
        >\
          <slot></slot>\
        </transition>\
      '

## 动态过渡
最基本的例子是通过 name 特性来绑定动态值; 或者通过hooks 实现更复杂的过渡

    <transition v-bind:name="transitionName">
    <!-- ... -->
    </transition>