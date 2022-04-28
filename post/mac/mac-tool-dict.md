---
title: mac tool 词典工具
date: 2020-10-28
private: true
---
# mac 自带的词典工具
> https://medium.com/p/8b07b7c8a88

mac 自带的词典APP, 名叫 Dictionary.app, 非常方便，本文我简写Dict.app 吧。
它提供了丰富的功能：
1. 各种在线、离线词典、wiki等
2. 三指查词
3. 快捷键语音朗读
4. 可以通过扩展工具alfred2 查词

## 选择你需要使用词典
Dict.app 支持非常多的词典，你按`Command+,` 就可以选择自己需要的词典，以及查词的顺序了. 如图

Dict.app 的字典文件在: /Library/Dictionaries ~/Library/Dictionaries 这两个目录

	$ du -sh /Library/Dictionaries/*
	$ du -sh ~/Library/Dictionaries/*
    Apple Dictionary.dictionary
	New Oxford American Dictionary.dictionary
	Oxford American Writer's Thesaurus.dictionary
	Oxford Dictionary of English.dictionary
	Oxford Thesaurus of English.dictionary
	Simplified Chinese - English.dictionary

自带的词典很不错. 如果不够用，你还可下载其它词典, 比如: 
1. langdao 词典(我有打包)
2. GoldenDict
3. 欧陆词典...

## 安装langdao 词典
我自己打包了langdao 的词典, 两种下载方式
1. [在baidu pan下载](链接: https://pan.baidu.com/s/17lP-y4cR18o8l6mL0B88qA 提取码: d4kd ),
2. https://github.com/ahuigo/eng-dict

下载后解压到字典目录就算安装好了:

	mkdir -p ~/Library/Dictionaries
	mv langdao-ec-gb.dictionary ~/Library/Dictionaries

安装好了后, 在词典中按`Cmd+,`开启新加的字典就可以了

## 三指查词
Mac 提供了一个非常方便的三指查词功能
1. 打开“系统偏好设置”然后在“触控板”(trackpad)
2. 打开这个功能 `查找&数据钩`（look up&data detectors）上)就可以啦

使用方法，就是在网页、终端中
1. 先选择单词
2. 再三指点按，或者按`Cmd+ctrl+d` 触发查词

## alfred
用alfred 查词非常方便. 

你可以设置快捷符`df`查询(默认是`define`)

    df word

还可以利用 alfred 的web search 定义baidu/google 翻译

    tl word
    tls word

终极的，可以实现通过快捷键`Shift+CMD+D` 划词查询其它词典，比如EDict(欧路词典). 方案可参考
1. 利用Alfred实现欧陆词典高效查词: 
    1. https://1991421.cn/2019/11/03/2d4d9af6/ 
    2. alfred workflow 下载：https://github.com/alanhg/alfred-workflows/tree/master/eudic-tools
2. https://wongdean.github.io/2019/10/11/Mac-%E7%AB%AF%E8%AF%8D%E5%85%B8%E6%8A%98%E8%85%BE%E5%B0%8F%E8%AE%B0/

# 欧陆词典
非常强大。 安装后可以设置很多快捷键。我常用的有：
1. 选中文字后，快捷键翻译 `Ctrl+Option+D`，类似于`Ctrl+Command+D` 使用Dict.app 查词


# F5:word completion.
绝大部分mac app 都支持用F5完成 word completion.

>Word completion seems to only work in Apple crafted cocoa apps, so you’ll be able to use the feature in Safari, Pages, Keynote, TextEdit, iCal, etc, but in a browser like Chrome you’re out of luck.

# text to voice
让 Mac 朗读屏幕上的文本， 可参考
https://support.apple.com/zh-cn/guide/mac-help/mh27448/mac
1. 在system Preference 中打开辅助菜单 Accessibility
2. Select `Spoken Cotent`
2. Enable `Speak selection`, 并在options 中开启`Option+ESC` Shortcuts

这样操作后，就可以选择一段文本，按`Alt+ESC` 触发单词朗读

## say 'word'

    $ say 'word'
	$ say -f mynovel.txt -o myaudiobook.aiff

## Voice Files Dir
可以选择其它发音文件，
所有的下载语音文件都是放在这里的：

    /System/Library/Speech/Voices
