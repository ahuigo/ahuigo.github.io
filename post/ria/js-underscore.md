# 通用array,obj,..
## map

    var list = _.map(obj, function (value, key) {
        return [value,key];
    });

## all:every,any:some
_.every([1, 4, 7, -3, -9], (x) => x > 0); // false
// 至少一个元素大于0？
_.some([1, 4, 7, -3, -9], (x) => x > 0); // true

## max / min:

    _.max(arr); // 9
    _.min(arr); // 3

    // 空集合会返回-Infinity和Infinity，所以要先判断集合不为空：
    _.max([]) -Infinity
    _.min([]) Infinity

    _.max({ a: 1, b: 2, c: 3 }); // 3

## groupBy
groupBy()把集合的元素按照key归类，key由传入的函数返回：

    var scores = [20, 81, 75, 40, 91, 59, 77, 66, 72, 88, 99];
    var groups = _.groupBy(scores, function (x) {
        if (x < 60) {
            return 'C';
        } else if (x < 80) {
            return 'B';
        } else {
            return 'A';
        }
    });
    // {
    //   A: [81, 91, 88, 99],
    //   B: [75, 77, 66, 72],
    //   C: [20, 40, 59]
    // }

## shuffle / sample
shuffle()用洗牌算法随机打乱一个集合：

    _.shuffle([1, 2, 3, 4, 5, 6]); // [3, 5, 4, 6, 2, 1]

sample()则是随机选择一个或多个元素：

    // 随机选1个：
    _.sample([1, 2, 3, 4, 5, 6]); // 2
    // 随机选3个：
    _.sample([1, 2, 3, 4, 5, 6], 3); // [6, 1, 4]

# Array
## flatten
flatten()最后都把它们变成一个一维数组：

    _.flatten([1, [2], [3, [[4], [5]]]]); // [1, 2, 3, 4, 5]

## zip / unzip
zip()把两个或多个数组的所有元素按索引对齐，然后按索引合并成新数组。

    var names = ['Adam', 'Lisa', 'Bart'];
    var scores = [85, 92, 59];
    l = _.zip(names, scores);

unzip()则是反过来：

    _.zip(...l)
    var [names, scores] = _.unzip(l) 

### object
名字和分数直接对应成Object呢？

    var names = ['Adam', 'Lisa', 'Bart'];
    var scores = [85, 92, 59];
    _.object(names, scores); // {Adam: 85, Lisa: 92, Bart: 59}

## uniq

    _.uniq(arr)
    _.uniq(arr,(x)=>x.toLowerCase());

## range
range()让你快速生成一个序列，不再需要用for循环实现了：

    [...Array(5).keys()]
    // 从0开始小于10:
    _.range(10); // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

    // 从0开始小于30，步长5:
    _.range(0, 30, 5); // [0, 5, 10, 15, 20, 25]

    // 从0开始大于-10，步长-1:
    _.range(0, -10, -1); // [0, -1, -2, -3, -4, -5, -6, -7, -8, -9]

# function
## bind原生
    func.bind(obj)

## partial
一个函数创建偏函数

    var pow2N = _.partial(Math.pow, 2);
    pow2N(3); // 8

不想固定第一个参数，想固定第二个参数怎么办？

    var cube = _.partial(Math.pow, _, 3);
    cube(3); // 9

## memoize
如果一个函数调用开销很大，我们就可能希望能把结果缓存下来，以便后续调用时直接获得结果。举个例子，计算阶乘就比较耗时：

    var factorial = _.memoize(function(n) {
        console.log('start calculate ' + n + '!...');
        var s = 1, i = n;
        while (i > 1) {
            s = s * i;
            i --;
        }
        console.log(n + '! = ' + s);
        return s;
    });

    // 第一次调用:
    factorial(10); // 3628800

对factorial()进行改进，让其递归调用：

    var factorial = _.memoize(function(n) {
        console.log('start calculate ' + n + '!...');
        if (n < 2) {
            return 1;
        }
        return n * factorial(n - 1);
    });

    factorial(10); // 3628800
    // 输出结果说明factorial(1)~factorial(10)都已经缓存了:
    // start calculate 10!...
    // start calculate 9!...

## once
等价于无参数的memoize

    var register = _.once(function () {
        console.log('Register ok!');
    });

## delay
delay()可以让一个函数延迟执行，效果和setTimeout()是一样的

    var log = _.bind(console.log, console);
    _.delay(log, 2000, 'Hello,', 'world!');

# Object
## keys()/allKeys()
1. _.keys(obj)可以非常方便地返回一个object自身所有的key
1. _.allKeys(obj) 包含从原型链继承下来的key

## values
_.values(obj)

## revert
    var obj = {
        Adam: 90,
        Lisa: 85,
        Bart: 59
    };
    _.invert(obj); // { '59': 'Bart', '85': 'Lisa', '90': 'Adam' }

## extend / extendOwn
相同的key，后面的object的value将覆盖前面的object的value。

    var a = {name: 'Bob', age: 20};
    _.extend(a, {age: 15}, {age: 88, city: 'Beijing'}); // {name: 'Bob', age: 88, city: 'Beijing'} a也改变了

extendOwn()和extend()类似，但获取属性时忽略从原型链继承下来的属性。

## clone
浅复制

    var copied = _.clone(source);

## isEqual

    {}==={} //false
    _.isEqual({a:1},{a:1}) // true

## chain
类似jquery 写成链式调用

    _.filter(_.map([1, 4, 9, 16, 25], Math.sqrt), x => x % 2 === 1);

    var r = _.chain([1, 4, 9, 16, 25])
            .map(Math.sqrt)
            .filter(x => x % 2 === 1)
            .value();
