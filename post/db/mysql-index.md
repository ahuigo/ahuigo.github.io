---
layout: page
title:	mysql 索引
category: blog
description:
---
# Preface

# todo
- [索引原理-meituan]

# clustered index
聚合索引(clustered index) / 非聚合索引(nonclustered index)

> *Clustered Index* 就是数据内容本身是stored in order, 因为是有序的，所以范围查询(id>100, group by, etc.)、倒序查询都非常的高效

# Data Index Type
> http://stackoverflow.com/questions/12813363/what-is-the-difference-between-a-candidate-key-and-a-primary-key

1. Primary Key:
	对数据对象唯一标识和完整标识的列. Primary Key 属于Candidate Key.  Each Candidate Key can qualify as Primary Key. Only one CK can be PK
2. Candidate Key:
	某关系变量的一组属性的集合，且同时满足：1.属性集合能确保在关系中能唯一标识元组，2. 在这个属性集合中找不出合适的子集满足条件
3. SuperKey:
	某关系变量的一组属性的集合，且同时满足：属性集合能确保在关系中能唯一标识元组. 所以候选键Candidate Key是最小超键SuperKey。

在数据库中，超键(SuperKey) 包含候选键(Candidate Key), 候选键包含主键(Primary Key)

外键Foreign Key: 连接两表之间的关系属性或者属性集合，通常是主键属性。
	在关系数据库中，关系用来表示表间关系：父数据表(Parent Entity)的Primary Key 会放在另一张表中, 两表通过PK 建立关系，这个PK 属性就是外键。

代理键和自然键: 如果数据表中的所有候选键都不适合做主键(数据太长，意义层面太多), 就会请一个无意义的键做主键（比如自增的id）, 这就是代理键。有意义的主键就是自然键。

## Foreign Key
用户量大，并发度高: 不要用外键，mysql IO消耗大


	[CONSTRAINT symbol] FOREIGN KEY [id] (从表的字段1)

	REFERENCES tbl_name (主表的字段2)

	[ON DELETE {RESTRICT | CASCADE | SET NULL | NO ACTION}] # 默认RESTRICT

	[ON UPDATE {RESTRICT | CASCADE | SET NULL | NO ACTION} # 默认RESTRICT

Example: 当employee ... todo

	ALTER TABLE employee ADD FOREIGN KEY(dept_id) REFERENCES department(id);

## force index
> See http://dev.mysql.com/doc/refman/5.7/en/index-hints.html

	tbl_name [[AS] alias] [index_hint_list]

	index_hint_list:
		index_hint [, index_hint] ...

	index_hint:
		USE {INDEX|KEY}
		  [FOR {JOIN|ORDER BY|GROUP BY}] ([index_list])
	  | IGNORE {INDEX|KEY}
		  [FOR {JOIN|ORDER BY|GROUP BY}] (index_list)
	  | FORCE {INDEX|KEY}
		  [FOR {JOIN|ORDER BY|GROUP BY}] (index_list)

	index_list:
		index_name [, index_name] ...

Example:

	//key
	select * from table FORCE INDEX (indexname1, indexname2) where ...;
	//possible keys
	SELECT * FROM table1 USE INDEX (col1_index,col2_index)..
	SELECT * FROM table1 IGNORE INDEX (col3_index)

## INDEX/KEY
普通索引

	CREATE INDEX indexName ON table (column(7));//只索引column 的7个字符
	create index name ON user(name);
	//or
	INDEX(uid, name);
	INDEX indexName(uid, name);

使用多列做索引能加快多列的查询效率：

	INDEX indexName(A,B,C)
		where A;
		where A and B;
		where A and B and C;//多列索引基于最左前缀: leftmost prefixing(注意左索引：一定要匹配类型)

KEY is a synonym for INDEX.
`PRIMARY KEY` creates a primary key(for real unique?) and an index, `KEY`(column_list) creates an index only.

## PRIMARY KEY
*Primary Key(PK)*
	适用于：

- id: 只是保证唯一，和其它字段没有关系
- 单字段主键:如果某列已经有字段是唯一，则不需要用id
- 多字段主键:如果多个字段联合表示唯一性，也不需要用id

	id .. PRIMARY KEY auto_increment;//单字段主键
	PRIMARY KEY(column);//单字段主键
	PRIMARY KEY(column_list)//多字段主键

You should remove the autoincrement property before dropping the key:

	ALTER TABLE table_name MODIFY id INT NOT NULL;
	ALTER TABLE table_name DROP PRIMARY KEY;

## UNIQUE(UK)
Either UK or PK is a column or group of columns that can identify a uniqueness in a row.
PK is a special UK.

	email char(6) UNIQUE;
	UNIQUE(column_list); //The default  key_name is the first column in column_list
	UNIQUE key_name(column_list);

	drop index `key_name`;//drop index and unique has same syntax

By Default:

1. Null: PK is not null but UK allows nulls(Note: By Default), so UK may not be unique.
1. Unique: There can only be one and only one PK on a table but there can be multiple UK's
1. Clustered index: PK creates a `Clustered index` and UK creates a `Non Clustered Index`.
1. Candidate: UK may not be candidate key(Because it may be not unique)

*Clustered Index* 就是数据内容本身是stored in order, 因为是有序的，所以范围查询(id>100, group by, etc.)、倒序查询都非常的高效

## FULLTEXT
mysql 全文索引(即对局部字符串的查找的索引) 是按照空格分割的单词(默认单词长度小于4会补忽略)，所以它不支持中文,除非先对中文分词.

	FULLTEXT(column_list);//比较特殊的是：FULLTEXT 的索引column_list 不支持leftmost prefixing 最左前缀
	FULLTEXT index `indexName`(column_list)

只能使用

	select * from tb_name match(column_list) against('word');//可以是'word' 或者'word1 word2' 不能是局部'%substr%', 因为全文索引是基于单词的。

`Match()` 用于where 时，*相关性*按*返回的记录与搜索字符串匹配程度*来定义. 这些函数放到select 时会得到匹配记录的加权分：

	> select match(desc1,desc2) against('my book'),desc1,desc2 from ahui;
	+---------------------------------------+------------------+-------------------+
	| match(desc1,desc2) against('my book') | desc1            | desc2             |
	+---------------------------------------+------------------+-------------------+
	|                    1.6311430931091309 | This is my book! | This is her book! |
	|                                     0 | Nooo             | Hello!            |

### With Query Expansion
> In this tutorial, we have introduced you to MySQL query expansion to widen the search results when the keywords provided by users are short.
Refer to: http://www.mysqltutorial.org/using-mysql-query-expansion.aspx

Technically, MySQL full-text search engine performs the following steps when the query expansion is used:

1. First, MySQL full-text search engine looks for all rows that match the search query.
2. Second, it checks all rows in the search result and finds the relevant words.
3. Third, it performs a search again but based on the relevant words instead of the original keywords provided by the users.

To use query expansion, use `with query expansion` search modifier in the `against()` function:

	SELECT column1, column2 FROM table1 WHERE
		MATCH(column1,column2) AGAINST('keyword',WITH QUERY EXPANSION)

*Example*

table:

	ALTER TABLE products ADD FULLTEXT(productName)

Search for products whose product name contains `1992`:

	> SELECT productName FROM products WHERE MATCH(productName) AGAINST('1992')
	+-----------------------------------+
	| productName                       |
	+-----------------------------------+
	| 1992 Ferrari 360 Spider red       |
	| 1992 Porsche Cayenne Turbo Silver |
	+-----------------------------------+

We can widen the search result by using query expansion as the following statement:

	> SELECT productName FROM products WHERE MATCH(productName) AGAINST('1992' WITH QUERY EXPANSION)
	+-------------------------------------+
	| productName                         |
	+-------------------------------------+
	| 1992 Porsche Cayenne Turbo Silver   |
	| 1992 Ferrari 360 Spider red         |
	| 2001 Ferrari Enzo                   |
	| 1932 Alfa Romeo 8C2300 Spider Sport |
	| 1948 Porsche 356-A Roadster         |
	| 1948 Porsche Type 356 Roadster      |
	| 1956 Porsche 356A Coupe             |
	+-------------------------------------+

> The first two rows are most relevant and the other rows come form the relevant words in first two rows
Query expansion tends to increase noise significantly by return non-relevant results.

### stopword 停止字
可以修改全文索引停止字的配置,

	ft_min_word_len 忽略小于ft_min_word_len 的单词
	ft_max_word_len 忽略大于ft_min_word_len 的单词
	ft_stopword_file 忽略file 所包含的单词, 默认的file 包含：am is this that.

修改配置后需要重启mysqld 并重新建立全文索引：

	REPAIR TABLE tb_name QUIK

stopword 因为会忽略单词，会导致搜索这些常用单词，最小单词时没有结果。

### BOOLEAN FULLTEXT
用BOOLEAN FULLTEXT: 最细粒度的搜索控制

1. 搜索包含'word1', 但不包含'word2', 'word3'的行
2. 确保结果集至少出现一个关键字、所有关键字、没有关键字

具体 BOOLEAN 控制:

	+ 前导确保后面的单词出现在每个结果
	- 前导确保后面的单词不出现在每个结果
	* 允许后面的单词变体
	" " 外围引号确保引号内的字符串出现在结果集
	<> 用于减少/增加后面单词的搜索级别相关度
	()	小于号用于单词分组为子表达式

EXAMPLE:

	Against('+word -word' in BOOLEAN MODE )

下例必须使`ft_min_word_len<=2` 才能生效, 因为`js` 只有两个字符

	Against('+(<js >php ) +web' in BOOLEAN MODE ); # 搜索包含js php web的记录 并js的搜索级别小于php

# 索引原理
我们用的英语字典查询中的 等值查询依赖字母顺序作索引。mysql 数据库的索引要复杂一些，除了等值，还有范围`>< between in`, 模糊`like`, 并集查询`or`

参考: [索引原理-meituan]

## disk IO 与预读
先简单介绍一下磁盘IO和预读，磁盘读取数据靠的是机械运动，每次读取数据花费的时间可以分为寻道时间、旋转延迟、传输时间三个部分，寻道时间指的是磁臂移动到指定磁道所需要的时间，主流磁盘一般在5ms以下；旋转延迟就是我们经常听说的磁盘转速，比如一个磁盘7200转，表示每分钟能转7200次，也就是说1秒钟能转120次，旋转延迟就是1/120/2 = 4.17ms；传输时间指的是从磁盘读出或将数据写入磁盘的时间，一般在零点几毫秒，相对于前两个时间可以忽略不计。那么访问一次磁盘的时间，即一次磁盘IO的时间约等于5+4.17 = 9ms左右，听起来还挺不错的，但要知道一台500 -MIPS的机器每秒可以执行5亿条指令，因为指令依靠的是电的性质，换句话说执行一次IO的时间可以执行40万条指令，数据库动辄十万百万乃至千万级数据，每次9毫秒的时间，显然是个灾难。下图是计算机硬件延迟的对比图，供大家参考：

![](/img/mysql-index.disk-io.png)

考虑到磁盘IO是非常高昂的操作，计算机操作系统做了一些优化，当一次IO时，不光把当前磁盘地址的数据，而是把相邻的数据也都读取到内存缓冲区内，因为局部预读性原理告诉我们，当计算机访问一个地址的数据的时候，与其相邻的数据也会很快被访问到。每一次IO读取的数据我们称之为一页(page)。具体一页有多大数据跟操作系统有关，一般为4k或8k，也就是我们读取一页内的数据时候，实际上才发生了一次IO，这个理论对于索引的数据结构设计非常有帮助。

## B+ 树
为了mysql 提高读取disk IO 的效率，我们需要做disk 预读，每次查找数据时把磁盘IO次数控制在一个很小的数量级，最好是常数数量级。

那么我们就想到如果一个高度可控的多路搜索树是否能满足需求呢？就这样，b+树应运而生。 先看看B+ 树的数据结构

![](/img/mysql-index.btree.jpg)

如上图，是一颗b+树，关于b+树的定义可以参见B+树，这里只说一些重点，浅蓝色的块我们称之为一个磁盘块，可以看到每个磁盘块包含几个数据项（深蓝色所示）和指针（黄色所示），如磁盘块1包含数据项17和35，包含指针P1、P2、P3，P1表示小于17的磁盘块，P2表示在17和35之间的磁盘块，P3表示大于35的磁盘块。真实的数据存在于叶子节点即3、5、9、10、13、15、28、29、36、60、75、79、90、99。非叶子节点只不存储真实的数据，只存储指引搜索方向的数据项，如17、35并不真实存在于数据表中。

### b+树的查找过程

如图所示，如果要查找数据项29，那么首先会把磁盘块1由磁盘加载到内存，此时发生一次IO，在内存中用二分查找确定29在17和35之间，锁定磁盘块1的P2指针，内存时间因为非常短（相比磁盘的IO）可以忽略不计，通过磁盘块1的P2指针的磁盘地址把磁盘块3由磁盘加载到内存，发生第二次IO，29在26和30之间，锁定磁盘块3的P2指针，通过指针加载磁盘块8到内存，发生第三次IO，同时内存中做二分查找找到29，结束查询，总计三次IO。真实的情况是，3层的b+树可以表示上百万的数据，如果上百万的数据查找只需要三次IO，性能提高将是巨大的，如果没有索引，每个数据项都要发生一次IO，那么总共需要百万次的IO，显然成本非常非常高。

### b+树性质

1. 通过上面的分析，我们知道IO次数取决于b+数的高度h，假设当前数据表的数据为N，每个磁盘块的数据项的数量是m，每个块指针数量`(m+1)`, 则有`h=㏒(m+1)N`，当数据量N一定的情况下，m越大，h越小；而`m = 磁盘块的大小 / 数据项的大小`，磁盘块的大小也就是一个数据页的大小，是固定的，如果数据项占的空间越小，数据项的数量越多，树的高度越低。这就是为什么每个数据项，即索引字段要尽量的小，比如int占4字节，要比bigint8字节少一半。这也是为什么b+树要求把真实的数据放到叶子节点而不是内层节点，一旦放到内层节点，磁盘块的数据项会大幅度下降，导致树增高。当数据项等于1时将会退化成线性表(应该是二叉树吧?)。
2. 当b+树的数据项是复合的数据结构，比如(name,age,sex)的时候，b+数是按照从左到右的顺序来建立搜索树的，比如当(张三,20,F)这样的数据来检索的时候，b+树会优先比较name来确定下一步的所搜方向，如果name相同再依次比较age和sex，最后得到检索的数据；但当(20,F)这样的没有name的数据来的时候，b+树就不知道下一步该查哪个节点，因为建立搜索树的时候name就是第一个比较因子，必须要先根据name来搜索才能知道下一步去哪里查询。比如当(张三,F)这样的数据来检索时，b+树可以用name来指定搜索方向，但下一个字段age的缺失，所以只能把名字等于张三的数据都找到，然后再匹配性别是F的数据了， 这个是非常重要的性质，即索引的最左匹配特性。

# 索引原则

## 索引自动选择
> http://ourmysql.com/archives/108?f=wb

如果id 是主键，program_id 是主键
这张表大约容量30G，数据库服务器内存16G，无法一次载入。就是这个造成了问题。
会有以下问题

	select * from program_access_log where program_id between 1 and 4000
		先通过索引文件找出了所有program_id在1到4000范围里所有的id，这个过程非常快.
			再通过id 查找记录，但是id 是离散的，所以mysql对这个表的访问不是顺序读取。

	select * from program_access_log where id between 1 and 500000 and program_id between 1 and 4000
		ID一到五十万和Program_id一到四千，因为program_id范围小得多，mysql选择它做为主要索引。
		同上

解决：
1. 分表
2. 分区(`mysql > 5.x`)
3. 使用id

	select * from program_access_log where id between 1 and 500000 and program_id between 1 and 15000000

现在program_id的范围远大于id的范围，id被当做主要索引进行查找，由于id是主键，所以查找的是连续50万条记录，速度和访问一个50万条记录的表基本一样

## 最左前缀匹配原则
1. mysql会一直向右匹配直到遇到范围查询(>、<、between、like)就停止匹配，比如a = 1 and b = 2 and c > 3 and d = 4 如果建立(a,b,c,d)顺序的索引，d是用不到索引的，如果建立 联合索引index(a,b,d,c) 则都可以用到，a,b,d的顺序可以任意调整。
2. =和in可以乱序，比如`a = 1 and b = 2 and c = 3 ` 建立`index(a,b,c)`索引可以任意顺序，mysql的查询优化器会帮你优化成索引可以识别的形式
3. 尽量选择区分度高的列作为索引,区分度的公式是 `count(distinct col)/count(*)`，表示字段不重复的比例，比例越大我们扫描的记录数越少，唯一键的区分度是1，而一些状态、性别字段可能在大数据面前区分度就是0.
	那可能有人会问，这个比例有什么经验值吗？使用场景不同，这个值也很难确定，一般需要join的字段我们都要求是0.1以上，即平均1条扫描10条记录
4. 索引列不能参与计算，保持列“干净”，比如from_unixtime(create_time) = ’2014-05-29’就不能使用到索引，原因很简单，b+树中存的都是数据表中的字段值，但进行检索时，需要把所有元素都应用函数才能比较，显然成本太大。
	所以语句应该写成create_time = unix_timestamp(’2014-05-29’);
5. 尽量的扩展索引，不要新建索引。比如表中已经有a的索引，现在要加(a,b)的索引，那么只需要修改原来的索引即可

## 对于准备要索引的列必须使用NOT NULL
这样就不会存储NULL(含NULL 的列区分度低), 而是默认值。我对这条有

## 对不使用的索引
请开启`--log-long-format`,日志会记录更详细的信息：谁发出的查询、什么时间发出的等。 方便日后做查询优化
而`log-short-format` 记录激活的更新日志、二进制更新日志、和慢查询日志的少量信息。但用户名和时间戳不记录下来。

# 优化查询

## show index

	show index from table_name;

## explain
用explain 获取mysql 如何query, 如何join(联结)，怎样的顺序join 参考：
http://dev.mysql.com/doc/refman/5.5/en/explain-output.html

	Column		Meaning
	id			The SELECT identifier
	select_type	The SELECT type
	table		The table for the output row
	partitions	The matching partitions
	type		The join type
				All 全表查询，range 范围查询, eq_ref 等值查询 index(也是全表，但是只用index数据，不需要所有数据的情况如count(*))
				ref 是在 eq_ref 不是 primary/unique 时
	possible_keys	The possible indexes to choose
	key			The index actually chosen
	key_len		The length of the chosen key
	ref			The columns compared to the index
	rows		Estimate of rows to be examined
	filtered	Percentage of rows filtered by table condition
	Extra		Additional information

这里需要强调rows是核心指标，绝大部分rows小的语句执行一定很快（有例外，下面会讲到）。所以优化语句基本上都是在优化rows。

## 慢查询优化步骤
0. 先运行看看是否真的很慢，注意设置SQL_NO_CACHE
1. where条件单表查，锁定最小返回记录表。这句话的意思是把查询语句的where都应用到表中返回的记录数最小的表开始查起，单表每个字段分别查询，看哪个字段的区分度最高
2. explain查看执行计划，是否与1预期一致（从锁定记录较少的表开始查询）
3. order by limit 形式的sql语句让排序的表优先查
4. 了解业务方使用场景
5. 加索引时参照建索引的几大原则
6. 观察结果，不符合预期继续从0分析

### ref
ref can be used for indexed columns that are compared using the = or <=> operator.
In the following examples, MySQL can use a ref join to process ref_table:

	SELECT * FROM ref_table WHERE key_column=expr;

	SELECT * FROM ref_table,other_table
	  WHERE ref_table.key_column=other_table.column;

	SELECT * FROM ref_table,other_table
	  WHERE ref_table.key_column_part1=other_table.column
	  AND ref_table.key_column_part2=1;

## 优化example

## 明确场景

## 无法优化的语句

# 内存限制
排序等操作需要消耗大量的内存，请设定足够的内存

# Reference
- [索引原理-meituan]

[索引原理-meituan]: http://tech.meituan.com/mysql-index.html
