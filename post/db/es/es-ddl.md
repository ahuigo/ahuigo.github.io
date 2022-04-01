---
title: elastic query
date: 2020-10-29
private: true
---
# ddl index
## 添加 index

    curl -XPUT http://es:49200/{index}
    curl -XPUT http://es:49200/index1

or via template json：

    # https://github.com/uber/cadence/blob/87b2eae366953ea908e7158f4cf06428bff8fa58/schema/elasticsearch/v6/visibility/index_template.json
	ES_SCHEMA_FILE=./schema/elasticsearch/v6/visibility/index_template.json
	curl -X PUT "http://127.0.0.1:9200/_template/cadence-visibility-template" -H 'Content-Type: application/json' -d "@$ES_SCHEMA_FILE"

### index 表达式
index 支持表达式

    <static_name{date_math_expr{date_format|time_zone}}>

    表达	解析为
    <accountdetail-{now-d}>	accountdetail-2015.12.29
    <accountdetail-{now-M}>	accountdetail-2015.11.30
    <accountdetail-{now{YYYY.MM}}>	accountdetail-2015.12

    # 读数据时
    /<accountdetail-{now-2d{YYYY.MM.dd|utc}}>/_search

注意：
1. static_name是表达式的一部分，保持不变
2. `date_math_expr`包含数学表达式，该数学表达式像`now-2d`一样动态确定日期和时间(表达2天前)。
3. `date_format`包含将日期写入诸如`YYYY.MM.dd`之类的索引中的格式。

### 自动建索引
默认是添加json 数据时，自动建索引（不必手动）。
可以通过将elasticsearch.yml文件中存在的以下参数的值更改为false来禁用此功能。

    action.auto_create_index:false
    index.mapper.dynamic:false

只允许使用具有特定模式的索引名称-自动建索引

    # + 允许 - 不允许
    action.auto_create_index:+acc*,-bank*


## 删除 index:

    curl -X DELETE "http://127.0.0.1:9200/cadence-visibility-dev2"
    curl -X DELETE "es2:49200/cadence-visibility-dev2"

## show index
### show index setting and mapping

    http://local:49200/{index-name}

### show index shards
一样的

    curl -s 'm:9200/{index}/_search?'
    curl -s 'm:9200/{index}/_doc/_search?'

# add data 
## 添加/更新数据
PUT/POST 都可以

    curl es:49200/school/_doc/1 -H 'Content-Type: application/json' -d ' {
        "name":"hilo",
        "age":1
    }'

## 数据加版本(更新数据)

    curl -XPUT 'es:49200/schools/_doc/5?version=7&version_type=external' -H 'Content-Type: application/json' -d '{
        "name":"Central School"
    }'

有两种最重要的版本控制类型-

1. 内部版本控制是默认版本，从1开始，并随着每次更新（包括删除）而递增。
2. 外部版本控制(指定版本)：要启用此功能`version_type设置为external`。

## 操作类型
操作类型用于强制执行创建操作。这有助于避免覆盖现有文档。下例如果已经创建过，会报错409

    PUT chapter/_doc/1?op_type=create
    {
    "Text":"this is chapter one"
    }

## 自动ID生成
如果在索引操作中未指定ID，则Elasticsearch会自动为该文档生成ID。

    POST chapter/_doc/
    {
        "user" : "tpoint"
    }


# read 数据
## 索引搜索
### list all indexes and type
    curl -s 'es:49200/_mapping?pretty=true' | jq 'to_entries | .[] | {(.key): .value.mappings | keys}'
    curl -s 'user:pass@localhost:9200/_mapping?pretty=true' | jq 'to_entries | .[] | {(.key): .value.mappings | keys}'

注意：

    .value.mappings | keys 代表 value['mappings'].keys()

### 搜索多个索引
    # 搜索所有
    curl es:49200/index1,index2,index3,school/_search 

    # 搜索来自index1, index2, index3,school 的JSON对象中包含 word1
    curl es:49200/index1,index2,index3,school/_search -H 'Content-Type: application/json' -d '{
        "query":{
            "query_string":{
                "query":"word1"
            }
        }
    }'

### _all 所有索引
    POST /_all/_search
    GET /_all/_search

### 通配符（*，+，–）

    POST 'es:49200/school*/_search'
    GET 'es:49200/school*/_search'

### 索引排除
搜索以`school`开头的索引，但不是来自school_gov

    POST '/school*,-schools_gov/_search'
    GET '/school*,-schools_gov/_search'
### 忽略索引报错
    POST /schools_pri*/_search?allow_no_indices=true

### 关闭索引
    curl es:49200/schools/_close

关闭索引后就不可以对索引读写了

## 响应结果
### 响应过滤
利用filter_path 过滤字段，类似jq

    curl 'es:49200/school/_search?filter_path=hits.total'
    // {"hits":{"total":3}}


## 读取指定id
    GET schools/_doc/5

特定文档的结果中指定所需的字段。

    GET schools/_doc/5?_source_includes=name,fees
    {
        "found" : true,
        "_source" : {
            "fees" : 2200,
            "name" : "Central School"
        }
    }

## 搜索URI
### q搜索key-value

    GET /_all/_search?q=city:paprola

除了q 外还有参数

    lenient
        此参数用于指定查询字符串。只要将此参数设置为 true，就可以忽略基于 Formatbased 的错误。默认false

    fields
        此参数用于指定查询字符串

    sort
        这个参数的可能值是fieldName, fieldName:asc/ fieldName:desc

    timeout
        限制搜索时间，并且响应只包含指定时间内的命中。默认情况下，没有超时
    terminate_after
        可以将响应限制为每个碎片的指定数量的文档，到达该分片时，查询将提前终止。默认情况下，没有 termin_after.
    from
        要返回的命中数的起始索引。默认为0。

    size
        它表示要返回的命中数，默认值为10。

## 正文搜索
    POST /schools/_search
    {
        "query":{
            "query_string":{
                "query":"word"
            }
        }
    }
    // word 区分大小写

# 删除API
您可以通过向Elasticsearch发送HTTP DELETE请求来删除特定的`索引/映射/文档`。

    # 删除文档4
    DELETE schools/_doc/4

# elastic query 语法
查询示例

    /{index}/{type}/{_id}?q=
    /{index}/{type}/_search?q=

    /{index}/_search?q=
    /weather/_doc/_search?q=
    /weather/beijing/_search?q=

查询配置（包括）

    '/{index}/_settings?pretty'

## query 结构
两种结构

json 查询

    curl -H 'Content-Type: application/json' 'm:9200/index/type/_search' -d '{"query":{"match":{"log":"ahui"}}}' | jq
    curl -H 'Content-Type: application/json' 'm:49200/cadence-visibility-staging/_search' -d '{"query":{"match":{"_id":"mss_base_workflow:47094f13-44b3-4212-9c2c-ff45db3a523c"}}}'

query结构, 注意AND 是大写

    q=NOT startTime:"1970-01-01T00:00:00Z" AND NOT endTime:"1970-01-01T00:00:00Z" AND startTime:[2020-10-18T00:00:00Z TO 2020-10-28T00:00:00Z] AND NOT taskDefName:FORK AND NOT taskDefName:DECISION AND NOT taskDefName:JOIN AND executionTime:[0 TO *] AND queueWaitTime:[0 TO *] AND status:COMPLETED

示例：


    $ curl 'localhost:9200/weather/beijing/abc?pretty=true'
    {
        "_index" : "accounts",
        "_type" : "person",
        "_id" : "abc",
        "found" : false
    }

我们主要讨论json 查询

## 查多层字段
    GET /my-index-000001/_search
    {
      "query": {
        "match": {
          "user.id": "kimchy"
        }
      }
    }
 
The API response returns the top 10 documents matching the query in the hits.hits property.

    "hits": [
      {
        "_index": "my-index-000001",
        "_type": "_doc",
        "_id": "kxWFcnMByiguvud1Z8vC",
        "_score": 1.3862942,
        "_source": {
          "@timestamp": "2099-11-15T14:12:12",
          "user": {
            "id": "kimchy"
          }
        }
      }
    ]

## 查询keyword

      "query": {
        "match": {
          "log": "word1"
        }
      }

种类

    match,  分词模糊匹配
    multi_match: 指定多字段
    match_all, 查询所有文档
    match_phrase, 短语匹配，必须匹配所有的分词并保证各个分词的相对位置不变(相当于strings.include)

### match_phrase
短语查询,slop定义的是关键词之间隔多少未知单词

    GET /library/books/_search 
    {
        "query":{
            "match_phrase" :{
                "query":"Elasticsearch,distributed",
                "slop":2                                 #表示Elasticsearch和distributed之间隔多少单词
            }
        }
    }
### multi_match
查询title和preview这两个字段都包含Elasticsearch关键词的文档

    GET /library/books/_search 
    {
        "query":{
            "multi_match":{
                "query":"Elasticsearch"
                "fields":["title","preview"]
            }
        }
    }

### match_all
通过match_all过滤出所有字段,然后通过partial在过滤出包含preview的字段和排除title,price的字段

    GET /library/books/_search 
    {
        "partial_fields":{
            "partial":{
                "include":["preview"],         #包含preview字段的文档
                "exclude":["title,price"]　　　 #排除title,price字段
            },
        "query":{
            "match_all":[]
            }
        }
    }

## 查value
where type="SUCCESS"

    "bool": {
      "must": [
          {
          "term": {
            "type": "SUCCESS"
          }
        },
        {
          "range": {
            "msgSubmissionTime": {
              "gte": "now-2m",
              "lt": "now"
            }
          }
        }
      ]
    }

### 查时间
query 查????

    query="StartTime>='2021-03-02T16:52:50+08:00' and User='ahuigo' and CloseTime=missing"

在body：

    curl -H 'Content-Type: application/json' 'm:9200/dev-index/_search' -d '{
        "from" : 0, "size" : 105,
        "query": {
            "bool":{
                "must":[
                    {"match":{"log":"MONITOR_LOG_TYPE"}},
                    {"match":{"kubernetes.container_name":"translog-format-worker"}},
                    {"range": {
                        "@timestamp":{"gte":"now-8h"}
                    }
                }
            ]}
        }
    '  | jq '.hits.hits[]._source["@timestamp"]'


## range 查询
    "query": {
        "range": {
            "age": {
                "gte": 10,
                "lte": 20,
                "boost": 2.0
            }
        }
    }

### range time
    "range": {
      "timestamp": {
        "time_zone": "+08:00",        
        "gte": "2020-01-01T00:00:00", 
        "lte": "now"                  
      }
    }

date 可以math计算，参考：https://www.elastic.co/guide/en/elasticsearch/reference/current/common-options.html#date-math

    "range": {
      "timestamp": {
        "gte": "now-1d",
        "gte": "now-1h",
        "gte": "now-1m", //minutes
        "lt": "now/d"
      }
    }


## and or 逻辑
或逻辑

    "query": {
        "match": {
            "log": "word1 word2"
        }
    }

与逻辑

    "query": {
        "bool": {
            "must": [
                { "match": { "log": "word1" } },
                { "match": { "log": "word2" } }
            ]
        }
    }
## sort
    sort=age:desc

# add and update
## add
    POST localhost:9200/<index>/<doctype>[/doctype[/doctype...]]
    POST localhost:9200/accounts/person/1 
    {
        "name" : "John",
        "lastname" : "Doe"
    }


    curl -X POST -H 'Content-Type: application/json' 'http://m:49200/cadence-visibility-staging/person/1' -d '{
        "name" : "John",
        "lastname" : "Doe"
    }'

## get
    GET localhost:9200/accounts/person/1 

The result will contain metadata and also the full document (shown in the _source field) :

    {
        "_index": "accounts",
        "_type": "person",
        "_id": "1",
        "_source": {
            "name": "John",
            "lastname": "Doe"
        }
    }

## update

    POST localhost:9200/accounts/person/1/_update
    {
        "doc":{
            "name" : "Hello John"
        }
    }
