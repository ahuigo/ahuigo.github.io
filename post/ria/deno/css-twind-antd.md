---
title: tailwind 与antd　冲突
date: 2023-03-07
private: true
---
# umi下使用tailwind 问题原因
`tailwind.css`引入的`@tailwind base`内的基础样式，覆盖掉了antd.css的部分样式. 
见`src/.umi/plugin-tailwindcss/tailwind.css`

## 解决方法
配置关闭preflight

    // tailwind.config.js
    module.exports = {
      content: [
        './src/pages/**/*.tsx',
        './src/components/**/*.tsx',
        './src/layouts/**/*.tsx',
      ],
      corePlugins: {
        preflight: false
      }
    }
