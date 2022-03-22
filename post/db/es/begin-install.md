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

## running status

    http://es:49200/_cluster/health?pretty
