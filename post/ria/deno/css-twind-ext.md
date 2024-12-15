---
title: tailwind
date: 2023-03-17
private: true
---
# tailwind 指令
> Refer　to：https://juejin.cn/post/6902291855782707214 @xxholly32 
> https://www.tailwindcss.cn/docs/functions-and-directives

## @apply
实现类的组合复用, 参考　https://tailwindcss.com/docs/reusing-styles#extracting-classes-with-apply　我们扩展一下`@layer components`

    <!-- After extracting a custom class -->
    <button class="btn-primary">
      Save changes
    </button>

    // tailwind.css
    @tailwind base;
    @tailwind components;
    @tailwind utilities;

    @layer components {
      .btn-primary {
        @apply py-2 px-4 bg-blue-500 text-white font-semibold rounded-lg shadow-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75;
      }
      .btn-blue:hover {
        @apply bg-blue-700;
        @apply font-bold;
      }
    }

不使用配置，直接在行内使用apply

    <style>
      .btn {
        @apply py-2 px-4 font-semibold rounded-lg shadow-md;
      }
      .btn-green {
        @apply text-white bg-green-500 hover:bg-green-700;
      }
    </style>
    <button class="btn btn-green"> Button </button>

## 其它tailwind 指令
1. @tailwind：使用 @Tailwind 指令将 Tailwind 的 base, components, utilities 插入到 CSS 中。
1. @apply：使用 @apply 将任何样式内联到您自己的自定义 CSS 中。
1. @layer：使用 @layer 指令告诉 Tailwind 属于一组自定义样式的 “块”。在 base, components, utilities 有效。
1. @variants：您可以通过在 @variant 指令中包装它们的定义来生成响应式、hover, focus, active 和其他伪类。
1. @responsive：声明响应式变体。

## @variants
    @tailwind base;
    @tailwind components;
    @tailwind utilities;

    @layer utilities {
        @variants focus, hover {
          .rotate-90 {
            transform: rotate(90deg);
          }
        }
    }

这将生成以下 CSS：

    .rotate-90 {
      transform: rotate(90deg);
    }

    .focus\:rotate-90:focus {
      transform: rotate(90deg);
    }

    .hover\:rotate-90:hover {
      transform: rotate(90deg);
    }

## @responsive
    @responsive {
      .bg-gradient-brand {
        background-image: linear-gradient(blue, green);
      }
    }

这是 `@variants responsive { ... }` 的简写方式，同样起作用。 使用默认断点，这将生成以下类：

    .bg-gradient-brand {
      background-image: linear-gradient(blue, green);
    }

    /* ... */

    @media (min-width: 640px) {
      .sm\:bg-gradient-brand {
        background-image: linear-gradient(blue, green);
      }
      /* ... */
    }


## tailwind nested 
TailwindCSS封装了postcss-nested与postcss-nesting插件，只需要:

    // postcss.config.js
    module.exports = {
        plugins: {
            'tailwindcss/nesting': {}, // [!code focus]
            tailwindcss: {},
            autoprefixer: {},
        },
    }


https://tailwindcss.com/docs/using-with-preprocessors#nesting
