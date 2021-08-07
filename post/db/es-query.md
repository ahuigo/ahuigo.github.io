---
title: elastic query
date: 2020-10-29
private: true
---
# install & run
    brew install elasticsearch
    # run server
    $ ./bin/elasticsearch

## config
默认情况下，Elastic 只允许本机访问，如果需要远程访问，可以修改 config/elasticsearch.yml文件，去掉network.host的注释

    network.host: 0.0.0.0

# read 数据
## list all indexes and type
    curl -s 'm:9200/_mapping?pretty=true' | jq 'to_entries | .[] | {(.key): .value.mappings | keys}'
    curl -s 'user:pass@localhost:9200/_mapping?pretty=true' | jq 'to_entries | .[] | {(.key): .value.mappings | keys}'

注意：

    .value.mappings | keys 代表 value['mappings'].keys()

## list one index
一样的

    curl -s 'm:9200/index/_search?'
    curl -s 'm:9200/index/_doc/_search?'


# elastic query 语法
查询示例

    /{index}/{type}/_search?q=
    /{index}/{type}/{_id}?q=
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

# get and update
## add
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
