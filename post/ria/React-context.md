---
title: React Context
date: 2019-09-07
private:
---
# React Context
Context 解决的是向孙子组件传值的问题。如主题、偏好

## 利用依赖注入传代替大量传值 
比如，考虑这样一个 Page 组件，它层层向下传递 user 和 avatarSize 属性，从而深度嵌套的 Link 和 Avatar 组件可以读取到这些属性：

    <Page user={user} avatarSize={avatarSize} />
        // ... 渲染出 ...
        <PageLayout user={user} avatarSize={avatarSize} />
            // ... 渲染出 ...
            <NavigationBar user={user} avatarSize={avatarSize} />
                // ... 渲染出 ...
                <Link href={user.permalink}>
                    <Avatar user={user} size={avatarSize} />
                </Link>

层层传递这两个 props 就显得非常冗余。而且一旦 Avatar 组件需要更多从来自顶层组件的 props，你还得在中间层级一个一个加上去，这将会变得非常麻烦。
一种解决方法，是直传Avatar

    const userLink = <Link href={user.permalink}>
        <Avatar user={user} size={avatarSize} />
    </Link>
    <Page userLink={userLink} />
    // ... 渲染出 ...
    <PageLayout userLink={props.userLink} />
    // ... 渲染出 ...
    <NavigationBar userLink={props.userLink} />
    // ... 渲染出 ...
    {props.userLink}

中单组件不用传那么多的值。但是，这种将逻辑提升到组件树的更高层次来处理，会使得这些高层组件变得更复杂


## Context demo1
下面以主题为例

    // 默认值light theme（可单独封装）
    const ThemeContext = React.createContext('light');
    export default ThemeContext

    class App extends React.Component {
     render() {
       // 在这个例子中，我们将 “dark” 作为当前的值传递下去。
       return (
         <ThemeContext.Provider value="dark">
           <Toolbar />
         </ThemeContext.Provider>
       );
     }
    }

    Toolbar = (props)=><ThemedButton />

    class ThemedButton extends React.Component {
      // 指定 contextType 读取当前的 theme context。
      // React 会往上找到最近的 theme Provider，然后使用它的值。
      // 在这个例子中，当前的 theme 值为 “dark”。
      static contextType = ThemeContext;
      render() {
        return <Button theme={this.context} />;
      }
    }

## Provide
    <MyContext.Provider value={/* 某个值 */}>

Provider 接收一个 value 属性，传递给消费组件。一个 Provider 可以和多个消费组件有对应关系。
1. 多个 Provider 也可以嵌套使用，里层的会覆盖外层的数据。
2. 当 Provider 的 value 值发生变化时，它内部的所有消费组件都会重新渲染。consumer 不受制于 shouldComponentUpdate 函数
3. 通过新旧值检测来确定变化，使用了与 Object.is 相同的算法。


## contextType 订阅单个
挂载在 class 上的 contextType 订阅this.context。通过 this.context 来消费最近 Context 上的值

    class MyClass extends React.Component {
        // MyClass.contextType = MyContext;
        static contextType = MyContext;

        componentDidMount() {
            let value = this.context;
            /* 在组件挂载完成后，使用 MyContext 组件的值来执行一些有副作用的操作 */
        }
        componentDidUpdate() {
            let value = this.context;
            /* ... */
        }
        componentWillUnmount() {
            let value = this.context;
            /* ... */
        }
        render() {
            let value = this.context;
            /* 基于 MyContext 组件的值进行渲染 */
        }
    }

## Consumer 订阅多个
    <MyContext.Consumer>
        /* Provider 提供的 value 值*/
        {value => <div name={value} />}
    </MyContext.Consumer>

多个嵌套

    class App extends React.Component {
      render() {
        const {signedInUser, theme} = this.props;

        // 提供初始 context 值的 App 组件
        return (
          <ThemeContext.Provider value={theme}>
            <UserContext.Provider value={signedInUser}>
              <Content />
            </UserContext.Provider>
          </ThemeContext.Provider>
        );
      }
    }

    // 一个组件可能会消费多个 context
    function Content() {
      return (
        <ThemeContext.Consumer>
          {theme => (
            <UserContext.Consumer>
              {user => (
                <ProfilePage user={user} theme={theme} />
              )}
            </UserContext.Consumer>
          )}
        </ThemeContext.Consumer>
      );
    }

## Note: consumer 重绘
当每一次 Provider 重渲染时，以下的代码会重渲染所有下面的 consumers 组件，因为 value 属性总是被赋值为新的对象：

          <Provider value={{something: 'something'}}>
            <Toolbar />
          </Provider>

为了防止这种情况，将 value 状态提升到父节点的 state 里：

    class App extends React.Component {
      constructor(props) {
        super(props);
        this.state = {
          value: {something: 'something'},
        };
      }

      render() {
        return (
          <Provider value={this.state.value}>
            <Toolbar />
          </Provider>
        );
      }
    }