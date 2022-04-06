---
title: Posgtre String
date: 2019-06-20
private:
---
# str Type
### VARCHAR/TEXT/CHAR

    VARCHAR(n)	variable-length with length limit
    CHAR(n)	fixed-length, blank padded
    TEXT/VARCHAR	variable unlimited length(TEXT 就是varchar)

### ENUM

	//如果声明了NOT NULL, 则默认使用第一个
    CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
    CREATE TABLE person (
        name text,
        current_mood mood
    );

### Mysql type
mysql 的类型

	VARCHAR(Length) [BINARY ]
		Length
			The length can be any value from 0 to 65536.
			If Length is 0, Char can only be NULL or ""
			If length is bigger than 255, it will be store as TEXT TYPE
		BINARY
			排序时区分大小写(默认不区分)
    CHARACTER(length)
        CHAR(length)

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


# define string
## 转义
1. 字符串，只能用`'`,`$$`,`$tag$` 为边界，双引号`"`是用于关键字的(e.g. table_name)
2. 单外号会转义

postgre 不支持\ 转义 

    select '\\'; #按字面输出
    select '\''; #error 

单引号转义

	select 'My''S'; --like vim 
		My'S
    select 'a''b' # 不支持 ’a\'b' 

多行：

    select 'a'
    'b';

### 用`$$`不转义

    Syntax: $tag$<string_constant>$tag$

    => select $$select * from  where id='11'$$;
    select * from  where id='11'

    => select $$I'm a string constant that contains a backslash \$$;
    => SELECT $message$I'm a string constant that contains a backslash \$message$;
     I'm a string constant that contains a backslash \

## concat
    select 'a:'||'b'||1.2 as bb;    //"a:b1.2"
    select concat('a:','b', 1.2); // "a:b1.2"
    select concat(key1,key2)

只适用于select :

	select 'My' 'S' 'OL';
		MySQL

concat hex:

	select concat(0x31,2);
	| 12             |

join:

    CONCAT_WS(separator,str_1,str_2,...);

join group:?????

    select string_agg(actor, ', ') AS actor_list
    SELECT movie, string_agg(actor, ', ' ORDER BY actor) AS actor_list FROM   tbl GROUP  BY 1;

## format string

    FORMAT(format_string [, format_arg [, ...] ])

### format syntax

    %[position][flags][width]type

### format type
tppe list:

    %s will format the argument value as a string. NULL could be treated as an empty string.
    %I deal with argument value as an SQL identifier.
    %L refers to the argument value as an SQL literal.
    We frequently use I and L for building dynamic SQL statements

%s type

    SELECT FORMAT('Welcome, %s','EduCBA');
    SELECT FORMAT('%s',stud_lname)  FROM ( select 1 as stud_lname) as f;

`%I`(按需双引号转义，相当于`quote_ident`) 
`%L`(强制单引号转义), `%s` 则不转义

    SELECT FORMAT('select * from %I where age=%L', 'my', 1);
    --------------
    select * from my where age='1'

数字转换可以用`to_char()`

    SELECT to_char(50, '99.99');

### format flags
padding flags

    SELECT FORMAT('|%20s|', 'ten'); -- right
    SELECT FORMAT('|%-20s|', 'ten'); -- left

### format position
position

    SELECT FORMAT('%1$s House, %2$s Villa, %1$s Flat', 'my', 'your');
         my House, your Villa, my Flat

### format as value
    do $$ 
    declare
        first_name varchar(50) := 'John';
        str varchar(100) := format('ahui' 'Im %I', first_name);
    begin 
        raise notice 'Value: %', str;
    end $$;


# str func
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
	select length('中\'); //2

其它

    SELECT length('');   --> 0
    SELECT length(NULL); --> NULL
    SELECT NULL IS NULL; --> TRUE
    SELECT '' IS NULL;   --> FALSE

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

## split string

    # 2是最后一个(不是从0开始)
    SELECT string_to_array('ordno-#-orddt-#-ordamt', '-#-');
    SELECT split_part('par1-#-par2-#-part3', '-#-', 2);
        par2

split array

    > select regexp_split_to_array('a,b,c,d', ',');
    -[ RECORD 1 ]---------+----------
    regexp_split_to_array | {a,b,c,d}
    > select string_to_array('a,b,,c,d', ',,');

help:

    \df+ 'string_to_array'

## contains strpos

    where strpos(name, '@') > 0
    where name ~ '@'

