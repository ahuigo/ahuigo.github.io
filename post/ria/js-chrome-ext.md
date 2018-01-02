---
layout: page
title:	ria chrome dev
category: blog
description: 
---
# Preface
Reference:
https://developer.chrome.com/extensions/examples/tutorials/getstarted/icon.png

# todo
http://blog.jobbole.com/46608/
http://www.cnblogs.com/guogangj/p/3235703.html#t1

# ext list
http://weibo.com/p/1001603917441372715024 link to  http://get.ftqq.com/8215.get


# manifest.json
It contains extension's name, description, version_number. 
declare to chrome what the extension is going to do, and what permissions it requires in order.[manifest](https://developer.chrome.com/extensions/manifest)

In our example will decalre a `browser action` and `activeTab permission` to see the URL of the current tab, and the `host permission` to access the external google image search API.

	{
	  "manifest_version": 2,

	  "name": "Getting started example",
	  "description": "This extension shows a Google Image search result for the current page",
	  "version": "1.0",

	  "browser_action": {
		"default_icon": "icon.png",
		"default_popup": "popup.html"
	  },
	  "permissions": [
		"activeTab",
		"https://*.googleapis.com/", //被允许访问的网站
	  ]
	}

> JavaScript and HTML must be in separate files: see our Content Security

# Page Action
http://files.cnblogs.com/guogangj/chrome-plugin-page-action-demo.7z
这个插件只有4个文件，其中两个还是图标，那就只剩下一个必须的manifest.json和一个background.js了。

mainifest.json：

	{
		 "manifest_version": 2,
		 "name": "cnblogs.com viewer",
		 "version": "0.0.1",
		 "background": { "scripts": ["background.js"] },
		 "permissions": ["tabs"],
		 "page_action": {
			  "default_icon": {
				   "19": "cnblogs_19.png",
				   "38": "cnblogs_38.png"
			  },
			  "default_title": "cnblogs.com article information"
		 }
	}

注意：这里是“page_action”而不是“browser_action”属性了. `pageAction` 是用于单个页面的(位于地址栏最右边)，而`browserAction` 是 用于全局的

页面按钮可以通过[chrome.pageAction] API控制，可以在不同的标签页中灵活的显示或者隐藏。

“permissions”属性里的“tabs”是必须的，否则下面的js不能获取到tab里的url，而这个url是我们判断是否要把小图标show出来的依据。
background是什么概念？
这是一个很重要的东西，可以把它认为是chrome插件的主程序，理解这个很关键，一旦插件被启用（有些插件对所有页面都启用，有些则只对某些页面启用），chrome就给插件开辟了一个独立的javascript运行环境（又称作运行上下文），用来跑你指定的background script，在这个例子中，也就是background.js。

	function getDomainFromUrl(url){
		 var host = "null";
		 if(typeof url == "undefined" || null == url)
			  url = window.location.href;
		 var regex = /.*\:\/\/([^\/]*).*/;
		 var match = url.match(regex);
		 if(typeof match != "undefined" && null != match)
			  host = match[1];
		 return host;
	}

	function checkForValidUrl(tabId, changeInfo, tab) {
		 if(getDomainFromUrl(tab.url).toLowerCase()=="www.cnblogs.com"){
			  chrome.pageAction.show(tabId);
		 }
	};

	chrome.tabs.onUpdated.addListener(checkForValidUrl);

代码中，我们使用了一个正则表达式去匹配url，获取出其中的domain部分，如果domain部分是“www.cnblogs.com”的话，就把小图标show出来

# script
scripts 分
- background script
- popup script
- content script(注入到页面| source content scripts)
- self script(页面自身的脚本)

为了避免content script 与页面自身(self script)发生冲突，chrome 开辟了一个独立的运行空间给content script 使用，它只能访问页面的dom 而不能直接访问page script

那么，Content Script会在什么时候运行呢？
默认情况下，是在网页加载完了和页面脚本执行完了，页面转入空闲的情况下（Document Idle），但这个是可以改变的，详情可参考https://developer.chrome.com/extensions/content_scripts.html，查看其中的“run_at”。

由于处于不同的运行环境中，Content Script和Background Script不能直接互相访问，那它们之间如何通信？
通过Message！这个之后的代码中会有。

我们完成这么一个例子：
抓取网页的内容得依靠content_script.js，然后通过sendMessage/onMessage和background.js交换数据，background.js将url信息通过ajax（XMLHttpRequest）发送给localhost，获取此页面的第一次访问的时间，最后，用户点小图标，popup.html出现，popup.html会读取（代码在popup.js中）background.js中的articleData的数据，把它显示出来。这就是整个过程。

## content js
通过`chrome.runtime.sendMessage` 向background js 发送消息

	var postInfo = $("div.postDesc");
	if(postInfo.length!=1){
		chrome.runtime.sendMessage({type:"cnblog-article-information", error:"获取文章信息失败."});
	}
	else{
		var msg = {
			type: "cnblog-article-information",
			title : $("#cb_post_title_url").text(),
			postDate : postInfo.find("#post-date").text(),
			author : postInfo.find("a").first().text(),
			url: document.URL
		};
		chrome.runtime.sendMessage(msg);
	}

## background js
`chrome.runtime.onMessage` 接收消息

	var articleData = {};
	articleData.error = "加载中...";
	chrome.runtime.onMessage.addListener(function(request, sender, sendRequest){
		if(request.type!=="cnblog-article-information")
			return;
		articleData = request;
		articleData.firstAccess = "获取中...";
		if(!articleData.error){
			$.ajax({
				url: "http://localhost/first_access.php",
				cache: false,
				type: "POST",
				data: JSON.stringify({url:articleData.url}),
				dataType: "json"
			}).done(function(msg) {
				if(msg.error){
					articleData.firstAccess = msg.error;
				} else {
					articleData.firstAccess = msg.firstAccess;
				}
			}).fail(function(jqXHR, textStatus) {
				articleData.firstAccess = textStatus;
			});
		}
	});

## popup js
popup 通过`chrome.extension.getBackgroundPage` 获取background 的变量

	document.addEventListener('DOMContentLoaded', function () {
		var data = chrome.extension.getBackgroundPage().articleData;
		if(data.error){
			$("#message").text(data.error);
			$("#content").hide();
		}else{
			$("#message").hide();
			$("#content-title").text(data.title);
			$("#content-author").text(data.author);
			$("#content-date").text(data.postDate);
			$("#content-first-access").text(data.firstAccess);
		}
	});

# Load Extension
Extension that you download from web store is packaged up as `.crx`. For development, chrome gives a quick way to loading up your working directory for testing

1. Visit `chrome://extensions`
2. Ensure that the `Developer mode`
3. Click `Load unpacked extension`

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
