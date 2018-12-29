---
title: mysql explain 的使用
date: 2018-12-29
---
# Mysql Explain 的使用

## show index

	show index from table_name;

## explain
用explain 获取mysql 如何query, 如何join(联结)，怎样的顺序join 参考：

	possible_keys	The possible indexes to choose
	key			The index actually chosen
	key_len		The length of the chosen key
	ref			The columns compared to the index
                被用于查找索引列上的 哪些列或常量
	rows		Estimate of rows to be examined
                找到结果集需要扫描读取的数据行数.
	filtered	Percentage of rows filtered by table condition
	Extra		Additional information

## select_type
The SELECT type

    simple  not using UNION or subqueries
    primary 最外层的查询
    union   union 随后的查询
        explain select id from t1   union select id from t1;
        +------+--------------+------------+-------+---------------+---------+---------+------+------+-------------+
        | id   | select_type  | table      | type  | possible_keys | key     | key_len | ref  | rows | Extra       |
        +------+--------------+------------+-------+---------------+---------+---------+------+------+-------------+
        |    1 | PRIMARY      | t1         | index | NULL          | abindex | 10      | NULL |    4 | Using index |
        |    2 | UNION        | t1         | index | NULL          | abindex | 10      | NULL |    4 | Using index |
        | NULL | UNION RESULT | <union1,2> | ALL   | NULL          | NULL    | NULL    | NULL | NULL |             |
    SUBQUERY, 子查询中的第一个 SELECT

## key
表示查询优化器使用了索引的字节数. 这个字段可以评估组合索引是否完全被使用
key_len 的计算规则如下:

    字符串
        char(n): 3n 字节长度
        varchar(n): utf8 编码3n+2, utf8mb4是 4n + 2字节
    数值类型:
        TINYINT: 1字节
        SMALLINT: 2字节
        MEDIUMINT: 3字节
        INT: 4字节
        BIGINT: 8字节
    时间：
        DATE: 3字节
        TIMESTAMP: 4字节
        DATETIME: 8字节
     DEFAULT NULL: 多占用一个字节

## extra

    Using index
        覆盖索引扫描, 表示查询在索引树中就可查找所需数据, 不用扫描表数据文件
    Using filesort 
        额外的排序 order by name。建议用可以用index(name)优化
    Using temporary
        查询有使用临时表, 一般出现于排序, 分组和多表 join 的情况
    Using join buffer
        join 没有使用索引，可能需要优化

## type
The join type

    const: 使用了主键、唯一索引: 只返回一个
        select id from t1 where id =15;
        select *  from t1 where id =15;
    range:
        select  * from t1 where id in (15,16);
        select id from t1 where id >15;
        select * from t1 where id >15;
    eq_ref join 查询是前表能匹配到后表，t1 join t2 on t1.id=t2.uid
        $ explain select * from t1 join t3 on t1.id=t3.id;
        | id   | select_type | table | type   | possible_keys | key     | key_len | ref        | rows | Extra |
        +------+-------------+-------+--------+---------------+---------+---------+------------+------+-------+
        |    1 | SIMPLE      | t1    | ALL    | PRIMARY       | NULL    | NULL    | NULL       |    4 |       |
        |    1 | SIMPLE      | t3    | eq_ref | PRIMARY       | PRIMARY | 4       | test.t1.id |    1 |       |
    ref join 查询, 针对于unique/pk索引, 或者是使用了 最左前缀 规则索引的查询
        SELECT * FROM ref_table,other_table 
            WHERE ref_table.key_column=other_table.column;
        > explain select * from t1 join t3 on t1.a=t3.a;
        +------+-------------+-------+------+---------------+---------+---------+-----------+------+-------------+
        | id   | select_type | table | type | possible_keys | key     | key_len | ref       | rows | Extra       |
        +------+-------------+-------+------+---------------+---------+---------+-----------+------+-------------+
        |    1 | SIMPLE      | t1    | ALL  | abindex       | NULL    | NULL    | NULL      |    4 | Using where |
        |    1 | SIMPLE      | t3    | ref  | abindex       | abindex | 5       | test.t1.a |    1 | Using index |
    index: 全索引扫描(full index scan), 不是全表扫描。只扫描索引，不扫描数据
        select id from t1 where id in (15,16);
    All 全表查询: 扫描整个数据 join t3 where t1.id=t3.id+1

## 慢查询优化步骤
0. 先运行看看是否真的很慢，注意设置SQL_NO_CACHE
1. where条件单表查，锁定最小返回记录表。这句话的意思是把查询语句的where都应用到表中返回的记录数最小的表开始查起，单表每个字段分别查询，看哪个字段的区分度最高
2. explain查看执行计划，是否与1预期一致（从锁定记录较少的表开始查询）
3. order by limit 形式的sql语句让排序的表优先查
4. 了解业务方使用场景
5. 加索引时参照建索引的几大原则
6. 观察结果，不符合预期继续从0分析

### ref
ref can be used for indexed columns that are compared using the = or <=> operator.
In the following examples, MySQL can use a ref join to process ref_table:

	SELECT * FROM ref_table WHERE key_column=expr;

	SELECT * FROM ref_table,other_table
	  WHERE ref_table.key_column=other_table.column;

	SELECT * FROM ref_table,other_table
	  WHERE ref_table.key_column_part1=other_table.column
	  AND ref_table.key_column_part2=1;

# 参考
1. https://segmentfault.com/a/1190000008131735
2. http://dev.mysql.com/doc/refman/5.5/en/explain-output.html