---
layout: page
title:	mysql 查询
category: blog
description:
---
# Preface

## client

	echo cmds | mysql
	mysql -e cmd -e cmd

## which database

	//show which database is in use
	SELECT DATABASE();

# Statement

## if

	select if(9<=7, '1-7', if(9=8, 8, 9));

# Operation
Insert update delete select

## select
[mysql-select](/p/mysql-select)

	select 1-3*2 as calc into @sum;//在存储例程中变量不需要加@
	select * from table where id in (3,4) or [name] in ('andy','paul');

### wildcard

	 select a.*,

### select with update
借助`last_insert_id` 实现原子操作`select+update`

	update t1 set counter=last_insert_id(counter+1) WHERE id = 1;
	select last_insert_id();//counter

	select last_insert_id('1234');
	select last_insert_id();//1234


#### last_insert_id 规则
lastInsertId :

1. 手动`insert into t(id)` 时，last_insert_id() 不改变()
2. 当通过`auto_increment` 自增并成功插入数据后，改变
3. update 时不改变，除非执行：`last_insert_id(id) `

### subquery 子查询
subquery 是嵌入另一条语句的select 语句. 他是数据集合

#### in

	select * from tb where id>(select id from t limit 1)

	//in
	select * from tb where id in (select id from tb2)
	//not in
	select * from tb where id not in (select id from tb2)

#### from sub sql

	select filed1 from (select 1 filed1,2) alias;

#### where exists

	//exists 判断结果集
	select * from tb where exists (select * from tb2 where tb2.id=tb.id)

> Traditionally, an EXISTS subquery starts with SELECT *, but it could begin with SELECT 5 or SELECT column1 or anything at all. MySQL ignores the SELECT list in such a subquery, so it makes no difference.
> 先查tb 的一条记录，然后将这条记录放到内层查询，如果内层查询有结果，则where 返回true 命中此条记录。然后继续下一条tb 中的记录

	select * from t1 where exists(select * from t2 where t2.id=t1.id);
	select * from t1 where exists(select * from t2,t1 where t2.id=t1.id);
								select * from t2,t1 where t2.id=t1.id;//always true

构建多表的查询叫联结(join)，与join 相比subquery 更简单直观

Example:

	create table `student`(
		id int auto_increment primary key,
		name char(20)
	);
	create table course(
		id int auto_increment primary key,
		cname char(20)
	);
	create table sc(
		id int auto_increment primary key,
		sid int,
		cid int
	);

	insert into student(name) values('Hilo'), ('Jack');
	insert into course(cname) values('Math'), ('Physic');
	insert into sc(sid,cid) values(1,1), (1,2);
	insert into sc(sid,cid) values(2,1);

	# 选修了Math 的学生
	select * from student  where exists (
		select * from sc,course where sc.cid=course.id and sc.sid=student.id and exists(
			select * from course where cname='Math' and id=sc.cid
	))
	select * from student  where exists (
		select * from sc,course where sc.cid=course.id and sc.sid=student.id and course.cname = 'Math'
	);

全量：第一层否定得到没有学的课程，第二层否定得到*没有没有学*的课程的`学生`。而不是已经学的`课程`。

	# 选修了所有课程的学生
	select * from student  where not exists (select * from course where not exists (select *  from sc where sc.cid=course.id and sc.sid=student.id));
		//该学生没有选择的课程
		select * from course where not exists (select *  from sc where sc.cid=course.id and sc.sid=student.id)

### Cursor 游标
Cursor 就是一个游标，相当于数组下标，指示当前数据集取到哪里了。
它的特点：

1. 只读: 只读cursor 所指的数据，而可写游标则可改变数据，mysql 只支持只读
2. 只向前：mysql 的游标只可向前，不可向后
3. 服务器端：mysql 的游标是放在服务器端的
4. 敏感：敏感游标引用数据库的实际数据(无内存消耗，慢)，而不敏感游标指向创建游标时所建的数据副本(申请内存，快)

操作

	//create cursor
	DECLARE cursor_name CURSOR FOR select_statement;

	//open cursor
	OPEN cursor_name

	//use cursor
	FETCH cursor_name into var1,var2,...

	//close cursor
	CLOSE cursor_name

游标通常要配合LOOP； 因为LOOP 需要判断游标是否结束，这还需要借助`declare continue handler` 的`NOT FOUND` 事件

Example:


	drop procedure if exists loop_t;
	delimiter //
	create procedure loop_t()
	BEGIN
		declare done int; /*变量必须在游标前定义*/
		declare var int;

		declare cursor_t CURSOR FOR select s1 from t1;
		declare continue handler for not found set done=1;/*游标结束时触发*/

		open cursor_t;
		BEGIN_t: LOOP
			FETCH cursor_t into var;
			IF done THEN
				LEAVE BEGIN_t;
			END IF;
			select var;
		END LOOP;
		close cursor_t;
	END;//
	delimiter ;
	call loop_t();

> 注意，所有的执行语句都必须放在`declare` 声明之后，否则会报错

## Insert

	INSERT INTO ed_names (com_id, c_date, c_time, c_type, c_request, c_by) VALUES ($id, CURRENT_DATE, CURRENT_TIME, 0 ,0,$user);
	INSERT INTO ed_names (com_id) VALUES (1),(2),(3);
	INSERT INTO ed_names VALUES (columns1),(columns2);

import

	insert into table1 (select 1,'zz', 'ab','2015-06-20 14:43:44',0,0,0,2);
	insert into table1 (select * from table2);
	insert into table1 select * from table2;

insert_id(php):

	mysql_insert_id();
	$mysqli->insert_id;
	$pdo->lastInsertId()

### insert when not exists
Not exists 保证

	INSERT INTO clients (client_id, client_name, client_type)
		SELECT supplier_id, supplier_name, 'advertising'
	FROM suppliers
	WHERE not exists (
		select * from clients,suppliers where clients.client_id = suppliers.supplier_id
		);

### update when DUPLICATE key
插入行后会导致在`一个UNIQUE索引或PRIMARY KEY`中出现重复值，则执行后面的UPDATE

	INSERT INTO table (a,b,c) VALUES (1,2,3)  ON DUPLICATE KEY UPDATE c=c+1;
	INSERT INTO table (a) VALUES (1) ON DUPLICATE KEY UPDATE id=id;//仅当insert: last_insert_id 改变
	INSERT INTO table (a) VALUES (1) ON DUPLICATE KEY UPDATE id=last_insert_id(id);//insert + update: last_insert_id 改变

	INSERT INTO table (a) VALUES (1),(1),(2),(3)  ON DUPLICATE KEY UPDATE id=id;//仅当insert: last_id 变;
	INSERT INTO table (a) VALUES (1),(1),(2),(3)  ON DUPLICATE KEY UPDATE id=last_insert_id(id);insert + update: 改变

`VALUES(column)` 会返回insert 中的值:

	INSERT INTO table (a,b,c) VALUES (1,2,3),(4,5,6) ON DUPLICATE KEY UPDATE a=VALUES(a), b=VALUES(b),c=VALUES(c);
	INSERT INTO table (a,b,c) VALUES (1,2,3),(4,5,6) ON DUPLICATE KEY UPDATE c=VALUES(a)+VALUES(b);

ON DUPLICATE KEY 不支持where

	# unsupported
	INSERT INTO table (a,b,c) VALUES (1,2,3)  ON DUPLICATE KEY UPDATE c=c+1 where c<5;

但可以使用if 代替:

	IF(condition, exp1, exp2)
	INSERT INTO table (a,b,c) VALUES (1,2,3)  ON DUPLICATE KEY UPDATE c=IF(c<5, c+1, c)
	select IF(false, 1, 0)

### replace when DUPLICATE key
REPLACE 可以将`DELETE和INSERT`合二为一，形成一个原子操作(它也是基于唯一键的)

	REPLACE INTO users (phone) VALUES(18210111011);
　
插入多条记录：

	REPLACE INTO users(phone) VALUES(18210111011), (18210111012);

REPLACE也可以使用SET语句

	REPLACE INTO users SET phone=1000,name='hilojack'

*Note:* 如果insert 时, 有两条记录都满足删除要求(比如phone,id 都DUPLICATE了)，则会删除两条（on DUPLICATE 则只删除最前面的一条）

	REPLACE INTO users(phone,id) VALUES(18210111011, 134);

## Update

	UPDATE ed_names SET c_request = c_request+1 WHERE id = 'x'"

### update DUPLICATE
mysql update 多个unique key 时,如果遇到 `duplicate key`

一般情况下可以通过排序避免(mysql update/insert 时会按一定的顺序去查数据是否有效):

	UPDATE <table> set i=i+1 where id>10 order by i desc;
	UPDATE <table> set i=i-1 where id>10 order by i asc;

如果`i`没有加索引，排序比较耗时或内存，就变通一下，比如负数：

	UPDATE <table> set i=-i where id>10;
	UPDATE <table> set i=1-i where id>10;

### LOCK

	LOCK TABLES `TTT_DATAALLOWANCE` WRITE;
	INSERT INTO `TTT_DATAALLOWANCE` VALUES (7,'2274153945',1,'13522565869');
	UNLOCK TABLES;

# where

	where name IS NOT NULL;
	where name IS NULL;  # 不可以用name=NULL
	where name <=> NULL; # 不可以用name=NULL
	where name!=''; # not null and not empty string

# join
Refer to: http://www.codedata.com.tw/database/mysql-tutorial-5-join-union/

先构建两张表: 国家和城市

- Country(Code, Capital)
- City(id, Name)

## Inner Join
Inner Join 有两种写法：差异在把结合条件设定在where 子句或from 子句

### join via where

	where a.id=b.id and a.uid=b.uid

join结合条件 在where:

	MariaDB [test]> select * from country,city;
	+---------+---------+----+----------+
	| code    | capital | id | name     |
	+---------+---------+----+----------+
	| China   | 1       |  1 | Beijing  |
	| America | 2       |  1 | Beijing  |
	| China   | 1       |  2 | Shanghai |
	| America | 2       |  2 | Shanghai |
	+---------+---------+----+----------+

	MariaDB [test]> select * from country,city where country.capital = city.id;
	+---------+---------+----+----------+
	| code    | capital | id | name     |
	+---------+---------+----+----------+
	| China   | 1       |  1 | Beijing  |
	| America | 2       |  2 | Shanghai |
	+---------+---------+----+----------+

	MariaDB [test]> explain select * from country,city where capital = id;
	+------+-------------+---------+------+---------------+------+---------+------+------+-------------------------------------------------+
	| id   | select_type | table   | type | possible_keys | key  | key_len | ref  | rows | Extra                                           |
	+------+-------------+---------+------+---------------+------+---------+------+------+-------------------------------------------------+
	|    1 | SIMPLE      | country | ALL  | NULL          | NULL | NULL    | NULL |    2 |                                                 |
	|    1 | SIMPLE      | city    | ALL  | PRIMARY       | NULL | NULL    | NULL |    2 | Using where; Using join buffer (flat, BNL join) |
	+------+-------------+---------+------+---------------+------+---------+------+------+-------------------------------------------------+

### Inner Join
和where 过滤条件的写法是一样的

	SELECT * FROM table_name [INNER] JOIN table_name ON <condition>;

	//以下等价
	SELECT * FROM table_name [INNER] JOIN table_name ON tb1.column=tb2.column;
	SELECT * FROM table_name [INNER] JOIN table_name USING (column); //适用于同名的column

Example:

	MariaDB [test]> select code,capital,name from country JOIN city ON capital = id;
	+---------+---------+----------+
	| code    | capital | name     |
	+---------+---------+----------+
	| China   | 1       | Beijing  |
	| America | 2       | Shanghai |
	+---------+---------+----------+

condion 可以通过`On` 使用and or 等

	On (cond1 and cond2)

## Outer Join
对于如下数据，Inner Join 会漏掉了capital=3 ,如果不想漏掉它， 此时应该考虑`{Left| Right} [OUTER] Join`(OUTER 是可有可无的)
Left Join 的结果集包括所有的Left, Right Join 则包括了所有的Right 结果集

	MariaDB [test]> select * from country;
	+---------+---------+
	| code    | capital |
	+---------+---------+
	| China   | 1       |
	| America | 2       |
	| England | 3       |
	+---------+---------+

### Left Join

	MariaDB [test]> select code,capital,name from country LEFT OUTER JOIN city ON capital = id;
	+---------+---------+----------+
	| code    | capital | name     |
	+---------+---------+----------+
	| China   | 1       | Beijing  |
	| America | 2       | Shanghai |
	| England | 3       | NULL     |
	+---------+---------+----------+

Right Join 则相反

#### get records with max value for group
http://dev.mysql.com/doc/refman/5.7/en/correlated-subqueries.html
correlated subqueries is slow:

	select * from record a where time = （select max(time) from record b where b.sid=a.sid）

Uncorrelated subquery(join):

	SELECT s1.article, dealer, s1.price
	FROM shop s1
	JOIN (
	  SELECT article, MAX(price) AS price
	  FROM shop
	  GROUP BY article) AS s2
  ON s1.article = s2.article AND s1.price = s2.price;

Uncorrelated subquery(left join):

	SELECT s1.article, s1.dealer, s1.price
	FROM shop s1
	LEFT JOIN shop s2 ON s1.article = s2.article AND s1.price < s2.price
	WHERE s2.article IS NULL;

left join:
http://stackoverflow.com/questions/12102200/get-records-with-max-value-for-each-group-of-grouped-sql-results
http://dev.mysql.com/doc/refman/5.7/en/example-maximum-column-group-row.html

	select a.*,b.* from record a left join record b on a.sid=b.sid;
	+------------+------+---------------------+------------+------+---------------------+
	| url        | sid  | time                | url        | sid  | time                |
	+------------+------+---------------------+------------+------+---------------------+
	| hilo.com   |    1 | 2015-06-09 00:00:00 | hilo.com   |    1 | 2015-06-09 00:00:00 |
	| hilo.com/a |    1 | 2015-06-10 00:00:00 | hilo.com   |    1 | 2015-06-09 00:00:00 |
	| hilo.com/b |    1 | 2015-06-11 00:00:00 | hilo.com   |    1 | 2015-06-09 00:00:00 |
	| hilo.com   |    1 | 2015-06-09 00:00:00 | hilo.com/a |    1 | 2015-06-10 00:00:00 |
	| hilo.com/a |    1 | 2015-06-10 00:00:00 | hilo.com/a |    1 | 2015-06-10 00:00:00 |
	| hilo.com/b |    1 | 2015-06-11 00:00:00 | hilo.com/a |    1 | 2015-06-10 00:00:00 |
	| hilo.com   |    1 | 2015-06-09 00:00:00 | hilo.com/b |    1 | 2015-06-11 00:00:00 |
	| hilo.com/a |    1 | 2015-06-10 00:00:00 | hilo.com/b |    1 | 2015-06-11 00:00:00 |
	| hilo.com/b |    1 | 2015-06-11 00:00:00 | hilo.com/b |    1 | 2015-06-11 00:00:00 |
	+------------+------+---------------------+------------+------+---------------------+
	> select a.*,b.* from record a left join record b on a.sid=b.sid and a.time<b.time ;
	+------------+------+---------------------+------------+------+---------------------+
	| url        | sid  | time                | url        | sid  | time                |
	+------------+------+---------------------+------------+------+---------------------+
	| hilo.com   |    1 | 2015-06-09 00:00:00 | hilo.com/a |    1 | 2015-06-10 00:00:00 |
	| hilo.com   |    1 | 2015-06-09 00:00:00 | hilo.com/b |    1 | 2015-06-11 00:00:00 |
	| hilo.com/a |    1 | 2015-06-10 00:00:00 | hilo.com/b |    1 | 2015-06-11 00:00:00 |
	| hilo.com/b |    1 | 2015-06-11 00:00:00 | NULL       | NULL | NULL                |
	+------------+------+---------------------+------------+------+---------------------+
	select a.*,b.* from record a left join record b
		on a.sid=b.sid and a.time<b.time
	where b.time is NULL

if record have two or more `max time`:

	select a.*,b.* from record a left
	join record b
		on a.sid=b.sid and (a.time<b.time or (a.time=b.time and a.id<b.id)  # get row by max(a.id)
	where b.time is NULL

slower(join):

	select record.* from record
	JOIN
	 	(select sid, max(time) as max_time from record group by sid) max_record
	on
		max_record.sid=record.sid and max_record.max_time=record.time;
	+------------+------+---------------------+
	| url        | sid  | time                |
	+------------+------+---------------------+
	| hilo.com/b |    1 | 2015-06-11 00:00:00 |
	+------------+------+---------------------+

# UNION
它与Join 不一样, UNION 查询就是合并查询，

	select_statement1 UNION select_statement2 [UNION select_statement3 [...]]

UNION 要求select 的colume 数一致(用于分表合并)！

	MariaDB [test]> select * from country union select * from city;
	+---------+----------+
	| code    | capital  |
	+---------+----------+
	| China   | 1        |
	| America | 2        |
	| England | 3        |
	| 1       | Beijing  |
	| 2       | Shanghai |
	+---------+----------+

`UNION [ALL | DISTINCT]` 默认是distinct

	MariaDB [test]> select 1,2,3 union select 1,2,3;
	+---+---+---+
	| 1 | 2 | 3 |
	+---+---+---+
	| 1 | 2 | 3 |
	+---+---+---+

	MariaDB [test]> select 1,2,3 union select 1,2,4;
	+---+---+---+
	| 1 | 2 | 3 |
	+---+---+---+
	| 1 | 2 | 3 |
	| 1 | 2 | 4 |
	+---+---+---+

	MariaDB [test]> select 1 union all select 1;
	+---+
	| 1 |
	+---+
	| 1 |
	| 1 |
	+---+

# max

## GREATEST and LEAST
max of multi field

	SELECT GREATEST(field1, field2)
	SELECT GREATEST(max(field1), max(field2))

It will return NULL if one of the fields is NULL. You could use IFNULL to solve this

	SELECT GREATEST(IFNULL(field1, 0), IFNULL(field2, 0))

# Group By
对于聚合函数(clustered function)`count`, `max` 等，要想指定聚合的范围，就需要用`group by` 分组.

	MariaDB [test]> select * from emp;
	+-------+------+--------+
	| name  | dept | salary |
	+-------+------+--------+
	| Jack  | RD   |   3500 |
	| Lily  | PM   |   4000 |
	| Hilo  | RD   |   5000 |
	| Jim   | PM   |   4500 |
	| Peter | PM   |   3100 |
	+-------+------+--------+

	MariaDB [test]> select * from t group by i%2 desc;

使用`group by` 时，非聚合的字段`dept`是不确定的，与`max` 无关

	MariaDB [test]> select  dept,max(salary) from emp group by dept;
	+------+-------------+
	| dept | max(salary) |
	+------+-------------+
	| PM   |        4500 |
	| RD   |        5000 |
	+------+-------------+

## group and where
放在group by 之前：

	where

之后：

	order by
	limit
	having(相当于where)

## sql excute order

SQL is implemented as if a query was executed in the following order:

	FROM clause
	WHERE clause
	GROUP BY clause
	HAVING clause
	SELECT clause
	ORDER BY clause

so it's not valid:

	select colA as colB from table group by colB
	select colB from table group by colA as colB(not supported)

using alias in Group By:

	select * from (select colA as colB from table ) a group by colB

## multi group

	group by primary_col [desc], second_col [asc];

## sum for distinct

	select sum(distinct score),count(*),score from stu; count(distinct) 与 count(*) 相互独立. score 取第一个
	select sum(distinct score),count(distinct score),score from stu;
	select sum(distinct score),count(*) from stu group by class;//按班分

## Group with where
where 作为限定语句，必须在group 分组之前。比如只统计收入小于5000 的：

	MariaDB [test]> select  dept,max(salary) from emp  where salary < 5000 group by dept;
	+------+-------------+
	| dept | max(salary) |
	+------+-------------+
	| PM   |        4500 |
	| RD   |        3500 |
	+------+-------------+

## Group order
order 也必须放在最后：

	$ select id,name2 from city group by name2 order by id desc;
	+----+-------+
	| id | name2 |
	+----+-------+
	| 34 | 23    |
	| 33 | haha  |

## Group filter(having)
分组之后的过滤需要使用`HAVING`, 且限定只能是聚合函数(组为最小单位).

比如过滤出员工数大于2，且平均大于3200 的部门

	MariaDB [test]> select  dept, max(salary),avg(salary) from emp group by dept having avg(salary) > 3200 and count(*) > 2;
	+------+-------------+-------------+
	| dept | max(salary) | avg(salary) |
	+------+-------------+-------------+
	| PM   |        4500 |   3866.6667 |
	+------+-------------+-------------+

## Group order by
Order by 需要放到group by 的后面做最后处理

	[GROUP BY {col_name | expr | position}
      [ASC | DESC], ... [WITH ROLLUP]]
    [HAVING where_condition]
    [ORDER BY {col_name | expr | position}
      [ASC | DESC], ...]

## 与distinct 比较
如果id 是索引的，那么它会在mysql 内部转为`group by`: 见 http://ccvita.com/156.html
以下两条语句是等价的：

	select distinct id from table;
	select id from table group by id;
