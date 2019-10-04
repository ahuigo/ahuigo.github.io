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

## define type

    varchar(10) not null;
    DECIMAL(4,2) not null;
    int not null;

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

## all type
    SELECT typname, typlen FROM pg_type WHERE typname ~ '^date';
