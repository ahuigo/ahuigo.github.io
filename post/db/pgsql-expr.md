---
title: pg sql
date: 2020-08-25
private: true
---
# 参考
http://www.postgres.cn/docs/9.3/plpgsql-structure.html

# pg sql
定义语句体

    [ <<label>> ]
    [ DECLARE
        declarations ]
    BEGIN
        statements
    END [ label ];

## do 执行语句体

    DO $$
    DECLARE myvar integer = 5;
    BEGIN
        CREATE TEMP TABLE tmp_table ON COMMIT DROP AS
            -- put here your query with variables:
            SELECT * 
            FROM oauth_tokens
            WHERE id = myvar;
    END $$;

    SELECT * FROM tmp_table;

## declare

    do $$ 
    declare
        counter    integer := 1;
        first_name varchar(50) := 'John';
        last_name  varchar(50) := 'Doe';
        payment    numeric(11,2) := 20.5;
    begin 
        raise notice '% % % has been paid % USD', 
            counter, 
            first_name, 
            last_name, 
            payment;
    end $$;


## select 语句
在begin/end 内，select 必须输出保存

    SELECT offer_id FROM users into idx;
    SELECT setval('oauth_tokens_id_seq', mid+100, true) into a;

或者用PERFORM：

    PERFORM offer_id FROM users;
    PERFORM setval('oauth_tokens_id_seq', mid+100, true);