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

# modify antd css
## via styled component
https://juejin.cn/post/7239714997710356537

    import styled from 'styled-components'
    import {Select} from 'antd'

    const StyledSelect = styled(Select)`
        .ant-select-selector {
            // write your style
        }
    `
    const Button = styled.a<{ $primary?: boolean; }>`
        --accent-color: white;
        &>button {
            background-color: ${props => props.$primary ? 'var(--accent-color)' : css`....`};
        }
        &:hover {
            filter: brightness(0.85);
        }`

## ProCard 

      <ProCard
        size="small"
        className='text-left p-0 m-0 [&>.ant-pro-card-body]:[padding:0px]'
        bodyStyle={{ padding: 0 }}
        headStyle={{ padding: 0 }}
      >

## Tablist
    <Tabs
        defaultActiveKey="body"
        className='[&_.ant-tabs-nav]:mb-0'
    >