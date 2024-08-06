---
title: k8s service
date: 2024-07-25
private: true
---
# service crud
Service 的作用有点像建立了一个`反向代理和负载均衡器`，负责把请求分发给后面的 pod。

## create service
    kubectl apply -f k8s/service.yaml

## get service

    #kubectl get services
    kubectl get svc
    kubectl get svc ginapp

## delete
    kubectl delete service ginapp

# service type
type分类
1. NodePort: k8s node 间访问
2. LoadBalancer: 外部访问

## type: NodePort
### 给node 分配一个port(30080), 转发

    # kubectl apply -f service.yaml
    ...
    spec:
      type: NodePort
      ports:
      - port: 4501        # Service port 对外暴露的端口, 
        targetPort: 4500  # service流量转发到的 Pod 上的端口
        nodePort: 30080  # 不写就随机分配的一个在 30000-32767 范围内的node端口。node 端口流量会被转发到 targetPort 上
      selector:
        app: ginapp

检查node ip 是否关联port

    $ kubectl get services ginapp
    NAME     TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
    ginapp   NodePort   10.106.234.54   <none>        4501:30080/TCP   2s

    # minikube 也可以查看
    minikube service ginapp

通过nodeIp+port 访问 pod

    $ kubectl get nodes -o json | jq -r '.items[] | {name:.metadata.name, ip:.status.addresses[] | select(.type=="InternalIP") .address}'
    { "name": "minikube-node", "ip": "192.168.49.2" }
    # 或
    $ minikube ip
    192.168.49.2

    $ curl 192.168.49.2:30080/echo/1

### 宿主机转发请求到 service port
minikube/k8s 宿主机的流量默认不会转发　nodePort, 也不会转发到 service port

让宿主机127.0.0.1:4502流量转发到 servicePort 4501

    kubectl port-forward svc/ginapp 4502:4501
    curl 127.0.0.1:4502/echo/1

怎么让宿主机外部ip:4501 的流量也能转发到　servicePort 或 nodePort 呢？用nat 映射(todo test)

    # 端口转发
    sudo iptables -t nat -A PREROUTING -p tcp --dport 30080 -j DNAT --to-destination $(minikube ip):30080
    sudo iptables -t nat -A POSTROUTING -j MASQUERADE

    # 清理
    sudo iptables -t nat -D PREROUTING -p tcp --dport 30080 -j DNAT --to-destination $(minikube ip):30080
    sudo iptables -t nat -D POSTROUTING -j MASQUERADE

## type: LoadBalancer
> LoadBalancer: 这种类型的 Service 除了具有 NodePort 的所有功能外.
k8s service 支持请求云提供商（如果有）为 Service 创建一个负载均衡器
1. 外部流量路由到这个负载均衡器
2. LoadBalancer 转发到节点的 NodePort
3. 最后 kube-proxy 将流量转发到后端 Pod

Minikube 可模拟一个负载均衡器(没有真正的外部负载均衡器，它仍然会为该服务分配一个 NodePort，并转发到Pods)

    spec:
      type: LoadBalancer
      ports:
      - port: 4501        # Service 对外暴露的端口, 
        targetPort: 4500  # service流量转发到的 Pod 上的端口
        nodePort: 30080  # 不写就随机分配的一个在 30000-32767的node端口。端口流量会被转发到 targetPort 上