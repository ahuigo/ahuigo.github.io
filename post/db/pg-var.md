---
layout: page
title: pg-datatype
category: blog
description: 
date: 2018-09-27
private:
---
# define var

## define type

    varchar(10) not null;
    DECIMAL(4,2) not null;
    int not null;

### 不要用null
	NULL means you do not have to provide a value for the field... default to null
	NOT NULL means you must provide a value for the fields. 但很多情况下，插入数据时默认会给一个空值(0, 或者空字符串).

Null 列的缺点:

- 难以优化索引：Mysql难以优化引用可空列查询，它会使索引、索引统计和值更加复杂。
- 更多的空间：可空列需要更多的存储空间，还需要mysql内部进行特殊处理。
> NULL columns require additional space in the rowto record whether their values are NULL. For MyISAM tables, each NULL columntakes one bit extra, rounded up to the nearest byte.”

## test type

    SELECT pg_typeof(your_variable);
    json_typeof(var)

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


# 数据类型
## bool
    True	False
    ------------
    true	false
    ‘t’	    ‘f‘
    ‘true’	‘false’
    ‘y’	    ‘n’
    ‘yes’	‘no’
    ‘1’	    ‘0’

使用

    insert into users(is_deleted) values(false)
    insert into users(is_deleted) values('false')
    insert into users(is_deleted) values('f')
    insert into users(is_deleted) values('0')



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
