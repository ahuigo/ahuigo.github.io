---
title: pg str regex
date: 2022-03-03
private: true
---
# substring
## substring
不支持负数和0, 从1开始

    SELECT SUBSTRING('2018-07-25 10:30:30',1,10);
        DATE('2018-07-25')
    SELECT DATE(SUBSTRING('2018-07-25 10:30:30' FROM 1 FOR 10));
        DATE('2018-07-25')

## match regex
    select substring('I have a dog', 'd[aeiou]g');
        dog
    select substring(' 30 yuan', '[[:digit:]]+');
        30
    ahuigo=# select substring(' a33b yuan', 'a(\d+)(b)');
        33


# regex
## group regex
    select regexp_matches(name, 'foo');
    ahuigo=# select regexp_matches('foo1', '(fo)o');
    {fo}
    ahuigo=# select regexp_matches('foo1', 'foo');
    {foo}
    ahuigo=# select regexp_matches('foo1', '(fo)(o)');
     {fo,o}
    ahuigo=# select pg_typeof(regexp_matches('foo1', 'foo'));
    text[]

## where regex
    
    select * from xx where name ~ '^\w{2}$'
