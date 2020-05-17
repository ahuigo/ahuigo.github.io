---
title: ruby time
date: 2020-05-17
private: true
---
# ruby time
## get time
    time = Time.new

    time.year    # => 日期的年份
    time.month   # => 日期的月份（1 到 12）
    time.day     # => 一个月中的第几天（1 到 31）
    time.wday    # => 一周中的星期几（0 是星期日）
    time.yday    # => 365：一年中的第几天
    time.hour    # => 23：24 小时制
    time.min     # => 59
    time.sec     # => 59
    time.usec    # => 999999：微秒
    Time.now.to_i #timestamp(s) Integer
        Time.now.to_f #timestamp(s) Float 精确到ms
    time.zone    # => "UTC","CST"：时区名称
        time.utc_offset # => 0：UTC 是相对于 UTC 的 0 秒偏移

to_s:

    time.inspect # 调用的to_s: 2015-09-17 15:23:14 +0800

to_a

    time.to_a
        [sec,min,hour,day,month,year,wday,yday,isdst,zone]
        [39, 25, 15, 17, 9, 2015, 4, 260, false, "CST"]

### format time
和php 是一样的

    time.strftime("%Y-%m-%d %H:%M:%S")

### timzzone 转化
    time.zone       # => "PST"（或其他时区）
    time.isdst      # => false：如果 UTC 没有 DST（夏令时）
    time.utc?       # => true：如果在 UTC 时区
    time.localtime  # 转换为本地时区
    time.gmtime     # 转换回 UTC
    time.getlocal   # 返回本地区中的一个新的 Time 对象
    time.getutc     # 返回 UTC 中的一个新的 Time 对象

## set time
### 按数字setTime
Time.utc、Time.gm 和 Time.local 函数

    Time.local(2008, 7, 8)  
    Time.local(2008, 7, 8, 9, 10)   

    Time.utc(2008, 7, 8, 9, 10)  
    Time.gm(2008, 7, 8, 9, 10, 11)

以上函数都支持

    Time.local(45, 50, 14, 17, 5, 2020, 0, 138, false, "CST")
    Time.local(*Time.new.to_a)


## timedelta
    past = time - 10          # 10 秒之前。Time - number => Time
    diff = time - past      # => 10  Time - Time => 秒数