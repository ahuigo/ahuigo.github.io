---
title: 配置中心方案比较
date: 2024-04-29
private: true
---
# 配置中心比较
consul,nacos,apollo
etcd：由 CoreOS 开发的一个开源的、高可用的分布式键值存储系统，可以用于配置管理、服务发现和共享锁等场景。
- 服务发现：
  - 注册：服务将自己的addr 写到kv 中
  - 发现：其它服务watch　这个key

Consul: 由 HashiCorp 开发的一个服务网络解决方案，提供了服务发现和键值存储功能，可以用作配置中心。
- doc: https://kingfree.gitbook.io/consul/day-1-operations/acl-guide

Nacos：虽然 Nacos 主要是 Java 开发的，但它的 Go 客户端也非常成熟。Nacos 是阿里巴巴开源的一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。
- doc: https://nacos.io/docs/ebook/ktwggk/
- Raft 和 Distro 
    1. raft 强一致性共识算法 
    2. Distro 协议是阿里巴巴自研的一个最终一致性协议
- demo: https://console.nacos.io/nacos/index.html#/configurationManagement?dataId=&group=&appName=&namespace=&pageSize=&pageNo=

Apollo：Apollo 是携程开源的配置中心，它的客户端支持多种语言，包括 Go。
- doc: https://www.apolloconfig.com/#/zh/deployment/quick-start?
- demo: 输入用户名apollo，密码admin后登录

r-Nacos: rust 实现的nacos
- doc: https://github.com/nacos-group/r-nacos?tab=readme-ov-file
- demo: 地址： https://www.bestreven.top/rnacos/ 用户名: dev ,密码: dev

## summary
我们用的配置中心是 apollo 。实地调研的结果是，consul 和 etcd 作为配置中心没有图形化的界面、权限管理、环境管理等，需要自己开发，最后选择了 apollo 。

# 配置中心的功能
- 基础配置支持: getConf('key')
- 监听配置变更
- 多级key支持：
  - 支持读取nested key: getConf('db') 能读取 getConf('db.pg'), getConf('db.redis')
- 权限控制
  - 多级key的权限控制: 比如即可以对'db' 配置权限，也可以对子级key 比如`db.pg`、`db.redis`单独配置权限
  - 权限角色支持用户组、用户：角色成员即可以加用户，也可以加用户组
- 支持配置引用, 比如：
  - 
  ```
  postgres1: &public.db.pg # 这里引用了pg的配置
  postgres2: 
    host: &public.db.pg.host # 这里引用了pg的host配置
    password: &public.db.pg.password # 这里引用了pg的password 配置
  redis: &public.db.redis # 这里引用了redis的配置
  ```
  - 方案1：sdk自行实现配置引用, 缺点：yaml 本身语义会丢失引用信息
  - 方案2：在yaml 中支持引用, 需要改造yaml 解析并支持引用(注意避免递归引用)
  - 方案3：不需要支持引用
- 支持配置继承：
  - 
  ```
  << default/mpush/conf_default.yaml # 继承默认配置 conf_default
  postgres: 
    host: pg.production.com
  ```
- 支持配置版本管理
- 客户端sdk/ui支持：
  - 前端UI 支持
  - Client SDK支持: 支持生成各语言的sdk sample, curl/go/python/js
- code example


