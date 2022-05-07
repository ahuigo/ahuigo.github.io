---
layout: page
title: pg-datatype
category: blog
description: 
date: 2018-09-27
private:
---
# define var
## test type

    SELECT pg_typeof(your_variable);
    json_typeof(var)


## define type

    varchar(10) not null;
    DECIMAL(4,2) not null;
    int not null;

### null
In SQL, NULL is not equal to anything. Nor is it unequal to anything.

    where c not like 'xxx%'; -- not include null

### 不要用null
	NULL means you do not have to provide a value for the field... default to null
	NOT NULL means you must provide a value for the fields. 但很多情况下，插入数据时默认会给一个空值(0, 或者空字符串).

Null 列的缺点:

- 难以优化索引：Mysql难以优化引用可空列查询，它会使索引、索引统计和值更加复杂。
- 更多的空间：可空列需要更多的存储空间，还需要mysql内部进行特殊处理。
> NULL columns require additional space in the rowto record whether their values are NULL. For MyISAM tables, each NULL columntakes one bit extra, rounded up to the nearest byte.”

## convert type
### convert type::
类型转换

    var::int
    var::jsonb
    var::text::jsonb
    select name::text::jsonb
    select 1::real

空数组

    array[]::varchar[]
    '{}'::text[]

### Cast Convert

	CAST(expr AS type)
		result value of a specified type, similar to CONVERT()
	CONVERT(expr, type)
		type supported:
			二进制，: BINARY    
			字符型，带参数 : CHAR(5)     对于hive 来说, 使用string
			日期 : DATE     
			时间: TIME     
			日期时间型 : DATETIME     
			浮点数 : DECIMAL      
			整数 : SIGNED     
			无符号整数 : UNSIGNED

Example:

	select max(cast(col as UNSIGNED));
	select	cast('2016-03-01 01:01:02' as date) |
	+-------------------------------------+
	| 2016-03-01

Hive内置的数据类型之间是否可以进行隐式的转换操作:

			bl		tinyint	si		int		bigint	float	double	dm		string	vc		ts		date	ba
	boolean	true	false	false	false	false	false	false	false	false	false	false	false	false
	tinyint	false	true	true	true	true	true	true	true	true	true	false	false	false
	smallint false	false	true	true	true	true	true	true	true	true	false	false	false
	int		false	false	false	true	true	true	true	true	true	true	false	false	false
	bigint	false	false	false	false	true	true	true	true	true	true	false	false	false
	float	false	false	false	false	false	true	true	true	true	true	false	false	false
	double	false	false	false	false	false	false	true	true	true	true	false	false	false
	decimal	false	false	false	false	false	false	false	true	true	true	false	false	false
	string	false	false	false	false	false	false	true	true	true	true	false	false	false
	varchar	false	false	false	false	false	false	true	true	true	true	false	false	false
	ts		false	false	false	false	false	false	false	false	true	true	true	false	false
	date	false	false	false	false	false	false	false	false	true	true	false	true	false
	binary	false	false	false	false	false	false	false	false	false	false	false	false	true

## 默认值

    COALESCE(variable,0)
    COALESCE(counters->>'bar','0')::int

## list all type
list all data type

    SELECT typname, typlen FROM pg_type WHERE typname ~ '^date';

特殊的类型

    \d pg_type
    name	Data type name
    oid	    Owner of the type


# `pg_class`
## 对象标识符OID
> http://www.postgres.cn/docs/9.4/datatype-oid.html
PostgreSQL在内部使用对象标识符(OID)作为各种系统表的主键。 
除此以外oid还有几个别名：regproc, regprocedure, regoper, regoperator, regclass, regtype, regconfig, 和regdictionary。


    名字             引用	         描述	            数值例子
    oid             任意             数字化的对象标识符	564182
    regproc	        pg_proc	        函数名字	        sum
    regprocedure	pg_proc	        带参数类型的函数	sum(int4)
    regoper	        pg_operator	    操作符名	        +
    regoperator	    pg_operator	    带参数类型的操作符	*(integer,integer) 或 -(NONE,integer)
    regclass	    pg_class	    关系名	        pg_type
    regtype	        pg_type	        数据类型名	    integer
    regconfig	    pg_ts_config	文本搜索配置	english
    regdictionary	pg_ts_dict	    文本搜索字典	simple

比如regclass 代表关系表的oid

    SELECT * FROM pg_attribute WHERE attrelid = 'mytable'::regclass; //自动转成关系表的oid
    SELECT * FROM pg_attribute WHERE attrelid = (SELECT oid FROM pg_class WHERE relname = 'mytable');

除了oid, 系统还有
1. 系统使用的另外一个标识符类型是事务(缩写xact)标识符xid。 它是系统字段xmin和xmax的数据类型。事务标识符是 32 位的量。
1. 系统需要的第三种标识符类型是命令标识符cid。 它是系统字段cmin和cmax的数据类型。命令标识符也是 32 位的量。
1. 系统使用的最后一个标识符类型是行标识符tid。 它是系统表字段ctid的数据类型。行 ID 是一对数值(块号，块内的行索引)， 它标识该行在其所在表内的物理位置

### pg_namespace
列出 namespace的oid

    select * from pg_namespace limit 100;
        oid |      nspname       | nspowner |                  nspacl
    --------+--------------------+----------+-------------------------------------------
        14  | pg_catalog         |       10 | 
        220 | public             |       10 | 

## 列表所有public的id sequence
`pg_class.relkind='S'` 代表`id_seq` 

    select pc.oid,nspname,relname from pg_class pc, pg_namespace pn where pc.relnamespace=pn.oid and pc.relkind='S';

# 常用类型
## bool 表达

    insert into users(is_deleted) values(false)
    insert into users(is_deleted) values('false')
    insert into users(is_deleted) values('f')
    insert into users(is_deleted) values('0')

    True	False
    ------------
    true	false
    ‘t’	    ‘f‘
    ‘true’	‘false’
    ‘y’	    ‘n’
    ‘yes’	‘no’
    ‘1’	    ‘0’

# Data Property

## AUTO_INCREMENT
Auto +1 and it must be defined as a key(primary key)

### initalize value
in mysql:

    ALTER TABLE users AUTO_INCREMENT=8;
    # if you haven't already added an id column, also add it
    ALTER TABLE users ADD id INT UNSIGNED NOT NULL AUTO_INCREMENT, ADD INDEX (id);

in pg: using the SERIAL or BIGSERIAL :

    CREATE TABLE books (
        id              SERIAL PRIMARY KEY,
        title           VARCHAR(100) NOT NULL,
    );
    ALTER TABLE test1 ADD COLUMN id SERIAL PRIMARY KEY;

in pg: if you want id start from 8,Using a Custom Sequence: https://chartio.com/resources/tutorials/how-to-define-an-auto-increment-primary-key-in-postgresql/

    CREATE SEQUENCE books_sequence
        start 8 increment 2;

    INSERT INTO books
        (id, title)
    VALUES
        (nextval('books_sequence'), 'The Hobbit');

## BINARY(Case Sensitive)
比较BINARY 列时将区分大小小方排序，默认不区分

## ZEROFILL

	int(5) ZEROFILL
