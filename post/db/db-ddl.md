# FUNCTION
pg update /delete 都不支持limit, 建议用array 而不是IN:

    DELETE FROM logtable 
        WHERE id = any (array(SELECT id FROM logtable ORDER BY timestamp LIMIT 10));

或者用

    CREATE or replace FUNCTION  update_status() returns character varying as $$
    declare
    match_ret record;
    begin
        SELECT * INTO match_ret FROM product_child WHERE product_status = 2 LIMIT 1 for update ;
        UPDATE product_child SET status_code = '1' where child_code = match_ret.child_code ;

        return match_ret.child_code ;
        commit;
    end ;
    $$ LANGUAGE plpgsql;
