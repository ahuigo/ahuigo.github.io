---
layout: page
title:
category: blog
description:
---
# Preface

# time

	import time
	time.time()
		19972314124.05238
        time.localetime(time.time())
	time.ctime()
        'Tue Sep 20 15:19:28 2016'

## sleep

	import time
	time.sleep(1)#1s
	time.sleep(random.random())

# datetime

	from datetime import datetime, timedelta

## range time

	base = datetime.datetime.today()
	date_generator = (base - datetime.timedelta(days=i) for i in itertools.count())
	>>> dates = itertools.islice(date_generator, 3)
	>>> list(dates)

pd.date_range():

	import pandas as pd
	datelist = pd.date_range(pd.datetime.today(), periods=100).tolist()

## 获取日期和时间元素
```
	from datetime import datetime
	>>> now = datetime.now() # 获取当前datetime
	>>> print(now)
	2015-05-18 16:28:07.198690
	>>> print(type(now))
	<class 'datetime.datetime'>
```

	d.year
	d.month
	d.weakday() 0~6
	d.day

	d.hour
	d.minute
	d.second
	d.microsecond

	date
		d.date() 2016-08-31
	time
		d.time() 09:41:52.256441
	datetime
		d
	timestamp
		d.timestamp()

### by format

	d=datetime.strptime('2015-6-1 18:19:59', '%Y-%m-%d %H:%M:%S')
	d.strftime('%a, %b %d %H:%M')
	d.strftime('%Y-%m-%d %H:%M')

和shell 一样

	%Y-%m-%d %H:%M:%S

	>>> from datetime import datetime
	>>> datetime.strptime('2015-6-1 18:19:59', '%Y-%m-%d %H:%M:%S')
	2015-06-01 18:19:59
	>>> print(now.strftime('%a, %b %d %H:%M'))
	Mon, May 05 16:28

formater: https://docs.python.org/3/library/datetime.html

    zone:
        %Z  (empty),UTC,EST,CST (time zone name)
        %z  UTC+0000,-0400,+1030,+0800 (time zone offset)
    weekday:
        %a Sun, Mon, ..., Sat (en_US);
        %A Sunday, Monday, ..., Saturday (en_US);
        %w 0,1,...,6(Saturday)
        %U	00,01,....,53 (Sunday as the first day)
        %W	00,01,....,53 (Monday as the first day)
    year:
        %y  00,01,...09
        %Y  0001,0002,....,2016,...
    month:
        %b Jan, Feb, ..., Dec (en_US);
        %B January, February, ..., December (en_US);
        %m  01,...,12
    day:
        %d  01,...,31
        %j  001,...,366
    Hour:
        %H  00,....,23
        %I  01,02,...,12(12 hour)
        %p  AM,PM

    Minute:
        %M  00,...,59
    Second:
        %S  00,...,59
    Microsecond
        %f  000000,...,999999

## set time
### by datetime：

	>>> from datetime import datetime
	>>> dt = datetime(2015, 4, 19, 12, 20) # 用指定日期时间创建datetime
	>>> print(dt)
	2015-04-19 12:20:00

### by timestamp

	timestamp = 0 = 1970-1-1 00:00:00 UTC+0:00
	timestamp = 0 = 1970-1-1 08:00:00 UTC+8:00

	>>> from datetime import datetime
	>>> t = 1429417200.0
	>>> print(datetime.fromtimestamp(t)) # 本地时间
	2015-04-19 12:20:00
	>>> print(datetime.utcfromtimestamp(t)) # UTC时间
	2015-04-19 04:20:00
	>>> datetime.now().timestamp()

## timedelta: datetime加减

    >>> timedelta(days=2, hours=12)
    >>> timedelta(1,3600).__str__()
    '1 day, 1:00:00'
    >>> timedelta(1,3600,2).__str__()
    '1 day, 1:00:00.000002'

使用timedelta你可以很容易地算出前几天和后几天的时刻。

	>>> from datetime import datetime, timedelta
	>>> now = datetime.now()
	>>> now
	datetime.datetime(2015, 5, 18, 16, 57, 3, 540997)
	>>> now + timedelta(hours=10)
	datetime.datetime(2015, 5, 19, 2, 57, 3, 540997)
	>>> now - timedelta(days=1)
	datetime.datetime(2015, 5, 17, 16, 57, 3, 540997)
	>>> now + timedelta(days=2, hours=12)
	datetime.datetime(2015, 5, 21, 4, 57, 3, 540997)

### CST
使用东8区显示：

    datetime.now(tz=timezone(timedelta(hours=8))).strftime('%a %b %d %Y %H:%M:%S GMT%z (CST)')
    'Thu Sep 22 2016 17:50:56 GMT+0800 (CST)'

# timezone

## create timeinfo
一个datetime类型有一个时区属性tzinfo

    from datetime import datetime, timedelta, timezone
    tz_utc_8 = timezone(timedelta(hours=8)) # 创建时区UTC+8:00
    tz_utc_0 = timezone.utc

## keep time
### replece timezone(keep time, change timestamp)
使用replace(tzinfo=tz) 标注时区，timestamp随着tz变化，不会改变字面时间
```
; 默认locale时:没有时区
>>> datetime.fromtimestamp(0).__str__()
'1970-01-01 08:00:00'

; 标注当前时区(字面时间不变)
>>> datetime.fromtimestamp(0).replace(tzinfo=timezone(timedelta(hours=8))).__str__()
'1970-01-01 08:00:00+08:00'
>>> datetime.fromtimestamp(0).replace(tzinfo=timezone(timedelta(hours=8))).timestamp()
0.0

; 标为时区为UTC+0(字面时间不变)
>>> datetime.fromtimestamp(0).replace(tzinfo=timezone.utc).__str__()
'1970-01-01 08:00:00+00:00'
>>> datetime.fromtimestamp(0).replace(tzinfo=timezone.utc).timestamp()
28800.0
```
### datetime(...,tzinfo=), (keep time, change timestamp)
```
>>> datetime(2015, 5, 18, 17, 2, 10, 871012, tzinfo=timezone(timedelta(0, 3600))).__str__()
'2015-05-18 17:02:10.871012+01:00'
```
## keep timestamp, switch timezone
### now(tz=), (change time, keep timestamp)
使用now(tz=tz) 标注时区，不会改变timestamp，字面时间随着tz变化
```
datetime.now(tz=timezone(timedelta(hours=7))).__str__()  # ok: 自动基于utc 时间加时区
```
### d.astimezone(tz)
```
	tokyo_dt = utc_dt.astimezone(timezone(timedelta(hours=9)))
	2015-05-18 18:05:12.377316+09:00
```

### utcnow() is evil!
utcnow()一开始就是错误的timestamp, 不要使用: 它只是单纯的当timestamp 减小了8个小时，时区居然不变！拿到的还是错误的时间!
```
datetime.now().timestamp()-datetime.utcnow().timestamp() = 28800
8:00+UTC8 - 0:00+UTC8
```
除非时区也减小到UTC+0:
```
#并强制设置正确的时区为UTC+0:00:
>>> utc_dt = datetime.utcnow().replace(tzinfo=timezone.utc)
```
# arrow/pendulum（python内带的datetime处理太弱了）

    >>> import arrow
    >>> utc = arrow.utcnow()
    >>> utc
    <Arrow [2013-05-11T21:23:58.970460+00:00]>

    >>> utc = utc.replace(hours=-1)
    >>> utc
    <Arrow [2013-05-11T20:23:58.970460+00:00]>

    >>> local = utc.to('US/Pacific')
    >>> local
    <Arrow [2013-05-11T13:23:58.970460-07:00]>

    >>> arrow.get('2013-05-11T21:23:58.970460+00:00')
    <Arrow [2013-05-11T21:23:58.970460+00:00]>

    >>> local.timestamp
    1368303838

    >>> local.format('YYYY-MM-DD HH:mm:ss ZZ')
    '2013-05-11 13:23:58 -07:00'

    >>> local.humanize()
    'an hour ago'

    >>> local.humanize(locale='ko_kr')
    '1시간 전'
