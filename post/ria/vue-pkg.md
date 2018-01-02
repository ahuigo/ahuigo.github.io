---
layout: page
title:
category: blog
description:
---
# Preface

# Bower
> https://segmentfault.com/a/1190000002971135
Bower是一个客户端技术的软件包管理器，它可用于搜索、安装和卸载如JavaScript、HTML、CSS之类的网络资源。YeoMan和Grunt 建立在Bower基础之上

## install bower

	$ npm install -g bower
	/usr/local/bin/bower -> /usr/local/lib/node_modules/bower/bin/bower

其中-g命令表示全局安装

## 自定义包的安装目录
这个.bowerrc文件是自定义bower下载的代码包的目录，比如现在我的项目结构如下图：

	{
	  "directory" : "js/lib"
	}

## bower初始化
命令行进入项目目录中，输入命令如下：

	bower init

会提示你输入一些基本信息，根据提示按回车或者空格即可，然后会生成一个bower.json文件，用来保存该项目的配置，如下：

	{
	  "name": "bb_boot",
	  "version": "0.0.1",
	  "authors": [
		"savokiss <jaynaruto@qq.com>"
	  ],
	  "moduleType": [
		"amd"
	  ],
	  "license": "MIT",
	  "ignore": [
		"**/.*",
		"node_modules",
		"bower_components",
		"js/lib",
		"test",
		"tests"
	  ],
	  "dependencies": {
	  }
	}

## 包的安装
下面终于开始安装需要的包了！
比如我要安装一个jquery，输入如下命令：

	bower install jquery --save

然后bower就会从远程下载jquery最新版本到你的js/lib目录下
其中--save参数是保存配置到你的bower.json，你会发现bower.json文件已经多了一行：

	  "dependencies": {
		"jquery": "~2.1.4"
	  }

## 包的信息
比如我们想要查找jquery都有哪些个版本，输入如下命令：

	bower info jquery

会看到jquery的bower.json的信息，和可用的版本信息

## 包的更新
上面安装的是最新版的高版本jquery，假如想要兼容低版本浏览器的呢？
已经查到兼容低版本浏览器的jquery版本为1.11.3，下面直接修改bower.json文件中的jquery版本号如下：

	  "dependencies": {
		"jquery": "~1.11.3"
	  }

然后执行如下命令：

	bower update
	bower就会为你切换jquery的版本了

## 包的查找

	bower search bootstrap

bower就会列出包含字符串bootstrap的可用包了

## 包的卸载
卸载包可以使用uninstall 命令：

	bower uninstall jquery
