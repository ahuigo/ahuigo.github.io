---
title: pg condition control
date: 2022-03-03
private: true
---
# Reference
https://www.postgresql.org/docs/9.1/plpgsql-control-structures.html

# IF
    IF boolean-expression THEN
        statements
    [ ELSIF boolean-expression THEN
        statements
    [ ELSIF boolean-expression THEN
        statements
        ...]]
    [ ELSE
        statements ]
    END IF;

## IF is null
    do $$
    DECLARE
        a int;
    BEGIN
        if a isnull THEN
            raise notice 'isnull';
        ELSE
            raise notice 'not null';
        END IF;
    END $$;


# loop object
## For loop sequence
    [ <<label>> ]
    FOR name IN [ REVERSE ] expression .. expression [ BY expression ] LOOP
        statements
    END LOOP [ label ];

for example:

    FOR i IN 1..10 LOOP
        -- i will take on the values 1,2,3,4,5,6,7,8,9,10 within the loop
    END LOOP;

    FOR i IN REVERSE 10..1 LOOP
        -- i will take on the values 10,9,8,7,6,5,4,3,2,1 within the loop
    END LOOP;

    FOR i IN REVERSE 10..1 BY 2 LOOP
        -- i will take on the values 10,8,6,4,2 within the loop
    END LOOP;

## For loop query(iter)
    [ <<label>> ]
    FOR target IN query LOOP
        statements
    END LOOP [ label ];

for example:

    CREATE TABLE foo (fooid INT, foosubid INT, fooname TEXT);
    INSERT INTO foo VALUES (1, 2, 'three');
    INSERT INTO foo VALUES (4, 5, 'six');

    CREATE OR REPLACE FUNCTION getAllFoo() RETURNS SETOF foo AS
    $BODY$
    DECLARE
        r foo%rowtype;
    BEGIN
        FOR r IN SELECT * FROM foo WHERE fooid > 0
        LOOP
            -- can do some processing here
            RETURN NEXT r; -- return current row of SELECT
        END LOOP;
        RETURN;
    END
    $BODY$
    LANGUAGE 'plpgsql' ;

    SELECT * FROM getallfoo();

## for in array
Looping Through Arrays


    CREATE FUNCTION sum(int[]) RETURNS int8 AS $$
    DECLARE
      s int8 := 0;
      x int;
    BEGIN
      FOREACH x IN ARRAY $1
      LOOP
        s := s + x;
      END LOOP;
      RETURN s;
    END;
    $$ LANGUAGE plpgsql;

# loop control
## Exit loop

    LOOP
        -- some computations
        IF count > 0 THEN
            EXIT;  -- exit loop
        END IF;
    END LOOP;

## Continue loop
    LOOP
    -- some computations
    EXIT WHEN count > 100;
    CONTINUE WHEN count < 50;
    -- some computations for count IN [50 .. 100]
END LOOP;

## while
    [ <<label>> ]
    WHILE boolean-expression LOOP
        statements
    END LOOP [ label ];

for example:

    WHILE amount_owed > 0 AND gift_certificate_balance > 0 LOOP
        -- some computations here
    END LOOP;

    WHILE NOT done LOOP
        -- some computations here
    END LOOP;


# return 
    RETURN NEXT expression;
    RETURN QUERY query;
    RETURN QUERY EXECUTE command-string [ USING expression [, ... ] ];

`RETURN NEXT` and `RETURN QUERY` do not actually return from the function — 
1. they simply append zero or more rows to the function's result set, 参考for loop query

# case when
    select CASE 'r' 
        WHEN 'r' THEN 'table'
        WHEN 'v' THEN 'view' 
        ELSE 'other' END as "Type";

    UPDATE t1 
    SET status = CASE 
        WHEN score <= 0 THEN 'false' 
        WHEN score < 100 THEN 'ok' 
        ELSE 'n/a' 
    END;