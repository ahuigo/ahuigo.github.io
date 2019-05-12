---
title: py-math-np
date: 2018-10-04
private:
---
# Preface
numpy是SciPy、Pandas等数据处理或科学计算库最基本的函数功能库。

1. 一个强大的N维数组对象ndarray
2. 广功能函数
3. 整合C/C++/Fortran代码的工具
4. 提供了线性代数、傅里叶变换、随机数生成的相关功能

Refer to : segmentfault.com/a/1190000011372128

## install
pip3 install numpy

# pandas
http://pandas.pydata.org/pandas-docs/stable/10min.html

## print
    pd.set_option('display.max_columns', None)  # or 1000
    pd.set_option('display.max_rows', None)  # or 1000
    pd.set_option('display.max_colwidth', -1)  # or 199

    with pd.option_context('display.max_rows', None, 'display.max_columns', None):
        print(df)

## DataFrame

    df=pd.DataFrame({'col1':{'index1':1,'k2':2}, 'b':{'index1':2, 'k2':4}})
    df=pd.DataFrame([dict1,dict2])
    df.index
    df.columns
    df['col1']['index1']
    df.iloc[0] # first row

    df[df.col1>1]
    df[df.col1>1].iloc[0] #first row

    df.loc[:,['col1','col2']]
    df.loc[:,'col1']

### rename column

    df=df.rename(index=str, columns={ "date": "时间"})

### index empty

    Notice the index is empty:
    >>> df_empty = pd.DataFrame({'A' : []})
    Empty DataFrame
    Columns: [A]
    Index: []
    >>> df_empty.empty
    True

### setIndex
let colume as index

    df.set_index('name', inplace=True)
    In [84]: d.set_index('b')
    Out[84]:
       a  c
    b
    2  2  3
    3  3  2
    In [88]: d.index=df['b']
    Out[89]:
       a  b  c
    b
    2  2  2  3
    3  3  3  2

revert index to column

    df['column1'] = df.index
    df.reset_index(level=0, inplace=True)

in index and colume and values

    'index_name' in df.index
    'col_name' in df
    'col_value' in df.values

### set all column value
    df['时间'] = self.yesterday

### filter
#### select column field:

    df0 = df[['col1','col2']]
    df1 = df.iloc[:,0:2]
    df.iloc[3][['dt_netprofit_yoy','profit_dedt']]

sigle column

    s1 = df['col1']
    s1 = df.col1
    s1.iloc[0]
    value = s1.iloc[0]
    value = s1.col1

#### select row: via column value / row_index

    # via column_value
    df.loc[df['column_name'] == some_value]

    # via lambda
    df[df.apply(lambda x: x['col1'] > x['col2'], axis=1)]

    # via index name
    df.loc['row_index'] # row_index

#### select row and column

    # via index
    df.iloc[0] # first row
    df[0:2]
    df.iloc[0:2, 1:5]

### dict/series to dataFrame

    rows_list = [series1,...]
    rows_list = [dict1,...]
    df = pd.DataFrame(rows_list)  

    pd.DataFrame({'email':sf.index, 'list':sf.values})

### sort df
    df = df.sort_values(by=['col1', 'col2'], ascending=False)
    df.sort_values(['job','count'],ascending=False).groupby('job').head(3)

### merge
Consider this behavior with a MultiIndex:

    mi = pd.MultiIndex.from_tuples([(1,10),(2,20),(3,30),(4,40)], names=['a','b'])
    df1 = pd.DataFrame({'c': [100,200,300,400]}, index=mi)
    df2 = pd.DataFrame({'a' : [1,3], 'b' : [10, 30], 'e' : [1000, 3000]})
    print("df1\n", df1)
    print("df2\n", df2)
    print("merge\n", pd.merge(df1, df2, how='left', left_index=True, right_on=['a','b']))

This yields:

    df1
            c
    a b      
    1 10  100
    2 20  200
    3 30  300
    4 40  400
    df2
        a   b     e
    0  1  10  1000
    1  3  30  3000
    merge
        c    a     b       e
    0  100  1.0  10.0  1000.0
    1  200  2.0  20.0     NaN
    1  300  3.0  30.0  3000.0
    1  400  4.0  40.0     NaN

### concat merge
with same index

    In [48]: pd.concat([df,df2],axis=1)
    Out[48]:
        a  b  a  c
        2  2  2  3
        3  3  3  2

    # drop duplicate columns
    df = df.loc[:,~df.columns.duplicated()]


append df

    pandas.concat([df1, df2])
    df1.append(df2)
    s1.append(s2)

### add row series
apped dict(必须忽略加入的index)

    df1 = pandas.DataFrame(numpy.random.randint(100, size=(5,5)), columns=['A', 'B', 'C', 'D', 'E'])
    df1 = df1.append( dict( (a,numpy.random.randint(100)) for a in ['A','B','C','D','E']), ignore_index=True)
    df.append(series,ignore_index=True)

update row via loc:

    >>> import pandas as pd
    >>> import numpy as np
    >>> df = pd.DataFrame(columns=['lib', 'qty1', 'qty2'])
    >>> for i in range(5):
    >>>     df.loc[i] = [np.random.randint(-1,1) for n in range(3)]
    >>>
    >>> print(df)
        lib  qty1  qty2
    0    0     0    -1
    1   -1    -1     1
    2    1    -1     1
    3    0     0     0
    4    1    -1    -1
    

### add col series
    DataFrame.add(s, axis=1)
    DataFrame['col1']= s

### to_dict:
    print(df.set_index('device_id').T.to_dict())

    df.to_dict()
    df.to_dict('record') # 按行
    df.to_json()
    series.to_dict()
    series.to_json()

    # series alone
    series.tolist()

### len

    len(df) == df.shape[0] # row number
    df.shape[1]     # col number

### T 转置
    df.T

### apply
    In [48]: df
    Out[48]:
    a  b  c
    d  1  2  3
    e  4  5  6

    In [49]: df.apply(lambda x:0, axis=0)
    Out[49]:
    a    0
    b    0
    c    0
    dtype: int64

    In [50]: df.apply(lambda x:1, axis=1)
    Out[50]:
    d    1
    e    1

### for loop
    for colname, series in df.items():
        print col['index1']
    for index, row in df.iterrows():
        row['col'] = v              # not work, iterrows are copies
        df.loc[index,'col'] = v     # work, 但是会扩展col
        df['col'][index] = v     # work
        print row['c1'], row['c2']

## series
Notice: pd.Series(d).name 是一个保留keyword, 请使用pd.Series(d)['name']

    s = pd.Series([1, 2, 3])
    s = pd.Series({'col1':1})
    s[['col1','col2']]
    s.col1
    s['col1']

### in series

    'value' in s.values
    'value' in s.unique()
    'value' in set(s)

in dataFrame

    '07311954' in df.date.values
    '07311954' in df['date'].values
    'index' in df.index

### concat series 2 series
    >>> s1 = pd.Series([1, 2, 3])
    >>> s2 = pd.Series([4, 5, 6])
    >>> s3 = pd.Series([4, 5, 6], index=[3,4,5])
    >>> s1.append(s2)
    0    1
    1    2
    2    3
    0    4
    1    5
    2    6
    dtype: int64
    >>> s1.append(s2, ignore_index=True) # reset index
    0    1
    1    2
    2    3
    3    4
    4    5
    5    6
    dtype: int64

keep index:

    s3 = pd.Series(s1.append(s2).to_dict())

### concat to dataFrame:

    s1 = pd.concat([s1, s4])
    df = pd.concat([s1, s4], axis=1)
    df = pd.concat([df1, df4], axis=1)

    In [1]: s1 = pd.Series([1, 2], index=['A', 'B'], name='s1')
    In [2]: s2 = pd.Series([3, 4], index=['A', 'B'], name='s2')

    In [3]: pd.concat([s1, s2], axis=1)
    Out[3]:
    s1  s2
    A   1   3
    B   2   4

    In [4]: pd.concat([s1, s2], axis=1).reset_index()
    Out[4]:
    index  s1  s2
    0     A   1   3
    1     B   2   4

### update
s是df 的映射，df 随着s 的修改而修改

    >>> s = pd.Series([1, 2], index=[0,1]

update via key

    # ok
    s['key'] = 'value'

update via series

    # will not update index=2(not exists)
    >>> s.update(pd.Series([4, 5, 6], index=[0,1,2])) 

update via dict

    >>> s.update(pd.Series({'key':'value'}))
    # error
    >>> s.update(({'key':'value'}))


### to_dict(), to_json, tolist():

    >>> s = pd.Series([1, 2, 3, 4])
    >>> s.to_dict()
    >>> s.to_dict(OrderedDict)
    >>> s.to_dict(defaultdict(list))
    s.tolist()
    json.loads(s.to_json())

### dict to series

    pd.Series({'a':1,'b':2})
    pd.Series(d.values, list(dict.keys()))

## datetime

    dates = pd.date_range('20130101', periods=6)

各种文件

    dataFrame = pandas.read_csv("./marks.csv", sep=",")
    dataFrame = pandas.read_table("./marks.csv", sep=",")

    xls = pd.ExcelFile("./marks.xlsx")
    >>> xls.sheet_names
    ['Sheet1', 'Sheet2', 'Sheet3']
    >>> sheet1 = xls.parse("Sheet1")
    df.to_excel('foo.xlsx', sheet_name='Sheet1')

## copy 

    df.copy() series.copy()

# np 数据类型

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

### 随机序列

    # 等差数列
    np.arange(start,stop,step)
        np.arange(stop) [0, stop)

    # 均匀分布整数或序列
    np.random.randint(from,stop, n)
        np.random.randint(0,10,3) # [27 40 29]
        np.random.randint(10) # [0,10)

    # 均匀颁小数或序列
    np.random.uniform()  # range [0,1)
    np.random.uniform(1.2)  # range [1, 1.2)
    np.random.uniform(0.5,1.0,12) 
        12个均匀分布数，0.5到1之间：

    # 正态分布或序列
    np.random.normal(loc=0.0, scale=1.0, size=None)

    # 从指定可迭代的数组中生成随机数
    np.random.choice([10,20,40,33], length=1)
            20

    # 生成4个beta分布
    np.random.beta(1,10,4)
        [ 0.02258548  0.25848896  0.00696899  0.0609543 ]

### 多维随机数
2. numpy.random.rand(d1,d2...) from uniform (in range [0,1)).
1. numpy.random.randn(d1,d2...) generates samples from the normal distribution, 
3. np.zeros
3. np.ones
4. np.arange(24).reshape(2,3,4) 一维变多维

    numpy.random.rand()
        Out[46]: 0.6642199932630231
    print(np.random.randn(2，2)) 2x2, (2,2,3,4) 2x2x3x4维
        [ 0.03082697,  1.27510255],
        [ 0.19114142,  0.61126788]
    >>>print(np.zeros([2,4])#初始化一个2行4列的数组
    >>>print(np.ones([2,4])
    [[ 0.  0.  0.  0.]
    [ 0.  0.  0.  0.]]
    [[ 1.  1.  1.  1.]
    [ 1.  1.  1.  1.]]

# matrix

## 矩阵化reshape
一维数组矩阵化：

    >>> np.arange(10)
    >>> np.arange(1,11,2) #得到step为2的range序列
    [1 3 5 7 9]

    >>> np.arange(10).reshape(2,5)
    array([[0, 1, 2, 3, 4],
        [5, 6, 7, 8, 9]])

遍历matrix: ndenumerate

    [(x,y,w) for (x,y),w in np.ndenumerate([[.1,.2], [.3,.4]])]
        [(0, 0, 0.10000000000000001),
        (0, 1, 0.20000000000000001),
        (1, 0, 0.29999999999999999),
        (1, 1, 0.40000000000000002)]

## 多维数组运算
下面介绍一些常用的运算操作：

```
lst=np.arange(1,11).reshape(2,5) # 2x5 二维
print(np.exp(lst)) #自然指数操作
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

    In [2]: list1 = np.array([10,20,30,40])
    In [3]: list2 = np.array([4,3,2,1])
    In [5]: print(list1+list2)
    [14 23 32 41]

但np最强大的地方不在于简单的一维运算，Np对矩阵也能进行基本的运算操作：

    lst1 =np.array([10,20,30,40])
    lst2 = np.array([4,3,2,1])
    print(np.dot(lst1.reshape([2,2]),lst2.reshape([2,2])))
        [[ 80  50]
        [200 130]]

此外，由于原生list没有确定的数据类型，所以维护起来成本较高，而使用C编写的numpy，则可以声明各种常见的数据类型：

    lst = [[1,3,5],[2,4,6]]
    np_lst = np.array(lst,dtype=np.float)

np所支持的数据类型都有bool、int8/16/32/64/128/、uint8/16/32/64/128、float16/32/43、complex64/128、string。

## csvtxt
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

## geometry

### sin
np.sin support: number, array, numpy.ndarray

    np.sin(np.pi)
    np.sin([1,2])

    X = np.linspace(-np.pi, np.pi, 256,endpoint=True)
    C,S = np.cos(X), np.sin(X)