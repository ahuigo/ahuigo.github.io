---
title: Momenta 前端面试题
date: 2019-11-19
private: 
---
# 前端基础笔试题(选答)
要求：
1. 时间有限，请选择最能反映你的经验、能力的问题作答。
2. 可简答、也可详答、也可只答自己知道的那一部分
3. 可用伪代码，但是要体现你的思路
4. 无论是代码题、问答题，请把答案写到代码区、或注释中

## dom/css 操作: 消息居中
1.请给下面的html代码加上css，让消息提示框居中显示：
![](/img/news/js-interview-css-center.png)

    <div class="msg">
        <h3>屏幕居中消息</h3>
    </div>

要求：
1. 消息框要屏幕居中(无论鼠标如何滚动，都居中显示)
2. 文字也要居中
3. 请备注一下你所用到的css 属性的含义

2.请封装一个通知消息提示的函数
1. 调用该函数，在屏幕中央能显示居中消息
2. 可以的话让给居中消息右键加一个X 可关闭点击按钮，允许关闭该消息

请补全代码：

    function notice(msg){
        ....
    }

    notice("屏幕居中消息")

## React 考查
用React 写一个简单的 四则运算计算器 ：
1. 输入: 两个数字，一个运算符
2. 使用：点击`=`等号，输出计算结果

## 实现一个js函数
能用js 实现这样一个js 函数吗

    sum(1)(2)() //3
    sum(1)(2)(3)() //6
    sum(1,2,3)() //6

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

## 两向量的平行
在平面中有两个向量，判断向量是否平行, 请补全以下代码

    vector1 = [1,2]
    vector2 = [-1,2]
    function isVectorParalell(vector1,vector2):boolean {

    }

## shell操作
有一个非常大的ip日志文件ip.log，格式为： ip,host,time

    $ cat ip.log
    192.168.1.1,momenta.ai,2020-07-06 T00:00:00
    192.168.1.2,baidu.com,2020-07-06 T00:00:01
    192.168.1.2,baidu.com,2020-07-06 T00:00:01

1. 请找到指定ip对应的域名?
2. 请找出访问次数最多的ip?

# 场景题(选答)

## 新冠状病毒
1000人中有1人带有病毒，我们需要对这1000人抽血，并用试剂盒 找出这名病毒携带者。
1. 试剂盒有限，我们可以将任意人次的血混合后检测（混合稀释不降低检测效果）
2. 每盒试剂盒验血，要1天才出结果, 试剂盒不可重复使用

你可以在几天? 用几盒试剂盒? 找出这名病毒携带者？
如果有一个或多个方案，请都给出

## 最近的餐厅
假设小明和小红想在晚餐时选择一家离两人最近餐厅，并且他们都有一个表示最喜爱餐厅的列表，
1. 每个餐厅的名字用字符串表示。
1. 餐厅的索引，表示餐厅到自己家的距离

帮助他们找出他们共同喜爱的最近的餐厅。如果有多个答案请全部给出 

示例:

    输入:
    ["沙县小吃", "四川火锅", "广东堡仔饭", "KFC"]
    ["KFC", "沙县小吃", "山西面馆"]
    输出: ["沙县小吃"]
    解释: 两数组中的值相同 且`离大家最近`的是"沙县小吃"，它有最小的距离和1(0+1)。

请实现代码, 并给出算法复杂度

## 求矩形相交的面积
请用任意语言实现矩形相交面积的计算(此题不能用伪代码, 代码要可执行)：

    var rectA = {
        left:-3, 
        bottom:0, 
        right:3, 
        top:4
    }
    var rectB = {
        left:0, 
        bottom:-1, 
        right:9, 
        top:2
    }
    function getIntersectArea(rectA, rectB){
        // 返回相交面积 或异常
    }
    getIntersectArea(rectA,rectB) == 6 //true

![](/img/news/interview-js.png)

扩展：如果是三维空间，两长方体的相交体积怎么计算（简答）？