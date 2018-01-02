---
layout: page
title:	vim vundle插件管理
category: blog
description: 
---
$TOC$

# 什么是vundle
之前介绍过一篇 vim插件管理利器之[pathogen]，pathogen本身不支持插件的白名单管理。而vundle比pathogen功能更丰富——插件白名单管理，插件的安装、更新、删除（其实用git submodule更方便）
关于vundle使用我就不多说了，直接上github吧：[vundle]

# 安装vundle
虽然github的安装说明了，不过出于习惯，还是记录一下吧。

## download vundle
先下载文件吧：

	git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

可以看到，是如下的结构

	.vim
	└── bundle
		└── vundle
			├── autoload
			│   ├── vundle
			│   │   ├── config.vim
			│   │   ├── installer.vim
			│   │   └── scripts.vim
			│   └── vundle.vim
			├── doc
			│   └── vundle.txt
			├── LICENSE-MIT.txt
			├── README.md
			└── test
				├── files
				│   └── test.erl
				├── minirc.vim
				└── vimrc
## config
按github给的config 写到.vimrc

	 set nocompatible               " be iMproved
	 filetype off                   " required!

	 set rtp+=~/.vim/bundle/vundle/
	 call vundle#rc()

	 " let Vundle manage Vundle
	 " required! 
	 Bundle 'gmarik/vundle'
	Bundle 'vim-scripts/fcitx.vim'


	 filetype plugin indent on     " required!

## :BundleInstall
执行:
	
	vim +BundleInstall +qall

再看看，自动下载了fcitx有木有？另外还对一个doc/生成了tags

	.vim
	└── bundle
	    ├── fcitx.vim
	    │   ├── plugin
	    │   │   ├── fcitx.py
	    │   │   └── fcitx.vim
	    │   ├── README
	    │   └── so
	    │       └── fcitx.vim
	    └── vundle
		├── autoload
		│   ├── vundle
		│   │   ├── config.vim
		│   │   ├── installer.vim
		│   │   └── scripts.vim
		│   └── vundle.vim
		├── doc
		│   ├── tags
		│   └── vundle.txt
		├── LICENSE-MIT.txt
		├── README.md
		└── test
		    ├── files
		    │   └── test.erl
		    ├── minirc.vim
		    └── vimrc

# 使用
使用:h vundle 查看详细帮助

	:h vundle

其中就提到：BundleInstall支持直接从github下载插件，你可以在配置文件中设置github插件路径（比如我的fcitx）。
或者，你也可以在命令行中下载，比如vim命令行安装我所使用的blog插件：
	
	:BundleInstall pkufranky/VimRepress

安装完了后，还得在.vimrc中启用
	
	Bundle 'VimRepress'

[pathogen]: /?p=1104
[vundle]: https://github.com/gmarik/vundle
