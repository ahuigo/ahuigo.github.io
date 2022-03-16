---
title: es introduction
date: 2022-03-15
private: true
---
# es introduction
es是分布式全文搜索分析引擎
涉及以下概念
## 节点
它指的是Elasticsearch的单个运行实例。单个物理服务器可容纳多个节点

## 群集(类似database)
它是一个或多个节点的集合。群集为所有数据提供了跨所有节点的集体索引和搜索功能。

## 索引(表)
它是不同类型的文档及其属性的集合。索引还使用分片的概念来提高性能。
- 字段相当于列,
- 文档相当于行

## 文档
它是以JSON格式定义的特定方式的字段集合。每个文档都属于一种类型，并且位于索引内。每个文档都与一个称为UID的唯一标识符相关联。

## 碎片
索引在水平方向上细分为碎片。这意味着每个分片都包含文档的所有属性，但所包含的JSON对象的数量要少于索引。水平分隔使分片成为一个独立的节点，可以将其存储在任何节点中。主分片是索引的原始水平部分，然后将这些主分片复制到副本分片中。

## 副本
相当于tmp table:
Elasticsearch允许用户创建索引和碎片的副本。复制不仅有助于在发生故障时提高数据的可用性，而且还通过在这些副本中执行并行搜索操作来提高搜索性能。

## 优势
Elasticsearch是在Java上开发的，这使得它在几乎所有平台上都兼容。

Elasticsearch是实时的，换句话说，一秒钟后添加的文档就可以在这个引擎中搜索了

Elasticsearch是分布式的，因此可以轻松地在任何大型组织中进行扩展和集成。

使用 gateway 的概念创建完整的备份非常简单，这个概念在 Elasticsearch 很常见。

与Apache Solr相比，在Elasticsearch中处理多租户非常容易。

Elasticsearch使用JSON对象作为响应，这使得可以使用大量不同的编程语言来调用Elasticsearch服务器。

除了不支持文本渲染的文档类型外，Elasticsearch支持几乎所有文档类型。

缺点
在处理请求和响应数据方面，Elasticsearch不提供多语言支持（仅在JSON中可用），与Apache Solr不同，后者可以CSV，XML和JSON格式。

有时，Elasticsearch会出现脑裂情况的问题。

Elasticsearch和RDBMS之间的比较
在Elasticsearch中，索引类似于RDBMS（关系数据库管理系统）中的表。每个表都是行的集合，就像每个索引都是Elasticsearch中的文档的集合一样。