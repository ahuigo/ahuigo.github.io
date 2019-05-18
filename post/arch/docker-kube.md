---
title: kubectl
date: 2019-05-16
private:
---
# kubectl
使用 Kubectl

## logs

    kubectl get pod -n dev-namespace
    kubectl logs -f node-name -n dev-namespace


#查看资源状态

    # 使用 kubectl get <resource> 查看集群资源的状态信息
    # -n , --namespace 指定命名空间
    # -o wide 输出更加详细的资源信息]
    # --watch 会自动更新状态改变的部分
    # -o yaml, -o json 将资源的配置文件输出为 yaml、json 格式
 
 
# 查看集群节点信息
kubectl get node
 
 
# 查看命名空间信息
kubectl get namespace
 
 
# 查看副本信息
kubectl get pod
 
 
# 查看服务信息
kubectl get service
 
 
# 查看ingress信息
kubectl get ingress
查看服务日志
# 首先要 kubectl get pod -n <namespace> 获得想要查看的podname
#
kubectl logs <pod-name> -n <namespace>
删除、重启、部署资源
# 部署
kubectl apply -f <config-file>
 
 
# 删除
# 通过部署文件删除
kubectl delete -f <config-fiel>
 
 
# 重启pod, 直接删除pod，会自动重启
kubectl delete pod <podname> -n <namespace>
进入容器
#类似于 docker的命令
# 如果一个 pod 内有多个 container， 加上 -c <conatainer-name>
kubectl exec -ti <pod-name> bash/sh
 
 
# 复制文件或者文件夹
kubectl cp <source-file-path> <pod-name>:<target-path> -n <namespace>