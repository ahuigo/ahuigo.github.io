---
title: Postgre Json
date: 2019-06-20
private:
---
# jsonb
## json vs jsonb 
jsonb 更better,
2. jsonb 以二进制存储，读取高效（不需要解析），json写入更高效(原样存text)
3. jsonb supports indexing, 包括 GIN (Generalized Inverted Index) indexes:
    - `CREATE INDEX idxgintags ON api USING GIN ((jdoc -> 'tags'));`
    - https://www.postgresql.org/docs/current/datatype-json.html#JSON-INDEXING
    - https://www.postgresql.org/docs/current/gin-intro.html

https://www.postgresql.org/docs/current/static/functions-json.html

### 定义
jsonb 即可以直接使用 json 字符串, 插入取出时自动转换成`::jsonb` 得到jsonb 类型

    select '{"key":123}'
    select concat('{"key":',123,'}')::jsonb;
    select '1' intger
    select '"1"' char

#### 表字段定义

    ALTER TABLE jsonb_tables ADD COLUMN config JSONB NOT NULL DEFAULT '{}';

### increment
1. with ||jsonb, 只适合第一层级, 更好的办法是使用jsonb_set(col, path, data)
2. `->>` 将jsonb 属性取出并转换成text, 转成数字还需要`::int`, 并且`::`与`+`优先级都高于`->>`

    UPDATE users SET counters = counters || '{"bar": 314}'::jsonb WHERE id = 1;
    UPDATE users SET counters = counters || CONCAT('{"bar":', COALESCE(counters->>'bar','0')::int + 1, '}')::jsonb WHERE id = 1;
    UPDATE users SET counters = jsonb_set(counters, '{bar}', CONCAT(COALESCE(counters->>'bar')::int + 1)::jsonb) WHERE id = 1;

### 操作

    []->int	 Get JSON object by index        '[{"a":"foo"},{"b":"bar"},{"c":"baz"}]'::json->2  {"c":"baz"}
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
    a||b    merge
    dic-'key'  delete key
    dic-'{k1,k2}' del
    arr-2       del 3nd valume
        '["a", "b"]'::jsonb - 1 → ["a"]
    jsonb-text[] → jsonb
        Deletes all matching keys or array elements from the left operand.
        '{"a": "b", "c": "d"}'::jsonb - '{a,c}'::text[] → {}
    #-path      del by path
        '["a", {"b":1}]'::jsonb#-'{1,b}' → ["a", {}]

path:

    '{1,kl2,kl3,kl4,5}'

### merge
merge jsonb via `||`:

    UPDATE users SET counters = counters || CONCAT('{"foo":', COALESCE(counters->>'foo','0')::int + 27, '}')::jsonb WHERE id = 1;

add jsonb via `jsonb_set`:

    jsonb_set('{"bar":1,"x":{}}'::jsonb, '{x,y}', 1::text::jsonb);
    {"x": {"y": 1}, "bar": 1}

## funtion
### json_array_elements
Expands a JSON array to a set of JSON values.	

    select * from json_array_elements('[1,true, [2,false]]');
    -----------
    1
    true
    [2,false]

Expands a JSON array to a set of text values.	

	select * from json_array_elements_text('["foo", "bar"]')
    -----------
    foo
    bar
