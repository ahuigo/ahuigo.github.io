---
title: Posgtre Var
date: 2019-06-20
private:
---
# array
## define array

    select array[1,2];
    select array['a','b'];
    select array['a',1]; # error

## crud
select first phone number(不是从0开始)

    SELECT phones[1] FROM contacts;

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

### in array