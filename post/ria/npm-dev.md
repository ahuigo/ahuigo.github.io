---
title: 写npm 包
date: 2018-10-04
private:
---

# Preface

本文内容:

1. 编写npm 包: 涉及库、cli
2. 发布npm 包
3. 安装npm 包
   1. 使用cnpm　代替npm
4. 管理mirrors

# 写npm 包

Node 实现一个命令行程序

- 生成包信息package.json: npm init
- 参考ahuigo/js-zfuncs 项目

## bin

如果要编写bin cli, 配置package.json

    "bin": {
        "hello": "lib/bin/hi.js"
    },

npm install 的bin 位于`$(npm bin)/hello`

## import

import directory 其实是import directory/index.js

    import {sth} from './directory'

## install

### 安装到本地

    npm install ./your-project -g
    yarn add global ./your-project

    # 等价于
    cd ./your-project
    npm link .    
        # 1. 将本目录link 到 `npm root -g` ; 
        # 2. bin 命令link 到 `npm　bin -g`/ 下面
        # Note 不要直接用：`npm link ./your-project`, 
        # 它会额外执行：$ cp -r ./your-project/node_modules ./

删除: 如果报错　npm ERR! Cannot read properties of null (reading 'package')　可忽略

    # 删除全局link(node_modules + bin)
    $ npm rm -g js-zfuncs
    $ npm unlink -g js-zfuncs

### 查看全局安装的目录：

查看包目录

    $ npm root -g        
    /opt/homebrew/lib/node_modules
    $ npm list -g
    └── js-zfuncs@1.0.0 -> ./../../../Users/ahui/www/js-zfuncs
    ├── npm@8.5.5
    ├── pnpm@6.32.6
    $ npm ls --g js-zfuncs
    └── js-zfuncs@1.0.0 -> ./../../../Users/ahui/www/js-zfuncs

bin 目录

    # 全局bin 目录
    $ npm bin -g
    /opt/homebrew/bin
    $ ls -l `which hello`
    lrwxr-xr-x  1 ahui  admin    43B Jun 14 10:18 /opt/homebrew/bin/hello -> ../lib/node_modules/js-zfuncs/lib/bin/hi.js

    # 局部bin 目录
    $ npm bin
    /Users/ahui/www/js-zfuncs/node_modules/.bin

## 加载包

以加载　js-zfuncs 为例

### 创建应用

    $ mkir npm-app && cd npm-app
    # init package.json
    $ npm init -y

### link 到app/node_modules

安装到全局的js-zfuncs 是不可在局部app 使用的, 下面这个安装只是全局

    npm install ./js-zfuncs -g
    npm install . -g

我们还需要将包link到局部app: `npm link js-zfuncs` (不能用这个`npm i js-zfuncs`安装）

    $ cd npm-app
    $ npm link js-zfuncs
    $ npm list js-zfuncs
    └── js-zfuncs@1.0.0 extraneous -> ./../../www/js-zfuncs

    注意：
    1.　如果本地存在./node_modules/link2 指向js-zfuncs的symlink. `npm link js-zfuncs` 会报ERR! Cannot read properties of null (reading 'package')

或者可以直接在`package.json` 中指定package link

    "dependencies": {
        "bar": "file:../foo/bar"
    }

### load commonjs(默认支持)

加载require

    $ cat > app.js <<MM
    const m2 = require('js-zfuncs')
    console.log(m2)
    MM
    $ node app.js

### load esm package

package.json 增加

    "type": "module",

再执行import:

    cat > app2.js <<MM
    import * as m2 from 'js-zfuncs'
    MM

    node app2.js

# 发布包

发布包的过程:

1. https://www.npmjs.com/ 注册账号
2. `npm adduser` 添加账号
3. `npm whoami` 验证
4. `npm publish` 发布
5. `npm unpublish <package>@<version>` //可以撤销发布自己发布过的某个版本代码。

## 选择registry
> 参考npm-pkg.md

手动配置registry:

    npm config set registry https://artifactory.sina.works/artifactory/api/npm/npm/
    npm login

with scope:

    npm config set @company:registry https://artifactory.sina.works/artifactory/api/npm/npm/
    npm login --registry=https://artifactory.company.works/artifactory/api/npm/npm/ --scope=@company

npm install 下载scoped 包时，就会去关联到的私有库下载

## adduser

注册命令: npm adduser

或者访问web 注册：

1. https://www.npmjs.com/signup
2. get it from artifactory if you use artifactory as npm mirror

## login and token

### 创建token

有很多方法可以创建token: # https://docs.npmjs.com/creating-and-viewing-access-tokens

    # cli
    npm login --registry=https://registry.npmjs.org/
    npm token create --registry=https://registry.npmjs.org/

使用npm login 后，会将token写到`~/.npmrc`

    registry=https://artifactory.company.works/artifactory/api/npm/npm/
    //registry.npmjs.org/:_authToken=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

### 显示token

    $ npm token list

## publish config

### include publish files

Set files in `package.json`,only the files will be publish to npm package,

    "files": ["lib/**/*"],

    // 指定打包的入口文件
    "main": "lib/index.js",


If you do not set files abolve. You can set exclude files in `.npmignore`:

    src
    tsconfig.json
    tslint.json
    .prettierrc

### exec publish

    npm test 
    npm run build
    npm version patch
    npm publish 
        npm publish --registry=https://registry.npmjs.org/

search package

    https://npmjs.com/package/{your-pacakge-name}

### scoped 包

scope 是包的命名空间：比如 `@babel/core` 在安装后，会被放在`node_modules/@babel/core/`,
对于企业/个人来说，可以将企业/个人名作为命名空间。

我们可以自己作一个scope 包, 然后发布：

    npm init --scope=ahuigo
    npm login
    npm publish

scoped 包默认发布是私有的，你如果没有权限上面的publish 不会成功。我们可以改成

    npm publish --access=public
## publish command
    # 发布ts前有一个make build 生成 lib/*
    npm publish --registry https://my.com/artifactory/api/npm/npm-repo1/

# 安装包

### with @scope
在~/.npmrc中加入

    @my:registry=https://npm.my.com/xxx/

或用命令加入

   npm config set @my:registry https://npm.my.com/xxx/

如果有密码的话：

    npm login --registry=https://npm.my.com/xxx/ --scope=@my

## install npm

    npm install <PACKAGE_NAME>
    npm install <PACKAGE_NAME> --registry https://artifactory.xxx.com/artifactory/api/npm/npm/

### with branch

    npm install webpack@beta
    npm install webpack/webpack#<tagname/branchname>
