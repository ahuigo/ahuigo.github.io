---
title: tailwind group
date: 2023-03-07
private: true
---
# space between
    space-y-1 
    .space-y-4 > :not([hidden]) ~ :not([hidden]) {
        margin-top: 1rem;
        margin-bottom: 1rem;
    }

# children
## tailwind >=3.1

    <div class="[&>*]:p-4">...</div>
    <div class="[&>p]:mt-0 ">...</div>

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
