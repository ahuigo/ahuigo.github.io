---
title: Posgtre String
date: 2019-06-20
private:
---
# str
1. 字符串，只能用`'` 为边界，双引号`"`是用于关键字的(e.g. table_name)

postgre 不支持\ 转义 

    select '\\'; #按字面输出
    select '\''; #error 

插入单引号

    select 'ahui''s blog'; 
    select 'a''b' # 不支持 ’a\'b' 

### concat
    select 'a:'||'b'||1.2 as bb;
    select concat('a:','b', 1.2)
    select concat(key1,key2)

join:

    CONCAT_WS(separator,str_1,str_2,...);

join group:

    string_agg(actor, ', ') AS actor_list
    SELECT movie, string_agg(actor, ', ' ORDER BY actor) AS actor_list FROM   tbl GROUP  BY 1;


### string length

    CHAR_LENGTH(name)
    REPLACE(name, 'substring', '')