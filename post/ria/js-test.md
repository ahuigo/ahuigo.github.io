---
layout: page
title:	前端自动化测试
category: blog
description: 
---
# Preface
前端自动化测试可以在几个方向进行尝试：

- 界面回归测试 测试界面是否正常，这是前端测试最基础的环节
- 功能测试 测试功能操作是否正常，由于涉及交互，这部分测试比界面测试会更复杂
- 性能测试 页面性能越来越受到关注，并且性能需要在开发过程中持续关注，否则很容易随着业务迭代而下降。
- 页面特征检测 有些动态区域无法通过界面对比进行测试、也没有功能上的异常，但可能不符合需求。例如性能测试中移动端大图素材检测就是一种特征检测，另外常见的还有页面区块静态资源是否符合预期等等。

# Reference
http://web.jobbole.com/82621/

# 界面回归测试
界面回归测试常见的做法有像素对比和dom结构对比两个方向。

**像素对比**

像素对比基本的思想认为，如果网站没有因为你的改动而界面错乱，那么在截图上测试页面应当跟正常页面保持一致。可以跟线上正常页面对比或者页面历史记录对比。像素对比能直观的显示图像上的差异，如果达到一定阈值则页面可能不正常。

	PhantomCSS
		像素对比比较出名的工具是PhantomCSS。 PhantomCSS结合了 Casperjs截图和ResembleJs 图像对比分析。单纯从易用性和对比效果来说还是不错的

**dom结构对比**

像素对比虽然直观，但动态元素居多且无法保证测试页面与线上页面同步时有所局限。@云龙大牛针对这个问题提供了新的解决方案page-monitor，根据dom结构与样式的对比来对比整个页面的变动部分。 使用效果示例：

	page-monitor
		你可以很快的搭建一个监控系统，监控页面的文字、样式等变动情况。

像素对比和dom结构对比各有优势，但也无法解决全部问题。何不综合利用呢？FEX部门QA同事就结合了两种方式提供了pagediff平台，正在对外公测中！有兴趣可以体验一把吧~ http://pagediff.baidu.com

# 功能测试 
通过模拟正常的操作流程来判断页面展现是否符合预期。

**Phantomjs**
大名鼎鼎的PhantomJS当然要隆重介绍啦！前面界面对比测试基本都是基于PhantomJS开发的， Phantom JS是一个服务器端的 JavaScript API 的 WebKit。其支持各种Web标准： DOM 处理, CSS 选择器, JSON, Canvas, 和 SVG。对于web测试、界面、网络捕获、页面自动化访问等等方面可以说是信手拈来。

**CasperJS**
casperjs是对PhantomJS的封装，提供了更加易用的API, 增强了测试等方面的支持。例如通过CasperJS可以轻松实现贴吧的自动发帖功能：

	casper.test.begin('测试发帖功能', function suite(test) {   
		
	//登录百度
		casper.loginBaidu();
	//实现略，可以通过cookie或者表单登录实现
		casper.thenOpen('http://tieba.baidu.com/p/3817915520', function () {  
			var text = "楼主好人";
			
	//等待发帖框出现
			this.waitForSelector(
				'#ueditor_replace', 
				function() {
					
	//开始发帖
					this.echo("开始发帖。发帖内容: " + text,"INFO");
					
	//执行js
					this.page.evaluate(function(text) {
						$("#ueditor_replace").text(text);
						$("a.poster_submit").click();
	//点击提交
					},text);
				},function(){
					test.fail("找不到发帖框#ueditor_replace");
				}
			);
		})
		.run(function () {
			test.done();
		});
	});

相对于单测来说，casperjs能用简单的API、从真实用户操作的角度来快速测试网站的功能是否正常，并且可以保留每一步测试的截图最终实现操作流可视化。

例如下面这个GitHub项目便使用Casperjs测试一个电子商务网站的登录、下单等重要流程是否正常。case完善之后一条命令便可测试整个网站。
casperjs能监听测试和页面的各个状态进行截图等操作，如果针对测试运行结果稍作优化，便可以形成一个可视化操作流：

*PhantomFlow操作对比测试*

有没有像图像对比一样直观，又能比较简单的写case的工具呢？可以考虑PhantomFlow, PhantomFlow假定如果页面正常，那么在相同的操作下，测试页面与正常页面的展现应该是一样的。 	
基于这点，用户只需要定义一系列操作流程和决策分支，然后利用PhantomCSS进行截图和图像对比。最后在一个很赞的可视化报表中展现出来。可以看下作者所在公司进行的测试可视化图表:

![](/img/ria-test-phantomflow.png)

图片中代表不同的操作，每个操作有决策分支，每个绿色的点代表图像对比正常，如果是红色则代表异常。点击进去可以查看操作的详情：

![](/img/ria-test-phantomflow.1.png)

这是一个不错的构思，它将操作测试的case浓缩成决策树，用户只需要定义进行何种操作并对关键部分进行截图即可。如果网站偏向静态或者能保证沙盒地址数据一致性，那么用这个测试工具能有效提高实施自动化测试的效率。

# 性能测试
[性能监控系统](http://fex.baidu.com/blog/2014/05/build-performance-monitor-in-7-days/)

*Phantomas*
这里推荐一个同样是基于PhantomJS的工具Phantomas,它能运行测试页面获取很多性能指标，加载时间、页面请求数、资源大小、是否开启缓存和Gzip、选择器性能、dom结构等等诸多指标都能一次性得到，并且有相应的grunt插件。

你也可以对检测指标进行二次开发，例如移动端定义一个最大图片大小的规则，在开发的时候如果使用了超过限制的大图则进行告警。不过如果把加载过程中的时间点作为常规的测试监控，则最好模拟移动端网络环境。

# 页面特征检测
我们还可以开发一些通用的测试规则，以测试页面是否正常。这种测试主要适用于在界面和操作上无法直接进行判断的元素。例如页面中广告部署是否正常。

广告部署检测实践
大部分都可以通过casperjs之类的工具来进行检测。 另外与广告相关的还有屏蔽检测等，检测页面div广告区块(非iframe广告)是否被拦截插件所拦截。

检测过程中只需要根据相关的检测规则判断选择器是否存在页面中即可。这在casperjs中一个api即可搞定:

	if(casper.exist(selector)){
		casper.captureSelector(filename,selector);
	}

这样便能直接截图被拦截的区域了。

*与自动化测试的结合*
回到刚才的需求，如何通过casperjs实现这些检测需求呢。casperjs支持执行JS来获取返回结果：

	this.page.evaluate(function(text) {
		$("#ueditor_replace").text(text);
		$("a.poster_submit").click();
	//点击提交
	},text);

而且可以主动注入jquery或者zepto等框架，这样你就可以以非常简单的方式来操作分析dom元素了。例如根据html结构特征获取部署类型、自动扫描广告检测容器宽度、获取广告的选择器来进行截屏等。如果页面有报错可以通过casper的api进行监听：

	casper.on("page.error", function(msg, trace) {
		this.echo(msg,'WARNING');
		
	//详细错误信息
		if(trace){
			this.echo("Error:    " + msg, "ERROR");
			this.echo("file:     " + trace[0].file, "WARNING");
			this.echo("line:     " + trace[0].line, "WARNING");
			this.echo("function: " + trace[0]["function"], "WARNING");
		}
	});

还能捕获网络请求分析死链或者广告请求：

	//记录所有请求
	casper.on('resource.requested', function(req,networkRequest) {
		
	//do something
	});

更加赞的是你还可以进入到跨域的iframe里面去进行操作！

	casper.withFrame(id/name,function(){
		
	//now you are inside iframe
	})

> 注意: iframe操作时推荐用name，id有时候会发生错位。

*配置化减小成本*
在开发了检测工具之后，当然要想办法减小使用成本，如上面例子中，只需将广告检测的一些规则和检测页面进行配置化，用户使用的时候只需要关注需要测试哪些页面而已。工具会根据用户提交配置自动运行并将结果返还给用户。

# 实践经验
前端自动化测试可以说还是一个在不断探索的领域，实施过程中也难免遇到问题。有些需要注意的点可以作为经验参考。

1. 与持续基础结合与CI系统的结合能更大范围更有效的发挥自动化测试的作用
1. 与构建工具结合`grunt`、`FIS`，将自动化测试与构建工具结合能更早的发现问题，也能减小使用和维护成本
1. 与工作流结合与日常工作流结合同样是为了减少使用成本，如将结果通过自定义的方式反馈给用户等。
1. 测试配置化测试配置化能让用户使用和维护更加简单、大部分情况下只需要维护配置脚本即可

## 与CI的结合
如果能通过ci实现一系列的自动化部署测试等工作，使用上就更加顺畅了。

谈起ci肯定要介绍jenkins,稳定可靠，是很多大公司ci的首选。只是在前端的眼中它看起来会感觉。丑了点和难用了点。。如果能像travis-ci那样小清新和直观易用该多好哈哈。

当然如果你要自己实现一套类似ci的流程也不复杂，因为对于上面提到的自动化测试来说只需要一个队列系统处理批量提交的测试任务然后将运行结果反馈给用户即可。当然前端测试可能对于自定义的报表输出要求更高点。
如果你想实现一套，使用laravel和beanstalkd能快速搭建一套完善的队列系统，laravel已经提供很多内置支持。各个服务的运行结果输出成html报表，就能实现一套轻量级且支持自定义展现的ci系统了。这方面有很多教程，可以自行搜索。

国外做的比较好的轻量级ci系统有:

	http://wercker.com/
	https://semaphoreci.com/
	https://codeship.com
	https://circleci.com/

良好的用户体验让人使用的心情愉悦没有障碍，如果想定制可以作为参考。
