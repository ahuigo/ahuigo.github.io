---
title: k8s cmd
date: 2021-08-04
private: true
---
# install

    minikube addons enable ingress 
    minikube addons list | ag ingress

    # 查看ingress信息
    kubectl get ingress