# Preface
numpy是SciPy、Pandas等数据处理或科学计算库最基本的函数功能库。

1. 一个强大的N维数组对象ndarray
2. 广功能函数
3. 整合C/C++/Fortran代码的工具
4. 提供了线性代数、傅里叶变换、随机数生成的相关功能

Refer to : segmentfault.com/a/1190000011372128

## install
pip3 install numpy

# 数据类型

## np数组定义
```
>>>lst = [[1,3,5],[2,4,6]]
>>>np_lst = np.array(lst,dtype=np.float)
>>>print(np_lst.shape)#返回数组的行列
>>>print(np_lst.ndim)#返回数组的维数
>>>print(np_lst.dtype)#返回数据类型，float默认为64
>>>print(np_lst.itemsize)#np.array每个元素的大小，float64占8个字节
>>>print(np_lst.size)#大小，6个元素
(2, 3)
2
float64
8
6
```

### 初始化数组

```
>>>print(np.zeros([2,4])#初始化一个2行4列的数组
>>>print(np.ones([2,4])
[[ 0.  0.  0.  0.]
[ 0.  0.  0.  0.]]
[[ 1.  1.  1.  1.]
[ 1.  1.  1.  1.]]
```

### 随机序列

```
>>>print(np.random.rand(2,4))#将生成一个处于0~1之间2行4列的随机数序列（不加参数将只返回一个）
[[ 0.39531286  0.4845      0.1463168   0.82327991]
[ 0.89042255  0.65049931  0.43890163  0.89577744]]
```

### 如果想要多个随机整数：

```
print(np.random.randint(22,55,3))#必须有（前两个参数）指定范围，第三个参数用于指定生成的个数
[27 40 29]

print(np.random.randn(2，4))#生成标准正态随机数
[[-1.15561548  0.3689953   0.38253231 -1.16346441]
[-1.32625322 -0.41707673 -0.11822205 -0.95807535]]

print(np.random.choice([10,20,40,33]))#从指定可迭代的数组中生成随机数
20
print(np.random.beta(1,10,4))#生成4个beta分布
[ 0.02258548  0.25848896  0.00696899  0.0609543 ]
```

## 多维数组运算
下面介绍一些常用的运算操作：

```
lst=np.arange(1,11).reshape(2,5)
print(np.exp(lst))#自然指数操作
[[  2.71828183e+00   7.38905610e+00   2.00855369e+01   5.45981500e+01    1.48413159e+02]
[  4.03428793e+02   1.09663316e+03   2.98095799e+03   8.10308393e+03    2.20264658e+04]]
```

此外，还可以sqrt、log、sin、sum、max等操作：

我们下定义一个三维数组：

```
lst = np.array([
                [[1,2,3,4],[4,5,6,7]],
                [[7,8,9,10],[10,11,12,13]],
                [[14,15,16,17],[18,19,20,21]]
            ])
print(lst.sum())
252
```

我们可以看到sum方法对lst的所有元素都进行了求和，此外我们还可以通过对sum方法增加参数axis的方式来设置求和的深入维度：

```
print(lst.sum(axis=0))
[[22 25 28 31]#22=1+7+14；25=2+8+15
[32 35 38 41]]

print(lst.sum(axis=1))
[[ 5  7  9 11]#5=1+4；7=2+5
[17 19 21 23]
[32 34 36 38]]
print(lst.sum(axis=2))
[[10 22]#10=1+2+3+4；22=4+5+6+7
[34 46]
[62 78]]
```

这里的axis取值为数组维数-1，axis可以理解为进行运算操作时的深入程度，axis越大，深入程度越大。同理，不仅sum函数，max等函数也可以一样理解。

#### 相加运算
numpy.array是np最简单的数据结构。np.array相比与Python原生列表其强大之处在于可以实现对数组数据的运算。我们知道，list只能对元素的追加。而numpy是真正意义上的数据运算。

例如

    In [1]: import numpy as np
    In [2]: list1 = np.array([10,20,30,40])
    In [3]: list2 = np.array([4,3,2,1])
    In [4]: print(list1)
    [10 20 30 40]
    In [5]: print(list1+list2)
    [14 23 32 41]

但np最强大的地方不在于简单的一维运算，Np对矩阵也能进行基本的运算操作：

    lst1 =np.array([10,20,30,40])
    lst2 = np.array([4,3,2,1])
    print(np.dot(lst1.reshape([2,2]),lst2.reshape([2,2])))
    [[10 22]
    [34 46]
    [62 78]]
    [[ 80  50]
    [200 130]]

此外，由于原生list没有确定的数据类型，所以维护起来成本较高，而使用C编写的numpy，则可以声明各种常见的数据类型：

    lst = [[1,3,5],[2,4,6]]
    np_lst = np.array(lst,dtype=np.float)

np所支持的数据类型都有bool、int8/16/32/64/128/、uint8/16/32/64/128、float16/32/43、complex64/128、string。

## arange
```
>>> np.arange(10)
array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])

>>> np.arange(1,11,2) #得到step为2的range序列
[1 3 5 7 9]


>>> np.arange(10).reshape(2,5)
array([[0, 1, 2, 3, 4],
       [5, 6, 7, 8, 9]])

>>> np.arange(24).reshape(2,3,4)
array([[[ 0,  1,  2,  3],
        [ 4,  5,  6,  7],
        [ 8,  9, 10, 11]],

       [[12, 13, 14, 15],
        [16, 17, 18, 19],
        [20, 21, 22, 23]]])
```
### csvtxt
#### savetxt
保存一个4 * 5的矩阵，元素0~19, 不可以保存三维数组
```
a= np.arange(20).reshape(4,5)

# np.savetxt(frame,array,fmt='%.18e",delimiter=None)
np.savetxt('demo.csv',a,fmt='%d',delimiter=',')
```

#### loadtxt
```
np.loadtxt(frame,dtype=np.float,delimiter=None,inpack=False)
np.loadtxt("demo.csv",delimiter=",")
```

1. frame:指定读入的文件来源
2. dtype:数据类型，默认为np.float。
3. delimiter:分割字符串
3. unpack：默认为False读入文件写入一个数组，如果为True，读入属性将分别写入不同变量

### fromtofile
csv 最多支持二维，使用tofile/fromfile 可以支持多维数据的存储(不常用，要自己记住数据结构)

tofile
```
a.tofile(frame,sep='',format='%d')

a = np.arange(100).reshape(5,10,2)
a.tofile("a.dat",sep=',',format='%d') # 不指定sep 则保存为二进制文件
```

既然tofile可以保存文本文件，那么也很容易猜到对应的fromfile可以还原这些信息。

```
np.fromfile(frame,dtype=float,count=-1,sep='')
    frame：文件
    dtype：读取元素使用的数据类型，默认为float
    count：读文件的个数，默认-1，读取全部
    sep:数据分割字符串，如果是空串，写入文件为二进制。

c = np.fromfile("b.dat",sep=',',dtype=np.int).reshape(5,10,2)
```
### 保存 / 读取高维度数据(save-savez/load-loadz)
```
np.save(frame,array)或np.savez(fname,array)(压缩)
+ frame：文件名，以.npy为扩展名，压缩扩展名为.npz
+ array：数组变量
np.load(fname)
```
Demo:
```
a = np.arange(100).reshape(5,10,2)
np.save("a.npy",a)
b=np.load("a.npy")
```

### range float(linspace)
得到 *numpy.ndarray* :

    from pylab import *
    list(np.linspace(start, end, amount, endpoint=True))
    list(np.linspace(1, 3, 3,))
        [1.0, 2.0, 3.0]
    list(np.linspace(1, 3, 3, endpoint=False))
        [1.0, 1.66, 2.33]

# geometry

## sin
np.sin support: number, array, numpy.ndarray

    np.sin(np.pi)
    np.sin([1,2])

    X = np.linspace(-np.pi, np.pi, 256,endpoint=True)
    C,S = np.cos(X), np.sin(X)

