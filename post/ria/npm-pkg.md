---
title: command
date: 2018-10-04
---
# cli usage
## run
http://www.ruanyifeng.com/blog/2016/10/npm_scripts.html

    "scripts": {
        "test:unit": "npm test -- test/unit/**/*-spec.js",
    }


    npm run test:unit

### npx
下面三种等价

    "scripts": {
        "build": "npx webpack"
    },
    $ node_modules/.bin/webpack
    $ npx webpack
    $ npm run build


### short cmd

    npm start是npm run start
    npm stop是npm run stop的简写
    npm test是npm run test的简写
    npm restart是npm run stop && npm run restart && npm run start的简写

# config file

## config edit
    ~/.npmrc

通过命令设置

    # 使用旧的peer 包dependency
    npm config set legacy-peer-deps true

直接编辑文件：

    npm config edit
    # or vi ~/.npmrc

对cnpm 来说

    cnpm config edit
    ~/.cnpmrc

## config list

    npm config ls -l

# npm help
    npm help install

# npm install
安装之前，会先检查，`node_modules`目录之中是否已经存在指定模块。 如果存在，就不再重新安装了，即使远程仓库已经有了一个新版本，也是如此。

如果你希望强制重新安装，可以使用-f或--force参数。

    $ npm install <packageName> --force
    $ npm update <packageName>

## 包类型
dev 包

    -D, --save-dev
        npm install -D 

peer 包（被大量包依赖的，如React）


## registry(mirrors)

### npm registry 

    npm install -g cnpm --registry=https://npmmirror.com/

或改写`~/.npmrc`

    npm config set registry https://npmmirror.com/
    npm config get registry
    npm config set registry https://artifactory.sina.works/artifactory/api/npm/npm/

访问 https://registry.npmjs.org/react，就会看到 react 模块所有版本的信息。

    # 它跟下面命令的效果是一样的。
    $ npm view react
    $ npm info react
    $ npm show react
    $ npm v react

### yrm registry
自动切换源, yrm是个npm镜像管理工具，可以很方便的切换镜像源

    yrm add taobao https://npmmirror.comt
    
    npm i yrm -g
    yrm -h
    yrm ls


## 安装目录
### bin path

    npm -g bin
    npm -g get prefix
    `npm -g get prefix`/lib/node_modules

### pkg path
    ~/.npm(缓存包)
        # 压缩包路径
        npm config get cache

        # .npm 储存结构是
        {cache}/{name}/{version}。

        # 压缩包的url+sumdb 列表
        npm cache ls

        # 查看单个包
        npm cache ls react

    /usr/local/lib/node_modules (全局包)
        # 查看全局node_modules路径
        `npm root -g`
        `npm -g get prefix`/lib/node_modules; 
        # 全局的包list
        npm list -g
        npm list -g --depth 0

    node_modules
        # 局部包路径
        npm root
        ls node_modules
        # local的包list
        npm list

你会看到里面存放着大量的模块，

    $ npm cache ls react
    ~/.npm/react/0.14.6/

## version semver

    ^1.1.0 匹配 >=1.1.0 且 <2.0.0
    ^0.0.3 匹配 >=0.0.3 且 <0.0.4

    latest 当前发布版本。
    * 匹配 >=0.0.0
    2.* 匹配 >=1.0.0 且 <2.0.0
    1.2.* 匹配 >=1.2.0 且 <1.3.0

    ~0.1.1 匹配 >=0.1.1 且 <0.2.0。
    ~1 匹配 >=1.0.0 且 <2.0.0

    1.30.2 - 2.30.2 匹配 >=1.30.2 且 <=2.30.2

### 版本冲突
http://aprilandjan.github.io/npm/2019/08/02/how-npm-handles-dependency-version-conflict/

1. npm v3: 依赖平铺, 无法避免多版本依赖冲突
    2. 模块的安装顺序可能影响 node_modules 内的文件结构

# npm list
查看node_modules 中的包

    npm list -g; # global
    npm list; # local
    npm dedupe -g; # Reduce duplication

# node require
> https://nodejs.org/api/modules.html#modules_loading_from_the_global_folders
Node.js will search in the following locations by default:

    1. NODE_PATH='path1:path2:' (global)
    2. ./node_modules (local)
    3. $HOME/.node_modules (global)