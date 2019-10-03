---
title: Posgtre Var
date: 2019-06-20
private:
---
# var
## Define and assign
    DECLARE vSite varchar DEFAULT 'TechOnTheNet.com';
    DECLARE vSite varchar := 'TechOnTheNet.com';
    vSite := 'CheckYourMath.com';

## type

    varchar(10) not null;
    DECIMAL(4,2) not null;
    int not null;

why not null???

### test type

    SELECT pg_typeof(your_variable);
    json_typeof(var)

### convert type
类型转换

    var::int
    var::jsonb
    var::text::jsonb
    select name::text::jsonb

## 默认值

    COALESCE(variable,0)
    COALESCE(counters->>'bar','0')::int

# Datetime
## timestamp
### To date
timestamp to date:'2018-07-25 10:30:30' to '2018-07-25', 3种方法

    SELECT DATE(column_name) FROM table_name;
    SELECT column_name::DATE;
        SELECT '2018-07-25 10:30:30'::TIMESTAMP::DATE;
    SELECT DATE(SUBSTRING('2018-07-25 10:30:30' FROM 1 FOR 10));

## delta

   select date '2001-09-28' + integer '7'
   select created_at + interval '1' day * day_field as deadline
   select created_at + interval '1' hour * hour_field as deadline

   select created_at + hour_field as deadline //not work
