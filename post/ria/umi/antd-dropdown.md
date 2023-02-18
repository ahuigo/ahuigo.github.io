---
title: antd dropdown
date: 2023-02-02
private: true
---
# antd dropdown
依赖: rc-dropdown -> rc-trigger

    git@github.com:react-component/dropdown.git rc-dropdown
    ->https://github.dev/react-component/dropdown/blob/master/src/Dropdown.tsx
        <Trigger popup={getMenuElementOrLambda()} > {renderChildren()} </Trigger>
        ->https://github.dev/react-component/trigger/src/index.tsx

# css dropdown demo
w3school

```
<style>
.dropdown {
  position: relative;
  display: inline-block;
}

.dropdown:hover .dropdown-content {
  display: block;
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: #f9f9f9;
  min-width: 160px;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
  padding: 12px 16px;
  z-index: 1;
}


</style>

<div class="dropdown">
  <h1>Mouse over me</h1>
  <div class="dropdown-content"><p>Hello World!</p></div>
</div>
```