---
title: React Component
date: 2019-05-02
---
# React Component

## ref
ref Allow you to ref a component or dom node

        # component this.myTextInput.refs.xxx
        <Dialog ref="myTextInput" />
        <Dialog ref={(ref) => this.myTextInput = ref} />

        # dom this.myTextInput.value
        <input type="text" ref={(ref) => this.myTextInput = ref} />

        # this.myTextInput.current.addEventlistener
        <input type="text" ref={this.myTextInput} />

ref 引用不可以放到render, 只能放render 之外的函数：

    class MovieItem extends React.Component {
        handleClick: function() {
            // Explicitly focus the text input using the raw DOM API.
            this.myTextInput.focus();
            ReactDOM.findDOMNode(this).addEventListener('nv-focus', this.handleNVFocus);
        },
        render: function() {
            return (
                <div>
                    <input type="text" ref={(ref) => this.myTextInput = ref} />
                    <input type="button" value="Focus the text input" onClick={this.handleClick} />
                </div>
            );
        }
    });
