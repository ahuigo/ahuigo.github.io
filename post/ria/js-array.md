---
layout: page
title:
category: blog
description:
---
# Preface
array 不像string 是primitive value, 所以length 可以缩短放大array。

	arr = [1,2,3]
	arr.length = 1; // [1]
	arr.length = 3;
	arr.push(4);// [ 1, <2 empty undefined>, 4 ]

## create array
序列:

    [...Array(5).keys()];
    Array.from({length: 5}, (x,i) => i);

undefined 数组:

    Array(5)
    Array.from({length:5})
    Array.from(Array(5))

## indexOf 位置方法:

    ['aa','bb','cc'].indexOf('aa');//0 找不到就返回-1
    ['aa','bb','cc','aa'].lastIndexOf('aa');//3 找不到就返回-1

## .slice([start[, end]])
python vs js

    arr[:] arr.slice()
    arr[1:] arr.slice(1)
    arr[1:-3] arr.slice(1,-3)
    arr[:-3] arr.slice(0,-3)

## concat
	var arr = ['A', 'B', 'C'];
	var added = arr.concat([1, 2, 3]);
	added; // ['A', 'B', 'C', 1, 2, 3]

concat()方法可以接收任意个元素和Array，并且自动把Array拆开，然后全部添加到新的Array里：

	var arr = ['A', 'B', 'C'];
	arr.concat(1, 2, [3, 4]); // ['A', 'B', 'C', 1, 2, 3, 4]

## join 转换:

		arr.toString();arr.valueOf();
		arr.join(',');//

## is_array
不要用`typeof []==='object'`

	if (Array.isArray)
	    return Array.isArray(v);
	else
		v instanceof Array


## inArray
不要用：`index in arr`

	Array.prototype.inArray = function(needle) {
        var length = this.length;
        for(var i = 0; i < length; i++) {
            if(this[i] == needle) return true;
        }
        return false;
    }

### for

    for(var index in arr){
        arr[index]
    }

还用map reduce

## map/reduce
迭代方法: all:every, any:some, filter, map/forEach

		.every(func);//每一项运行给定函数都返回true,结果才返回true. 
		.some(func);//只要其中一项运行指定函数时返回true,结果就返回true.


		.filter(func);//返回运行为true item组成的数组
		.map(func);//返回函数运行结果组成的数组
		.forEach(func);//只运行不返回

        func = function (element, index, self)

去重复:

    r = arr.filter(function (element, index, self) {
        return self.indexOf(element) === index;
    });

	归并方法:

		.reduce(func);//从第1,2项开始; 不可以为空！单个按原值返回
		.reduceRight(func);//从最后1,2项开始
		arr.reduce(function(pre,cur,index,array_self){return pre+cur;})
		[1,2,3].reduce(function(pre,cur,index,array_self){return pre+cur;})
			array_self 作为数组是按引用传值的(数组元素length>=2)
			prev = prev+ curr = 1+2 = 3;
			prev = prev+ curr = 3+3 = 6;



## 方法列表

	new Array(1,2,3);
	arr = [1,2,'d'];
	brr[0]=11;
	arr;//[11,2,'d']; //因为数组赋值使用的是对象引用

	.concat(arr2)
	.join([separator]); //implode
	.reverse()
	.shift();//左移(移出) .unshift(item1,item2);//右移(移入)

	.splice(start, howmany[, newValue]);//删除
        a=[1,2,3,4,5]
            [1, 2, 3, 4, 5]
        a.splice(2,2,'abc')
            [3, 4]
        a;
            [1, 2, "abc", 5]
	.sort([funcSort]);

## push,pop, shift

	栈方法:

		arr.push('new item', 'item2'); //return length
		arr.pop();

	队列:

		arr.push('new');
		arr.shift();//LIFO 后进先出

## sort
重排方法(改变arr本身, 并返回arr):

    arr.reverse();//倒序
    arr.sort();//从小到大
    arr.sort(function(a,b){return a-b;});//自定义排序

## splice 
操作方法:

		[0,1].concat(2,[3,4]);//返回数组[0,1,2,3,4];
		arr.slice(start,[end]);//范围不含end本身,end可为负数,
		arr.splice(start,[howmany]);//返回删除范围
		arr.splice(start,howmany,val1,val2,....);//返回删除范围,并插入数据


# Map/Set

## Map
这里的map/set 不是数组的method, 而是一个原型类:

    var m = new Map([['Michael', 95], ['Bob', 75], ['Tracy', 85]]);
    m.get('Michael'); // 95

map crud:

    m.set('Adam', 67); // 添加新的key-value
    m.has('Adam'); // 是否存在key 'Adam': true
    m.delete('Adam'); // 删除key 'Adam'
    m.get('Adam'); // undefined

## Set
Set中自动被过滤：

    var s = new Set([1, 2, 3, 3, '3']);
    s; // Set {1, 2, 3, "3"}

Set crud:

    s.add(4);
    s.delete(3);
    s.has(4)

# for-in vs for-of
1. 用for-in 遍历属性, 除了length 等不可读的属性
2. for of：只循环集合本身的元素
3. .forEach: 只循环元素、key、mamp/arr/集合本身

    s = new Set([1,2,3])
    for(var it of s){
        console.log(it)
    }

    for(var it of (new Map([[1,2],[3,4]))){
        console.log(it[0], it[1])
    }
    for(var i of [1,2,3]){console.log(i)}

## .forEach

    var m = new Map([[1, 'x'], [2, 'y'], [3, 'z']]);
    m.forEach(function (value, key, map) {
        console.log(value, map===m);
    });