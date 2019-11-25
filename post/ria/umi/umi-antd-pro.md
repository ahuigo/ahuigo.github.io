---
title: Ant desigin pro 开发介绍
date: 2019-11-20
---
# Ant desigin pro 开发介绍
antd pro 由umijs 这个脚手架生成， 我看重的几点：
1. 按需要加载: 不会因为项目变大，首页加载变慢
2. HMR: 开发时的热更新
3. TS 支持: 避免类型错误、超好用的装饰器
3. 模板脚手架、自定义模板: 页面一键生成
5. Mock 数据支持
6. 集成Jest 测试

## 基础学习
1. React:基本概念和hooks 重点看 https://zh-hans.reactjs.org/docs/hello-world.html
2. typescript(可选) https://github.com/xcatliu/typescript-tutorial
3. antd pro 学习：https://pro.ant.design/docs/getting-started-cn
4. antd 学习: https://ant.design/docs/react/getting-started-cn 

## antd pro 文件结构
典型的业务代码结构：

    src/
        pages/          这里放页面
            page1/
                index.tsx   react 渲染页
                model.ts    数据管理（基于dva-redux）
                service.ts  api封装
                _mock.ts    mock api
                *.less      局部组件的样式表
                *.ts        其它逻辑代码
            page2/
                ....
    config/
        config.ts       这时放路由、配置
        
完整的目录说明, 参考：https://pro.ant.design/docs/getting-started-cn

    ├── config                   # umi 配置，包含路由，构建等配置
    ├── mock                     # 本地模拟数据
    ├── public
    │   └── favicon.png          # Favicon
    ├── src
    │   ├── assets               # 本地静态资源
    │   ├── components           # 业务通用组件
    │   ├── e2e                  # 集成测试用例
    │   ├── layouts              # 通用布局
    │   ├── models               # 全局 dva model
    │   ├── pages                # 业务页面入口和常用模板
    │   ├── services             # 后台接口服务
    │   ├── utils                # 工具库
    │   ├── locales              # 国际化资源
    │   ├── global.less          # 全局样式
    │   └── global.ts            # 全局 JS
    ├── tests                    # 测试工具
    ├── README.md
    └── package.json

## 一个welcome 页面
初始化一个welcome 页面

    mkdir -p newProject
    cd newProject
    yarn create umi

    # 安装module
    yarn
    # 启动
    npm start

## 脚手架
antd pro 的umi 提供了非常方便的脚手架, 你可以
1. 通过访问localhost:3000 选择模板、区块创建新页面
2. 通过命令行直接生成新页面, 参考https://pro.ant.design/docs/block-cn

你可以自定义模板-区块，默认的区块源是：

    config/config.ts
    72: defaultGitUrl: 'https://github.com/ant-design/pro-blocks',

有了block 脚手架，如果我们可以一键生成这样的页面

![](/img/ria/umi/antd-pro-block.png)
