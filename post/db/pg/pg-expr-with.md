---
title: pg with expression
date: 2023-09-19
private: true
---
# pg with expression
这个是用于创建临时表的, 比如

    WITH T(uid, age)
    AS (SELECT 1,1 UNION ALL
        SELECT 1,3 UNION ALL
        SELECT 1,2 UNION ALL
        SELECT 2,1)
    SELECT distinct uid FROM T ;
     uid 
    -----
    1
    2

## WITH RECURSIVE
一个 WITH RECURSIVE 查询由两部分组成：

1. 非递归项：这是递归查询的基础。它运行一次，并产生初始结果集。
2. 递归项：这是递归查询的递归部分。它重复使用自己先前的输出作为输入，对其进行操作，然后生成新的输出。这个过程会持续进行，直到不再有新的结果被生成。

以下是 WITH RECURSIVE 的一个简单示例，生成从1到5的序列：

    WITH RECURSIVE t(n) AS (
        SELECT 1    -- 非递归项，产生第一个记录1(初值n=1)
        UNION ALL
        SELECT n+1 FROM t WHERE n < 5 -- 递归产生n+1 (前值作为输入，直到n=5结束)
    )
    SELECT n FROM t; -- echo {1..5}

以下例子是递归找出所有当前`current_user` 继承哪些的role：

    WITH RECURSIVE user_roles AS (
      SELECT
        r.oid,
        r.rolname
      FROM
        pg_roles r
      WHERE
        r.rolname = current_user -- 非递归项：初始化，找出当前user的oid
      UNION ALL
      SELECT
        r.oid,
        r.rolname
      FROM
        pg_roles r
        JOIN pg_auth_members m ON r.oid = m.roleid
        JOIN user_roles ur ON ur.oid = m.member -- 递归项: 通过r.oid 找m.member->m.roleid -> r.oid->r.rolname
    )
    SELECT rolname AS username FROM user_roles;

注意：pg_auth_members 是关系表，`btree (member, roleid)` roleid一般包含多个member成员