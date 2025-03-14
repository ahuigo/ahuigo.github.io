---
title: tailwind group
date: 2023-03-07
private: true
---
# class on parent(trigger by self)
## space between
space-y-4 :

    .space-y-4 > :not([hidden]) ~ :not([hidden]) {
        margin-top: 1rem;
        margin-bottom: 1rem;
    }

### tailwind >=3.1
改变**所有子元素**的样式:

    class="*:p-4"
        .\*\:p-4 > * {}

作用在**子元素hover**, 改变**所有子元素**的样式:

    <div class="[&>*:hover]:p-4"> </div>
        .\[\&\>\*\:hover\]\:p-4>*:hover { }
    <div class="[&>p]:hover:mt-0 ">...</div>

作用在**父元素hover**, 改变**所有子元素**的样式(same as group,`[&>*]:p-4` 与　`*:p-4` 等价)

    <div class="[&>*]:hover:p-4"> </div>
        .\[\&\>\*\]\:hover\:p-4:hover>* { }
    <div class="[&>p]:hover:mt-0 ">...</div>

注意：以下的 `&>` 与`&_`不同，　后者是孙子节点

    [&>.ant-pro-card-body]:[padding-block:4px]
        [&>.ant-pro-card-body]:[padding-block:4px]>.ant-pro-card-body{}
    [&_.ant-pro-card-body]:[padding-block:4px]
        [&>.ant-pro-card-body]:[padding-block:4px] .ant-pro-card-body{}

## via plugin
in tailwind.config.js, demo: https://play.tailwindcss.com/h7eDGStsE9?file=config

    plugins: [
        function ({ addVariant }) {
            addVariant('children', '& > *');
            addVariant('child-hover', '& > *:hover');
        }
    ],

then use:

    children:p-4 children:text-white 
    child-hover:text-blue-500

### odd+children

    odd:children:bg-gray-100 even:children:bg-blue-500
    # 编译为：
    .odd:children:bg-gray-100 > *:nth-child(odd) {
        background-color: rgb(243 244 246);
    }

# class on children
https://stackoverflow.com/questions/65946335/how-to-make-parent-div-activate-styling-of-child-div-for-hover-and-active

## group(trigger by parent)

    <div class="group">
        <div class="group-hover:bg-red-100">...<div>
        <div class="group-hover:bg-red-100">...<div>
    </div>

作用在父元素`.group:hover`, 修改的所有子元素`.group-hover\:bg-red-500`

    .group:hover .group-hover\:bg-red-500 {
        --tw-bg-opacity: 1;
        background-color: rgb(239 68 68 / var(--tw-bg-opacity));
    }

## odd and even
note:　odd/even 控制也是自己

    .even\:p-2:nth-child(even) {
        padding: 0.5rem;
    }

  <tbody>
    {#each people as person}
      <!-- Use a white background for odd rows, and slate-50 for even rows -->
      <tr class="even:p-2 odd:bg-white ">
        <td>{person.name}</td>
        <td>{person.title}</td>
        <td>{person.email}</td>
      </tr>
    {/each}
  </tbody>
