---
title: pg block
date: 2021-10-28
private: true
---
# pg block
http://www.postgres.cn/docs/9.3/plpgsql-structure.html

codeblock's Syntax:

    [ <<label>> ]
    [ DECLARE
        declarations ]
    BEGIN
        statements;
        ...
    [EXCEPTION
        Exception handler ]
    END [ label ];

## do block without label

    DO [ LANGUAGE lang_name ] codeblock

Note: The DO statement does not belong to the block. It is used to execute an anonymous block. 

    do $$
    declare
       film_count integer;
    begin 
       select count(*) into film_count from alert_users;
       raise notice 'The number of films: %', film_count;
    end $$;

注意：`$$`相当于`'`, 参考 pg-var-str.md

## do with label

    DO $$ 
    <<first_block>>
    DECLARE
      counter integer := 0;
    BEGIN 
       counter := counter + 1;
       RAISE NOTICE 'The current value of counter is %', counter;
    END first_block $$;

## block in block
`outer_block.counter` 是label 引用

    DO $$ 
    <<outer_block>>
    DECLARE
      counter integer := 0;
    BEGIN 
       counter := counter + 1;
       RAISE NOTICE 'The current value of counter is %', counter;

       DECLARE 
           counter integer := 0;
       BEGIN 
           counter := counter + 10;
           RAISE NOTICE 'The current value of counter in the subblock is %', counter;
           RAISE NOTICE 'The current value of counter in the outer block is %', outer_block.counter;
       END;
       RAISE NOTICE 'The current value of counter in the outer block is %', counter;
    
    END outer_block $$;

output: 

   NOTICE:  The current value of counter is 1
    NOTICE:  The current value of counter in the subblock is 10
    NOTICE:  The current value of counter in the outer block is 1
    NOTICE:  The current value of counter in the outer block is 1 


# References
- https://www.geeksforgeeks.org/postgresql-block-structure/