---
title: 初学 Typescript Vue
date: 2018-10-04
private:
---
# 创建一个ts+vue 项目
手动或者用vue-cli 自动创建

    $ npm install -g vue-cli
    $ vue init vuets/rollup-simple-vue2 my-project
    $ cd my-project
    $ npm install
    $ npm run dev

可以再vscode 中手动创建：https://www.cnblogs.com/hammerc/p/7413228.html

    1.创建tsconfig.json，使用命令行在项目文件夹下输入“tsc --init”即可；
    2.创建tasks.json，在VSCode中，使用ctrl+shift+p打开命令板，然后输入configure task Runner，按回车选择typescript-tsconfig.json即可；
    3.执行tasks.json的命令，即把.ts编译为.js文件，按ctrl+shift+b可以执行该命令，如果报错，可以重启VSCode试试；
    4.按下"F5"，配置和创建launch.json文件，后续只要按下"F5"即可执行；
    5.执行"npm install @types/node --save-dev"命令生成node的对应.d.ts文件