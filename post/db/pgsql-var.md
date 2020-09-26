---
title: pgsql var
date: 2020-08-28
private: true
---
# Define var and assign

## initial var
### declare
    variable_name data_type [:= expression];
    vSite varchar DEFAULT 'TechOnTheNet.com';

example

    do $$ 
    declare
        created_at time := now();
        counter    integer := 1;
        payment    numeric(11,2) := 20.5;
        mid  integer:= (select max(id) from oauth_tokens);
        first_name varchar(50) := 'John';
        last_name  varchar(50) := 'Doe';
        wholname varchar(100) := first_name || ' ' || last_name
    begin 
        raise notice '% % % has been paid % USD', 
            counter, 
            first_name, 
            last_name, 
            payment;
    end $$;


### define via set
    my_db=> \set myvar 5
    my_db=> SELECT :myvar;
    my_db=> SELECT :myvar  + 1 AS my_var_plus_1;

### defeine via with
    WITH myconstants (var1, var2) as (
        values (5, 'foo')
    ) SELECT var1,var2 FROM myconstants

### via session
    set session my.vars.id = '1';
    select * from person where id = current_setting('my.vars.id')::int;

### use select into
    CREATE FUNCTION get_userid(username text) RETURNS int
    AS $$
        #print_strict_params on
        DECLARE userid int;
        BEGIN
            SELECT users.userid INTO STRICT userid
                FROM users WHERE users.username = get_userid.username;
            RETURN userid;
        END
    $$ LANGUAGE plpgsql;