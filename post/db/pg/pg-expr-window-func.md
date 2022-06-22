---
title: pg expr window func
date: 2020-01-23
private: 
---
# pg window func

# Lead
https://www.postgresqltutorial.com/postgresql-window-function/postgresql-lead-function/

    LEAD(expression [,offset [,default_value]])
    OVER (
        [PARTITION BY partition_expression, ... ]
        ORDER BY sort_expression [ASC | DESC], ...
    )

说明：
1. offset: 
   1. specifies the number of rows forwarding from the current row. The offset defaults to 1 
2. default_value: 
   1. The default_value is the return value if the offset goes beyond the scope of the partition. The default_value defaults to NULL if you omit it

This example uses the LEAD() function to return the sales amount of the current year and the next year:

    WITH cte AS (
        SELECT year, SUM(amount) amount FROM sales GROUP BY year ORDER BY year
    )
    SELECT year, amount, LEAD(amount,1) OVER ( ORDER BY year) next_year_sales FROM cte;

销量增长：

    WITH cte AS (
        SELECT year, SUM(amount) amount FROM sales GROUP BY year ORDER BY year
    ), cte2 AS (
        SELECT year, amount, LEAD(amount,1) OVER ( ORDER BY year) next_year_sales FROM cte
    )   
    SELECT year, amount, next_year_sales,  (next_year_sales - amount) variance FROM cte2;

partion+lead 分组聚合的例子:
每个季报每个股票code 的扣非利润`q_dtprofit`增长

    select code,end_date,q_dtprofit,
        q_dtprofit-LEAD(q_dtprofit,1) OVER(
            PARTITION BY code 
            ORDER BY end_date desc
        ) increase
    from profits;

只取最新财报数据

    WITH qdtVariance AS (
        select code,end_date,q_dtprofit,
            q_dtprofit-LEAD(q_dtprofit,1) OVER(
                PARTITION BY code 
                ORDER BY end_date desc
            ) variance
        from profits
    ), latest2 AS(
        SELECT *, 
        ROW_NUMBER() OVER(PARTITION BY code ORDER BY end_date DESC) AS rk 
        FROM qdtVariance
    )
    SELECT * FROM latest2 where rk=1

# Laterial
> https://stackoverflow.com/questions/8840228/postgresql-using-a-calculated-column-in-the-same-query
用于 using a calculated column in the same query, lateral 相当于生成新的field:total1+total2

    SELECT cost_1, quantity_1, cost_2, quantity_2, total_1, total_2,
        total_1 + total_2 AS total_3
    FROM data
    ,LATERAL(SELECT cost_1 * quantity_1, cost_2 * quantity_2) AS s1(total_1,total_2);

using calculated column in where-clause? 没有找到答案
https://www.codeproject.com/tips/606442/how-to-pass-calculated-columns