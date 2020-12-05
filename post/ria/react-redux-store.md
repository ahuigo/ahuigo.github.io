---
title: redux store read
date: 2020-12-04
private: true
---
# redux store read

https://stackoverflow.com/questions/38332912/how-do-i-access-store-state-in-react-redux
```js
import store from '../reducers/store';

class Items extends Component {
  constructor(props) {
    super(props);

    this.state = {
      items: [],
    };

    store.subscribe(() => {
      // When state will be updated(in our case, when items will be fetched), 
      // we will update local component state and force component to rerender 
      // with new data.

      this.setState({
        items: store.getState().items;
      });
    });
  }

  render() {
    return (
      <div>
        {this.state.items.map((item) => <p> {item.title} </p> )}
      </div>
    );
  }
};

render(<Items />, document.getElementById('app'));
```