---
title: postgres material view
date: 2025-02-13
private: true
---
# material view vs view

| 特性   | 普通视图 (View)   | 物化视图 (Materialized View)                               |
| -------| -----------------------------| -----------------|
| 数据存储| 不存储数据                   | 存储数据 (查询结果)                |
| 数据更新| 实时更新 (每次查询都重新计算)   | 需要手动刷新 (使用 `REFRESH MATERIALIZED VIEW`)    |
| 查询性能| 较慢 (每次查询都执行原始查询)   | 较快 (直接从磁盘读取数据)                       |
| 适用场景| 实时性要求高，数据量较小，查询不频繁 | 实时性要求不高，数据量较大，查询频繁       |
| 资源消耗| 较小 (不占用存储空间)       | 较大 (占用存储空间)              |
| 事务支持| 与底层表保持一致           | 刷新操作可以放在事务中，但数据一致性依赖于刷新频率   |
| 创建语句| `CREATE VIEW view_name AS SELECT ...`| `CREATE MATERIALIZED VIEW materialized_view_name AS SELECT ...` |
| 修改  | 使用 `CREATE OR REPLACE VIEW` 或先 `DROP` 再 `CREATE` | 先 `DROP MATERIALIZED VIEW` 再 `CREATE MATERIALIZED VIEW`           |

# material view
## view definition
```sql
\d+ view_user_top100
```

-- 方法一：
SELECT pg_get_viewdef('customer_order_summary'::regclass, true);

-- 方法二：
SELECT definition
FROM pg_matviews
WHERE matviewname = 'customer_order_summary';

-- 方法三（在 psql 中）：
\d+ customer_order_summary

## create material view

    CREATE MATERIALIZED VIEW customer_order_summary AS
     SELECT
      c.customer_id,
      c.customer_name,
      count(o.order_id) AS total_orders,
      sum(o.order_total) AS total_spent
     FROM
      customers c
      JOIN orders o ON c.customer_id = o.customer_id
     GROUP BY
      c.customer_id,
      c.customer_name;

## alter material view
    -- 1. 删除现有的物化视图
    DROP MATERIALIZED VIEW IF EXISTS product_summary;

    -- 2. 创建新的物化视图
    CREATE MATERIALIZED VIEW product_summary AS
    SELECT
        p.product_id,
        p.product_name,
        p.price,
        c.category_name  -- 添加 category_name 列
    FROM
        products p
    JOIN
        categories c ON p.category_id = c.category_id
    WHERE
        p.price > 100;    -- 修改 WHERE 条件

    -- 3. 刷新物化视图: 手动刷新物化视图，才能使其包含最新的数据
    REFRESH MATERIALIZED VIEW product_summary;
