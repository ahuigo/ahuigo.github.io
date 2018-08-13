# mixins
混入 (mixins) 用于分发 Vue 组件中可复用功能

    // 定义一个混入对象
    var myMixin = {
      created: function () {
        this.hello()
      },
      methods: {
        hello: function () {
          console.log('hello from mixin!')
        }
      }
    }

    // 定义一个使用混入对象的组件
    var Component = Vue.extend({
      mixins: [myMixin]
    })

    var component = new Component() // => "hello from mixin!"

## 选项合并的优先级
### 组件data同名优先

    var mixin = {
      data: function () {
        return {
          message: 'hello',
          foo: 'abc'
        }
      }
    }

    new Vue({
      mixins: [mixin],
      data: function () {
        return {
          message: 'goodbye',
          bar: 'def'
        }
      },
      created: function () {
        console.log(this.$data)
        // => { message: "goodbye", foo: "abc", bar: "def" }
      }
    })

混入对象的钩子将在组件自身钩子之前调用。

    var mixin = {
      created: function () {
        console.log('混入对象的钩子被调用')
      }
    }

    new Vue({
      mixins: [mixin],
      created: function () {
        console.log('组件钩子被调用')
      }
    })

    // => "混入对象的钩子被调用"
    // => "组件钩子被调用"

### 全局混入
    Vue.mixin({
      created: function () {
        var myOption = this.$options.myOption
        if (myOption) {
          console.log(myOption)
        }
      }
    })

    new Vue({
      myOption: 'hello!'
    })
    // => "hello!"

### 自定义选项合并策略
在合并自定义选项(custom option)时，Vue 会使用默认策略，即覆盖已有值。

如果想要定制自定义选项的合并逻辑，则需要向 `Vue.config.optionMergeStrategies` 添加一个函数：

    Vue.config.optionMergeStrategies.myOption = function (toVal, fromVal) {
		.... 合并策略
        // return mergedVal
    }

对于大多数基于对象(object-based)的选项，可以使用 methods 的合并策略：

    var strategies = Vue.config.optionMergeStrategies
    strategies.myOption = strategies.methods

高级的例子可以在 Vuex 的 1.x 混入策略里找到：

    const merge = Vue.config.optionMergeStrategies.computed
    Vue.config.optionMergeStrategies.vuex = function (toVal, fromVal) {
      if (!toVal) return fromVal
      if (!fromVal) return toVal
      return {
        getters: merge(toVal.getters, fromVal.getters),
        state: merge(toVal.state, fromVal.state),
        actions: merge(toVal.actions, fromVal.actions)
      }
    }


