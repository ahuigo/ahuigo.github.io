# command

    npm list -g; # global
    npm list; # local
    npm dedupe -g; # Reduce duplication

## run
http://www.ruanyifeng.com/blog/2016/10/npm_scripts.html

    "scripts": {
        "test": "jasmine --config=jasmine.json",
        "test:unit": "npm test -- test/unit/**/*-spec.js",
        "test:specs": "npm test -- test/specs/**/*-spec.js",
        "test:lint": "eslint bin/marked .",
        "test:redos": "eslint --plugin vuln-regex-detector --rule '\"vuln-regex-detector/no-vuln-regex\": 2' lib/marked.js",

        //internal
        "start": "node server.js"，
        "install": "node-gyp rebuild"

        //hooks: build, install, start....
        "prebuild": "echo I run before the build script",
        "postbuild": "echo I run after the build script"


    npm run test:unit
    npm run test:lint

    # security
    npm run test:redos

    # specs
    npm run test:specs

## short cmd

    npm start是npm run start
    npm stop是npm run stop的简写
    npm test是npm run test的简写
    npm restart是npm run stop && npm run restart && npm run start的简写

# repo

    # temp
    npm --registry https://registry.npm.taobao.org install <package>

    # persistance
    npm config set registry https://registry.npm.taobao.org
    # verify
    npm config get registry

# npm install 说起
安装之前，会先检查，`node_modules`目录之中是否已经存在指定模块。 如果存在，就不再重新安装了，即使远程仓库已经有了一个新版本，也是如此。

如果你希望强制重新安装，可以使用-f或--force参数。

    $ npm install <packageName> --force
    $ npm update <packageName>

# 三、registry
npm update命令怎么知道每个模块的最新版本呢？

2. 以 npmjs.org 为例，它的查询服务网址是 https://registry.npmjs.org/ 。
3. 这个网址后面跟上模块名，就会得到一个 JSON 对象，里面是该模块所有版本的信息。比如，访问 https://registry.npmjs.org/react，就会看到 react 模块所有版本的信息。

它跟下面命令的效果是一样的。

    $ npm view react

    # npm view 的别名: info show v
    $ npm info react
    $ npm show react
    $ npm v react

返回的 JSON 对象里面，有一个dist.tarball属性，是该版本压缩包的网址。

    dist: {
      shasum: '2a57c2cf8747b483759ad8de0fa47fb0c5cf5c6a',
      tarball: 'http://registry.npmjs.org/react/-/react-0.14.6.tgz'
    },

# 四、缓存目录
npm install或npm update命令，从 registry 下载压缩包之后，都存放在本地的缓存目录。

这个缓存目录，在 Linux 或 Mac 默认是用户主目录下的.npm目录，在 Windows 默认是%AppData%/npm-cache。通过配置命令，可以查看这个目录的具体位置。

    $ npm config get cache
    $HOME/.npm

    $ npm cache ls

你会看到里面存放着大量的模块，储存结构是{cache}/{name}/{version}。

    $ npm cache ls react
    ~/.npm/react/0.14.6/

.npm目录保存着大量文件，清空它的命令如下。

    $ rm -rf ~/.npm/*
    # 或者
    $ npm cache clean

# 五、模块的安装过程
总结一下，Node模块的安装过程是这样的。

1. 发出npm install命令
2. npm 向 registry 查询模块压缩包的网址
3. 下载压缩包，存放在`~/.npm`目录
4. 解压到`node_modules目录`. e.g. `/usr/local/lib/node_modules`
5. 但是，运行npm install的时候，只会检查node_modules目录，而不会检查~/.npm目录。也就是说，如果一个模块在～/.npm下有压缩包，但是没有安装在node_modules目录中，npm 依然会从远程仓库下载一次新的压缩包。