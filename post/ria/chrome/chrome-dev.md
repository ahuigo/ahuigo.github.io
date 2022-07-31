---
layout: page
title:	chrome dev
category: blog
private:
description: 
---
# Load Extension
Extension that you download from web store is packaged up as `.crx`. For development, chrome gives a quick way to loading up your working directory for testing

1. Visit `chrome://extensions`
2. Ensure that the `Developer mode`
3. Click `Load unpacked extension`

## Storage Location for Packed Extensions
Navigate to chrome://version/ and look for **Profile Path**, it is your default directory where all the `extensions, apps, themes` are stored.

    # Mac OSX
    ~/Library/Application\ Support/Google/Chrome/Default/Extensions

# debug
Right click `inspect popup`
Right click `inspect view`
https://developer.chrome.com/extensions/tut_debugging

- 重新cmd+r 加载extension, 清除缓存、dns、重启浏览器..
- 其它插件的干扰，如`Go Agent`
- 使用`incognito` 模式

# API
https://developer.chrome.com/extensions/api_index

Chrome的程序和扩展程序都非常喜欢调用chrome.* APIs，这些API可以让你通过不同的方式来操控浏览器，API通常会在后台脚本里面被调用，这是我找到的一些常用API：

- chrome.tabs 标签页：新建、刷新、关闭、访问和操控标签页
- chrome.history 历史：访问用户浏览历史
- chrome.bookmarks 书签：添加、编辑、移除和搜索用户书签
- chrome.events 事件：监听或者管理浏览器发生的事件
- chrome.commands 命令：添加或者改变键盘命令
- chrome.contextMenus 右键：添加条目到右键下文菜单
- chrome.omnibox 多功能框（地址栏）：添加多功能框关键字，使用户可以向扩展发送指令或者激活扩展

这些权限必须在`manifest.json` 中声明 才能使用

	{
	  "permissions": [
	    "contextMenus",
	    "tabs",
	    "https://google.com/*",
	    "https://developer.mozilla.org/*"
	  ]
	}

## contextMenus 右键菜单
chrome.contextMenus 是另一个提供用户界面，方便用户和扩展交互的方式。Chrome的右键菜单通过右键激活，但根据激活内容的变化，菜单内容也会做相应改变。

chrome.contextMenusAPI允许你向为不同内容激活的右键菜单添加项目，若要使用此API，则在manifest.json文件中声明相应的contextMenus权限。

目前可用的激活内容有：

	all, page, frame, selection, link, editable,image, video,  audio

对应：所有内容、页面、框架、选择、链接、可编辑、图像、视频、音频，以下这个例子需要contextMenus 和tabs权限，他可以使扩展为右键菜单添加一个根项目，然后添加一个子菜单，用来复制当前的页面到一个新选项卡。[b]

	var root = chrome.contextMenus.create({
	   title: 'MyExtension',
	   contexts: ['page']
	}, function () {
	   var subMenu = chrome.contextMenus.create({
		   title: 'Duplicate Tab'
		   contexts: ['page'],
		   parentId: root,
		   onclick: function (evt) {
			   chrome.tabs.create({ url: evt.pageUrl })
		   }
	   });
	});

# Reference
[chrome.pageAction]: https://developer.chrome.com/extensions/pageAction
[chrome.contextMenus]: http://developer.chrome.com/extensions/contextMenus.html
