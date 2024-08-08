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

## output
### format
    kubectl get deployment ginapp -o yaml
    kubectl get deployment ginapp -o json


### jsonpath
via key.fields

    kubectl get deployment ginapp -o jsonpath='{.spec.template.spec.containers[*].name}'

via range

    kubectl get pods -l app=<deployment-name> -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.name}{", "}{end}{end}'