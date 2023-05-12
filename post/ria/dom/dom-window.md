---
title: dom window
date: 2023-05-12
private: true
---
# Dom window

## 屏幕-窗口-页面 位置与尺寸

屏幕-窗口-页面 页面全高为: scrollTop + 窗口内高

### screen

    //屏幕大小
    screen.width/screen.height 屏幕的宽和高 这个是固定的分辨率
    1440/900

    //屏幕可用于窗口的宽高(窗口最大化时的大小)
    screen.availWidth/screen.availHeight 屏幕可用工作区宽/高(比如任务栏占用)
    1440/826

device-width(jquery)

    $(window).bind('resize', function () {
        deviceWidth = $(window).width();
    })

### window窗口

窗口位置 (0,22)

    screenX = screenLeft, screenY = screenTop (窗口左上角点在整个屏幕的位置)

窗口内宽/高

    window.innerWidth, window.innerHeight;
    //Same as
    document.documentElement.clientWidth, document.documentElement.clientHeight
    897,731

窗口外宽/高(包含了窗口菜单栏、dev-tool、底边任务栏等) (对于用户来说，基本没有用)

    window.outerWidth, window.outerHeight 当前页面可视区的外宽/高(含边界)
    1177,826

### 页面/Element(width height)
#### width/height

![dom-offset](/img/ria-dom-offset.gif)

div 的长宽度:

    padding + border + width(clientHeight)
    如果加 box-sizing: border-box; width 就相当于scrollWidth, 包括border+padding

不含border, and margin.(clientWidth)

    document.body.clientWidth .clientHeight body本身的宽/高
    ele.clientWidth, ele.clientHeight; //=padding+[ele.style.width, ele.style.height] (css的style必须指明:height:50px)

含border: offsetWidth = clientWidth + (clientLeft + cleintRight(没有这个属性)).:
clientLeft 就是 border-left

    document.body.offsetWidth .offsetHeight; //padding+border
    ele.offsetWidth, ele.offsetHeight; //padding+border

含border + margin

    document.body.scrollWidth .scrollHeight
    960,11473	 11473 = 10742+731
    	body.scrollHeight(固定) >= document.body.scrollTop(变化) + window.innerHeight
    	body.scrollWidth(固定) >= document.body.scrollLeft(变化) + window.innerWidth

#### 滚动偏移

##### 整个页面滚动偏移: 
body.style=width:3009px; 不是window的偏移，而是其内页面偏

    # 等价 scrollY == window.pageYOffset
    window.scrollX/scrollY
    window.pageXOffset/window.pageYOffset
        el.scrollLeft/scrollTop

    window.scrollTo(left,top);
    window.scrollBy(offsetX,offsetY)
    	window.scrollTo(0, 100) == window.scroll(0, 100) 
    	window.scrollBy(0, -100) 归位

到指定位置:

    window.scrollTo(0, 0) 
    window.scrollBy(x, y)

元素切换到可视区：

    ele.scrollIntoView()

滑动到底部(div 必须是overflow:scroll):

    // 滚动偏移=总长-clientHight
    div.scrollTop = div.scrollHeight - div.clientHeight;

##### scroll 底部检测

document　到底部检测:

    window.scrollY+document.body.clientHeight >= document.documentElement.scrollHeight

    //或（等价）
    window.scrollY + window.innerHeight
    >= document.documentElement.scrollHeight

div(overflow:scroll; height:100px) 底部检测

    div.scrollTop + div.clientHeight >=div.scrollHeight

##### 元素的滚动偏移(overflow: auto)

所有元素默认0: 页面滚动不影响它。不是本身的偏移，而是其内部元素偏

    ele.scrollLeft, ele.scrollTop
    body.scrollLeft .scrollTop	正文滚动的偏移

jquery:

    $(window).scrollTop([top])

元素归位:

    ele.scrollTo(0,0)
    ele.scrollBy(10,10)

切换到可视区:

    ele.scrollIntoView(0,0); 
    ele.scrollIntoView();

example:[js-postion](/demo/js-demo/dom-position.html)

#### 相对偏移

##### 相对父元素偏移

offsetLeft,offsetTop 相对上一个offsetParent(not static)左上角的偏移:

left:

    static: 当前块border的外边，与父层(offsetParent) border 的内边的距离
    relative/absolute: 当前块border的外边，与上层postion: not static 内边的距离

e.g.:

1. offsetLeft = left + margin(left)
2. clientLeft = the width of left border

e.g.:

    ele.offsetLeft, ele.offsetTop; //ele.style.left, ele.style.top 也是相对偏移，不过带有字符串"px"(必须显式指定)
    $(this).offset().left; $(this).offset().top;

##### touch 偏移(页面)

    var touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
    touchOriginY = touch.pageY;

#### 元素在视窗的位置
下面的是视窗位置(即窗口), 受滚动影响，它相对窗口的位置是变化的

    div.getBoundingClientRect().x y left,top, height,width
    x==left
    y==top

用 `ele.getClientRects()[0]`, 这个left/top/bottom, 它不是offsetLeft,
不受滚动影响（它是相对于可视窗口的, 而不是页面）

    rect.x = react.left 
    rect.y = react.top
    rect.right
    react.bottom
    function visible(ele){
    	rect = ele.getClientRects()[0]
    	return (rect.left<0 || rect.top <0) ? false : true;
    }

##### 切换视窗可见
goto:

    element.scrollIntoView();

##### 判断视窗可见
    function isVisible(elm) {
        const rect = elm.getBoundingClientRect();
        const viewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight);
        return !(rect.bottom < 0 || rect.top - viewHeight >= 0);
    }

#### 元素在页面的位置
方法1： 直接使用：

    function getOffset(el) {
        const rect = el.getBoundingClientRect();
        return {
            left: rect.left + window.scrollX,
            top: rect.top + window.scrollY
        };
    }

方法2：
如果父元素没有relative/absolute, 可直接使用：

    $0.offsetLeft

否则累加offsetLeft:

    function GetObjPos(ATarget) {
    	var target = ATarget;
    	var pos = {x:target.offsetLeft, y:target.offsetTop};

    	var target = target.offsetParent;
    	while (target)
    	{
    		pos.x += target.offsetLeft;
    		pos.y += target.offsetTop;

    		target = target.offsetParent
    	}
    	return pos;
    }

不要用： getComputedStyle(ele).left

    window.getComputedStyle($0).left;//可能返回的是auto; 而且它只是相对父元素(relative/fixed)的偏移

### 根据window位置(innerWidth,innerHeight) 查询element
It only works if the element is in the viewport.

    document.elementFromPoint(500,10)
    document.elementFromPoint(x, y).click();

https://stackoverflow.com/questions/9011668/get-element-at-point-in-entire-page-even-if-its-not-visible