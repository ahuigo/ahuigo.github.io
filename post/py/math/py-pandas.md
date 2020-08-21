---
title: py-math-np
date: 2018-10-04
private:
---
# pandas 简介
pandas 基于numpy,mpilot 等，比较适合做矩阵运算
pandas教程：
1. 10min pandds: http://pandas.pydata.org/pandas-docs/stable/10min.html
2. joinquant pandas: https://www.joinquant.com/research?target=research&url=/user/281387418609/notebooks/%E6%96%B0%E6%89%8B%E6%95%99%E7%A8%8B%E2%80%94Pandas%E5%BA%93%E4%BD%BF%E7%94%A8%E7%A4%BA%E4%BE%8B.ipynb

## pandas 输出显示(display)
默认pandas根据屏大小输出部分数据，如果想输出完整数据：

    pd.set_option('display.max_columns', None)  # or 1000
    pd.set_option('display.max_rows', None)  # or 1000
    pd.set_option('display.max_colwidth', -1)  # or 199
    pd.options.display.width = None

    with pd.option_context('display.max_rows', None, 'display.max_columns', None):
        print(df)

# series
在讲DataFrame(实例一般写作df) 之前，先讲series. 
1. series 组成df，比如：df.col1
2. series 是一个线性映射表。不同是Dict 结构，它的key 中重复

## define/export
### dict to series

    pd.Series({'a':1,'b':2})
    pd.Series(d.values, list(dict.keys()))

### list to series
使用range 自动生成index 

    pd.Series([1,2,3])

指定index

    >>> s3 = pd.Series([4, 5, 6], index=[3,4,5])

### export: to_dict(), to_json, tolist():

    >>> s = pd.Series([1, 2, 3, 4])
    >>> s.to_dict()
    >>> s.to_dict(OrderedDict)      #不打乱顺序
    >>> s.to_dict(defaultdict(list))

    s.tolist()
    s.to_json()

to_csv to_pg:

    output = io.StringIO()
    df.to_csv(output, sep='\t', header=False, index=False)
    output.seek(0)

    cur = conn.cursor()
    cur.copy_from(output, 'table_name', null="", columns=df.keys()) # null values become ''
    conn.commit()

## Calc Series 运算
### math 四则运算

    new_series = df['col1']/2
    df.col1*2
    df.col1-df.col2

### 逻辑运算:and,or,not,xor

    df.col1&df.col2
    df.col1|df.col2
    ~df.col1
    df.col1^255

### 聚合运算 sum/mean
    s.sum()
    s.mean()

df 的聚合是以column 为group 的

    >> df.mean()
    0    4.5
    1    2.0

### 比较运算
    > df.col1>df.col2
    > df.col1>1
    index1    False
    index2    False
    dtype: bool

## Read Series 读取
### index/keys()
对于series 来说，index与keys() 是一样的

    s.index === s.keys()

### Read values

    'value' in s.values
    'value' in s.unique()
    'value' in set(s)

s.values 与to_list() 不一样，后者是纯list

#### loop Values

    for value in s.values:
        pass
    for k,value in s.iteritems():
        pass

### get value
#### via key

    s = pd.Series({'k1':1,'index':2,1:3})
    s.k1
    s.index     #读取的是keys(), index 是关键字
    s['index']  #2 

filter via keys

    s[['k1','k2']]

#### via iloc,loc
via index

    s.iloc[0]
    s.iloc[0:2]

via key

    s.loc['index1']
    s.loc[['index1','index2']

## Modify Series
### add element
    s['new_key'] = 1 # not work
    s.new_key = 1   # not work

### drop
    s1=pd.Series(['a1',33],index=['a','b'])
    s1.drop('a')

### update
s是df 的映射，df 随着s 的修改而修改

    >>> s = pd.Series([1, 2], index=[0,1])

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

### append series
append is immutable

    >>> s1 = pd.Series([1, 2, 3])
    >>> s2 = pd.Series([4, 5, 6])
    >>> s3 = pd.Series([4, 5, 6], index=[3,4,5])

keep all index

    >>> s1.append(s2)
    0    1
    1    2
    2    3
    0    4
    1    5
    2    6
    dtype: int64

reset index

    >>> s1.append(s2, ignore_index=True) # reset index
    0    1
    1    2
    2    3
    3    4
    4    5
    5    6
    dtype: int64

overide index: 

    s3 = pd.Series(s1.append(s2).to_dict())

### concat series
append

    s1 = pd.concat([s1, s4])

merge series to dataFrame(add column)

    df1 = pd.concat([s1, s4], axis=1)
    # 下面两个等价
    df = pd.concat([df1, df1], axis=1)
    df = pd.concat([s1,s4,s1,s4], axis=1)

例子:

    In [1]: s1 = pd.Series([1, 2], index=['A', 'B'], name='s1')
    In [2]: s2 = pd.Series([3, 4,5], index=['A', 'B','C'], name='s2')

    In [3]: pd.concat([s1, s2], axis=1)
    Out[3]:
        s1  s2
    A   1   3
    B   2   4
    C   NaN 5

    In [4]: pd.concat([s1, s2], axis=1).reset_index()
    Out[4]:
        index  s1  s2
    0     A   1   3
    1     B   2   4
    2     C   NaN 5

## isnull()/isna()
null 与 NaN 是一个意思

    np.isnan(v)
    np.isnull(np.NaN)
    pd.isna(v)
    pd.isnull(np.NaN)

series/df 也支持

    series.isnull()
    df.isnull()

# DataFrame
df 是pands 最重要的概念，类似于二维关系表

## 定义(import/export)
### Define df
via col: dict/series

    df=pd.DataFrame({'col1':{'index1':1,'index2':2}, 'col2':{'index1':2, 'index2':4}})
    pd.concat([s1,s2,s3],axis=1)

via row: record/series

    pd.DataFrame([{'col1':1},{'col2':2}], index=['index1','index2'])
    pd.DataFrame([s1,s2], index=['index1','index2'])  

via numpy narray

    pd.DataFrame(numpy.random.randint(100, size=(1,2)))
    pd.DataFrame(numpy.random.randint(100, size=(1,2)), columns=['c1', 'c2'],index=['A'])

### import file
import csv

    dataFrame = pandas.read_csv("./marks.csv", sep=",")
    dataFrame = pandas.read_table("./marks.csv", sep=",")

import xlsx

    xls = pd.ExcelFile("./marks.xlsx")
    >>> xls.sheet_names
    ['Sheet1', 'Sheet2', 'Sheet3']
    >>> sheet1 = xls.parse("Sheet1")

import json:

    pd.read_json(_, orient='split') #to_json(orient='split')
    pd.read_json(_, orient='index')  #to_json(orient='index')
    pd.read_json(_, orient='records') #to_json(orient='record')

export xlsx

    df.to_excel('foo.xlsx', sheet_name='Sheet1')

### export format(dict/json)
    # 按列
    df.to_dict()
        pd.DataFrame.from_dict(data)
    df.to_json()
        pd.read_json(json)
    # 按行
    df.to_dict('record') 

example: 

    >> data = {'col_1': [3, 2, 1, 0], 'col_2': ['a', 'b', 'c', 'd']}
    >> pd.DataFrame.from_dict(data)
        col_1 col_2
    0      3     a
    1      2     b
    2      1     c
    3      0     d

## Read df 读取
### Read length

    len(df) == df.shape[0] # row length
    df.shape[1]     # col length

### Read index/column
    df.index        //row name list
    df.keys()       //col name list
    df.columns      //col name list

### exist index/column
    'g' in df.index

### Read values
    df.values       //column values list(二维数组)
    series.values   //一维数组

#### get row/column
get row(series)

    # row index
    row = df.iloc[0]
    # row key
    row = df.loc['row-key']

get column(series)

    # column index
    col = df.iloc[:,0] # first column

    # column key
    col = df.loc[:,'col1'] # first column
    col = df['col1']

#### filter row/column
filter row: via index/key

    # via row index
    df[0:3]
    df.iloc[0:3]

    # via row key
    df['row0':'row3']
    df.loc['row0':'row3']
    # 包括了3
    df.loc['0':'3']

filter column: axis=1

    # via column index
    df0 = df[[0:2]] // wrong, python 无语法支持
    df1 = df.iloc[:,0:2]

    # via column key
    df0 = df[['col1','col2']]
    df.loc[:,['col1','col2']]

##### filter func
filter row:

    # via column_value
    df.loc[df['column_name'] == some_value]
    df[df.col1>1]
    df[df.col1>df.col2]

    # axis=1 取column 项
    df[df.apply(lambda x: 'ST' in x['col1'], axis=1)]

filter column

    df.loc[:,df.apply(lambda x:x['index1'] < 2)]

#### filter df
不是真的过滤，未被过滤的值，被设置NaN

    >> df[df<5]  
        col1   col2  col3
    A -10000 -10000   NaN
    B -10000 -10000   NaN

全部为正

    >> df[df<0] = -df

## Calc df
### 普通运算
    df<df2
    df<5
    df*2
    df*df
    df*df2

    -df*2
    ~df

#### add series
add as row(数值相加)

    df0 = pd.DataFrame([{'col1':0,'col2':0}],index=['A']) 
    >> df0.add(pd.Series([1,2],index=['A','B']), axis=0)
       col1  col2
    A   1.0   1.0
    B   NaN   NaN

add as column

    >> df0.add(pd.Series([1,2],index=['col1','col2']), axis=1)
        col1  col2
    A     1     2

### T 转置
    df.T

### 聚合运算apply
f.apply 是一个row/column 的聚合函数

    >>> df.apply(lambda x:x['index1'] >=2)
    col1    False
    col2     Truek
    >>> df.apply(lambda x:x['col1'] >=2, axis=1)

### 聚合运算rolling_apply

    # 计算close收盘价的5日均线和20日均线
    data['MA_' + str(5)] = pd.rolling_apply(data['close'], 5,np.mean)
    data['MA_' + str(20)] = pd.rolling_apply(data['close'], 20,np.mean)

计算季度利润:



### 比较df

    In [438]: df>df2
    In [438]: df>5 
    Out[438]: 
            col1  col2
    index1  True  True
    index2  True  True

### grupby

    df.groupby('col').sum()
    df.groupby('col').head(3)
    df.groupby(['A','B']).sum()

默认是以column 分组

    df.sum()

例子：

    > df=pd.DataFrame([{'col1':1,'col2':2,'col3':3,},{'col1':1,'col2':4,'col3':5}],index=['A','B'])
    col1  col2  col3
    A     1     2     3
    B     1     4     5
    >df.sum()
    col1    2
    col2    6
    col3    8

    > df.groupby('col1').sum()
          col2  col3
    col1            
    1        6     8

    > df.groupby('col1').head(3)

### sort df
    df.sort_values(by=['col1', 'col2'], ascending=False)
    df.sort_values(['job','count'],ascending=False).groupby('job').head(3)

按索引排序

    # axis=0 跨行（down），axis=1跨列(across)　axis=0是默认值
    df.sort_index(axis=1, ascending=False)

按索引排序例子

    >>> df = pd.DataFrame([[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3]], \
    ... columns=["col1", "col2", "col3", "col4"])
    >>> df
    col1  col2  col3  col4
    0     1     1     1     1
    1     2     2     2     2
    2     3     3     3     3
    >>> df.mean(axis=1)
    0    1.0
    1    2.0
    2    3.0
    >>> df.mean(axis=0)
    col1    2.0
    col2    2.0
    col3    2.0
    col4    2.0

### shift
从头部移入一行空行

    >>> df
    col1  col2  col3  col4
    0     1     1     1     1
    1     2     2     2     2
    2     3     3     3     3
    >>> df.shift(1)
        0    1    2    3
    0  NaN  NaN  NaN  NaN
    1  1.0  1.0  1.0  1.0
    2  2.0  2.0  2.0  2.0

series.shift: 

    >>> df[0]
    0    1
    1    2
    2    3
    Name: 0, dtype: int64
    >>> df[0].shift(1)
    0    NaN
    1    1.0
    2    2.0

计算价格增长百分比

    >>> df/df.shift(1)-1    # 计算价格增长百分比
    col1  col2  col3  col4
    0   NaN   NaN   NaN   NaN
    1   1.0   1.0   1.0   1.0
    2   0.5   0.5   0.5   0.5

    >>> df.pct_change()     # 计算价格增长百分比
    col1  col2  col3  col4
    0   NaN   NaN   NaN   NaN
    1   1.0   1.0   1.0   1.0
    2   0.5   0.5   0.5   0.5


如果想计算按列之环比：

    df.pct_change(axis='columns')

### update value
#### update column
    df.col = series
    df.col = df.index
    df.col = range(5)
    df['col2'] = round(df['col2']/3600,2)
    df.col = 5
    df.loc[:,['col1','col2']]=10000 

#### update row
    df['row'] = 5
    df['row'] = df['row']*2

#### update filter
大于5 取反

    df2[df2 > 5] = -df2

#### update single value
要用

    df.loc[index,col] = v  # work

不能用下面的方法修改修值，series 是on a copy of a slice from a DataFrame, 而不是引用

    df.col.A=1             # not work?
    df.loc[index].col = v  # not work? 

#### replace NaN/None,inf
repalce NaN/None to 0/'':

    df.fillna(0, inplace=True)
    df.fillna('', inplace=True)

分组替换：

    values = {'column1': 0, 'columa': 1}
    df.fillna(value=values)

also with array:

    //np.nan 会替换None/NaN
    newdf = df.replace([np.inf, np.NINF,np.nan], 0)

check is nan

    math.isnan(x)

### isEmpty

    >>> df_empty = pd.DataFrame({'A' : []})
    >>> df_empty.empty
    True

## Raname column/index
### change column type
    df['A']= df['A'].apply(lambda x: float(x))

### change column order
    > cols = df.columns.tolist()
    > cols = cols[-1:] + cols[:-1]
    > df = df[cols] 

用set 类型也是可以过滤column

    cols = set(df.columns) - blank_column_list
    df[cols]

### rename column name
immutable rename column

    df=df.rename(columns={ "date": "时间"})

### rename index name
    df=df.rename(index={"sum":'合计'})
    series.rename(index={'b':'b1'})

#### set_index
set_index: move colume to index

    # immutable
    df.set_index('name')

    # inplace
    df.set_index('name', inplace=True)

e.g.

    In [84]: d.set_index('b')
    Out[84]:
       a  c
    b
    2  2  3
    3  3  2

#### assign index
df.index: copy colume to index

    In [88]: d.index=df['b']
    Out[89]:
       a  b  c
    b
    2  2  2  3
    3  3  3  2

#### reset index
revert index to column

    df.reset_index(inplace=True)
    // 上面的等价于下面
    df['index'] = df.index
    df.index=range(len(df.index))
    df.index=range(len(df))

或者通过insert:

    df.insert(0, 'ann_date', df.index)
    df.index = range(len(df))

如果不想再插入index

    df.reset_index(inplace=True, drop=True)

### move column to first
    col = df.pop("ann_date")
    df.insert(0, col.name, col)

## df 添加数据
### concat series/df as df
concat column:

    pd.concat([s1,s2],axis=1)
    pd.concat([df1,df2],axis=1)

concat row:

    pd.concat([s1,s2]) //结果只是 series
    pd.concat([df1,df2])

### merge df column
init:

    >>> df1=pd.DataFrame([{'a':1,'b':1}, {'a':2,'b':2}])
    Out[3]:
       a  b
    0  1  1
    1  2  2
    >>> df2=pd.DataFrame([{'a':2,'c':32}, {'a':1,'c':31}])
    Out[4]:
       a   c
    0  2  32
    1  1  31

基于on 的merge (通过`how`控制(`how:{‘left’, ‘right’, ‘outer’, ‘inner’}, default ‘inner’`), 重复的column 会自动加col_x, col_y)

    In [23]: pd.merge(df1, df2, how='left', left_on=['a'], right_on=['a'])
    In [23]: pd.merge(df1, df2, left_on=['a'], right_on=['a'])
    In [23]: pd.merge(df1, df2, on='a')
    Out[23]:
       a  b   c
    0  1  1  31
    1  2  2  32

基于index 的merge

    In [31]: pd.merge(df1, df2.set_index('a'),  right_index=True, left_on=['a'])
    Out[31]:
       a  b   c
    0  1  1  31
    1  2  2  32


合并on原基准是多列：

    left_on=['col1','col2']
    right_on=['col1','col2']

### append df column
还可以df1.join　将df2的列，合并到df1

    In [31]: df1.join(df2)

### append df row
    >>> df1.append(df2)
       a    b     c
    0  1  1.0   NaN
    1  2  2.0   NaN
    0  2  NaN  32.0
    1  1  NaN  31.0

### add series
#### add column
list,series,dict as column

    df['new_col'] = range(2)    # 默认以df.index 为顺序添加
    df['new_col'] = pd.Series([3,1],index=['B','A']) # 指定index
    df['k'] = {0:1,1:2}     # 等价于 df['k']=dict.keys()

#### add row
list,series,dict as row

    df.loc['k'] = [33,44]
    df.loc['k'] = pd.Series([33,44], index=['col1','col2'])
    df.loc['k']={'a':1,'c':2}

还有吗？当然

    df0 = pd.DataFrame([series],index=['index1'])
    df.append(df0)

如果想重排ranged index:

    df.append(series, ignore_index=True)
    df.append(series_list, ignore_index=True)
    df.append({'col1':1}, ignore_index=True)


## Drop
### Drop columns
immutable(非原地修改)

    # 等价 axis 必须是1(代表跨列across)
    >>> df.drop(['B', 'C'], axis=1)
        A   D
    0  0   3
    1  4   7
    2  8  11
    >>> df.drop(columns=['B', 'C'])
        A   D
    0  0   3
    1  4   7
    2  8  11

原地修改

    del df['open']          # 原地修改
    df.drop('open',axis=1)  # 非原地修改

drop duplicate columns: 通过filter expr 办到

    df = df.loc[:,~df.columns.duplicated()]

### Drop row 
Drop a row by index.(不存在的index会报错)

    >>> df.drop(['index1','index2'])

### dropna
剔除所有包含缺失值的行数据

    df2.dropna(how='any')
    # 填充缺失值
    df2.fillna(value=154)


## for loop
todo 怎样在循环体中修改值最好呢？
1. 用iloc/loc

### loop column
    for colname, col in df.items():
        col['index1']
        col.index1 += 1; # 警告+性能问题
        df.loc[index1,colname] =1; # work

for col_name key only

    for column_name in df:
        pass

### loop rows

    for index, row in df.iterrows():
        row['col'] = v         # not work, 是copy 不是引用
        df.loc[index,'col'] = v  # work
    for i in range(len(df)):
        row = df.iloc[i]:
        row['col']=v #work

## Index Type
### BaseIndex

    >>> pd.DataFrame({'col1':{'index1':1,'k2':2}}).index
    Index(['index1', 'k2'], dtype='object')

### RangeIndex
    >>> pd.DataFrame([{'k1':1},{'k2':2}]).index
    RangeIndex(start=0, stop=2, step=1)

### DatetimeIndex

    >> pd.date_range('20130101', periods=6)
    DatetimeIndex()

# df/series 通用
## copy 

    df.copy() series.copy()

# Var type
## DateTime
将str 转 time:

    >>> df['date_time'] = pd.to_datetime(df['date_time'])

指定format 更快：

    return pd.to_datetime(df[column_name],format='%d/%m/%y %H:%M')

利用index isin 切片

    df=pd.DataFrame({'datetime':[datetime.now(),datetime.strptime('20101010 18','%Y%m%d %H')], 'b':[3,4]})
    df.set_index('date_time', inplace=True)

    # 计算`[17-24)`时段的电费
    peak_hours = df.index.hour.isin(range(17, 24))
    df.loc[peak_hours, 'cost_cents'] = df.loc[peak_hours, 'energy_kwh'] * 28

pd.cut()根据分组bins产生的区间生成对应的标签“费率”(include_lowest参数设定第一个间隔是否包含在组bins中)

    cents_per_kwh = pd.cut(x=df.index.hour,
                           bins=[0, 7, 17, 24],
                           include_lowest=True,
                           labels=[12, 20, 28]).astype(int)
    df['cost_cents'] = cents_per_kwh * df['energy_kwh']



# pandas 优化
参考
1. pandas 优化: https://mp.weixin.qq.com/s?__biz=MzAwOTgzMDk5Ng==&mid=2650834821&idx=1&sn=61c2e85ebbe47f901661a8fa1a6d823f&

## HDFstore
Pandas的HDFstore方法可以将DataFrame存储在HDF5文件中，可以有效读写，同时仍然保留DataFrame各列的数据类型和其他元数据。不会像读取csv 那样经过漫长的格式转换

    $ pip install --upgrade tables

创建存储类文件并命名 `processed_data`

    data_store = pd.HDFStore('processed_data.h5')

    #将DataFrame写入存储文件中，并设置键（key） 'preprocessed_df'
    data_store['preprocessed_df'] = df
    data_store.close()

HDF5文件中访问数据的方法:

    data_store = pd.HDFStore('processed_data.h5')

    # 读取键（key）为'preprocessed_df'的DataFrame
    df = data_store['preprocessed_df']
    data_store.close()