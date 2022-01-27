---
title: pg transaction
date: 2021-05-20
private: true
---
# pg transaction

# FAQ
## current transaction is aborted
当发生问题却没有rollback 就会这样，比如

    ```shell
    ahuigo=#  CREATE TABLE t1 ( id serial PRIMARY KEY);
    ahuigo=# begin;
    BEGIN
    ahuigo=*# insert into t1 values(1);
    INSERT 0 1
    ahuigo=*# select * from t1;
    id 
    ----+-----
    1 
    (1 row)

    ahuigo=*# insert into t1 values(1);
    ERROR:  duplicate key value violates unique constraint "t1_pkey"
    DETAIL:  Key (id)=(1) already exists.
    ahuigo=!# insert into t1 values(2);
    ERROR:  current transaction is aborted, commands ignored until end of transaction block
    ```