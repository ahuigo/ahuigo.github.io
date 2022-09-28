---
title: React diff
date: 2019-09-09
---
# Diff 的设计动力
在 state 或 props 更新时，相同的 render() 方法会返回一棵新的树。React 需要基于这两棵树之间的差别来判断如何有效率的更新 UI 以保证当前 UI 与最新的树保持同步。

这个算法问题有一些通用的解决方案，即生成将一棵树转换成另一棵树的最小操作数。 然而，即使在最前沿的算法中，该算法的复杂程度为 O(n 3 )，其中 n 是树中元素的数量。 React 在以下两个假设的基础之上提出了一套 O(n) 的启发式算法：

1. 两个不同类型的元素会产生出不同的树；
2. 开发者可以通过 key prop 来暗示哪些子元素在不同的渲染下能保持稳定；
在实践中，我们发现以上假设在几乎所有实用的场景下都成立。

# Diff 算法
当对比两颗树时，React 首先比较两棵树的根节点。不同类型的根节点元素会有不同的形态。
## 类型比对 
### 比对不同类型的元素
当根节点为不同类型的元素时，React 会拆卸原有的树并且建立起新的树。举个例子，

    当一个元素从 <a> 变成 <img>，
    从 <Article> 变成 <Comment>，
    或从 <Button> 变成 <div> 都会触发一个完整的重建流程。

当拆卸一颗树时
1. 对应的 DOM 节点也会被销毁。组件实例将执行 `componentWillUnmount()` 方法。

当建立一颗新的树时:
1. 对应的 DOM 节点会被创建以及插入到 DOM 中。
2. 组件实例将执行 `componentWillMount()` 方法，
3. 紧接着 componentDidMount() 方法。所有跟之前的树所关联的 state 也会被销毁。

    在根节点以下的组件也会被卸载，它们的状态会被销毁。比如，当比对以下更变时：

    <div>
        <Counter />
    </div>

    <span>
        <Counter />
    </span>

React 会销毁 Counter 组件并且重新装载一个新的组件。

### 比对同一类型的元素
当比对两个相同类型的 React 元素时，React 会保留 DOM 节点，仅比对及更新有改变的属性。比如：
通过比对这两个元素，React 知道只需要修改 DOM 元素上的 className 属性。

    <div className="before" title="stuff" />
    <div className="after" title="stuff" />


当更新 style 属性时，React 仅更新有所更变的属性。比如：
通过比对这两个元素，React 知道只需要修改 DOM 元素上的 color 样式，无需修改 fontWeight。

    <div style={{color: 'red', fontWeight: 'bold'}} />
    <div style={{color: 'green', fontWeight: 'bold'}} />

在处理完当前节点之后，React 继续对子节点进行递归。

### 比对同类型的组件元素
1. 当一个组件更新时，组件实例保持不变，这样 state 在跨越不同的渲染时保持一致。
2. React 将更新该组件实例的 props 以跟最新的元素保持一致，并且调用该实例的 componentWillReceiveProps() 和 componentWillUpdate() 方法。

下一步，调用 render() 方法，diff 算法将在之前的结果以及新的结果中进行递归。

## 对子节点进行递归
在默认条件下，当递归 DOM 节点的子元素时，React 会同时遍历两个子元素的列表；当产生差异时，生成一个 mutation。

在子元素列表末尾新增元素时，更变开销比较小。比如：

    <ul>
      <li>first</li>
      <li>second</li>
    </ul>

    <ul>
      <li>first</li>
      <li>second</li>
      <li>third</li>
    </ul>

React 会先匹配 `<li>first</li>` 对应的树，然后匹配第二个元素 `<li>second</li>` 对应的树，最后插入第三个元素的 <li>third</li> 树。

如果在列表头部插入会很影响性能，那么更变开销会比较大。比如：

    <ul>
      <li>Duke</li>
      <li>Villanova</li>
    </ul>

    <ul>
      <li>Connecticut</li>
      <li>Duke</li>
      <li>Villanova</li>
    </ul>

React 会针对每个子元素 mutate销毁和重建, `<li>Duke</li> 和 <li>Villanova</li>` 子树会被销毁和重建，元素一多可能导致性能问题

### Keys
为了解决以上问题，React 支持 key 属性。当子元素拥有 key 时，React 使用 key 来匹配原有树上的子元素以及最新树上的子元素。
仅当 key 变化时， React 会创建一个新的而不是更新一个既有的组件

    <EmailInput key={this.props.user.id} />

以下例子在新增 key 之后使得之前的低效转换变得高效：

    <ul>
      <li key="2015">Duke</li>
      <li key="2016">Villanova</li>
    </ul>

    <ul>
      <li key="2014">Connecticut</li>
      <li key="2015">Duke</li>
      <li key="2016">Villanova</li>
    </ul>

现在 React 知道只有带着 '2014' key 的元素是新元素，带着 '2015' 以及 '2016' key 的元素仅仅移动了。

    <li key={item.id}>{item.name}</li>

你可以用一部分内容作为哈希值来生成一个 key。这个 key 不需要全局唯一，但在列表中需要保持唯一。
#### 不用index 当key
最后，你也可以使用元素在数组中的下标作为 key。这个策略在元素不进行重新排序时比较合适，

如果 key 是一个下标，那么修改顺序时会修改当前的 key，导致非受控组件的 state（比如输入框）可能相互篡改导致无法预期的变动。

## 执行但不render
    function App(props){
        const [c,setClick] = useState(0);
        const [a,setA] = useState(0);
        console.log('renderApp',a,c)
        return (<Provider store={store}>
            <div>
                <h1 onClick={e=>{ setA(1) }}
                >a: {a}; {(e=>{console.log('执行但不render');return Math.random()})()}</h1>
                {a<5 && <Child a={1} pclick={setClick.bind(this)} /> }
            </div>
        </Provider>)
    }

# 权衡
我们定期探索优化协调算法。在当前的实现中，
1. 可以理解为一棵子树能在其`兄弟之间`移动，但不能移动到其他位置。在这种情况下，算法会重新渲染整棵子树。
2. 该算法`不会尝试匹配不同组件类型`的子树。如果你发现你在两种不同类型的组件中切换，但输出非常相似的内容，建议把它们改成同一类型。
3. 不稳定的 key（比如通过 Math.random() 生成的）会导致许多组件实例和 DOM 节点被不必要地重新创建

