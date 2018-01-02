---
layout: page
title:
category: blog
description:
---
# Preface

# Format Convert Time

## select now(),sysdate(),current_date(),sleep(5),now(),sysdate();
- `Current_date()`  will only give you the date.
- `now()` give you the datetime when the statement,procedure etc... started.
- `sysdate()` give you the current datetime.

	select now(),sysdate(),current_date(),sleep(5),now(),sysdate();
	+---------------------+---------------------+----------------+----------+---------------------+---------------------+
	| now()               | sysdate()           | current_date() | sleep(5) | now()               | sysdate()           |
	+---------------------+---------------------+----------------+----------+---------------------+---------------------+
	| 2016-06-23 11:50:44 | 2016-06-23 11:50:44 | 2016-06-23     |        0 | 2016-06-23 11:50:44 | 2016-06-23 11:50:49 |
	+---------------------+---------------------+----------------+----------+---------------------+---------------------+
	select current_date;

## Convert Time

### FROM_UNIXTIME

	mysql> SELECT FROM_UNIXTIME(1447430881);
			-> '2015-11-13 10:08:01'
	mysql> SELECT FROM_UNIXTIME(1447430881) + 0;
			-> 20151113100801
	mysql> SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(),'%Y %D %M %h:%i:%s %x');
			-> '2015 13th November 10:08:01 2015'

	hive> SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(),'YYMMddHHmm');//hive

#### sec_to_time

	select SEC_TO_TIME(103600000)
	| 838:59:59              |

	select TIME_FORMAT(SEC_TO_TIME(3600),'%H:%m');
	| 01:00                                  |

### from datetime(UNIX_TIMESTAMP)

	select UNIX_TIMESTAMP('2013-08-05 18:19:03');
		1375697943

UNIX_TIMESTAMP to datetime:

	> select FROM_UNIXTIME(1369967316);
	+---------------------------+
	| FROM_UNIXTIME(1369967316) |
	+---------------------------+
	| 2013-05-31 10:28:36       |

## Format Time
FROM_UNIXTIME(unix_time, format)
DATE_FORMAT(date_str, format)
TIME_FORMAT(date_str, format)

scanf:
	str_to_date(date_str, format);

### cast as date

	CAST(expr AS type)
		result value of a specified type, similar to CONVERT()
	CONVERT(expr ,type)
		type supported:
			二进制，: BINARY    
			字符型，可带参数 : CHAR()     
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

### as year/month
type 不支持year/month

	select year('2016-03-01 01:01:02') |
	| 2016

	select	month('2016-03-01 01:01:02') |
	| 3

### as year-month

	+---------------------------------------------+
	| DATE_FORMAT('2016-03-01 01:01:02', '%Y/%m') |
	+---------------------------------------------+
	| 2016/03                                     |

### DATE_FORMAT
https://dev.mysql.com/doc/refman/5.5/en/date-and-time-functions.html#function_date-format

	mysql> SELECT DATE_FORMAT('2007-10-04 22:23:00', '%H:%i:%s');
			-> '22:23:00'

The following specifiers may be used in the format string. The “%” character is required before format specifier characters.

	%a	Abbreviated weekday name (Sun..Sat)
	%b	Abbreviated month name (Jan..Dec)
	%c	Month, numeric (0..12)
	%D	Day of the month with English suffix (0th, 1st, 2nd, 3rd, …)
	%d	Day of the month, numeric (00..31)
	%e	Day of the month, numeric (0..31)
	%f	Microseconds (000000..999999)
	%H	Hour (00..23)
	%h	Hour (01..12)
	%I	Hour (01..12)
	%i	Minutes, numeric (00..59)
	%j	Day of year (001..366)
	%k	Hour (0..23)
	%l	Hour (1..12)
	%M	Month name (January..December)
	%m	Month, numeric (00..12)
	%p	AM or PM
	%r	Time, 12-hour (hh:mm:ss followed by AM or PM)
	%S	Seconds (00..59)
	%s	Seconds (00..59)
	%T	Time, 24-hour (hh:mm:ss)
	%U	Week (00..53), where Sunday is the first day of the week; WEEK() mode 0
	%u	Week (00..53), where Monday is the first day of the week; WEEK() mode 1
	%V	Week (01..53), where Sunday is the first day of the week; WEEK() mode 2; used with %X
	%v	Week (01..53), where Monday is the first day of the week; WEEK() mode 3; used with %x
	%W	Weekday name (Sunday..Saturday)
	%w	Day of the week (0=Sunday..6=Saturday)
	%X	Year for the week where Sunday is the first day of the week, numeric, four digits; used with %V
	%x	Year for the week, where Monday is the first day of the week, numeric, four digits; used with %v
	%Y	Year, numeric, four digits
	%y	Year, numeric (two digits)
	%%	A literal “%” character
	%x	x, for any “x” not listed above

#### str_to_date(time mask)
This is the inverse of the `DATE_FORMAT()`

	select STR_TO_DATE('2013 08 05 18:19:03', '%Y %m %d %H:%i:%s');
		2013-08-05 18:19:03

### TIME_FORMAT()

	mysql> SELECT TIME_FORMAT('15:02:28', '%H %i %s');
	Result: '15 02 28'

	mysql> SELECT TIME_FORMAT('15:02:28', '%h:%i:%s %p');
	Result: '03:02:28 PM'

format

	%f	Microseconds (000000 to 999999)
	%f is available starting in MySQL 4.1.1
	%H	Hour (00 to 23 generally, but can be higher)
	%h	Hour (00 to 12)
	%I	Hour (00 to 12)
	%i	Minutes (00 to 59)
	%p	AM or PM
	%r	Time in 12 hour AM or PM format (hh:mm:ss AM/PM)
	%S	Seconds (00 to 59)
	%s	Seconds (00 to 59)
	%T	Time in 24 hour format (hh:mm:ss)


# calc time

## diff time

### TIMESTAMPDIFF

	> SELECT UNIX_TIMESTAMP('2010-11-29 13:16:55') - UNIX_TIMESTAMP('2010-11-29 13:13:55') as output
	180
	> SELECT ABS(UNIX_TIMESTAMP(t.datetime_col1) - UNIX_TIMESTAMP(t.datetime_col2)) as out

better solution:

	SELECT TIMESTAMPDIFF(SECOND, '2010-11-29 13:13:55', '2010-11-29 13:16:55')

### datediff

	mysql> SELECT DATEDIFF('2007-12-31 23:59:59','2007-12-30');
			-> 1
	mysql> SELECT DATEDIFF('2010-11-30 23:59:59','2010-12-31');
			-> -31

### subdate

	select current_date
		2016-03-20

	# tomorrow
	select subdate(current_date, -1)
	select subdate(current_date, 0.25);//6 hours ago
		2016-03-21

## Compare
time format:

	'20140102101213'
	'20140102'
	20140102101213
	'2014-01-01 01:02:03'
	'01:02:03'

Compare time

	select * from table where settime > '2014-01-01 01:02:03' limit 1;
	select * from table where settime > '2014-01-01' limit 1;
	select * from table where settime > 20140102101213 limit 1;
	select * from table where settime > 20140102 limit 1;

### between

	val BETWEEN val1 and val2;
	date BETWEEN date1 and date2;

example

	select 5 between 3 and 6;
		1
	select 3 between 3 and 6;
		1
	select 6 between 3 and 6;
		1
	select 1 between 3 and 6;
		0

# date & time dataType
对于所有日期和时间格式，mysql 支持任何非字母数字作间隔的日期，比如`2010!08!10`

	DATE; //支持20101012 , 2010-8-10等
	TIME; //10:11:12
	DATETIME; //支持2010-01-02 10:11:12, 20100102101112 等
                //不支持20100102 10:11:12

	TIMESTAMP [DEFAULT] [ON UPDATE]; // 2015-10-12 21:52:41

### TIMESTAMP
TIMESTAMP 比较特殊，`默认`的INSERT 或者UPDATE 会触发时间更新为当前的时间(它其实不是时间戳，而是DATA+TIME 字符串):

> 5.6.5 之前，如果有别列显示的指定CURRENT_TIMESTAMP, 而本列默认是0:

	TIMESTAMP;
	TIMESTAMP not null;

设置了default 后，仅当insert 是才更新时间为default 对应的值:

	TIMESTAMP null; //insert 时, 会被更新为NULL
	TIMESTAMP DEFAULT CURRENT_TIMESTAMP; //insert 时, 会被更新为当前的时间
	TIMESTAMP default 20140102101213; //insert 时间会被更新为默认的值"2014-01-02 10:12:13"
	TIMESTAMP default "20140102101213"; //insert 时间会被更新为默认的值"2014-01-02 10:12:13"
	TIMESTAMP default "2014-01-02 10:12:13"; //insert 时间会被更新为默认的值"2014-01-02 10:12:13"

除非增加了on update, update 时将时间更新，insert 时默认时间为0

	d TIMESTAMP default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP;//insert 时默认时间为当前的时间
	d TIMESTAMP on update CURRENT_TIMESTAMP;//insert 时默认时间为0

### YEAR

	YEAR [(2|4)]
		1~69 , as 2001~2069
		"00"~"69", as 2000~2069
		70~99 , as 1970~1999
		"70"~"99" , as 1970~1999
		1901~2155
