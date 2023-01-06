---
title: pass props to children
date: 2023-01-06
private: true
---
# Add props to childrend
https://stackoverflow.com/questions/32370994/how-to-pass-props-to-this-props-children

    const Child = ({ childName, sayHello }) => (
      <button onClick={() => sayHello(childName)}>{childName}</button>
    );

    function Parent({ children }) {
      // We pass this `sayHello` function into the child elements.
      function sayHello(childName) {
        console.log(`Hello from ${childName} the child`);
      }

      const childrenWithProps = React.Children.map(children, child => {
        // Checking isValidElement is the safe way and avoids a
        // typescript error too.
        if (React.isValidElement(child)) {
          return React.cloneElement(child, { sayHello });
        }
        return child;
      });

      return <div>{childrenWithProps}</div>
    }

    function App() {
      // This approach is less type-safe and Typescript friendly since it
      // looks like you're trying to render `Child` without `sayHello`.
      // It's also confusing to readers of this code.
      return (
        <Parent>
          <Child childName="Billy" />
          <Child childName="Bob" />
        </Parent>
      );
    }

    ReactDOM.render(<App />, document.getElementById("container"));