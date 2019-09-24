---
title: Posgtre Var
date: 2019-06-20
private:
---
# array

## define array

    CREATE TABLE contacts (
        id serial PRIMARY KEY,
        name VARCHAR (100),
        phones TEXT []
    );
    select array[1,2];
    select array['a','b'];
    select array['a',1]; # error

## insert array
    INSERT INTO contacts (name, phones) VALUES (
      'John Doe',
      ARRAY [ '(408)-589-5846', '(408)-589-5555' ]
   );

or use bracket to insert:

    INSERT INTO contacts (name, phones) VALUES (
        'William Gate', 
        '{"(408)-589-5842","(408)-589-58423"}'
    );

## select array
select first phone number(不是从0开始)

    SELECT phones[1] FROM contacts;

### where array
检查第一个值

    where phone[1]='(408)-589-58423'

### array.include

    WHERE '(408)-589-5555' = ANY (phones);

### array in
利用交集：

    SELECT ARRAY[1,4,3] && ARRAY[2,1] -- true

所以array in 的写法

    where (phones && ARRAY['1234','1235'])

## modify array
update all array:

    UPDATE contacts SET phones = '{"(408)-589-5843"}' WHERE ID = 3;

update one array element:

    UPDATE contacts SET phones[2] = '(408)-589-5843' WHERE ID = 3; 

# Array function
## expand array
    # select id,unnest(phones) from contacts where name='John Doe';
    id |     unnest
    ----+----------------
    1 | (408)-589-5846
    1 | (408)-589-5555

## array length
第二个参数代表维度1维数组

    select array_length(string_to_array(name, 'o'), 1) - 1

## compamre
### is empty array
array_length() requires two parameters, the second being the dimension of the array:

    array_length(id_clients, 1) > 0

compare it to an empty array:

    id_clients = '{}'

That's all. You get:

    TRUE .. array is empty
    NULL .. array is NULL
    FALSE .. any other case

