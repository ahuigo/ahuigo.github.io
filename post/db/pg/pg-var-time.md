---
title: Postgre Time
date: 2019-10-03
private:
---

# Postgre Time

## Compare Time

    select time > '20101013'
    time > '2010-10-13'
    time > '2010-10-13 10:00:00'
    time > '2010-10-13 10:00:00+08'
    time > '20101013 10:00:00+08'

## Time Type

    SELECT typname, typlen FROM pg_type WHERE typname ~ '^date';
    date 
        '2016-06-22',
    time
        '19:10:25',
    timestamp  //datetime, default CURRENT_TIMESTAMP
        '2016-06-22 19:10:25',
    timestamptz
        '2016-06-22 19:10:25-07',

### timestamp with timezone

    SET timezone = 'America/New_York';
    SHOW TIMEZONE;

switch timezone

    > SELECT timezone('America/New_York','2016-06-01 00:00');
    2016-06-01 03:00:00
    # 上面的例子，PostgreSQL casts string to timestamptz implicitly
    > SELECT timezone('America/New_York','2016-06-01 00:00'::timestamptz);

### timestamp without timezone

timestamp to date:'2018-07-25 10:30:30' to '2018-07-25', 3种方法

    SELECT DATE(column_name) FROM table_name;
    SELECT column_name::DATE;
        SELECT '2018-07-25 10:30:30'::TIMESTAMP::DATE;
    SELECT DATE(SUBSTRING('2018-07-25 10:30:30' FROM 1 FOR 10));

## Get time

get time only, date only

    > CURRENT_DATE;
    20191001

    > SELECT CURRENT_TIME; 
    20:49:04.566025-07

get datetime(timestamp)

    > SELECT NOW();
    > SELECT CURRENT_TIMESTAMP; 
    2016-06-22 20:44:52.134125-07

    > select  TIMESTAMP 'yesterday' ;

### trunc 对齐
    > select date_trunc( 'day', '2024-01-03 23:59:59' :: timestamp);
    2024-01-03 00:00:00
    > select date_trunc( 'week', TIMESTAMP WITH TIME ZONE '2024-01-03 23:59:59' :: timestamp);
    2024-01-01 00:00:00

### get serials
    select *  FROM generate_series(
            date_trunc( 'day', '2023-12-30 00:00:00' :: timestamp), 
            date_trunc( 'day', '2024-01-03 23:59:59' :: timestamp), 
            '1 day'
        ) AS start_time;
    ---------------------
    2023-12-30 00:00:00
    2023-12-31 00:00:00
    2024-01-01 00:00:00
    2024-01-02 00:00:00
    2024-01-03 00:00:00

## Set time

    show timezone;
        Asia/Shanghai

字面强转换会忽略字符中包含的时区, `where created_time > '2022-06-01 00:00:00+08'`则不会忽略

    select '2022-06-01 00:00:00+08'::timestamp;
     2022-06-01 00:00:00
    select '2022-06-01 00:00:00+00'::timestamp;
     2022-06-01 00:00:00
    select '2022-06-01'::timestamp;
     2022-06-01 00:00:00

    select '2022-06-01 00:00:00+08'::date
    select '2022-06-01 00:00:00+08'::date
    select '2022-06-01 00:00:00-11'::date;
        2022-06-01 00:00:00
    select '2022-06-01T23:00:00+11'::timestamp;
        2022-06-01 23:00:00

## Delta time(plus)

    select date '2001-09-28' + integer '7'
    select date '2001-09-28' + integer '7' day
    select date '2001-09-28' + integer '7 day'
    select created_at + interval '1' day * 7 as deadline
    select created_at + interval '1' day * day_field as deadline
    select created_at + interval '1' hour * hour_field as deadline

    select created_at + hour_field as deadline //not work

### Get delta time

    select  now() - INTERVAL '1 day' ;
    select (now()-created_at) from task_checks limit 1;
    --------------------------
    451 days 18:51:57.959561

info

    // to seconds
    SELECT EXTRACT(epoch FROM (SELECT (NOW() - '2014-08-02 08:10:56')))
    // to days
    SELECT (EXTRACT(epoch FROM (SELECT (NOW() - '2014-08-02 08:10:56')))/86400)::int
    SELECT EXTRACT(DAY FROM NOW() - '2014-08-02 08:10:56');


### compare delta time

    where exittime - entrytime > interval '1 hour';
    WHERE now()- updated_at > interval '5 minutes';"
    where age(now(),updated_at) < interval '22 days';