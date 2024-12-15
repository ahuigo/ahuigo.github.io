---
title: chrome debug source
date: 2024-11-07
private: true
---
# todo
https://developers.google.com/web/tools/chrome-devtools/evaluate-performance?hl=zh-CN

# devTool Source
参考文章:
- https://umaar.com/dev-tips/162-network-overrides/

我们做web 开发时常常想直接在devtools 中实时修改js/css/html 文件

chrome devtool 的source 选项卡(`cmd+6`) 正好提供了这样的功能. 它包括了：
1. Workspace(原名Filesystem)
    - 用于直接修改本地文件 
    - chrome 会智能的将filesystem 与localhost 请求绑定(link to filesystem), 
    - 绑定后有一个绿色的标志，这样就不会cache 请求，(127.0.0.1)网络请求就会实时生效。
2. Overrides: 覆盖网络请求 headers+content
    1. 先指定临时目录（只能指定一个目录）: 这个目录是临时目录，用于保存调试overrides 的文件。
        1. 一般地，如果想覆盖`/js/marked.js`, 就选择打开本地的`js`目录即作为临时目录，又可以查看修改源文件
    2. 覆盖网络请求: 在`source/page`或`network`中右键`save for override`, 
        1. 然后直接`edit`此文件
        2. `command+s`保存的文件都被存储到overrides 指定目录(`按照域名建立文件夹`). 
    3. 断点debug 时，实时保存文件后，**不用重新刷新**, 代码实时生效
3. Content scripts: 调用扩展程序的js
4. snippets: 存放你的code，按`cmd+enter`执行

## Workspace 使用
在soruce的workspace 中
1. 选择 Add folder to workspace，然后选择的文件夹。
2. 进行修改并保存，修改会立即生效
    1. chrome会自动根据当前页面**加载的资源**映射到workspace(如果映射关联workspace相应的文件, 文件会有一个小绿点)
    2.  Overrides 中的修改会优先生效。 没有 Overrides 时: Workspace 中的修改会生效。

## source map
js-debug-sourcemap.md

# 断点调试
## remote debug
查看可调试的设备：

	chrome://inspect

参考: 
- https://developer.chrome.com/devtools/docs/remote-debugging
- http://taobaofed.org/blog/2015/11/20/webkit-remote-debug-test/

Chrome DevTools 协议:

    # Chrome 会在本地机器的 9223 端口上启动一个调试服务器。你可以通过这个端口使用 Chrome DevTools 协议来远程调试 Chrome 实例。
	open -a Google\ Chrome.app --args -remote-debugging-port=9223
    lsof -i:9223

## override js
1. edit js in sources
2. cmd+s to saved
3. Refresh to clear edit

即使在断点时，你也可以编辑代码，按ctrl+S保存之后，你会看到区域2的背景由白色变为浅色，而断点会重新开始执行。

## Element
- Dom Breakpoint

### Select element and inspect it

	$0 current select
	$1 last select
	$2 the last 2'th select
	$3 the last 3'th select

### watch Element
当DOM改变时创建一个断点

仅仅想找出是哪段脚本改变了某个元素的属性，简单地选中你要监视的元素，右键点击它，选择中断条件：

- Break on Subtree Modification
- Break on Attributes Modification
- Break on Node Removal


## js Breakpoint
- Cmd+P 打开source file

## watch var
### watch var value
在debug js时，call stack 右侧有一个scope/watch:
- scope: 有local/script/Global 三个观察对象,有点多
- watch: 添加要查看的变量名（当断点位置可以访问到变量时，才能观察值）

### watch variable change

	console = console || {}; // just in case
	console.watch = function(oObj, sProp) {
		sPrivateProp = "$_"+sProp+"_$"; // to minimize the name clash risk
		oObj[sPrivateProp] = oObj[sProp];//为了保留历史值. js中的obj.prop 相当与obj['prop'] 是一样的

		// overwrite with accessor
		Object.defineProperty(oObj, sProp, {
			get: function () {
				return oObj[sPrivateProp];
			},

			set: function (value) {
				//console.log("setting " + sProp + " to " + value); 
				debugger; // sets breakpoint
				oObj[sPrivateProp] = value;
			}
		});
	}

Invocation:

	console.watch(obj, "someProp");

有人还写了watch.js。

### JS Breakpoint
> 断点时，console 中的this 指向backbone 而不是window

1. Press `Pretty print`, if the code is not human readable.
2. Add Breakpoint or Watch Expression
3. Refresh

断点shortcuts:

	F10 step over
	F11 step in
	Shift+F11 step out
	F8	resume/stop script execution

### watch
press `+`, 输入变量名, 比如`i` 就可以观察变量。不区分scope, 在当前scope 如果没有`i` 就显示`undefined`

### XHR Breakpoint
击+ 并输入 URL 包含的字符串即可监听该 URL 的 Ajax 请求，输入内容就相当于 URL 的过滤器。如果什么都不填，那么就监听所有 XHR 请求。一旦 XHR 调用触发时就会在 request.send() 的地方中断。

# console funcs
## console log

	console.log('%s-%d','abc', 123)

	//console color
	console.info()
	console.warn()
	console.debug()
	console.error()

console group 用于对log 分组:

	console.group('group1')
	console.groupEnd();

## console log

	console.log("%d年%d月%d日",2011,3,26);

可以显示一个对象所有的属性和方法。
dir

	console.dir(console)

keys values

	keys(obj)

console.table

	console.table([{name: 'ye'}])
	console.table({a:{name: 'ye'}})

Chrome 控制台中原生支持类jQuery $

	$('#id')

console.group

	console.group("第一组信息");
	console.log("xx1");
	console.log("xx");
	console.groupEnd();

assert

	console.assert(year == 2018 );

count

	console.count('次数')
    1

## console 性能
第一种是通过 console.time 函数计时

	console.time('a'); //用一个key标记计时开始
	...do sth....
	console.timeEnd('a'); //得到这个key 标识开始的代码的耗时

第二种是console.profile() 生成profile, 然后在profile tab 中观察代码耗时的细节

	console.profile()
	...do sth....
	console.profileEnd(); //生成profile1 用于

## trace
会记录函数调用栈的信息，并打印到控制台//like xdebug trace

    function f(){console.trace()}

## print

### print reference variable
console.log happens in an asynchronous manner. 打印对象可能不是语句调用时，也不是最新的。而是语句执行时，

1. 某些ref var按引用传值，可以用json：

	str = JSON.stringify(obj);
	str = JSON.stringify(obj, null, 4); // (Optional) beautiful indented output.
	console.log(str);

2. 其它ref var(比如document.body)不可以json, 则需要break point: `debugger`

### console.dir
console.dir(object) 用于查看对象的所有属性
# charlesproxy
前面说的那些方法大多只能处理压缩的文件，无法处理混淆后的文件。

刚出炉的一片文章：使用 charlesproxy 的 map local 功能，这个功能可以在当前环境中用你的本地文件替代你的线上文件。
http://blog.icodeu.com/?p=709