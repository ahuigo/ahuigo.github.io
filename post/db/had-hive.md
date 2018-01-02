# hive 命令

    hive –e 'select * from test';
    # 查看分布式文件系统目录
    hadoop fs -ls /home/

# high

    hadoop job -set-priority <job-id> <priority>
    hadoop job -set-priority job_201403160138_54485 VERY_HIGH

    query = ""
    query += "SET hive.exec.compress.output=true;"
    query += "SET mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec;"
    query += "
            set mapred.job.name=foobarJob-1239701;
            set mapred.job.priority=VERY_HIGH;
            "
    query += "set hive.exec.dynamic.partition=true;"
    query += "set mapred.output.compress=true;"
    query += "set mapred.compress.map.output=true;"
    query += "set hive.merge.mapredfiles=true;"
    query += "set hive.merge.mapfiles=true;"
    query += "insert overwrite table hourly_clicks
            partition (dated='#{date}', country, hour)
            select * from hourly_clicks where dated='#{date}'"
    query = "hive -e \"#{query}\""

# hive 脚本

    echo "show databases;" > a.hql

方法比较多，就是不能指定database

    hive -f a.hql
    cat a.hql | hive
    hive> source a.hql
    hive -e 'use logsget;...'

# Debug

  Invalid column reference Time
    select 的子句中没有Time
  mismatched input 'Time' expecting ) near 't'
    Time 被当成关键字了。。Group by Time?
  Expression not in GROUP BY key total
    total 不属于group by total
  Invalid table alias or column reference total
    因为子名不存在total
    ref: sql excute order

# TIME
You can design your own format patterns for dates and times from the list of symbols in the following table:

  select from_unixtime(unix_timestamp(ctime), 'YYMMddHHmm')

  Symbol	Meaning	Presentation	Example
  G	era designator	Text	AD
  y	year	Number	2009
  M	month in year	Text & Number	July & 07
  d	day in month	Number	10
  h	hour in am/pm (1-12)	Number	12
  H	hour in day (0-23)	Number	0
  m	minute in hour	Number	30
  s	second in minute	Number	55
  S	millisecond	Number	978
  E	day in week	Text	Tuesday
  D	day in year	Number	189
  F	day of week in month	Number	2 (2nd Wed in July)
  w	week in year	Number	27
  W	week in month	Number	2
  a	am/pm marker	Text	PM
  k	hour in day (1-24)	Number	24
  K	hour in am/pm (0-11)	Number	0
  z	time zone	Text	Pacific Standard Time
  '	escape for text	Delimiter	(none)
  '	single quote	Literal	'

# Optimize

## rank over
Let’s look at an example. Consider a click-stream event table:

	  CREATE TABLE clicks (
	  timestamp date, sessionID string, url string, source_ip string
	  ) STORED as ORC tblproperties ("orc.compress" = "SNAPPY");

Each record represents a click event, and we would like to find the latest URL for each sessionID.

One might consider the following approach:

	  SELECT clicks.* FROM clicks inner
	  join
		(select sessionID, max(timestamp) as max_ts from clicks group by sessionID) latest
	  ON clicks.sessionID = latest.sessionID and
		clicks.timestamp = latest.max_ts;

In the above query, we build a sub-query to collect the timestamp of the latest event in each session, and then use an inner join to filter out the rest.

While the query is a reasonable solution—from a functional point of view—it turns out there’s a better way to re-write this query as follows:

	SELECT * FROM
	(SELECT
	*,
	RANK() over (partition by sessionID, order by timestamp desc) as rank
	FROM clicks) ranked_clicks
	WHERE ranked_clicks.rank=1;

Here we use Hive’s OLAP functionality (OVER and RANK) to achieve the same thing, but without a Join.

	RANK() over (partition by sessionID, order by timestamp desc)

Clearly, removing an unnecessary join will almost always result in better performance, and when using big data this is more important than ever. I find many cases where queries are not optimal — so look carefully at every query and consider if a rewrite can make it better and faster.
