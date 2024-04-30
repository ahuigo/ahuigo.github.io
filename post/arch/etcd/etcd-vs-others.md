---
title: 配置中心比较
date: 2024-04-29
private: true
---
# 配置中心比较
etcd：由 CoreOS 开发的一个开源的、高可用的分布式键值存储系统，可以用于配置管理、服务发现和共享锁等场景。
- 服务发现：
  - 注册：服务将自己的addr 写到kv 中
  - 发现：其它服务watch　这个key

Consul：由 HashiCorp 开发的一个服务网络解决方案，提供了服务发现和键值存储功能，可以用作配置中心。

Nacos：虽然 Nacos 主要是 Java 开发的，但它的 Go 客户端也非常成熟。Nacos 是阿里巴巴开源的一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。
- doc: https://nacos.io/docs/ebook/ktwggk/
- Raft 和 Distro 
    1. raft 强一致性共识算法 
    2. Distro 协议是阿里巴巴自研的一个最终一致性协议
- demo: https://console.nacos.io/nacos/index.html#/configurationManagement?dataId=&group=&appName=&namespace=&pageSize=&pageNo=

Apollo：Apollo 是携程开源的配置中心，它的客户端支持多种语言，包括 Go。
- doc: https://www.apolloconfig.com/#/zh/deployment/quick-start?
- demo: 输入用户名apollo，密码admin后登录


# 配置中心
- 多级key支持：
  - 支持读取nested key: getConf('db') 能读取 db.pg db.mysql
- 权限控制
  - 多级key的权限控制
  - 支持用户组权限控制
- 支持配置引用：
  - ```
  postgres: 
    host: &public.postgres.host # 引用全局的配置
  ```
  - sdk自行引用公共的配置，比如mysql/postgres/redis的 hostname; 缺点：yaml 本身语义会丢失引用信息
  - 在yaml 中支持引用(sdk 默认不开启引用): 需要改造yaml 解析并支持引用; 有限递归
  - 不支持引用：全局修改postres.host 的话，需要深度遍历所有的配置，并调用api 修改: 开发简单, 但是不方便开发者自行管理
- 支持配置继承：(不太重要)
  - ```
  << default/mpush/conf_default.yaml # 继承默认配置
  postgres: 
    host: pg.production.com
  ```

- value 类型支持：text/json/yaml/toml
- 历史日志
- 查看：
  - 前端
  - SDK: 支持生成各语言的sdk sample, curl/go/python/js
  - cli


