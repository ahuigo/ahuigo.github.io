---
title: Posgtre String
date: 2019-06-20
private:
---
# define string
1. 字符串，只能用`'` 为边界，双引号`"`是用于关键字的(e.g. table_name)

postgre 不支持\ 转义 

    select '\\'; #按字面输出
    select '\''; #error 

插入单引号

    select 'ahui''s blog'; 
    select 'a''b' # 不支持 ’a\'b' 

# str func
### concat
    select 'a:'||'b'||1.2 as bb;    //"a:b1.2"
    select concat('a:','b', 1.2); // "a:b1.2"
    select concat(key1,key2)
	select 'My' 'S' 'OL'
		MySQL

	select 'My''S';like vim 
		My'S

join:

    CONCAT_WS(separator,str_1,str_2,...);

join group:?????

    select string_agg(actor, ', ') AS actor_list
    SELECT movie, string_agg(actor, ', ' ORDER BY actor) AS actor_list FROM   tbl GROUP  BY 1;


### string length

    CHAR_LENGTH(name)

### str padding

    ahuigo=# select lpad(4444::text, 3, '0'), to_char(4444, '000')
    ahuigo-# ;
    lpad | to_char 
    ------+---------
    444  |  ###

### replace str
    REPLACE(name, 'substring', '')


#### str to hex
hex() and unhex

	mysql> SELECT X'616263', HEX('abc'), UNHEX(HEX('abc'));
			-> 'abc', 616263, 'abc'
	mysql> SELECT HEX(255), CONV(HEX(255),16,10);
			-> 'FF', 255

concat hex as string:

	select concat(0x31,2);
	| 12             |

#### length

	select length('国'); //1
	select length("中\');

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

## String
VARCHAR 本来不会存储尾部空白`\0`，而从5.0.3 开始出于兼容性考虑，会跟CHAR一样存储尾部空白。

	update talbeName set c='str' where id = 1

	"abc\n123"

单引号也会转义

	'a\tb'
	'a\nb'
	'\\d+'; //所以正则应二次转义


# str Type

## VARCHAR

	VARCHAR(Length) [BINARY ]
		Length
			The length can be any value from 0 to 65536.
			If Length is 0, Char can only be NULL or ""
			If length is bigger than 255, it will be store as TEXT TYPE
		BINARY
			排序时区分大小写(默认不区分)

## Other

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

## Limit string set
String set

### ENUM

	//如果声明了NOT NULL, 则默认使用第一个
    CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
    CREATE TABLE person (
        name text,
        current_mood mood
    );
