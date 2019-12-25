---
title: yarn
date: 2019-11-01
private: 
---
# yarn
    # 国内源tyarn
    npm i yarn tyarn -g

## yarn bin
    echo 'export PATH="$PATH:`yarn global bin`"' >> ~/.profile

## dependencies

    yarn [install] --ignore-optional

### dependencies 种类

    -D, --dev                           save package to your `devDependencies`
    -P, --peer                          save package to your `peerDependencies`
    -O, --optional                      save package to your `optionalDependencies`

optionalDependencies 一般是最不需要安装的，如puppeteer

#### peerDependencies
假设packageA 依赖packageB, 则有：

    |- node_modules
        |- PackageA
            |- node_modules
                |- PackageB


如果在项目中直接这样写会有问题:

    var packageA = require('PackageA')
    var packageB = require('PackageB')//找不到

这时可以在packageA 中的package.json中注明：

    "peerDependencies": {
        "PackageB": "1.0.0"
    }

表示packageA 向npm/node 表示谁引入我的话，就必须在相同目录中引入packageB

    |- node_modules
        |- PackageA
        |- PackageB

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
