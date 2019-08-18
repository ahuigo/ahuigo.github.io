---
date: 2018-08-20
title: node 的npx 是什么？
---
# node 的npx 是什么？
> http://www.ruanyifeng.com/blog/2019/02/npx.html

以前我们要手动输入路径:

    ./node_modules/.bin/webpack -v
    `npm bin`/webpack -v
    ./node_modules/.bin/livereload.js dist

用npx 就不用手动写路径，以及后缀了：

    npx webpack -v
    npx livereload dist

## 远程执行
npx 还可以远程执行:

    npx github:piuccio/cowsay hello
    npx cowsay hello
    npx webpack -v

    npx create-react-app my-react-app

上面代码运行时，npx 将create-react-app下载到一个临时目录，使用以后再删除。所以，以后再次执行上面的命令，会重新下载create-react-app。


## 强制使用本地模块
如果想让 npx 强制使用本地模块，不下载远程模块，可以使用--no-install参数。如果本地不存在该模块，就会报错。

    $ npx --no-install http-server

## 强制安装使用远程模块
可以使用--ignore-existing参数。比如，本地已经全局安装了create-react-app，但还是想使用远程模块，就用这个参数。

    $ npx --ignore-existing create-react-app my-react-app

## 指定模块的version
可以指定某个版本的 Node 运行脚本

    $ npx node@0.12.8 -v
    v0.12.8

原理是从 npm 下载这个版本的 node，使用后再删掉。

## -p参数用于指定 npx 所要安装的模块
所以上一节的命令可以写成下面这样:
上面命令先指定安装node@0.12.8，然后再执行node -v命令。

    $ npx -p node@0.12.8 node -v 
    v0.12.8


-p参数对于需要安装多个模块的场景很有用。

    $ npx -p lolcatjs -p cowsay [command]

## -c 参数
`cowsay hello | lolcatjs`执行时会报错，原因是第一项cowsay由 npx 解释，而第二项命令localcatjs由 Shell 解释，但是lolcatjs并没有全局安装，所以报错。

    $ npx -p lolcatjs -p cowsay 'cowsay hello | lolcatjs'
    # 报错


-c参数可以将所有命令都用 npx 解释。有了它，下面代码就可以正常执行了。

    $ npx -p lolcatjs -p cowsay -c 'cowsay hello | lolcatjs'

-c参数的另一个作用，是将环境变量带入所要执行的命令。举例来说，npm 提供当前项目的一些环境变量，可以用下面的命令查看。

    $ npm run env | grep npm_

-c参数可以把这些 npm 的环境变量带入 npx 命令。

    $ npx -c 'echo "$npm_package_name"'

上面代码会输出当前项目的项目名。

## 执行 GitHub 源码
npx 还可以执行 GitHub 上面的模块源码。


    # 执行 Gist 代码
    $ npx https://gist.github.com/zkat/4bc19503fe9e9309e2bfaa2c58074d32

    # 执行仓库代码
    $ npx github:piuccio/cowsay hello

注意，远程代码必须是一个模块，即必须包含package.json和入口脚本。