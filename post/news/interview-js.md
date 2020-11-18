---
title: 面试
date: 2019-10-29
private: 
---
# 前端基础笔试题
以下题型，至少选2题并完成。

## dom/css 操作
1.请写css 实现div居中

    <div>
        <h3>屏幕居中消息</h3>
    </div>

请给上面代码加上css，让消息提示框居中显示：
![](/img/news/js-interview-css-center.png)

要求：
1. 消息框要屏幕居中(无论鼠标如何滚动，都居中显示)
2. 消息框的文字也要上下左右居中
3. 请备注你所用到的css 属性的含义

2.请封装一个通知消息提示的函数

    //请补全代码：
    function notice(msg){
        ....
    }

    notice("屏幕居中消息")

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
请示例说明

## http
1. http与tcp 区别是什么？
2. http请求头Content-Type 有哪些？发送文件时用什么头？
1. 有什么工具可以抓包查看http 请求

## 以下代码结果是什么？为什么？
　　var name = "The Window";

　　var object = {
　　　　name : "My Object",

　　　　getNameFunc : function(){
　　　　　　return function(){
　　　　　　　　return this.name;
　　　　　　};

　　　　}

　　};

　　alert(object.getNameFunc()());

## 能否给Array 加一个uniq 方法?

    console.log([1,2,3,3].uniq()) // [1,2,3]

## cookie 与 session 有什么区别？

# 加试
## 前端性能优化方案
请列举一下你了解掌握的性能优化方案有哪些？

## 你了解几种排序算法？
你了解几种排序算法？
请写一段编排序程序(不限语言)

     unsorted_array = [ 7, 8, 9, 4, 3, 2, 1, 6, 5 ]

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

## 两向量的投影
在平面中有两个向量，为了判断向量是否平行, 请补全以下代码

    vector1 = [1,2]
    vector2 = [-1,2]
    function isVectorParalell(vector1,vector2):boolean {

    }

两向量的夹角是(数学求角公式是什么)?

## shell操作知识
有一个非常大的ip日志文件ip.log，格式为： ip,host,time

    $ cat ip.log
    192.168.1.1,momenta.ai,2020-07-06 T00:00:00
    192.168.1.2,baidu.com,2020-07-06 T00:00:01
    192.168.1.2,baidu.com,2020-07-06 T00:00:01

2. 请找出访问数量最多的ip

## 正则知识
用户的邮箱形式如：

    Lily@gmail.com
    zhang1@qq.com
    liu1@momenta.works

请写一个正则检查一下用户输入的邮箱是否合法.

## 老鼠试毒
1000瓶药水，1瓶有毒药，服用后一小时毒发，毒药可以无限混合稀释。
那么一小时内用几只小白鼠能够找出毒药？

## 求最小索引和
假设Andy和Doris想在晚餐时选择一家餐厅，并且他们都有一个表示最喜爱餐厅的列表，每个餐厅的名字用字符串表示。

你需要帮助他们用最少的索引和找出他们共同喜爱的餐厅。 如果答案不止一个，则输出所有答案并且不考虑顺序。 你可以假设总是存在一个答案。

示例 1:

    输入:
    ["Shogun", "Tapioca Express", "Burger King", "KFC"]
    ["KFC", "Shogun", "Burger King"]
    输出: ["Shogun"]
    解释: 两数组中的值相同 且 具有`最小索引和`的是“Shogun”，它有最小的索引和1(0+1)。

代码：

    请实现代码
