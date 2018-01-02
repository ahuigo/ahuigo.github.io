---
layout: page
title:	About Date
category: blog
description:
---

# 各世界时间标准
我们经常遇到这4种时间：GMT,UTC,DST,CST。google了一下，在此做个小结.

## 格林威治标准时间GMT
含义：「格林威治标准时间」(Greenwich Mean Time，简称G.M.T.)以伦敦格林威治的子午线为基线，以地球自转为标准，全球都以此标准设定时间。
以下几个时间相同，但用于不同的时区/地区。

	Wed Aug 14 08:21:05 GMT 2013 //标准GMT时间
	Wed Aug 14 16:21:05 GMT+8 2013 //东8区，即我们的北京时间
	Wed Aug 14 03:21:05 GMT-5 2013 //西5区，美国和加拿大时间

## 协调世界时间UTC
由于地球每天的自转是有些不规则的，而且正在缓慢减速，因此格林威治时间已经不再被作为标准时间使用。现在的标准时间，是由原子钟报时的协调世界时（UTC: Coordinated Universal Time）。UTC比GMT更精确严谨。

	Wed Aug 14 08:21:05 UTC 2013 //标准UTC时间
	Wed Aug 14 16:21:05 UTC+8 2013 //东8区，即我们的北京时间
	Wed Aug 14 03:21:05 UTC-5 2013 //西5区，美国和加拿大时间

> 国际原子时的误差为每日数纳秒

> 对我们日常所使用的时间工具而言，UTC和GMT时间没有区别。

## 夏时制DST
[夏时制]DST(Daylight Saving Time)，或称夏令时(Summer Time)是一种为节约能源而人为规定地方时间的制度。一般在天亮早的夏季人为将时间提前一小时，可以使人早起早睡，减少照明量，以充分利用光照资源，从而节约照明用电。

> 全球有110个国家实行夏时制（不包括中国）。

## CST
CST是时区缩写，可以指下列的时区：

1. 澳洲中部时间，Central Standard Time (Australia)
1. 中部标准时区（北美洲），Central Standard Time (North America)
1. 北京时间，China Standard Time
1. 古巴标准时间，Cuba Standard Time，参见北美东部时区

建议不要使用CST时间，对于以下时间，你可能不知道它到底是北京时间，还是其它时间：

	Wed Aug 14 08:21:05 CST 2013 //北京、北美中部、古巴、澳洲中部？Who knows?

# 时间单位
看了下维基[orders_of_magnitude_time]

1. ms = 1/1000 s(milisecond 毫秒)
2. us = 10^-6 s （microsecond微秒）
2. ns = 10^-9s (nanosecond 纳秒)
2. ps = 10^-12s (picosecond 皮秒)
2. fs = 10^-15s (femtosecond 飞秒)
2. as = 10^-18s (attosecond 阿秒)，用于光子研究

## Latency numbers in computer

	L1 cache reference ......................... 0.5 ns
	Branch mispredict ............................ 5 ns
	L2 cache reference ........................... 7 ns
	Mutex lock/unlock ........................... 25 ns
	Main memory reference ...................... 100 ns
	Compress 1K bytes with Zippy ............. 3,000 ns  =   3 µs
	Send 2K bytes over 1 Gbps network ....... 20,000 ns  =  20 µs
	SSD random read ........................ 150,000 ns  = 150 µs
	Read 1 MB sequentially from memory ..... 250,000 ns  = 250 µs
	Round trip within same datacenter ...... 500,000 ns  = 0.5 ms
	Read 1 MB sequentially from SSD* ..... 1,000,000 ns  =   1 ms
	Disk seek ........................... 10,000,000 ns  =  10 ms
	Read 1 MB sequentially from disk .... 20,000,000 ns  =  20 ms
	Send packet CA->Netherlands->CA .... 150,000,000 ns  = 150 ms

# linux date命令
man date可以发现其参数众多。看起来有些乱，归纳一下：

## 时间显示

	date //显示cst时间
	date -u //显示utc时间

### FORMAT

	date +FORMAT //定制时间显示格式
	date '+%Y/%m/%d %H:%M:%S'

	Weekday:
		%a   locale's abbreviated weekday name (e.g., Sun)
		%A   locale's full weekday name (e.g., Sunday)
		%U   week number of year, with Sunday as first day of week (00..53)
		%W   week number of year, with Monday as first day of week (00..53)
		%V   ISO week number, with Monday as first day of week (01..53) //start from Monday strictly!
	Year:
		%Y   year(1970-2038(32bit))
		%y   last two digits of year (00..99)
		%g   last two digits of year of ISO week number (see %G) //date --date '2013-12-29' +%V+%A+%g+%G
		%G   year of ISO week number (see %V); normally useful only with %V //date --date '2013-12-30' +%V+%A+%g+%G
	Month:
		%m   month (01..12)
		%b   locale's abbreviated month name (e.g., Jan)
		%B   locale's full month name (e.g., January)
		%h   same as %b
	Day:
		%d   day of month (e.g., 01)
		%e   day of month, space padded; same as %_d
		%u   day of week (1..7); 1 is Monday
		%w   day of week (0..6); 0 is Sunday
		%j   day of year (001..366)
	Hour:
		%H   hour (00..23)
		%I   hour (01..12)
		%k   hour, space padded ( 0..23); same as %_H
		%l   hour, space padded ( 1..12); same as %_I
		%p   locale's equivalent of either AM or PM; blank if not known
		%P   like %p, but lower case
	Minute:
		%M   minute (00..59)
	Seconds:
		%S   second (00..60)
	Timestamp:
		%s   seconds since 1970-01-01 00:00:00 UTC
	Comlpex:
		Full date&time:
			%c   locale's date and time (e.g., Thu Mar  3 23:05:25 2005)
		Full date:
			%x   locale's date representation (e.g., 12/31/99)
			%D   date; same as %m/%d/%y
			%F   full date; same as %Y-%m-%d
		Full time:
			%X   locale's time representation (e.g., 23:13:48)
			%T   time; same as %H:%M:%S
			%r   locale's 12-hour clock time (e.g., 11:11:04 PM)
			%R   24-hour hour and minute; same as %H:%M

	Century:
		%C   century; like %Y, except omit last two digits (e.g., 20)
	Other:
		%n   a newline
		%N   nanoseconds (000000000..999999999)
		%t   a tab
		%z   +hhmm numeric time zone (e.g., -0400)
		%Z   alphabetic time zone abbreviation (e.g., EDT)

By default，date pads numeric fields with zeroes.
The following optional flags may follow '%':

	-  (hyphen) do not pad the field //date --date='12:03' +%-M  :3
	_  (underscore) pad with spaces //date --date='12:03' +%_M  : 3
	0  (zero) pad with zeros //date --date='12:03' +%0M  :03
	^  use upper case if possible //date --date='12:03' +%^a  :WEDNESDAY
	#  use opposite case if possible //date --date='12:03' +%#a  :wednesday


### 指定显示时间-d

	date --date='@12345' //指定时间戳
	date -d@12345 //指定时间戳
	date -d 'TZ="America/Los_Angeles" 00:00 next Fri'//指定时区和时刻
	date -d '-1 days'//Yesterday
	date -d '2014-01-01 +2 days'

	date  --date="1 days ago"
	date --date="-1 day"

## 设置时间

	$date -s '+10 minutes' //设置时间
	$date -s '2013-08-14 12:50:00' //设置时间(rfc-2822格式)
	$date -s '2013-08-14 12:50:00 +8' //设置时间(rfc-2822格式) 东8区
	$date -s 'Wed Aug 14 14:48:33 CST 2013' //设置时间(美国时间格式)

# mac

    The command:

           date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"
           date "+%m%d%H%M%Y.%S"

    will display:

           DATE: 1987-11-21
           TIME: 13:36:16

## set time
man date:

    date [[[mm]dd]HH]MM[[cc]yy][.ss]]
        .ss seconds

The command:

     date 1432
       sets the time to 2:32 PM
     date 10121432
       sets the time to Oct.12th 2:32 PM
     date 101214322016

# Linux 文件时间

Wikipedia says:

* mtime: time of last modification (ls -l),
	mtime is modification time - contents have changed.
* ctime: time of last status change (ls -lc) and
	ctime is status change time - perms and ownership as well as contents.
* atime: time of last access (ls -lu).

> Also you can  use `stat file` to see file time.
> Note that ctime is not the time of file creation.

1. Writing to a file changes its mtime, ctime, and atime.
2. A change in file permissions or file ownership changes its ctime and atime.
2. Reading a file changes its atime.

File systems mounted with the noatime option do not update the atime on reads, and the relatime option provides for updates only if the previous atime is older than the mtime or ctime. Unlike atime and mtime, ctime cannot be set with utime() (as used e.g. by touch); the only way to set it to an arbitrary value is by changing the system clock.

## stat a.txt
mac 下的结果

	atime mtime ctime mtime
	staff 0 4 "May 19 11:05:19 2016" "May 19 10:33:44 2016" "May 19 10:33:44 2016" "May 19 10:33:44 2016" 4096 8 0 a.txt

# sync time

	/usr/sbin/ntpdate asia.pool.ntp.org >> /var/log/ntpdate.log
	# tencent
	/usr/sbin/ntpdate ntpupdate.tencentyun.com

# 参考
- [夏时制]
- [UTC]
- [orders_of_magnitude_time]

[UTC]: http://zh.wikipedia.org/wiki/%E5%8D%94%E8%AA%BF%E4%B8%96%E7%95%8C%E6%99%82
[国际地球自转服务]: http://zh.wikipedia.org/wiki/%E5%9B%BD%E9%99%85%E5%9C%B0%E7%90%83%E8%87%AA%E8%BD%AC%E6%9C%8D%E5%8A%A1
[夏时制]: http://zh.wikipedia.org/zh/%E5%A4%8F%E6%97%B6%E5%88%B6
[orders_of_magnitude_time]: http://en.wikipedia.org/wiki/Orders_of_magnitude_(time)
