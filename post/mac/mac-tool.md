---
layout: page
title:	mac 工具集
category: blog
date: 2018-10-10
description:
---
# Preface
本文是我所用的mac 工具集大杂烩。

一些mac osx 能做而linux 桌面级OS 目前不能做的事情：

- mac 支持全局readline , 字符编辑的效率非常非常高(可以搜索 Emacs-like keybindings system-wide, linux 要做到这一点非常麻烦). 。
- 呼起程序(搜索/词典/手册/qq(qq下的swift)/计算)：mac 下的Alfred2 非常强大, linux 下有launchy 就比较鸡肋了
- 更高效稳定的窗口系统和窗口管理器
	1. mac 的硬件软件一体化，比ubuntu/archlinux等省心多了。而linux desktop 而因为糟糕的X11, 以及参差不齐的图形软件, 效率很低。
	2. mac OSX 使用的Quartz Compositor 较x11 高效稳定太多太多了，Linux 的Wayland 窗口系统或许有望解决这个问题，不过还是到那一天再说吧。大多数流行的桌面软件对mac OSX 的支持比linux 好很多, 比如QQ

mac OSX 有很多技巧(这些在 linux/windows 实现起来特别繁琐)：

	高效使用mac tips 1: http://www.zhihu.com/question/19550256
	高效使用mac tips 2: http://www.zhihu.com/question/20873070
	高效使用mac tips 3: http://apple.stackexchange.com/questions/400/please-share-your-hidden-os-x-features-or-tips-and-tricks
	Automator : http://macshuo.com/?tag=automator

linux desktop 的优点：

- 更加原汁原味的本地化linux开发环境，而OSX 需要稍微配置一下（其实很简单的啦）, 其实mac OSX 中装个virtualBox(centos 不要装X11) 也是很不错的选择
- Mac OSX 有极少数私有的命令, 比如：dscl （相当于linux下的用户管理命令 useradd, usermod ）
- Mac OSX 有一些命令不是gnu版本的: 比如sed，awk, 不过可以一键安装gnu 版的命令: `brew install gsed gawk`


# Invisible Shortcuts
> Reference: http://apple.stackexchange.com/questions/400/please-share-your-hidden-os-x-features-or-tips-and-tricks

## Space(View content)
In finder, press `space` to view file content.

## Option + click (for detail options)
1. option + click 右上角的图标

## ctrl+click
*open dir from title*
In a document-based application (like Finder, TextEdit, Preview, Pages…), after a document has been saved, a proxy icon for the document appears in the title bar. It represent the file itself, and can be likewise manipulated:

click it for a few seconds and drag to another application to open it, or to the desktop/Finder if you want to copy/move it, etc…
⌘-click (or control-click, or right-click) it to view the path menu, useful to open the folder or any subfolders of the file in the Finder.

## option+shift
1. ⌥ + ⇧ + other

*volume/brightness*
You can increase or decrease your volume by quarter increments by Pressing:

	⌥ + ⇧ + Volume Up/Down

This also works for brightness.

> Related to this tip, option+any volume key will open the sound system preference pane, and shift+vol up/down will change volume silently (without the little plink sound.

## cmd-tab
While Cmd tabbing between applications, without releasing CMD, you can hit 'Q' to quit or 'H' to hide the selected application. Works great with the mouse to get rid of a whole bunch of applications quickly.

The bevel won't go away and you can repeat this for as many applications as you like as long as you're holding CMD.

# System
## clipboard( pbpaste )
1. Copy a string: `echo "ohai im in ur clipboardz" | pbcopy`
2. Copy the HTML of StackOverflow.com: `curl "http://stackoverflow.com/" | pbcopy`
2. Open a new buffer in VIM, initialized to the content of the clipboard: `pbpaste | vim -`
2. Save the contents of the clipboard directly to a file: `pbpaste > newfile.txt`

## service
mac 下的任何app 都可以写成服务，通过服务你也可以为之设定相应的快捷键

### create service shortcut
	http://computers.tutsplus.com/tutorials/how-to-launch-any-app-with-a-keyboard-shortcut--mac-31463

### delete service
	ls ~/Library/Services
	rm ~/Library/Services/*

## pkgutil
pkgutil 是原生的管理mac 安装包的命令行工具

	man pkgutil
	//List all currently installed package IDs
	pkgutil --pkgs |grep -i xcode
	//List all package IDs
	pkgutil --pkgs-plist

	//list installed files
	pkgutil --files com.apple.pkg.XcodeMAS_iOSSDK_8_1 |grep php

	//check app's location
	pkgutil --pkg-info the-package-name.pkg
	pkgutil --pkg-info com.apple.pkg.XcodeMAS_iOSSDK_8_1

	//specify files or dirs
	pkgutil --only-files --files com.apple.pkg.XcodeMAS_iOSSDK_8_1
	pkgutil --only-dirs --files com.apple.pkg.XcodeMAS_iOSSDK_6_1

The forget argument removes an entry from the installer database but without removing the actual files:

	//Discard receipt data for the specified package
    sudo pkgutil --forget org.netbeans.ide.php.201310111528

[pkgutil](https://wincent.com/wiki/Uninstalling_packages_(.pkg_files)_on_Mac_OS_X)
[pkg uninstall](https://github.com/mpapis/pkg_uninstaller)


## Automator

### Shortcuts
ls ~/Library/Services/
[via Automator services]( http://computers.tutsplus.com/tutorials/how-to-launch-any-app-with-a-keyboard-shortcut--mac-31463)

google in chrome
http://superuser.com/questions/369934/mac-os-x-lion-chrome-shortcut-for-search-with-google
> U can also set shortcut for translate in google.

## Alfred2/raycast
> raycast 可替代alfred
通过它你可以呼起任意的app, url. 而且可以定制呼起关键词, 传递的参数

	wolfram x^2+y^2+z^2=10

> Flashlight 是一个Spotlight Plugin ，很强大:
http://sspai.com/27734

	brew cask info flashlight

## Thin out
给air 瘦身， 先通过这个命令查找最占用空间的目录/文件。

	du -s * path | sort -nr > path.du

### weixin
微信视频本地存储位置：

	~/Library/Containers/com.tencent.xinWeChat/Data/Library/Application Support/Wechat/1.2/{一串字符}/Message/MessageTemp/{一串字符}/Video

微信图片本地存储位置：

	~/Library/Containers/com.tencent.xinWeChat/Data/Library/Application Support/Wechat/1.2/{一串字符}/Message/MessageTemp/{一串字符}/Image

微信聊体文件本地存储位置：

	~/Library/Containers/com.tencent.xinWeChat/Data/Library/Application Support/Wechat/1.2/{一串字符}/Message/MessageTemp/{一串字符}/OpenData

### /Application Support

	/Users/hilojack/Library/Application Support/WebIde80

### /Var
var目录是放置临时文件/日志的地方，你可以通过`man hier`得到更详细的目录简介
有可能这里占用了很多空间，比如我的

	man hier
	# before restart
	$ sudo du -s /private/var/* | sort -n -r
	7128360	/private/var/db
	4325376	/private/var/vm
	2476936	/private/var/folders(1.2G)
	94528	/private/var/log

我重启后，mac会自动清理一些文件：

	# after reboot
	8598136	/private/var/db
	4325376	/private/var/vm
	1892216	/private/var/folders
	66376	/private/var/log
	25672	/private/var/root
	4240	/private/var/audit

### cache

	/Library/Caches/Homebrew
	/Library/Caches/*

### iPhoto
	uninstall iPhoto or del /Applications/iPhoto.app//iPhoto/Contents/Resources/Themes/

### Speech synthesis voices
	rm /System/Library/Speech/Voices/ #just keep one(My favorite voice is Tom and Alex )
	sudo mv Tom.SpeechVoice/ Tom.SpeechVoice.ori
	sudo find . -maxdepth 1 -name '*.SpeechVoice' -exec rm -rf {} \;
	sudo mv Tom.SpeechVoice.ori/ Tom.SpeechVoice

### mail
	rm /Users/hilojack/Library/Containers/com.apple.mail/Data/Library/Mail\ Downloads/*

### dict(This is my Dictionary List)

	 du -sh /Library/Dictionaries/*
	 du -sh ~/Library/Dictionaries/*
		4.3M	/Library/Dictionaries/Apple Dictionary.dictionary
		 65M	/Library/Dictionaries/New Oxford American Dictionary.dictionary
		4.8M	/Library/Dictionaries/Oxford American Writer's Thesaurus.dictionary
		 65M	/Library/Dictionaries/Oxford Dictionary of English.dictionary
		6.7M	/Library/Dictionaries/Oxford Thesaurus of English.dictionary
		 29M	/Library/Dictionaries/Simplified Chinese - English.dictionary

	sudo rm -rf Sanseido\ The\ WISDOM\ English-Japanese\ Japanese-English\ Dictionary.dictionary/
	rm ~/Library/Dictionaries/

> ps:
在任何文字区域上按下 control+cmd+D 就可呼出取词窗口，词典会根据鼠标的位置自动取词

### ~/Library

#### Netbeans

	rm ~/Library/Application\ Support/NetBeans/7.4/var/log/heapdump.hprof.old (800M)

#### QQ

	rm -r ~/Library/Containers/com.tencent.qq/Data/Library/Application\ Support/QQ/* (1.2G)

### Music

	rm ~/Music/*

### ctags
自带的ctags/etags 不好用，改用brew install 安装新的

	sudo rm /usr/bin/{ctags,etags}

## Command line tool for xcode
mac 下一些工具的编译，比如brew/macvim/gcc 等，都需要command line tool for xcode 的支持。（这个tool 不依赖于xcode, 如果不开发mac/iphone app, 那么xcode 本身就不必安装）

https://developer.apple.com/downloads/

## monitor
mac 有gui 版的monitor , 还有一个命令行的top

## diskutil
diskutil是OS X磁盘工具应用的命令行版。既可以完成图形界面应用的所有任务，也可以做一些全盘填0、全盘填随机数等额外的任务。
先使用`diskutil list`查看所有磁盘的列表和所在路径，然后对特定的磁盘执行命令。

警告：不正确使用diskutil可能意外的破坏磁盘数据。请小心。

### view UUID

	diskutil info /dev/disk1s2

# 流程图/脑图
processon flowchart + mind + UI(Wireframes) + UML
## ps
https://ps.gaoding.com/#/

## Flow Chart 流程图
1. http://resources.jointjs.com/demos
0. https://excalidraw.com/ 最极简的画板工具
1. Zen Flowchart 简单好用的在线流程图工具。
2. www.processon.com 功能非常全
3. draw 服务器在国外 https://www.draw.io/
4. gliffy https://www.gliffy.com
5. lucidchart 画连线特别方便
6. 百度脑图 速度非常快
7. 代码图： https://mermaid-js.github.io/mermaid/#/sequenceDiagram?id=activations

### client app
- yEd diagram app
- omniGraffle 非常流行的流程图客户端
	https://www.omnigroup.com/omniGraffle

## 图床
https://zhuanlan.zhihu.com/p/35270383

## logo
https://thenounproject.com/

## 矢量图
adobe XD

## PS
https://www.photopea.com/
在线图像编辑器，免费，可以替代 PhotoShop 的一部分功能

## Digital color meter
1. Digital color meter 原生的取色器
1. ColorSync Utility 原生的颜色工具（带rgb/hsv 转换）

## grapher & wolfram
MAC自带的grapher 画方程的图比matlab还给力啊

## 脑图

### 用代码画图
用Graphviz 画图, 用于绘制DOT语言脚本描述的图形

http://blog.2baxb.me/archives/906

### naotu 百度脑图
http://naotu.baidu.com/edit.html

	SHIFT+TAB

## Wireframes 原型图
- Axure RP
- Balsamiq Mockups
- https://modao.cc/ 墨刀，国内团队开发，不错的Axure 替代品

# File

## convert file
docx to txt

    textutil -convert html from.docx
    textutil -convert txt from.docx

## mdfind file
OS X有杀手级搜索工具Spotlight，命令行上就是mdfind命令了。
Spotlight能做的查找，mdfind也能做。包括搜索文件的内容和元数据（metadata）。

mdfind还提供更多的搜索选项。例如-onlyin选项可以约束搜索范围为一个目录：

	$ mdfind -onlyin ~/Documents essay
	$ mdfind -onlyin ~/Pictures/ image

mdfind的索引数据库在后台自动更新，不过你也可以使用mdutil工具诊断数据库的问题，诊断mdfind的问题也等同于诊断Spotlight。
如果Spotlight的工作不正确，`mdutil -E`命令可以强制重建索引数据库。也可以用`mdutil -i`彻底关闭文件索引。

> Refer to: http://segmentfault.com/a/1190000000509514

# image upload
https://sm.ms/

# Screen/Video

## screen record

### asciinema, 终端录制工具

	brew install asciinema
	asciinema rec

## Flameshot
Flameshot：Linux下最接近Snipaste的截图软件

## screencapture
screencapture命令可以截图。和Grab.app与cmd + shift + 3或cmd + shift + 4热键相似，但更加的灵活。

抓取包含鼠标光标的全屏幕，并以image.png插入到新邮件的附件中：

	$ screencapture -C -M image.png
	用鼠标选择抓取窗口（及阴影）并复制到剪贴板：

	$ screencapture -c -W
	延时10秒后抓屏，并在Preview中打开之：

	$ screencapture -T 10 -P image.png
	用鼠标截取一个矩形区域，抓取后存为pdf文件：

	$ screencapture -s -t pdf image.pdf
	更多用法请参阅screencapture --help。

## QuickTime
Screen/Audio/Movie Recording

## Snagit
Snagit: Screen capture, Video Capture, Edit Video
It's be charged

## ASCII Art
Graph::Easy

    ASCII Art：使用纯文本流程图
    原文：http://weishu.me/2016/01/03/use-pure-ascii-present-graph/

### Monodraw
可以直接粘在txt里的图像：为Mac度身设计的文本图像编辑器
    http://36kr.com/p/216120.html

## GIF
If you think a GIF of what is happening would be helpful, consider tools like 
https://www.cockos.com/licecap/, 
https://github.com/phw/peek 
https://www.screentogif.com/ 

### my app installed
mac app(installed):
1. GIPHY
2. Kap

### draw gif
    ms paint: http://gifpaint.com/
    ppt

### Kap +KeyCastr
1. Kap 开源+简洁, 替代recordit/LICEcap/Gifcam
2. KeyCastr 显示按键

### recordit
700k, 极简，直接保存图片到recordit 自己的服务器(需要代理), 返回一个url

### LICEcap
LICEcap 非常轻量级，700KB。
不可编辑（除了增加text），直接导出为gif

### GifCam
比LICEcap 功能强大，但是不在appStore 列表
编辑状态可查看每一帧，下可以删除帧、增加当前帧延时。

## zapier
zapier 不是mac 下的工具，它一款让你更方便的使用其它web app 的web app. 它就像是胶水，将其它app 粘合起来
zapier.com
