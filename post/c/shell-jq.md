---
title: jq
date: 2020-06-24
private: true
---
# jq
> 最近同事用jq 配合做压测，做一个笔记


## format
常规用法

    jq -ncM '{key:"v"}'

jq 参数：

    -n 无输入
    -c 紧凑输出（json无换行）
    -M 输出无终端color

### 解析字符串

    # -r 解析字符串
    printf %s '"a\nv"'  | jq 
    printf %s '"a\nv"'  | jq -r

## 随机数据

    jq -ncM 'while(true; .+1) | {method: "POST", body: {"num":("num"+(.|tostring))}}'

    while(true; .+1) 中对.这个变量进行自增

# 控制语句
## if else

    echo '{"value": 10}' | jq 'if .value > 5 then "greater" else "smaller" end'

    echo '{"value": 10}' | jq 'if .value > 5 then "greater" else "smaller" + obj end'
# 变量

设置入口变量$：

    echo '{"value": 10}' | jq --arg obj " than 5" 'if .value > 5 then "greater" else "smaller" + $obj end'
    echo '{"value": 10}' | jq --arg obj "than 5" 'if .value > 5 then "greater " + $obj else "smaller " + $obj end'

动态设置变量$

    echo '{"value": 10}' | jq 'if .value > 5 then . as $obj | "greater " + ($obj | tostring) else . as $obj | "smaller " + ($obj | tostring) end'

# 管道
jq 支持管道，比如我们利用管道生成base64

    > jq -ncM '{body: "data" | @base64 }'
    {"body":"ZGF0YQ=="}
    > jq -ncM 'while(true; .+1) | {method: "POST", body: {"num":("num"+(.|tostring))} | @base64 }'

## select/filter

    jq '.data[]  | select(.domain == "domain2") | .prop'
    jq '.package_name_list + [.data[] | select (.package_name | startswith("ddld")) |.package_name]'

        select (.package_name | startswith("ddld"))：从 data 数组中选择那些其 package_name 属性的值以 "ddld" 值开始的元素。
        |.package_name：从上一步选择的元素中获取 package_name 的值。
        +：将 package_name_list 的值和新创建的数组合并

    curl -s https://api.github.com/repos/go-swagger/go-swagger/releases/latest | \
    jq -r '.assets[] | select(.name | contains("'"$(uname | tr '[:upper:]' '[:lower:]')"'_amd64")) | .browser_download_url'

note:

    $ echo "$(uname | tr '[:upper:]' '[:lower:]')" 
    darwin

## nested pipe
    cat <<-MM | jq -r '.|{name:.metadata.name, ip:.status.addresses[] | select(.type=="InternalIP") .address}'
    {
    "metadata": { "name": "minikube"},
    "status": {
        "addresses": [
            { "address": "192.168.49.2",  "type": "InternalIP" },
            { "address": "193.168.49.3",  "type": "OuterIP" }
        ]
    }}
    MM


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
        ]
        }                        
    $ jq '"id=\(.id) item=\(.items[] | "\(.key)\(.name)")"' a.json
    "id=1 item=1alex"
    "id=1 item=2alex2"

解释一下：

    放双引号是为了拼接字符串
    放\(...)是为了插入表达式

print`id: name[]`:

    $ jq -r '"id=\(.id) names=\(.items | map(.name) | join(","))"' a.json
    id=1 names=alex,alex2

### map reduce:join

    $ cat b.json
    [ {
        "id": 9145,
        "issue_bags": [
            {
                "children": { "issue_bag_md5": "x1" }
            },
            {
                "children":{ "issue_bag_md5": "x2" }
            }
        ]
    }]

how to print `id:issue_bag_md5[]`

    $ jq -r '.[] | "id=\(.id) issue_bag_md5=\(.issue_bags[] | .children.issue_bag_md5)"' b.json
    id=9145 issue_bag_md5=x1
    id=9145 issue_bag_md5=x2
    
    $ jq -r '.[] | "id=\(.id) issue_bag_md5=\(.issue_bags | map(.children.issue_bag_md5) | join(","))"'  b.json 
    id=9145 issue_bag_md5=x1,x2

解释一下：

    .issue_bags[]：这种写法用于遍历 issue_bags 数组中的每一个元素
    .issue_bags：代表数组整体
    map(.children.issue_bag_md5): 搜索map 函数，它的结果是数组
    join(",") : 它的结果是字符串

### map: generate dict
对数组每一item 取`keys(item['mappings'])`

    curl -s 'es:49200/_mapping?pretty=true' | jq 'to_entries | .[] | {(.key): .value.mappings | keys}'

    cat <<-MM | jq 'to_entries | .[] | {(.key): .value.mappings | keys}'
    {
    "fruit": {
        "mappings": { "color": "red", "size": "large" }
    },
    "vegetable": {
        "mappings": { "color": "green", "size": "small" }
    }}

## 对象
### 获取keys:
    echo '[{"user":"Alex", "age":1,"extra":{"no":1}},{"user":"John","age":2,"extra":{"father":"Li"}}]' | jq '.[].extra | keys

## inner json
    echo '{"data":"{\"age\":1}"}' |  jq '.data|fromjson|.age'
    echo '"{\"age\":1}"' |  jq -r 'fromjson|.age'

## string
### concat　string
    jq -r '.data.users[] | select(.name=="Alex") | "name=\(.name) \(.job)"'
### how to trim quotes?

    echo '"abc"' | jq
    echo '"abc"' | jq -r .