---
title: Posgtre Var
date: 2019-06-20
private:
---
# Bit Operation

    2&1 //0
    2|1 //3
    ~1 //-2

# math

    3^3 //27

# 交集
http://www.postgresqltutorial.com/postgresql-intersect/

    SELECT employee_id FROM keys
    INTERSECT
    SELECT employee_id FROM hipos;
    //out:
    employee_id
    -------------
            5
            2