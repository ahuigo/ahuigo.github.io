---
title: 写npm 包
date: 2018-10-04
private:
---
# npm reistry

    npm config set registry https://artifactory.sina.works/artifactory/api/npm/npm/
    npm login

with scope: 

    npm config set @company:registry https://artifactory.sina.works/artifactory/api/npm/npm/
    npm login --registry=https://artifactory.company.works/artifactory/api/npm/npm/ --scope=@company

npm install 下载scoped 包时，就会去关联到的私有库下载

## login
除了使用npm login 外，还可以通过~/.npmrc 配置身份

全局认证

    _auth = <USERNAME>:<PASSWORD> (converted to base 64)
    email = youremail@email.com
    always-auth = true

scope 认证：

    @<SCOPE>:registry=https://artifactory.momenta.works/artifactory/api/npm/npm/
    //artifactory.momenta.works/artifactory/api/npm/npm/:_password=<BASE64_PASSWORD>
    //artifactory.momenta.works/artifactory/api/npm/npm/:username=<USERNAME>
    //artifactory.momenta.works/artifactory/api/npm/npm/:email=youremail@email.com
    //artifactory.momenta.works/artifactory/api/npm/npm/:always-auth=true

## install npm

    npm install <PACKAGE_NAME>
    npm install <PACKAGE_NAME> --registry https://artifactory.momenta.works/artifactory/api/npm/npm/

### with branch

    npm install webpack@beta
    npm install webpack/webpack#<tagname/branchname>

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

也可参考：https://github.com/nicejade/arya-jarvis

## import 
import directory 其实是import directory/index.js

    import {sth} from './directory'


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

# scoped 包
scope 是包的命名空间：比如 `@babel/core` 在安装后，会被放在`node_modules/@babel/core/`, 对于企业/个人来说，可以将企业/个人名作为命名空间。

我们可以自己作一个scope 包, 然后发布：

    npm init --scope=ahuigo
    npm login
    npm publish

scoped 包默认发布是私有的，你如果没有权限上面的publish 不会成功。我们可以改成

    npm publish --access=public

# 参考
- Node 实现一个命令行程序 https://zhuanlan.zhihu.com/p/28705824