
# Postgre CRUD
## insert 
    CREATE TABLE users (id INT, counters JSONB NOT NULL DEFAULT '{}');
    INSERT INTO users (id, counters) VALUES (1, '{"bar": 10}');

### last insert id
3 ways,all are concurrent safe:

    SELECT currval(table_name+'_id_seq');
    SELECT LASTVAL();
    insert into .... RETURNING id;

### insert+update
1. 加条insert+update 两句
INSERT INTO table (id, field, field2)
       SELECT 3, 'C', 'Z'
       WHERE NOT EXISTS (SELECT 1 FROM table WHERE id=3);
2. insert + onconflict do update

    INSERT INTO the_table (id, column_1, column_2) VALUES (1, 'A', 'X'), (2, 'B', 'Y'), (3, 'C', 'Z')
    ON CONFLICT (id) 
    DO UPDATE 
        SET column_1 = EXCLUDED.column_1, 
            column_2 = the_table.column_2 
        [RETURNING id];
    DO NOTHING;

#### on conflict
`ON CONFLICT target action [RETURNING id]`:

    target:
        (uid, phone)
        ON CONSTRAINT constraint_name
        WHERE predicate
    action:
        DO NOTHING
        DO UPDATE SET column_1 = EXCLUDED.value_1,v2, .. WHERE condition

## select 

## del
SELECT '{"a":[null,{"b":[3.14]}]}' #- '{a,1,b,0}'


## update

	UPDATE ed_names SET c_request = c_request+1 WHERE id = 'x'"

### update DUPLICATE
mysql update 多个unique key 时,如果遇到 `duplicate key`, 比如所有的i加1

一般情况下可以通过排序避免(mysql update/insert 时会按一定的顺序去查数据是否有效):

	UPDATE <table> set i=i+1 where id>10 order by i desc; # 大的先加1，避免冲突

如果`i`没有加索引，排序比较耗时或内存，就变通一下，比如：放弃排序，先负数：

	UPDATE <table> set i=-i where id>10; # 先变负，就不存在+1冲突
	UPDATE <table> set i=1-i where id>10;

# var

## type

SELECT pg_typeof(your_variable);
json_typeof(var)

类型转换

    var::int
    var::jsonb
    var::text::jsonb

## 默认值

    COALESCE(variable,0)
    COALESCE(counters->>'bar','0')::int

## string
1. 字符串，只能用`'` 为边界，又引号是用于关键字的(e.g. table_name)
2. postgre 不支持\ 转义, 只支持双单引号转义

    '\\'
    'a''b' # 不支持 ’a\'b' 

### concat
    select 'a:'||'b'||1.2 as bb;
    select concat('a:','b', 1.2)
    select concat(key1,key2)

## array

    select array[1,2];
    select array['a','b'];
    select array['a',1]; # error

## jsonb
https://www.postgresql.org/docs/current/static/functions-json.html

### 定义
jsonb 即可以直接使用 json 字符串, 插入取出时自动转换成`::jsonb` 得到jsonb 类型

    select '{"key":123}'
    select concat('{"key":',123,'}')::jsonb;
    select '1' intger
    select '"1"' char

### increment
1. with ||jsonb, 只适合第一层级, 更好的办法是使用jsonb_set(col, path, data)
2. `->>` 将jsonb 转换成text, 转成数字还需要`::int`, 并且`::`与`+`优先级都高于`->>`

    UPDATE users SET counters = counters || '{"bar": 314}'::jsonb WHERE id = 1;
    UPDATE users SET counters = counters || CONCAT('{"bar":', COALESCE(counters->>'bar','0')::int + 1, '}')::jsonb WHERE id = 1;
    UPDATE users SET counters = jsonb_set(counters, '{bar}', CONCAT(COALESCE(counters->>'bar')::int + 1)::jsonb) WHERE id = 1;

### 使用:

    []->int	 Get JSON array(0, -3)          '[{"a":"foo"},{"b":"bar"},{"c":"baz"}]'::json->2
    {}->'text' Get JSON object field by key   '{"a": {"b":"foo"}}'::json->'a'
    []->>int	as text                     '[1,2,3]'::json->>2	3
    {}->>'text'	as text                     '{"a":1,"b":2}'::json->>'b'	2
    # 多级路径path
    {}[]#>'{k1,k2}' Get JSON object	        '{"a": {"b":{"c": "foo"}}}'::json#>'{a,b}'	{"c": "foo"}
    {}[]#>>'{k1,k2}'Get JSON object as text	'{"a":[1,2,3],"b":[4,5,6]}'::json#>>'{a,2}'	3

其它：

    a @> b  check a include b
    a <@ b  check a is included by b
    dic?'b' check b key exists
    dic?|array('b','a') check any [a,b] exists
    dic?&array('b','a') check all [a,b] exists
    a||b merge
    dic-'key'  delete
    dic-'{k1,k2}' del
    arr-2       del 2nd valume
    #-path      del by path

path:

    '{1,kl2,kl3,kl4,5}'

### merge
merge jsonb via `||`:

    UPDATE users SET counters = counters || CONCAT('{"foo":', COALESCE(counters->>'foo','0')::int + 27, '}')::jsonb WHERE id = 1;

add jsonb via `jsonb_set`:

    jsonb_set('{"bar":1,"x":{}}'::jsonb, '{x,y}', 1::text::jsonb);
    {"x": {"y": 1}, "bar": 1}