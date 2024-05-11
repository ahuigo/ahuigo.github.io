---
title: jq
date: 2020-06-24
private: true
---
# jq
> 最近同事用jq 配合做压测，做一个笔记

常规用法

    jq -ncM '{key:"v"}'

jq 参数：

    -n 无输入
    -c 紧凑输出（无换行）
    -M 输出无终端color

## 随机数据

    jq -ncM 'while(true; .+1) | {method: "POST", body: {"num":("num"+(.|tostring))}}'

    while(true; .+1) 中对.这个变量进行自增


# 管道
jq 支持管道，比如我们利用管道生成base64

    > jq -ncM '{body: "data" | @base64 }'
    {"body":"ZGF0YQ=="}
    > jq -ncM 'while(true; .+1) | {method: "POST", body: {"num":("num"+(.|tostring))} | @base64 }'

## select/filter

    jq '.data[]  | select(.domain == "domain2") | .prop'

    curl -s https://api.github.com/repos/go-swagger/go-swagger/releases/latest | \
    jq -r '.assets[] | select(.name | contains("'"$(uname | tr '[:upper:]' '[:lower:]')"'_amd64")) | .browser_download_url'

note:

    $ echo "$(uname | tr '[:upper:]' '[:lower:]')" 
    darwin

## to_entries
map 转数组：

    echo '{"k1":"v1"}' | jq 'to_entries'
    [ { "key": "k1", "value": "v1" } ]

## 数组

### 数组取值 index
    # 取全部
    echo '{"k1":"v1"}' | jq 'to_entries | .[]'

    # 第0个
    echo '{"k1":{"name":"ahui"},"k2":{"name":"go"}}' | jq 'to_entries | .[1] '
    { "key": "k1", "value": { "name": "ahui" } }


### 数组取值 prop
    curl url | jq '.executions[]|.closeTime'
    curl url | jq '.executions[].closeTime'
    curl url | jq '.stus.names[]._source["@timestamp"]'

    jq -c '.[]|.task_name'

### 取多个props

    $ echo '[{"user":"Alex", "age":1,"extra":{"no":1}},{"user":"John","age":2,"extra":{"father":"Li"}}]' | jq '.[] | "\(.user): \(.age)"'
    "Alex: 1"
    "John: 2"

### 数组map
对数组每一item 取`keys(item['mappings'])`

    curl -s 'es:49200/_mapping?pretty=true' | jq 'to_entries | .[] | {(.key): .value.mappings | keys}'

### 数组filter

    jq '.data.users[] | select(.name=="Alex")'
    jq '.data.users[] | select(.name=="Alex") | "name=\(.name) \(.job)"'

### map merge other jq query

    $ cat a.json
        {
        "id": 1,
        "name": "ox",
        "items": [
            {"key":1,"name":"alex"},
            {"key":2,"name":"alex2"}
        ],
        }                        
    $ jq '"id=\(.id) item=\(.items[] | "\(.key)\(.name)")"' a.json
    "id=1 item=1alex"
    "id=1 item=2alex2"

## 对象
### 获取keys:
    echo '[{"user":"Alex", "age":1,"extra":{"no":1}},{"user":"John","age":2,"extra":{"father":"Li"}}]' | jq '.[].extra | keys

## inner json
    echo '{"data":"{\"age\":1}"}' |  jq '.data|fromjson|.age'
    echo '"{\"age\":1}"' |  jq -r 'fromjson|.age'

## string
how to trim quotes?

    echo '"abc"' | jq
    echo '"abc"' | jq -r .