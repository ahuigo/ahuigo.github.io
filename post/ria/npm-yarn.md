---
title: yarn
date: 2019-11-01
private: 
---
# yarn

## yarn create
类似npx： yarn create运行时会自动安装或者更新需要的包，同时在它的名字前加上`create-`前缀。

    yarn create react-app my-app
    # 1. $ yarn global add create-react-app
    # 2. $ create-react-app my-app

以上命令中
1. Yarn 首先会自动运行`yarn global add create-react-app`
2. 再运行位于新安装包「package.json」中「bin」字段中的可执行文件，并将剩余的命令行参数传递给该可执行文件 

再比如

    $ yarn create react-app antd-demo-ts --typescript
    $ npx create-react-app antd-demo-ts --typescript
