---
title: 写npm 包
date: 2018-10-04
---
# npm reistry
    npm config set @company:registry https://sina.com.cn/artifactory/api/npm/npm-sina/
    npm login --registry=https://artifactory.company.works/artifactory/api/npm/npm-company/ --scope=@company

# 写npm 包
1. 生成包信息package.json
    npm init
2. https://www.npmjs.com/ 注册账号
3. `npm adduser` 添加账号
3. `npm whoami` 验证
5. `npm publish` 发布
6. `npm unpublish <package>@<version>` //可以撤销发布自己发布过的某个版本代码。

参考: [js-dom-event-slide](/p/ria/js-dom-event-slide)

## bin
如果要编写bin cli, 配置package.json

    "bin": {
        "egg-bin": "bin/egg-bin.js",
        "mocha": "bin/mocha.js"
        "hi": "bin/hi.js"
    },

npm install 的bin 位于`/usr/local/bin/{mocha, egg-bin}`

## link
在插件还没发布前，可以通过 npm link 的方式进行本地测试，具体参见 npm-link

    $ cd example-app
    $ npm link ../egg-ua
    $ npm i
    $ npm test

## install
安装到本地

    npm install ./your-project -g
    yarn add ./your-project

npm:

    cd ~/projects/node-bloggy  # go into the dir of your main project
    npm link ../node-redis     # link the dir of your dependency

you can declare local dependencies in package.json

    "dependencies": {
        "bar": "file:../foo/bar"
    }

# 参考
- Node 实现一个命令行程序 https://zhuanlan.zhihu.com/p/28705824