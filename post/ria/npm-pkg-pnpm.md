---
title: pnpm
date: 2023-02-28
private: true
---
# pnpm
## 硬链接
使用pnpm 后

    node_modules/
        umi -> ./.pnpm/.../umi
        .pnpm/

观察一下，可以看到，umi.js被链接了 st_nlink=13 次

    $ l -i node_modules/.pnpm/registry.npmjs.org+umi@4.0.53_xxx/node_modules/umi/bin/umi.js
    17632683 -rwxr-xr-x  13 ahui  staff   793B Jul 28  2022 node_modules/.pnpm/registry.npmjs.org+umi@4.0.53_xxx/node_modules/umi/bin/umi.js
    $ stat -s  node_modules/.pnpm/registry.npmjs.org+umi@4.0.53_xxx/node_modules/umi/bin/umi.js 
    st_dev=16777231 st_ino=17632683 st_mode=0100755 st_nlink=13 st_uid=501 st_gid=20 st_rdev=0 st_size=793 st_atime=1658999054 st_mtime=1658998042 st_ctime=1677590364 st_birthtime=1658998042 st_blksize=4096 st_blocks=8 st_flags=0

那么原始文件在哪里呢？
https://remysharp.com/2014/05/23/where-is-that-console-log

    $ pnpm store path
    ~/Library/pnpm/store/v3
    linux: ~/.local/share/pnpm/store

## 幽灵依赖：Phantom dependencies
假如我们的package.json 

    "dependencies": {
        "pkgA": "^3.0.4"
    },
    "devDependencies": {
        "rimraf": "^2.6.2"
    }

pkgA又依赖pkgB, 然后我们的项目

    var pkgA= require("pkgA")
    var pkgB = require("pkgB");  // 它被pkgA依赖安装
    var glob = require("rimraf");  // 它被dev rimraf依赖安装

虽然pkgB没有在package.json中声明，但是也可以用。这会有bug
1. 依赖包版本不一致：不同环境，安装的pkgB版本不一致
2. 包缺失：项目作为包被安装时，不会安装devDependencies rimraf, 它依赖的glob也会缺失

避免：确保每个包的代码只会require package.json所声明的依赖

# config
## config path
    On Windows: ~/AppData/Local/pnpm/config/rc
    On macOS: ~/Library/Preferences/pnpm/rc
    On Linux: ~/.config/pnpm/rc

get config:

    pnpm config list
    pnpm config get global-dir

## cache dir
get 

    # npm-pkg.md
    npm config get cache

    # pnpm
    $ pnpm store path

set

    echo 'store-dir='$HOME/Library/pnpm/store >> /usr/local/etc/npmrc

## registry
pnpm willl use `./.npmrc` and `~/.npmrc`

    # npm
    npm config set registry https://registry.npmjs.org/
    npm config delete registry

    # or
    pnpm config set registry https://registry.npmjs.org/
    pnpm config delete registry
