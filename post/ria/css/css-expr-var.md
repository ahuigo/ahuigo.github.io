---
title: css var
date: 2023-03-14
private: true
---
# css var
> Refer: https://hospodarets.com/css_properties_in_depth

## calc vs var
    :root {
        --width: 100px;
        --spacer: 2;
    }
    padding: var(--spacer)px
    width: calc(10px + 100px);
    width: calc(100% - 30px);
    width: calc(2em * 5);
    width: calc(var(--width) + 20px);

## var default
    /* header-color isn't set, and so remains blue, the fallback value */
    color: var( --header-color, blue);

    p {
        margin: var(--p-margin, 0 0 10px);
    }

## Scope 作用域

block scope:

    <div class="block">
      My block is
      <div class="block__highlight">awesome</div>
    </div>
    .block {
      --block-font-size: 1rem;
      font-size: var(--block-font-size);
    }

    .block__highlight {
      --block-highlight-font-size: 1.5rem;
      font-size: var(--block-highlight-font-size);
    }

Another simple example of the scope would be pseudo-classes (e.g. :hover):

    body {
      --bg: #f00;
      background-color: var(--bg);
      transition: background-color 1s;
    }

    body:hover {
      --bg: #ff0;
    }

## Reassign vars from others
    .block {
      --block-text: 'This is my block';
      --block-highlight-text: var(--block-text)' with highlight';
    }
## set/get in js
    // GET
    getComputedStyle(document.documentElement).getPropertyValue('--screen-category').trim();

    // SET
    document.documentElement.style.setProperty('--screen-category', 'custom');
## 内置变量
### currentColor
    :root { color: red; }
    div { border: 1px solid currentColor; }