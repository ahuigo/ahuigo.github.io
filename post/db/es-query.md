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
    curl -s '.../_mapping?pretty=true' | jq 'to_entries | .[] | {(.key): .value.mappings | keys}'


# elastic query 语法
查询示例

    /{index}/{type}/_search?q=
    /{index}/{type}/{_id}?q=
    /{index}/_search?q=
    /weather/_doc/_search?q=
    /weather/beijing/_search?q=

## query 结构
两种结构

json 查询

    curl -H 'Content-Type: application/json' 'm:9200/index/type/_search' -d '{"query":{"match":{"log":"ahui"}}}' | jq

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
        "lastname" : "Doe",
        "job_description" : "Systems administrator and Linux specialit"
    }
## get
    GET localhost:9200/accounts/person/1 

The result will contain metadata and also the full document (shown in the _source field) :

    {
        "_index": "accounts",
        "_type": "person",
        "_id": "1",
        "_source": {
            "name": "John",
            "lastname": "Doe",
            "job_description": "Systems administrator and Linux specialit"
        }
    }

## update

    POST localhost:9200/accounts/person/1/_update
    {
        "doc":{
            "job_description" : "Systems administrator and Linux specialist"
        }
    }
