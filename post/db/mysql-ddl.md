---
layout: page
title:	mysql
category: blog
description:
---
# Storage Engines

	mariadb> show engines

mysql 下所有引擎的其表结构保存在`tb_name.frm` 中, 而数据结构在不同的引擎下，保存的文件有所不同。

## Convert Engine
Two method:

	//via alter
	ALTER TABLE tableName ENGINE=MyISAM
	//via convert engine tool
	$ mysql_convert_table_format -uroot --type='MyISAM' dbName [db1 db2 ... ]

## MyISAM Engine
适用于

- 选择密集的表
- 插入密集的表

### 存储
优化技术：

- MyISAM 静态：如所有的表列大小是静态的(不使用xBLOB,xTEXT,VARCHAR), 就自动使用静态格式。占用空间大，但使用性能高
- MyISAM 动态：如某表列是动态的，就自动使用动态格式。这时需要不定期的使用OPTIMIZE TABLE 语句整理表碎片，恢复由于表删除或者更新导致的空间丢失。
- MyISAM 压缩：如果一张表在整个生命周期内是只读的，就可以使用myisampack 将表转换成只读的MyISAM 压缩表。

MyISAM 的数据文件(.MYD)与索引文件(.MYI)是分开的. 而(.log) 是日志文件

## InnoDB Engine
适用于

- 更新密集的表: 特别适合多重并发的更新请求
- 事务
- 自动灾难恢复

### 存储
InnodB 需要更多的内存, 它需要在主内存中建立*缓冲池* 以存放*高速缓冲数据和索引*

InnoDB 数据和索引都在`*.ibd` 中. 这是一个*单表表空间文件*(file per table), 每张InnoDB 表使用一个表空间。(也可以多个表放一个文件)

	mysqld --verbose --help | grep 'innodb-data-home-dir'

InnoDB 可以通过`innodb_data_home_dir` 单独设置data 目录

> MariaDB 与 Percona 使用的是增强版的InnoDB - Percona XtraDB, 其事务处理能力提高到2.7 倍.
MariaDB在性能、功能、管理、NoSQL扩展方面包含了更丰富的特性。比如微秒的支持、线程池、子查询优化、组提交、进度报告

## InnoDB vs MyISAM
Refer [myisam-innodb]

### 事务
与MyISAM 相比，它是事件安全（transaction safe, ACID compliant）型表: 事务(commit)、外部键、回滚(rollback)、崩溃修复能力(crash recovery capacibilities)

### lock
MyISAM 仅运行表级锁：select，update，delete，insert 时自动加表锁，如加锁后满足insert 并发的情况下，可在表发问插入新的数据

InnoDB 支持行级锁：提高了并必的能力。但是行锁只在有*where 主键*时有效，非主键where 会锁全表

### 表主键
MyISAM: 允许没有主键和索引

InnoDB: 如果没有主键，会自动生成一个6字节的主键(用户不可见). 数据是主索引的一部分, 必须要有主索引

### 行数
MyISAM: 表存储了总行数，`select count(*) from table` 直接取值(没有where)

InnoDB: 表没有存储总行数，`select count(*) from table` 会遍历数据表, 资源消耗大.如果有where 二者无差异

### CURD 操作
MyISAM: 适合大量的select, 小量的CUD

MyISAM: 适合大量的Update/Insert, 性能更优秀. 但Delete from table 时，它是一行一行的删除表而不是像MyISAM 那样重新建表. 如果想清空 InnoDB 表, 最好用`truncate table` 命令

## BrightHouse Engine
这是InfoBright 开源的引擎，采用基于知识网格的学习机制

InfoBright最大的特点是列式存储，数据压缩以及基于它独有的知识网格（Knowledge grid）查询优化方式。暂时撇开列存以及压缩不表，本文着重分析知识网格的实现方式，以及它的查询优化器如何进行SQL优化。

http://mp.weixin.qq.com/s?__biz=MjM5MjIxNDA4NA==&mid=203605230&idx=1&sn=aee71beb96c3be9a523862a1eea9c216&scene=4#rd

## MEMORY Engine
It's another name is  HEAP Engine.
场景：

- 小数据，表不能超过max_heap_table_size
- 只支持固定长度的列，VARCHAR/BLOB/TEXT 被会转为固定的长度？
- 临时数据

特点：

1. 支持散列索引和B 树索引. B 树索引更优秀的是：可以使用最左前缀和范围查询(`< > >=`等)

	create table users(
		name varchar(15) not null,
		passwd varchar(15) not null,
		INDEX USING HASH(name),
		INDEX USING BTREE(name)
	)ENGINE=MEMORY;

## MERGE Engine
本质上是`MyISAM` 表的聚合器，分表后这聚合成MERGE 表会使操作非常方便。然后删除MERGE 表而不影响原来的数据。

	create table user1(id int auto_increment primary key, name varchar(20)) ENGINE=MyISAM;
	create table user2(id int auto_increment primary key, name varchar(20)) ENGINE=MyISAM;
	CREATE TABLE IF NOT EXISTS `alluser` (
	   `id` int(11) NOT NULL AUTO_INCREMENT,
	   `name` varchar(20) NOT NULL,
	   index(id)
	 ) TYPE=MER_MyISAM UNION=(user1,user2) INSERT_METHOD=LAST;


## FEDERATED Engine 引用
创建一个对远程表的引用，然后就可以像使用本地表一样使用远程的表了

	create table product(
		name varchar(13) not null
	)ENGINE=FEDERATED CONNECTION='mysql://username:passwd@ip/dbName/tableName'

> 需要在编译时通过--with-federated-storage-engine 开启

## ARCHIVE Engine
场景：

- 需要长久的保存数据的地方，像银行医院
- 不允许删除和更新数据(其实可以用MyISAM 压缩代替)
- 不支持索引（除非转换成MyISAM 等其它引擎）

## CSV
这只是一个存放数据的文本格式，不支持索引

## EXAMPLE Engine
这是一个创建引擎的模板，供研究引擎的开发者练习

# Operation

## database

	//create
	> CREATE DATABASE dbName;
	$ mysqladmin create dbName;

	//drop
	> DROP DATABASE dbName;
	$ mysqladmin DROP dbName;

There is no `rename` for database special, but you could rename database via table

	//For innoDB
	RENAME TABLE old_db.table TO new_db.table;
	//or
	mysqladmin create new_db;
	mysqldump old_db | mysql -D new_db

Here is a `renameInnoDB` shell:

	for tb in mysql -uroot -e "show tables from $old_db"; do
		mysql -uroot -e "rename table $old_db.$tb $new_db.$tb";
	done;

## TABLE

	> show tables from db;

### Create

	CREATE TABLE [IF NOT EXISTS] `TTT_DATAALLOWANCE` (
	  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	  `uid` char(15) NOT NULL,
	  `status` tinyint(2) DEFAULT NULL,
	  `number` char(15) NOT NULL,
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `uid` (`uid`),
	  KEY `number` (`number`)
	) ENGINE=MyISAM DEFAULT CHARSET=utf8

#### Copy Table
Copy table struct only:

	create table tb_name like tb_other;

Copy table struct and data;

	create table tb_name select * from tb_other;
	create table tb_name select col1,col2 from tb_other;

#### Create Temporary Table

	"like copy table, except that it's data is stored in temp dir `/usr/tmp/` or `/var/tmp` or `/tmp`
	CREATE TEMPORARY TABLE tb_name select col1 from tb_other limit 10;

可以通过`mysql -t <tmpdir>` 指定tmpdir. 否则会默认查看： `$TMPDIR, $TEMP, $TMP`

	"linux
	/usr/tmp /var/tmp /tmp
	"mac OSX
	/var/folders/73/7vxr7kzs09ndh3kwzw9zpdj80000gn/T/

### union table 分表联合

	CREATE TABLE `union_tb` (
		`uid` char(10) NOT NULL,
		`create_time` int(10) unsigned NOT NULL,
		INDEX(uid)
	) TYPE=MERGE UNION=(union_tb1,union_tb2,union_tb3,.......) INSERT_METHOD=LAST

将分表合为一张表，方便分表查询

### rename TABLE

	rename TABLE tb1 to tb2 , tb3 to tb4, ...
	rename TABLE db.tb1 to new_db.tb2

### drop TABLE if exists
DROP TABLE table;
DROP TABLE IF EXISTS `tablename`

### View Table

	> describe <table>
	> show columns from <table>
	> show create table <table>
	shell> mysqlshow <db> <table>

## Column

### Alter(add/drop column)
modify change add

	alter table tabelname ...
	ALTER TABLE table_name DROP Column
	ALTER TABLE table_name ADD KEY `provice` (`province`)
	ALTER TABLE table_name ADD KEY (`province`)
	ALTER TABLE table_name drop `provice`

You should remove the autoincrement property before dropping the key:

	ALTER TABLE table_name MODIFY id INT NOT NULL;
	ALTER TABLE table_name DROP PRIMARY KEY;

### alter change(update column)

	alter table t1 change a b tinyint(1) not null;

# data

## Variable
mysql 变量不区分大小写

	"set variable
	set @sum = 10,@i = 1;
	select id into @sum from table;

全局变量需要加前缀 `@`, 比如`@sum`
局部变量则不需要加前缀

Read `system variable` with `@@`:

	set autocommit=0;
	select @@AUTOCOMMIT;

### add

	set @i=0;
	SELECT (@i:=@i+1) AS rowNumber,id from t1;

# INFORMATION_SCHEMA
mysql 的show 的不足：

1. 不是标准数据库特性
2. 它功能不强大：虽然能查看库、表、表列信息，以及用户权限、支持的引擎、正在执行的进程信息；但是它不能了解表的引擎类型，表列类型

INFORMATION_SCHEMA 则得到的SQL 标准的支持，支持查看更详细的服务器配置，它有28张表：

	CHARACTER_SETS
		可用字符集
	COLLATIONS
		字符集校正信息
	COLLATION_CHARACTER_SET_APPLICABILITY
		COLLATIONS 的子集，为字符集匹配各个校正
	ENGINES
	EVENTS
		存储调度事件信息
	FILES
		存储NDB 磁盘数据表信息
	GLOBAL_STATUS
		存储服务器状态变量信息
	GLOBAL_VARIABLES
		存储服务器设置的有关信息
	KEY_COLUMN_USAGE
		存储键列约束的有关信息
	PARTITIONS
		存储分区表
	PLUGINS
		插件
	PROFILING
		查询概况 show profile, show profiles
	PROCESSLIST
		运行线程有关信息
	REFERENTIAL_CONSTRAINTS
		外键有关信息
	ROUTINES
		存储过程和函数信息
	SCHEMATA
		数据库有关信息，如库名和有关字符集
	SCHEMA_PRIVILEGES
		存储数据库有关权限信息
	SESSION_STATUS
		会话状态
	SESSION_VARIABLES
		会话配置
	STATISTICS
		各个表索引有关信息，如列名、是否NULL,是否唯一
	TABLES
	TABLE_CONSTRAINTS
		表约束信息
	TABLE_PRIVILEGES
		表权限信息（其实是从mysql.tables_priv 表获取的）
	COLLUMNS
		表列
	COLLUMNS_PRIVILEGES
		表列权限（其实是从mysql.columns_priv 表获取的）
	USER_PRIVILEGES
		全局权限
	TRIGGERS
		触发器信息
	VIEWS
		视图信息

# Function

## String Func
http://dev.mysql.com/doc/refman/5.5/en/string-functions.html#function_format

# Stored Routine 存储例程
可理解为sql 语句组成的脚本: 与用应用程序一次执行多条sql语句相比，降低了应用程序的复杂度、提高sql的安全低、方便DBA 为mysql 做调试与优化。

1. 高性能: 因为mysql 批量执行sql 操作(减少sql请求的网络消耗，降低应用程序的复杂性), 方便DBA 做优化. 这不是绝对的：这也可能增加mysql 内存/CPU 的消耗。
2. 一致性：将数据库相关的逻辑从不同的应用程序中解耦出来，交给Routine 完成
3. 安全性：使用Routine 可更好的确保开发人员只访问必要的数据信息. 但是安全性，也牺牲了开发人员的灵活性。
4. 架构：方便架构。但可维护性（很多IDE很难支持例程调试）与可移植性(例程的语法特殊)会降低

Stored Routine 分为stored procedure 和 stored function ，即存储过程和存储函数

*CREATE*

	CREATE
		[DEFINER = { user | CURRENT_USER }]
		PROCEDURE sp_name ([proc_parameter[,...]])
		[characteristic ...] routine_body

	CREATE
		[DEFINER = { user | CURRENT_USER }]
		FUNCTION sp_name ([func_parameter[,...]])
		RETURNS type
		[characteristic ...] routine_body

	proc_parameter:
		[ IN | OUT | INOUT ] param_name type

	func_parameter:
		param_name type

	type:
		Any valid MySQL data type

	characteristic:
		COMMENT 'string'
	  | LANGUAGE SQL
	  | [NOT] DETERMINISTIC
	  | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
	  | SQL SECURITY { DEFINER | INVOKER }

	routine_body:
		Valid SQL routine statement

*DROP*

	DROP {PROCEDURE | FUNCTION} [IF EXISTS] sp_name
	DROP PROCEDURE [IF EXISTS] sp_name

## Create Stored Routine 创建存储例程
因为存储过程和存储函数语法不一样，所以二者可以同名！它们的区别是返回值的形式不同

### create stored procedure

*存储过程*

	CREATE PROCEDURE get_num()
		select 45 as num;
		select 5 as age;

	CALL get_num();
	+-----+
	| num |
	+-----+
	|  45 |

*存储过程*可以接受输入参数，并且可将输入参数再返回给调用方。需要回传的参数需要在前面加`@`(表示这是一个变量,且是按引用传值?)

	IN	向过程传递信息
	OUT	从过程传回信息
	INOUT	双向传递信息

	CREATE PROCEDURE get_num(IN i int, OUT count int)
		select i+1 INTO count;//存储过程内部的变量,以及参数变量，不需要加前缀@
	CALL get_num(5, @sum);
	select @sum;//6

### create stored function
*存储函数* 不支持OUT 返回值，但支持return

If you enabled `bin-log` for replication (This is by default), there are some Conditions of stored function:[](http://dev.mysql.com/doc/refman/5.0/en/stored-programs-logging.html)

1. To create or alter a stored function, you must have the *super* privilege!
2. To create function, you must declare either that it is deterministic or that it does not modify data. Otherwise, it may be unsafe for data recovery or replication.
3. At least one of DETERMINISTIC, NO SQL, or READS SQL DATA must be specified explicitly. Otherwise an error occurs: `ERROR 1418 (HY000): This function has...`.

Also, you could ignore the safety problem in replication, you could set `SET GLOBAL log_bin_trust_function_creators = 1;` to  relax the preceding conditions on function creation.

	delimiter //
	create function gsum(i int, j int)
	RETURNS int
	BEGIN
		DECLARE s int;
		set s=i+j;
		RETURN s;
	END; //
	delimiter ;
	select gsum(1,3);

> 创建存储例程时，语句很长会难以调试，建议将语句写到文件中，然后再执行`mysql db_name < test.sql`

### safety
存储例程要求只能是 和DEFINER 定义的user 相匹配的用户 或者SUPER(root) 用户可以使用存储过程. 默认的user 是定义时的：CURRENT_USER

	CREATE PROCEDURE DEFINER='hilojack'@'localhost' get_num()
		select 45 as num;

### CHARACTERISTIC 特点

	characteristic:
		COMMENT 'string'		"描述信息
	  | LANGUAGE SQL			"SQL 是存储例程唯一支持的语言，将来可能支持perl/python/php
	  | [NOT] DETERMINISTIC		"有助于存储函数的优化，带此标识的函数只要每次的参数不变，都返回不变的值(但可以执行update/insert)
	  							"而NOT 则可返回变化的值. 默认的是 NOT DETERMINISTIC.
								"声明的是 DETERMINISTIC, 而产生的是nondeterministic 也不会报错，mysql 不会检查, 这需要人为保证
	  | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }	"指示存储过程将完成的任务类型，默认值CONTAINS SQL 指示会出现SQL但不会读写数据，NO SQL 指示无SQL，READS 指示只能读数据，MODIFIES 指示SQL 可以读写
	  | SQL SECURITY { DEFINER | INVOKER }	"默认DEFINER 根据定义过程的*定义者*的权限执行此过程，INVOKER 则根据调用过程用户的权限执行

## BEGIN-END 语句块
这是一个作用域，可为此作用域设定局部变量.
在`BEGIN` 和 `END` 之间, 子语句间以`;` 分割

	delimiter //
	CREATE PROCEDURE get(inout j int)
		BEGIN
			select j as j;
			DECLARE i int;
			set i=100;
			select i+10;
		END;
	//

> 一般用于空语句、多行存储例程。按照规则，多行语句的存储例程，其边界分割符必须设置为其它值, 比如`delimiter //`

## alter stored routine
目前mysql只能修改例程的特点：

	ALTER (FUNCTION | PROCEDURE) spname [characteristic ...]

或者删除再建：

	DROP (FUNCTION | PROCEDURE) spname [characteristic ...]

## show stored routine
show routines: show function, show procedure

	SHOW (PROCEDURE | FUNCTION) STATUS [LIKE 'pattern' | WHERE expr];
	SHOW (PROCEDURE | FUNCTION) STATUS like 'get_%';

show create routine

	SHOW CREATE (PROCEDURE | FUNCTION) dbname.spname;

## Condition Expression

### IF

	IF condition THEN
		statement list;//不像例程语句体，它即不需要BEGIN/END 也不需要 其它的delimiter
	ELSEIF condition THEN
		statement list;
	ELSE
		statement list;//an empty statement_list is not permitted.
		BEGIN
		END;
	END IF;

###	CASE
REFER to : help case statement

	CASE
		WHEN id=0 THEN statement_list;
		WHEN 3 THEN statement_list;
		[ELSE statement_list;]//如果所有条件都不匹配，而且又没有else, 就会报语法错误。所以，务必带上ELSE
	END CASE;

另外一种常见的:

	CASE v
		WHEN 0 THEN statement_list;
		WHEN 3 THEN statement_list;
		[ELSE statement_list;]//如果所有条件都不匹配，而且又没有else, 就会报语法错误。所以，务必带上ELSE
	END CASE;

还有一种`help case operator`:

	CASE value
		WHEN [compare_value] THEN result
		[WHEN [compare_value] THEN result ...]
		[ELSE result] END

	CASE WHEN [condition] THEN result [WHEN [condition] THEN result ...]
	[ELSE result] END

## Loop Expression

### ITERATE
相当于goto, 通常用于continue

	calcloop: LOOP
		do sth....
		IF condition then
			ITERATE calcloop; //相当于continue
		ELSE
			LEAVE calcloop;//跳出LOOP, 或者BEGIN/END
		END IF;
	END LOOP;

###	LOOP
这是一个死循环：

	[begin_label:] LOOP
		select 1;
	END LOOP [end_label];

通过定界字符，模拟给LOOP 传参数(LOOP 本身没有参数支持)

### WHILE

	[begin_label:] WHILE search_condition DO
		statement_list
	END WHILE [end_label]

### REPEAT
与DO...WHILE 相似

	[begin_label:] REPEAT
		statement_list
	UNTIL search_condition
	END REPEAT [end_label]

## Variable in Routine
存储过程中的变量需要先声明再使用。它只是一个在`BEGIN` 和 `END` 之间的局部变量, 不需要加前缀`@`

	"define variable
	DECLARE total DECIMAL(9,2) default 10;
	"set variable
	set total = 10,i = 1;
	select id into total from table;

## 条件处理
to read:
http://dev.mysql.com/doc/refman/5.0/en/declare-handler.html
http://dev.mysql.com/doc/refman/5.6/en/declare-condition.html

	DECLARE handler_action HANDLER
		FOR condition_value [, condition_value] ...
		statement

	handler_action:
		CONTINUE
	  | EXIT
	  | UNDO

	condition_value:
		mysql_error_code
	  | SQLSTATE [VALUE] sqlstate_value
	  | condition_name
	  | SQLWARNING
	  | NOT FOUND
	  | SQLEXCEPTION

# debug
语句很长会难以调试(比如存储例程)，建议将语句写到文件中，然后再执行`mysql db_name < batch-file`
或者执行：

	mysql > source batch-file;
	mysql > \. batch-file

> 注意后者没有分号

## declare
注意，所有的执行语句都必须放在`declare` 声明之后，否则会报错

## keyword
不要使用end select desc asc if

# Trigger 触发器
在某种事件(插入，删除等)发生前后(before trigger and after trigger)，触发某一任务的执行.
它的场景是：

1. 审计跟踪
2. 验证
3. 强制引用完整性: 关系表数据间的完整约束

触发器有些局限：

1. 不支持TEMPORARY 表
1. 当前更新的表不同等于 Trigger 更改的表
1. 不支持视图
1. 无法从触发器返回结果集，但是可以调用存储例程(不返回结果，但可以做SET)
4. 触发器必须唯一：不可以针对同一个表、事件创建多个 trigger
5. 错误处理和报告支持很弱：没有恰当的方法在trigger 失败时向用户返回有用信息。

## Create Trigger

	CREATE
		[DEFINER = { user | CURRENT_USER }]
		TRIGGER trigger_name
		trigger_time trigger_event
		ON [db_name.]tbl_name FOR EACH ROW
		trigger_body

	trigger_time: { BEFORE | AFTER }
	trigger_event: { INSERT | UPDATE | DELETE }

EXAMPLE:

	delimiter //
	CREATE trigger bu_get
	before update on test.ahui
	for each row
	BEGIN
	if NEW.d>20140101020304 then
		update ahui set i='8' where id=10 limit 1;
	end if;
	end; //
	delimiter ;

其中：

	NEW 表示更新的NEW ROW
	OLD 表示更新的OLD ROW
	bu 约定为before update (只是约定啦)

## Show Triggers
List triggers via command:

	"list triggers
	SHOW TRIGGERS [FROM db_name] [LIKE expr | WHERE expr]
	"show create trigger
	SHOW CREATE TRIGGER dbname.trigger_name;

### Trigger in INFORMATION_SCHEMA

	select * from INFORMATION_SCHEMA.triggers \G

## alter trigger
没有alter trigger!

## drop strgger

	DROP TRIGGER [IF EXISTS] [schema_name.]trigger_name

删除数据库（schema_name）或者表(table_name)，相应的trigger 也会被删除

# View
视图View 用于将单表或者多张表抽象为一张更简单的虚表: 简化多表查询的操作; 隐藏不需要的或者敏感的字段
更新视图数据时，View背后的表也会被更新

## Create View

	CREATE
		[OR REPLACE]
		[ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
		[DEFINER = { user | CURRENT_USER }]
		[SQL SECURITY { DEFINER | INVOKER }]
		VIEW view_name [(column_list)]
		AS select_statement
		[WITH [CASCADED | LOCAL] CHECK OPTION]

Example:

	create view t_view as
		select s1,s2,t1.id from t1,t2 where t1.id=t2.id order by s2;

	create view t_view_alias (seg1, seg2, id) as
		select s1,s2,t1.id from t1,t2 where t1.id=t2.id order by s2;

## View Algorithm

### Algorithm Merge
执行视图时*语句将被合并*到视图查询定义中：

	create t_view as select * from t order by name;

执行`select name from t_view`时,实行执行的会是

	select name from t order by name;

### Algorithm TEMPTABLE
对Merge 算法的View 而言，如低层表有变化，View 会立即反映出来。 但是如果数据比较大，可考虑将View 作为一个临时表(TEMPTABLE), 从而更快的释放表锁。
这种情况下，View 数据可能会比较旧，需要考虑一下更新策略。

### Algorithm UNDEFINED
这是默认的值，View 视图会：

1. 使用TEMPTABLE: 查询聚集函数(SUM)；当查询结果与视图结果是一对一关系时
2. 通常使用MERGE: 效率更高

### WITH CHECK OPTION
因为可以根据其它视图创建视图，所以必须有一种方法确保更新内嵌视图时不违反定义

比如:

	create e_age_view as
		select * from e_view where age >20
		With LOCAL CHECK OPTION;
	create e_view as
		select * from e where salary>5;

当执行以下语句会违反内嵌视图`e_view` 对salary 的限制`salary>5`：

	insert into e_age_view(age, salary) values(21,3);

- 默认不检查规则
- `LOCAL CHECK OPTION` 只会检查本视图是否违反规则
- `CASCADED CHECK OPTION` 会检查本视图和内嵌视图是否违反规则.

## DROP VIEW

	DROP VIEW [IF EXISTS]
		view_name [, view_name] ...
		[RESTRICT | CASCADE]

## Alter View
Replace `Create View` with `Alter View`

## Use View

	select * from t_view order by s1 desc;//覆盖默认的s2 排序

## 更新视图
对视图的更新会直接作用于低层的视图和表，但是当视图牌如下任何条件时，视图就不可以被更新(因为update/insert 不可与以下任何条件合并)：

1. 包含聚焦函数,如SUM()
2. 当算法为TEMPTABLE
2. 包含DISTINCT, GROUP BY, HAVING, UNION, 或者UNION ALL.
4. 包含外联(outer jion)
5. from 子句包含不可更新的视图
5. 在select/from 子句中包含子查询，以及引用from 子句中的表的where 子句包含子查询
6. 只引用直接量值(常量)

## Show View
There is no `show view`, but `show create view `:

	show create view view_name;

via `information_schema.views`:

	select * from INFORMATION_SCHEMA.views\G

# Transaction 事务
Transaction 具备ACID特点：

1. 原子性(Atomicity)：
	事务内的操作序列不受其它进程或者线程干扰. 也就是操作不可分割
2. 一致性(Consistency):
	要么所有的操作都成功(commit)，要么所有的操作都失败(rollback), 不会出现数据不一致的情况
3. 隔离性(Isolation):
	未完成的操作序列必须与系统隔离，直到事务完成(commit)为止。又称独立性
3. 持久性(Durability):
	所有提交的数据都应该以某种方式保存，系统一旦出现故障后可以成功恢复

> 数据一致性在分布式系统中是指多个节点的数据相同。强一致指任何时间数据都要相同，弱一致指数据经过一段时间后，数据可以达到最终一致性（比如DNS分布缓存系统）。Refer to : http://www.zhihu.com/question/20113030

支持事务的引擎有：InnoDB 和 BOB, 事务的特点：

1. 事务无法嵌套
2. 事务不可回滚数据定义语句(DDL), 即创建删除数据库，创建修改表语句
3. 事务不可回滚非事务表, ROLLBACK 会产生错误
4. 需要经常创建InnoDB 数据(可用mysqldump)和 日志的快照(备份二进制文件)

## Start Transaction
`Autocommit 0`表示关闭事务的自动提交，`begin` 是*临时*关闭事务的自动提交:

	mysql> start Transaction	#事务结束时，不会开新的事务
								#等价于begin，但是不推荐begin 因为begin 主要用于code block
	mysql> AUTOCOMMIT 0			#事务结束，开启新的事务

`AUTOCOMMIT 1` 表示每个命令都自动提交, 相当于关闭事务. 可以用以下命令查询：

	select @@AUTOCOMMIT
	select @@autocommit

> 注意`start transaction` 与 `begin` 不会修改`autocommit` 变量. 但是它们的作用是`临时性的禁用了autocommit`.

## Excute Transaction
在`commit` `rollback` 之前，任务数据修改都不会生效.

	mysql> COMMIT
	mysql> ROLLBACK

# comment

	mysql> SELECT 1+1;     # This comment continues to the end of line
	mysql> SELECT 1+1;     -- This comment continues to the end of line
	mysql> SELECT 1 /* this is an in-line comment */ + 1;

# Reference
- [myisam-innodb]

[myisam-innodb]: http://www.biaodianfu.com/mysql-myisam-innodb.html
