---
title: Postgre Json
date: 2019-06-20
private:
---
# jsonb
https://www.postgresql.org/docs/current/static/functions-json.html

### 定义
jsonb 即可以直接使用 json 字符串, 插入取出时自动转换成`::jsonb` 得到jsonb 类型

    select '{"key":123}'
    select concat('{"key":',123,'}')::jsonb;
    select '1' intger
    select '"1"' char

### increment
1. with ||jsonb, 只适合第一层级, 更好的办法是使用jsonb_set(col, path, data)
2. `->>` 将jsonb 属性取出并转换成text, 转成数字还需要`::int`, 并且`::`与`+`优先级都高于`->>`

    UPDATE users SET counters = counters || '{"bar": 314}'::jsonb WHERE id = 1;
    UPDATE users SET counters = counters || CONCAT('{"bar":', COALESCE(counters->>'bar','0')::int + 1, '}')::jsonb WHERE id = 1;
    UPDATE users SET counters = jsonb_set(counters, '{bar}', CONCAT(COALESCE(counters->>'bar')::int + 1)::jsonb) WHERE id = 1;

### 使用

    []->int	 Get JSON array(0, -3)          '[{"a":"foo"},{"b":"bar"},{"c":"baz"}]'::json->2  {"c":"baz"}
    {}->'text' Get JSON object field by key   '{"a": {"b":"foo"}}'::json->'a'
    []->>int	as text                     '[1,2,3]'::json->>2	3
    {}->>'text'	as text                     '{"a":1,"b":2}'::json->>'b'	2
    # 多级路径path
    {}[]#>'{k1,k2}' Get JSON object	        '{"a": {"b":{"c": "foo"}}}'::json#>'{a,b}'	{"c": "foo"}
    {}[]#>>'{k1,k2}'Get JSON object as text	'{"a":[1,2,3],"b":[4,5,6]}'::json#>>'{a,2}'	3

example

    select * from rego_data where document->>'id'='mcs:access_catalog_90';

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