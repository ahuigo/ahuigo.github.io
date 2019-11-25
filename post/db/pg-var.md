---
layout: page
title: pg-datatype
category: blog
description: 
date: 2018-09-27
private:
---
# Data Type(数据类型)

	NULL means you do not have to provide a value for the field... default to null
	NOT NULL means you must provide a value for the fields. 但很多情况下，插入数据时默认会给一个空值(0, 或者空字符串).

## 不要用null
Null 列的缺点:

- 难以优化索引：Mysql难以优化引用可空列查询，它会使索引、索引统计和值更加复杂。
- 更多的空间：可空列需要更多的存储空间，还需要mysql内部进行特殊处理。
> NULL columns require additional space in the rowto record whether their values are NULL. For MyISAM tables, each NULL columntakes one bit extra, rounded up to the nearest byte.”

## Type Convert

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

## Number

	2e30
	2+3*3
	10%3

What the exactly number if value over range?

> If number is above the range, the value mysql store will be the max value.
> If number is below the range, the value mysql store will be the min value.

What does the number in parenthesis mean?

> int(2) will generate an INT with minimum display width of 2. It's up to mysql client.
In most clients, if a colume specified with `INT(2) ZEROFILL`, the number 6 will be displayed as '06'.
> `DECIMAL(M,D)、FLOAT(M,D)、DOUBLE(M,D)` M是显示长度，D是可存的小数位数

### function

	FLOOR(RAND() * 401) + 100

### pg number
decimal 与numeric  是一样的

    smallint	2 bytes	small-range integer	-32768 to +32767
    integer	4 bytes	typical choice for integer	-2147483648 to +2147483647
    bigint	8 bytes	large-range integer	-9223372036854775808 to 9223372036854775807
    decimal	variable	user-specified precision, exact	up to 131072 digits before the decimal point; up to 16383 digits after the decimal point
    numeric	variable	user-specified precision, exact	up to 131072 digits before the decimal point; up to 16383 digits after the decimal point
    real	4 bytes	variable-precision, inexact	6 decimal digits precision
    double precision	8 bytes	variable-precision, inexact	15 decimal digits precision
    serial	4 bytes	autoincrementing integer	1 to 2147483647
    bigserial	8 bytes	large autoincrementing integer	1 to 9223372036854775807

### mysql INT

	### TINYINT
	Their signed value range is (-128,127) , and unsigned range (0,255)。

	#### BOOL & BOOLEAN
	They are TINYINT(1) alias

	### SMALLINT [(M)] [UNSIGNED] [ZEROFILL]
	Their unsigned range is (0,2^16-1)。

	### MEDIUMINT [(M)] [UNSIGNED] [ZEROFILL]
	Their unsigned range is (0,2^24-1)。

	### INT [(M)] [UNSIGNED] [ZEROFILL]
	Their unsigned range is (0,2^32-1)。

	### BIGINT [(M)] [UNSIGNED] [ZEROFILL]
	Their unsigned range is (0,2^64-1)。

for postgre:

    Oracle	NUMBER(3,0), -103-1 to 103-1
    MySQL	TINYINT, Signed: -128 to 127, Unsigned: 0 to 255
    PostgreSQL	SMALLINT, -32768 to 32767

### Float

#### DECIMAL ([M,D]) [UNSIGNED] [ZEROFILL]
以字符串存储浮点数。

	DECIMAL(4,1);//只能存储4位字符，小数部分1位(不含小数点和负号). 即-999.9~ 999.9 或 0.0 ~ 999.9
	DECIMAL; //Same as DECIMAL(10,0)

####  FLOAT([M,D]) [UNSIGNED] [ZEROFILL]

	FLOAT(4,1);//Same as DECIMAL(4,1). Storage as string

	FLOAT;
		//参照c 语言的IEEE 754 double 32位存储 signed: +/- 10^38, unsigned: 0~10^38

####  DOUBLE([M,D]) [UNSIGNED] [ZEROFILL]

	DOUBLE(4,1);//Same as DECIMAL(4,1). Storage as string

	DOUBLE;
		//参照c 语言的IEEE 754 double 64位存储 signed: +/- 10^308, unsigned: 0~10^308

## String
VARCHAR 本来不会存储尾部空白`\0`，而从5.0.3 开始出于兼容性考虑，会跟CHAR一样存储尾部空白。

	update talbeName set c='str' where id = 1

	"abc\n123"

单引号也会转义

	'a\tb'
	'a\nb'
	'\\d+'; //所以正则应二次转义

### str padding

    ahuigo=# select lpad(4444::text, 3, '0'), to_char(4444, '000')
    ahuigo-# ;
    lpad | to_char 
    ------+---------
    444  |  ###

### Function
> https://dev.mysql.com/doc/refman/5.0/en/string-functions.html

	SELECT CONCAT('My', 'S', 'QL');
	select 'My' 'S' 'OL'
		MySQL
	select 'My''S';like vim
		My'S

#### str to hex
hex() and unhex

	mysql> SELECT X'616263', HEX('abc'), UNHEX(HEX('abc'));
			-> 'abc', 616263, 'abc'
	mysql> SELECT HEX(255), CONV(HEX(255),16,10);
			-> 'FF', 255

concat:

	select concat(0x31,2);
	| 12             |

#### length

	select length('国'); //1
	select length("中\');

### CHAR
Length 不是字节数，而是字符数

	CHAR(Length) [BINARY | ASCII | UNICODE ]

		Length
			The length can be any value from 0 to 255.
			If Length is 0, Char can only be NULL or ""
			If length is bigger than 255, it will be store as TEXT TYPE
		BINARY
			排序时区分大小写(默认不区分)
		ASCII
			使用Latin1 这种万能字符集(默认?)
		UNICODE
			使用ucs2 字符集(又字节?)

### VARCHAR

	VARCHAR(Length) [BINARY ]
		Length
			The length can be any value from 0 to 65536.
			If Length is 0, Char can only be NULL or ""
			If length is bigger than 255, it will be store as TEXT TYPE
		BINARY
			排序时区分大小写(默认不区分)

### Other

	LONGBLOB
		支持2^32-1个字符, 最大的二进制存储
	LONGTEXT
		支持2^32-1个字符, 最大的文本存储(不能存储\0)
	MEDIUMBLOB/MEDIUMTEXT
		2^24-1
	BLOB/TEXT
		2^16-1 = 65535
	TINYBLOB/TINYTEXT
		2^8-1 = 255

### Limit string set
String set

#### ENUM

	ENUM("str1",...., "str65535")
	//如果声明了NOT NULL, 则默认第一个，否则默认NULL

#### SET
SET 可以指定预定值中的一个或者多个值


	set("str1","str2", ....)
	insert table values('str1,str2,..')

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

## NATIONAL
该列使用默认字符集，兼容考虑
It can only be used to CHAR/STRING.


# variable
mysql 变量不区分大小写

	"set variable
	set @sum = 10,@i = 1;
	select id into @sum from table;

全局变量需要加前缀 `@`, 比如`@sum`
局部变量则不需要加前缀

Read `system variable` with `@@`:

	set autocommit=0;
	select @@AUTOCOMMIT;

## add

	set @i=0;// set @i:=0; //The := operator is never interpreted as a comparison operator
	SELECT (@i:=@i+1) AS rowNumber,id from t1;

## if

	select if(9<=7, '1-7', if(9=8, 8, 9));

## math

	select 1-3*2 as calc into @sum;//在存储例程中变量不需要加@
	select * from table where id in (3,4) or [name] in ('andy','paul');