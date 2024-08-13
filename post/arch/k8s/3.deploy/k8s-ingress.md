---
title: k8s cmd
date: 2021-08-04
private: true
---
# Preface
## ingress vs LoadBalancer
- LoadBalancer: 每个service 都要创建独立的外部负载均衡，成本较高。
- Ingress：更复杂、更灵活的流量路由机制。
  - 提供 SSL/TLS 、域名称基础的虚拟主机等
  - Ingress　controller: 内置inginx或使用支厂商的(如AWS ALB)
## install

    minikube addons enable ingress 
    minikube addons list | ag ingress

# 使用ingress
## 编写ingress
> 参考：https://github.com/ahuigo/ginapp/blob/main/k8s/ingress.yml
类似nginx location路由:

    - path: '/(.*)'
      pathType: Prefix
      backend:
        service:
          name: ginapp
          port:
            number: 4501      # servicePort
    - path: /v2/(.*)          # /v2/xxx -> /xxx
      pathType: ImplementationSpecific
      backend:
        service:
          name: ginapp  # 也可以是其他service
          port:
            number: 5500

service.port.number 是servicePort. 
> 如果填写targetPort, 且与servicePort不一致，minikube 下测试也可以用(可能是k8s 自动修复)

3种pathType:
1. Prefix: 前缀匹配; 优先匹配最长的路径; 没有rewrite
2. Exact: 完全相等；
3. ImplementationSpecific: 由 Ingress 控制器来决定 rewrite

## create ingress service

    #kubectl apply -f http://xxx/ingress.yml 
    kubectl apply -f k8s/ingress.yml 

delete ingress

    kubectl delete ingress <ingress-name> -n <namespace>
    kubectl delete -f k8s/ingress.yml

## get ingress
查看ingress信息

    $ kubectl get ingress
    NAME             CLASS   HOSTS          ADDRESS        PORTS   AGE
    ginapp-ingress   nginx   ginapp.local   192.168.49.2   80      4m30s

这里的ADDRESS 是什么ip:
1. 在云环境中，ADDRESS 可能是一个负载均衡器的公共 IP, 通过它访问集群中的服务。
1. 在私有环境中，ADDRESS 可能是NodeIp
### describe ingress
    $ kubectl describe ingress ginapp-ingress
    ginapp.local  
                /(.*)      ginapp:4501 (svc.port1:4500,svc.port2:4500)
                /v2/(.*)   ginapp:5500 (10.12.0.33:5500,10.12.0.34:5500)

### test ingress

    echo '192.168.49.2 ginapp.local' >> /etc/hosts
    kubectl logs -l app=ginapp -f

    curl ginapp.local/dump/1

