---
title: Js Array 整理
date: 2018-10-04
priority:
---
# Js Array 整理
array 不像string 是primitive value, 所以length 可以缩短放大array。

	arr = [1,2,3]
	arr.length = 1; // [1]
	arr.length = 3;
	arr.push(4);// [ 1, <2 empty undefined>, 4 ]
    arr[10] = 10;// [ 1, <2 empty undefined>, 4 , <empty undef>, 10]

empty item 不会被for in 遍历, 但是会被 for of 遍历

## create array
### range 序列:

    [...Array(5).keys()]; //[[undefined, ....].keys]
    Array.from({length: 5}, (v,i) => i);
        [...Array(5)].map((v,i) => i);
    _.range(5)

以下有问题，可能引入prototype

    // bad
    for(let _ in Array(5))
    // better
    for(let _ of Array(5))

undefined 数组:

    Array(5)
    Array.from({length:5})
    Array.from(Array(5))

### fill

    Array(6).fill(8)
    > [1,2,3].fill(8)
    [ 8, 8, 8 ]

## .slice([start[, end]])
python vs js

    arr[:] arr.slice()
    arr[1:] arr.slice(1)
    arr[1:-3] arr.slice(1,-3)
    arr[:-3] arr.slice(0,-3)

## concat merge array
    [...arr1,...arr2]

concat()方法可以接收任意个元素和Array，并且自动把Array拆开，然后全部添加到新的Array里：

	var arr = ['A', 'B', 'C'];
	arr.concat(1, 2, [3, 4]); // ['A', 'B', 'C', 1, 2, 3, 4]

## join/obj
### join 转换:

    arr.toString();arr.valueOf();
    arr.join(',');//
	.join([separator]); //implode
### obj 转换:
    obj ={...arr}

## concat

	.concat(arr2) not in-place
	.concat(1,2) not in-place

## flat

    arr.flat(2); //二维变一维

## push,pop, shift


    arr.push('new item', 'item2'); //return length
    arr.pop();

    arr.unshift(...buffer) //return length
    arr.shift()
        .shift();//左移(移出) .unshift(item1,item2);//右移(移入)

## remove: splice

    first:
        arr.indexOf('3') !== -1 && arr.splice(arr.indexOf('3'), 1)
    all:
        arr = arr.filter(e => e !== '3')

    Array.prototype.remove = function() {
        var what, a = arguments, L = a.length, ax;
        while (L && this.length) {
            what = a[--L];
            while ((ax = this.indexOf(what)) !== -1) {
                this.splice(ax, 1);
            }
        }
        return this;
    };

## copy list
slice, merge, Object.assign, Array.from,  都是浅copy.

    arr.slice(0)
    Array.prototype.slice.call(arr)
    [...arr]
    Array.from(arr)

Array fill 的引用问题

    const squares = Array(3).fill(Array(3).fill(null))
    squares[0][0] = 1
    console.log(squares) // [[1,null,null],[1,null,null],[1,null,null]]

用临时函数生成避免引用

    const squares = Array.from({length:3},() => Array(3).fill(null))
    squares[0][0] = 1
    console.log(squares) // [[1,null,null],[null,null,null],[null,null,null]]

## .sort .reverse inplace(python)+return
重排方法(改变arr本身, 并返回arr):

    arr.reverse();//倒序
    arr.sort();//从小到大
    arr.sort(function(a,b){return a-b;});//自定义排序

不改变

    arr.slice(0).sort()
    Array.prototype.slice.call(list).sort
    python:
        sorted(list)

### .sort + filter/unique

  myData = myData.sort().filter(function(el,i,a){return i==a.indexOf(el);})

sort()方法会直接对Array进行修改，它返回的结果仍是当前Array

  myData.sort((i,j)=>i-j); //从小到大
  myData.sort((i,j)=>i>j?1:-1); //从小到大
  myData.sort((i,j)=>i>j); //wrong!!!!!

for list:

    var list = document.querySelector('#test-list')
    //Array.prototype.slice.call(list)
    [...list]
        .sort((a,b)=>a.innerText>b.innerText?1:-1)
        .map(node=>list.appendChild(node))

## splice 
操作方法:

		[0,1].concat(2,[3,4]);//返回数组[0,1,2,3,4];
		arr.slice(start,[end]);//范围不含end本身,end可为负数,

有副作用

		arr.splice(start,[howmany]);//返回删除范围
		arr.splice(start,howmany,val1,val2,....);//返回删除范围,并插入数据
        // remove key
        arr.splice(index,1)


# find

## indexOf(value)

    ['aa','bb','cc'].indexOf('aa');//0 找不到就返回-1
    ['aa','bb','cc','aa'].lastIndexOf('aa');//3 找不到就返回-1

## find & findIndex(callback)
returns the value of the first element:

    // expected output: 12
    [5, 12, 8, 130, 44].find((element) => element > 10)
    // expected output: 1
    [5, 12, 8, 130, 44].findIndex((element) => element > 10)

## include inArray

    ['a', 'b', 'c'].includes('a')     // true
    ['a', 'b', 'c'].indexOf('a') > -1      //true
    2 in ['a', 'b', 'c']

    ['a', 'b', 'c', 'd'].includes('c', 2)      // true
    ['a', 'b', 'c', 'd'].includes('c', 3)      // false

inludes 是类型匹配的

    ['',undefined].includes(null) //false

for string

    'hello world'.includes('hello') //true
    'hello world'.includes('')      //true

### in array
    const set = new Set(['foo', 'bar']);
    console.log(set.has('foo'));
    console.log(set.has('baz'));

## index in arr/obj
是用：`index in arr`, 不是`value in arr`(这与python 不同)

	Array.prototype.inArray = function(needle) {
        var length = this.length;
        for(var i = 0; i < length; i++) {
            if(this[i] == needle) return true;
        }
        return false;
    }

## is_array
不要用`typeof []==='object'`

	if (Array.isArray)
	    return Array.isArray(v);
	else
		v instanceof Array

# for

## for in: index
1. 用for-in 遍历`array/string + obj` 的属性(length 等不可读的属性除外)

    for(var index in arr){
        arr[index]
    }
    for(var index in 'str'){
        'str'[index]
    }

## for of: value
1. for of：只循环`array/string + map-set-generator`本身的元素

e.g.

    s = new Set([1,2,3])
    for(var it of s){
        console.log(it)
    }

    for(var it of (new Map([[1,2],[3,4]]))){
        console.log(it[0], it[1])
    }
    for(var i of [1,2,3]){console.log(i)}


## chunk

    for(i=0;i<arr.length; i=i+size){
        arr.slice(i,i+size)
    }

## .forEach
string  没有此属性. array/set/map 等都有
3. .forEach: value、key、self(`arr + map-set-generator`本身)

    var m = new Map([[1, 'x'], [2, 'y'], [3, 'z']]);
    m.forEach(function (value, key, map) {
        console.log(value, map===m);
    });

## entries: python enumerate
dict and array:

    for(let [key, value] of Object.entries(myObject)) {
        console.log(key, value); // "first", "one"
    }

### fromEntries
    Object.fromEntries([['a',1],['b',2]])

## loop circle

    var len = myArray.length
    for (const [i, value] of myArray.entries()) {
        console.log('%d: %s', i, myArray[(i+1)%len]);
    }

## flat
    [[1,2],3].flat() //[1,2,3]
    ['a','b,c'].flatMap(v=>v.split(',')) //[a,b,c]

## inter, diff, union 交差并
intersection:

    let intersection = arrA.filter(x => arrB.includes(x));

diff:

    let difference = arrA.filter(x => !arrB.includes(x));

union

    arrA.concat(arrB)
    let union = [...arrA, ...arrB];
    let union = [...new Set([...arrA, ...arrB)];

# Map/Set
python 早就提供了

## Map
这里的map/set 不是数组的method, 而是一个原型类:

    var m = new Map([['Michael', 95], ['Bob', 75], ['Tracy', 85]]);
    m.get('Michael'); // 95

map crud:

    m.set('Adam', 67); // 添加新的key-value
    m.has('Adam'); // 是否存在key 'Adam': true
    m.delete('Adam'); // 删除key 'Adam'
    m.get('Adam'); // undefined

map to array, 类似Object.entries()

    const newArr1  = [ ...map  ]; 
    const newArr2 = Array.from( map );

### WeakMap
key 只能为对象，WeakMap 不可遍历

    var obj = {};
    var wm = new WeakMap();
    wm.set(obj, 1);
    wm.get(obj);	// 1

    obj = null;     //wm 没有引用obj, 被垃圾回收了
    wm.get(obj);	// like python: wm[id(obj)]

wm 适合记录对象额外信息， 比如标记对象状态，对象呗回收就失效了

    wm[obj1] = ...
    wm[obj2] = ...

## Set
Set中自动被过滤：

    var s = new Set([1, 2, 3, 3, '3']);
    s; // Set {1, 2, 3, "3"}

Set crud:

    s.add(4);
    s.delete(3);
    s.has(4)

### 交集
    union=new Set([...a,...b]);
    intersect=new Set([...a].filter(x=>b.has(x)))
    diff=new Set([...a].filter(x=>!b.has(x)));

## map/reduce/any:some/all:every
迭代方法: all:every, any:some, filter, map/forEach

		.every(func);//每一项运行给定函数都返回true,结果才返回true. 
		.some(func);//只要其中一项运行指定函数时返回true,结果就返回true.


		.filter(func);//返回运行为true item组成的数组
		.map(func);//返回函数运行结果组成的数组
		.forEach(func);//只运行不返回

        func = function (element, index, self)

对于object:

    > Object.entries({a:101}).every(([k,v])=>v>100)

去重复:

    r = arr.filter(function (element, index, self) {
        return self.indexOf(element) === index;
    });

	归并方法:

		.reduce(func);//从第1,2项开始; 不可以为空！单个按原值返回
		.reduce(func, init_value);//从第1项开始; 可以为空！
		.reduceRight(func);//倒序
        //index 指向的是cur
		arr.reduce(function(pre,cur,index,array_self){return pre+cur;})
		[1,2,3].reduce(function(pre,cur,index,array_self){return pre+cur;})
			array_self 作为数组是按引用传值的(数组元素length>=1)
			prev = prev+ curr = 1+2 = 3;
			prev = prev+ curr = 3+3 = 6;