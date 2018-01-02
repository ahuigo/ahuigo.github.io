---
layout: page
title:
category: blog
description:
---
# Preface

# 字符集

## collation( 字符序)
[用于指定数据集如何排序，以及字符串的比对规则](http://zhongwei-leg.iteye.com/blog/899227)

	show collation;

collation 名字的规则可以归纳为这两类：

1. `<character set>_<language/other>_<ci/cs>`(按语言、大小写)
2. `<character set>_bin`(按字节值)

ci 是 case insensitive 的缩写， cs 是 case sensitive 的缩写。即，指定大小写是否敏感。

### 语言
那么 `utf8_general_ci, utf8_unicode_ci, utf8_danish_ci` 有什么区别? 
同一个 character set 的不同 collation 的区别在于排序、字符对比的准确度（相同两个字符在不同国家的语言中的排序规则可能是不同的）以及性能。

1. utf8_general_ci 在排序的准确度上要逊于 utf8_unicode_ci， 当然，对于英语用户应该没有什么区别。但性能上（排序以及比对速度）要略优于 utf8_unicode_ci. 例如前者没有对德语中 `ß = ss` (在德语中他们意义是等价的)的支持。
2. 而 utf8_danish_ci 相比 utf8_unicode_ci 增加了对丹麦语的特殊排序支持。

> 当表的 character set 是 latin1 时，若字段类型为 nvarchar, 则字段的字符集自动变为 utf8.
可见 database character set, table character set, field character set 可逐级覆盖。

### 大小写

	字符序“utf8_general_ci”下，字符“a”和“A”是等价的；

在 ci 的 collation 下，如何在比对时区分大小写：
推荐使用

	mysql> select * from pet where name = binary 'whistler'; //这样可以保证当前字段的索引依然有效
	mysql> select * from pet where binary name = 'whistler'; //会使索引失效。

## 查看字符集

	//查看mysql 支持的字符集
	show character set;
	show collation;//影响字符排序\对比的性能与准确度

	//check
	show variables like "%char%";
	show create table db.table;
	show create database db;

	client->connect->server/system/database->results

	//临时设置编码
	mysql_query("SET NAMES 'utf8'");//设定字符集,告诉服务器,我用的是utf-8编码, 我希望你也给我返回utf-8编码的查询结果.他会影响: results|client|connect
	mysql_set_charset("utf8");//调用set names utf8 / set collation，设定字符集(会影响mysql_real_escape_string())
	mysql_query("SET CHARACTER_SET_CLIENT=utf8");
	mysql_query("SET CHARACTER_SET_RESULTS=utf8");
	mysql_query("SET CHARACTER_SET_RESULTS=latin1");

### 其他注意事项
my.cnf中的default_character_set设置只影响mysql命令连接服务器时的连接字符集，不会对使用libmysqlclient库的应用程序产生任何作用！

SQL语句中的裸字符串会受到连接字符集或introducer设置的影响，对于比较之类的操作可能产生完全不同的结果，需要小心！

# 基本概念
> http://www.laruence.com/2008/01/05/12.html

## MySQL字符集设置
系统配置

	[client]
	default-character-set = utf8

	[mysqld]
	default-storage-engine = INNODB
	character-set-server = utf8
	collation-server = utf8_general_ci

重启MySQL后，可以通过MySQL的客户端命令行检查编码：

系统变量：

	character_set_server：默认的内部操作字符集

	character_set_client：客户端来源数据使用的字符集

	character_set_connection：连接层字符集

	character_set_results：查询结果字符集

	character_set_database：当前选中数据库的默认字符集

	character_set_system：系统元数据(字段名等)字符集

	还有以collation_开头的同上面对应的变量，用来描述字符序。

用introducer指定文本字符串的字符集：

	– 格式为：[_charset] 'string' [COLLATE collation]

例如：

	SELECT _latin1 'string';

	SELECT _utf8 '你好' COLLATE utf8_general_ci;

由introducer修饰的文本字符串在请求过程中不经过多余的转码，直接转换为内部字符集处理。

## MySQL中的字符集转换过程

1. MySQL Server收到请求时将请求数据从character_set_client转换为character_set_connection；

2. 进行内部操作前将请求数据从character_set_connection转换为内部操作字符集，其确定方法如下：

使用每个数据字段的CHARACTER SET设定值；

	若上述值不存在，则使用对应数据表的DEFAULT CHARACTER SET设定值(MySQL扩展，非SQL标准)；

	若上述值不存在，则使用对应数据库的DEFAULT CHARACTER SET设定值；

	若上述值不存在，则使用character_set_server设定值。

3. 将操作结果从内部操作字符集转换为character_set_results。

## 常见问题解析

• 向默认字符集为utf8的数据表插入utf8编码的数据前没有设置连接字符集，查询时设置连接字符集为utf8

– 插入时根据MySQL服务器的默认设置，character_set_client、character_set_connection和character_set_results均为latin1；

– 插入操作的数据将经过latin1=>latin1=>utf8的字符集转换过程，这一过程中每个插入的汉字都会从原始的3个字节变成6个字节保存；

– 查询时的结果将经过utf8=>utf8的字符集转换过程，将保存的6个字节原封不动返回，产生乱码……

• 向默认字符集为latin1的数据表插入utf8编码的数据前设置了连接字符集为utf8

– 插入时根据连接字符集设置，character_set_client、character_set_connection和character_set_results均为utf8；

– 插入数据将经过utf8=>utf8=>latin1的字符集转换，若原始数据中含有\u0000~\u00ff范围以外的Unicode字 符，会因为无法在latin1字符集中表示而被转换为“?”(0x3F)符号，以后查询时不管连接字符集设置如何都无法恢复其内容了。


