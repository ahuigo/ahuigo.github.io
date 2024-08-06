---
title: kubectl cmd args
date: 2024-08-06
private: true
---
# kubectl args
使用 kubectl get <resource> 查看集群资源的状态信息

    kubectl get all
    -n , --namespace 指定命名空间: dev/production...
    -o wide 输出更加详细的资源信息
    --watch 会自动更新状态改变的部分
    -o yaml, -o json 将资源的配置文件输出为 yaml、json 格式 