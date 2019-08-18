---
title: Posgtre Var
date: 2019-06-20
private:
---
# Posgtre Var
## Define and assign
    DECLARE vSite varchar DEFAULT 'TechOnTheNet.com';
    DECLARE vSite varchar := 'TechOnTheNet.com';
    vSite := 'CheckYourMath.com';

# Datetime
## timestamp
### To date
timestamp to date:'2018-07-25 10:30:30' to '2018-07-25', 3种方法

    SELECT DATE(column_name) FROM table_name;
    SELECT column_name::DATE;
        SELECT '2018-07-25 10:30:30'::TIMESTAMP::DATE;
    SELECT DATE(SUBSTRING('2018-07-25 10:30:30' FROM 1 FOR 10));

# string

## concat
    select * from table where fullname like concat(name, "%")