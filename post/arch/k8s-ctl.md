---
title: k8s ctl
date: 2021-12-25
private: true
---
# k8s ctl
## 常用命令
    # 部署应用
    kubectl apply -f app.yaml
    # 查看 deployment
    kubectl get deployment
    # 查看 pod
    kubectl get pod -o wide
    # 查看 pod 详情
    kubectl describe pod pod-name
    # 查看 log
    kubectl logs pod-name
    # 进入 Pod 容器终端， -c container-name 可以指定进入哪个容器。
    kubectl exec -it pod-name -- bash
    # 伸缩扩展副本
    kubectl scale deployment test-k8s --replicas=5
    # 把集群内端口映射到节点
    kubectl port-forward pod-name 8090:8080
    # 查看历史
    kubectl rollout history deployment test-k8s
    # 回到上个版本
    kubectl rollout undo deployment test-k8s
    # 回到指定版本
    kubectl rollout undo deployment test-k8s --to-revision=2
    # 删除部署
    kubectl delete deployment test-k8s

其它：

    # 查看全部
    kubectl get all
    # 重新部署
    kubectl rollout restart deployment test-k8s
    # 命令修改镜像，--record 表示把这个命令记录到操作历史中
    kubectl set image deployment test-k8s test-k8s=ccr.ccs.tencentyun.com/k8s-tutorial/test-k8s:v2-with-error --record
    # 暂停运行，暂停后，对 deployment 的修改不会立刻生效，恢复后才应用设置
    kubectl rollout pause deployment test-k8s
    # 恢复
    kubectl rollout resume deployment test-k8s
    # 输出到文件
    kubectl get deployment test-k8s -o yaml >> app2.yaml
    # 删除全部资源
    kubectl delete all --all

还有：

    $ kubectl apply -n <namespace> -f <servicename>
    $ kubectl edit deployments.apps -n <namespace> <servicename>

    $ kubectl get pod -n <namespace>
    $ kubectl exec -it  -n <namespace> <servicename>-7994cf9f84-44x7b bash
    $ kubectl logs -n <namespace>  <servicename>-7994cf9f84-44x7b
        $ kubectl logs -n <namespace> -f <servicename>-7994cf9f84-44x7b

## 查看
    kubectl get node
    kubectl get pod

# pod

# Reference
- k8s 教程：https://k8s.easydoc.net/docs/dRiQjyTY/28366845/6GiNOzyZ/puf7fjYr