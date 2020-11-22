---
title: 面试
date: 2019-10-29
private: 
---
# 前端基础笔试题
要求：
1. 请至少完成3题或以上。 
2. 时间有限，请选择最能反映你的经验、能力的问题作答。
3. 可简答、也可详答（注意要简明扼要)、也可只答自己知道的那一部分
4. 不限语言
5. 有些答案不是代码，请把答案写到注释中

## dom/css 操作: 消息居中
1.请给下面的html代码加上css，让消息提示框居中显示：
![](/img/news/js-interview-css-center.png)

    <div class="msg">
        <h3>屏幕居中消息</h3>
    </div>

要求：
1. 消息框要屏幕居中(无论鼠标如何滚动，都居中显示)
2. 消息框的文字也要上下左右居中
3. 请备注一下你所用到的css 属性的含义

2.请封装一个通知消息提示的函数
2.1. 调用该函数，在屏幕中央能显示居中消息
2.2. 可以的话让给居中消息右键加一个X，允许关闭该消息

请补全代码：

    function notice(msg){
        ....
    }

    notice("屏幕居中消息")

## React 考查
请说说什么是useReducer？
请说说什么是useRef？
请说说什么是useEffect？
举例说明useState

## Promise 
用js写一个sleep 延时函数

    function sleep(seconds){
        //请补全
    }

    (async function(){
        console.log('begin....');
        await sleep(5);
        console.log('5 seconds eslaped.');
    })()

## 什么是冒泡事件、捕获事件？
什么是冒泡事件、捕获事件？
如果可以请简单示例说明

## http
1. http与tcp 区别是什么？
2. http请求头Content-Type 有哪些？发送文件时用什么Content-Type头？
1. 有什么工具可以抓包查看http 请求, 请求、响应分别是由什么组成的？

## 以下代码输出的是哪个name？为什么？
    var name = "The Window";
    var object = {
    　　name : "My Object",
    　　getNameFunc : function(){
    　　　　return function(){
    　　　　　　return this.name;
    　　　　};
    　　}
    };
    console.log(object.getNameFunc()());

## 给Array 加一个uniq 方法
给Array 加一个uniq 去重方法, 请补全代码

    Array.prototype.uniq = function() {
        //请补全代码
    };
    console.log([1,2,3,3].uniq()) //output: [1,2,3]

能解释一下为什么是用Array.prototype.uniq 而不是 Array.uniq 吗？

## cookie 与 session 有什么区别？

## 在过去的开发中，你解决过什么坑？
请举一例简明描述一下

## 前端缓存方法有哪些
说明一下前端缓存方案有哪些方法，各自有什么特点？

## 两向量的投影
在平面中有两个向量，为判断向量是否平行, 请补全以下代码

    vector1 = [1,2]
    vector2 = [-1,2]
    function isVectorParalell(vector1,vector2):boolean {

    }

## shell操作知识
有一个非常大的ip日志文件ip.log，格式为： ip,host,time

    $ cat ip.log
    192.168.1.1,momenta.ai,2020-07-06 T00:00:00
    192.168.1.2,baidu.com,2020-07-06 T00:00:01
    192.168.1.2,baidu.com,2020-07-06 T00:00:01

1. 请找到指定ip对应的域名?
2. 请找出访问次数最多的ip?

## 老鼠试毒
1000瓶药水，1瓶有毒药，服用后一小时毒发，毒药可以无限混合稀释。
你可以在多长时间内用几只小白鼠能够找出毒药？简单说明一下方法

## 求最小索引和
假设Andy和Doris想在晚餐时选择一家餐厅，并且他们都有一个表示最喜爱餐厅的列表，每个餐厅的名字用字符串表示。

你需要帮助他们用最少的索引和找出他们共同喜爱的餐厅。 如果答案不止一个，则输出所有答案并且不考虑顺序。 你可以假设总是存在一个答案。

示例 1:

    输入:
    ["Shogun", "Tapioca Express", "Burger King", "KFC"]
    ["KFC", "Shogun", "Burger King"]
    输出: ["Shogun"]
    解释: 两数组中的值相同 且 具有`最小索引和`的是“Shogun”，它有最小的索引和1(0+1)。

请实现代码

# 备用题
## 求矩形相交的面积
请用任意语言实现矩形相交面积的计算：

    var rectA = {
        left:10, 
        bottom:10, 
        right:30, 
        top:30
    }
    var rectB = {
        left:20, 
        bottom:20, 
        right:30, 
        top:30
    }
    function getIntersectArea(rect1, rect2){
        // 返回相交面积 或异常
    }
    getIntersectArea(rect1,rect2) == 100 //true

![](/img/news/interview-js.png)
