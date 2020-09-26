---
title: antd design
date: 2020-05-28
private: true
---
# antd layout
默认表单是右对齐的，可以改成全局左对齐

    .ant-form-item-label {
        text-align: left;
    }

## override classes
antd's style:

    .ant-btn { ... }

局部修改:

    .my-btn.ant-btn { ... }
    <Button className="my-btn"/>

全局修改:

    .project { .ant-btn{...} }

    <div className="project">
        <Button className="my-btn"/>
    </div>

# antd theme
多种主题：https://github.com/ant-design/ant-design/tree/master/components/style/themes
定制theme: https://ant.design/docs/react/customize-theme

## umi
.umirc.ts

    import darkTheme from '@ant-design/dark-theme';

    export default defineConfig({
        theme: {
            ...darkTheme,
            // '@primary-color': '#1DA57A',
            'text-color': 'white',
            'font-size-base': '14px',
            'badge-font-size': '12px',
            'btn-font-size-lg': '@font-size-base',
            'menu-dark-bg': '#00182E',
            'menu-dark-submenu-bg': '#000B14',
            'layout-sider-background': '#00182E',
            'layout-body-background': '#f0f2f5',
        };

### Style Override
For example, modify the font size of all Tag in src/global.less.

    // src/global.less
    :global {
      .ant-tag {
        font-size: 12px;
      }
    }

## 局部主题切换
定义一个局部的local.less

    // local.less
    @import '~antd/es/style/themes/default.less';

    .nav {
        :global(.num) {
            margin: 0 5px;
        }
    }

然后直接引入

    import styles from './local.less';

    <div className={styles.nav}>    
        <div className={'num'}>    


## create-react-app
### 引入antd
Add antd/dist/antd.css at the top of src/App.css.

    // src/App.css
    @import '~antd/dist/antd.css';

    //src/App.js
    import React from 'react';
    import { Button } from 'antd';
    import './App.css';

### 切换theme
直接修改引用的theme 路径

    @import '~antd/lib/style/themes/default.less';
    @import '~antd/dist/antd.less'; // Import Ant Design styles by less entry
    @import 'your-theme-file.less'; // variables to override above
