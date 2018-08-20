---
date: 2018-03-03
---
# Chrome devtools 使用汇总
chrome://chrome-urls/

# devTool Source
参考文章:
- https://umaar.com/dev-tips/162-network-overrides/

我们做web 开发时常常想直接在devtools 中实时修改js/css/html 文件

chrome devtool 的source 选项卡(`cmd+6`) 正好提供了这两个功能
2. Filesystem
    - 用于直接修改本地文件 
    - chrome 会智能的将filesystem 与localhost 请求绑定(link to filesystem), 
    - 绑定后有一个绿色的标志，这样就不会cache 请求，(127.0.0.1)网络请求就会实时生效。
1. Overrides
    - 用于覆盖网络请求: 在`source/page`右键`save for override`或直接`edit`，保存的文件都被存储到overrides 指定目录(`按照域名建立文件夹`). 这种改写是`临时的`
    - 只能指定一个目录
    - 断点debug 时，实时修改文件，然后保存后会恢复到第一个断点，不用重新刷新
3. charles/fiddler 用代理 map 请求

## source map
> 参考： http://www.ruanyifeng.com/blog/2013/01/javascript_source_map.html
> devtool 中的设置: preference 开启 enable js/css source map

开发者调试代码时，直接调试`*.min.js`太麻烦了， 而是browser 通过`*.min.map`记录找到真正的`源代码`并定位到`出错位置`

1. 启用source map: 在行尾加`//@ sourceMappingURL=/path/to/file.js.map`
2. 生成map: 用java 生成:
    ```
    java -jar compiler.jar \ 
    　　　　--js script.js \
    　　　　--create_source_map ./script-min.js.map \
    　　　　--source_map_format=V3 \
    　　　　--js_output_file script-min.js
    ```

### manually add source map
按`Cmd+p` 或在`Source Tab` 中打开想map 的文件，右键`add source map`.
不过手动添加的一刷新就没有了，还是overriddes 靠谱

# print

## print reference variable
console.log happens in an asynchronous manner. 打印对象可能不是语句调用时，也不是最新的。而是语句执行时，

1. 某些ref var按引用传值，可以用json：

	str = JSON.stringify(obj);
	str = JSON.stringify(obj, null, 4); // (Optional) beautiful indented output.
	console.log(str);

2. 其它ref var(比如document.body)不可以json, 则需要break point: `debugger`

### console.dir
console.dir(object) 用于查看对象的所有属性

## watch variable change

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

# console

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

trace

	console.trace();//like xdebug trace

time 计时

	console.time([flag])
	//do sth.
	console.timeEnd([flag])
	console.time('egg')

profile

	console.profile('start')
	console.profileEnd()

# Edit JS
编辑js 是生效的，必须设置断点(但是一刷新就没有了，除非设置Filesystem: workspace)

	Add a break-point at an earlier point in the script
	Reload page
	Edit your changes into the code
	CTRL + s (save changes)
	Unpause the debugger

# 远程调试协议
http://taobaofed.org/blog/2015/11/20/webkit-remote-debug-test/

	open -a Google\ Chrome.app --args -remote-debugging-port=9222

# Network
chrome://chrome-urls
- Dns Cache
chrome://net-internals/#dns

- spdy
chrome://net-internals/#spdy

# shortcuts
建议使用vimium

# 保存你的更改
在工具中即时编辑样式或JavaScript很爽。但当你高高兴兴地做了修改，然后又要在源代码中重新实现一遍就不那么爽了。

Chrome和Safari的资源选项卡中提供了一项贴心的功能：它保存了你每次修改的版本（按Ctrl + S之后），还允许你往前或往后查看每个版本的变化。

你修改过的文件名旁边会出现一个箭头图标，表示它可以展开/收起以查看修改过的版本列表。在Chrome中，右键点击文件名可以选择保存这个文件。不过在Safari中你只能悲剧地复制和粘贴了。

# Element
- Dom Breakpoint

## Select element and inspect it

	$0 current select
	$1 last select
	$2 the last 2'th select
	$3 the last 3'th select

## watch Element
当DOM改变时创建一个断点

仅仅想找出是哪段脚本改变了某个元素的属性，简单地选中你要监视的元素，右键点击它，选择中断条件：

- Break on Subtree Modification
- Break on Attributes Modification
- Break on Node Removal

# var
所有浏览器中的一个常用工具，“监视”允许通过脚本选项卡右上栏的方便的区域来观察一组变量。要观察一个变量很简单，只要输入它的名字，“监视”将保持它最新的值。

# console

## 实时编辑和执行JavaScript代码

Chrome–在Chrome中，你可以直接在页面中进行编辑，并不需要使用单独的编辑器或者重新加载页面。简单地双击你想要改变代码，然后输入新的代码！按Ctrl + S （Mac，Cmd+S）保存。


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
console.trace(); 会记录函数调用栈的信息，并打印到控制台（我还是不会用..）

# JS

## Breakpoint
- Cmd+P 打开source file

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

## snippets
关闭浏览器后不会消失. 浏览器刷新时也不会执行，除非手动执行

## edit js
1. edit js in sources
2. cmd+s to saved
3. Refresh to clear edit

即使在断点时，你也可以编辑代码，按ctrl+S保存之后，你会看到区域2的背景由白色变为浅色，而断点会重新开始执行。

## remote debug
打开：

	chrome://inspect

连接手机:
https://developer.chrome.com/devtools/docs/remote-debugging

# console
如果是自己的项目可以在发布的时候生成三份东西

1. 源代码,比如 app.js
2. 压缩后的代码，比如 app.min.js
3. Sourcemap文件，比如app.js.map,这个文件保存了 `2->1` 映射

在Chrome等现代浏览器中你可以开启Sourcemap功能，这样你调试app.min.js的时候就像调试app.js一样方便

参考文章：
阮一峰的博文 http://www.ruanyifeng.com/blog/2013/01/javascript_source_map.html
英文	http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/

# charlesproxy
前面说的那些方法大多只能处理压缩的文件，无法处理混淆后的文件。

刚出炉的一片文章：使用 charlesproxy 的 map local 功能，这个功能可以在当前环境中用你的本地文件替代你的线上文件。
http://blog.icodeu.com/?p=709
