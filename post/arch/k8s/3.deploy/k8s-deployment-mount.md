---
title: k8s mount
date: 2024-09-02
private: true
---
# k8s mount

## mount path
    spec:
      containers:
      - image: app1
        volumeMounts:
        - mountPath: /config/conf.yaml  # 指定挂载点
          name: my-conf-file    # 指定使用volume
          subPath: conf.yaml  # 可选，指定volumes 中的子目录或文件
      volumes: 
      - name: my-conf-file # 定义volume
        configMap:
          name: myconf-file
          defaultMode: 420

定义其它volumes 

      volumes: # 定义volume
      - name: timezone
        hostPath:
          path: /usr/share/zoneinfo/Asia/Shanghai
          type: ""

# configmap 管理
## configmap 定义
### create configmap
    kubectl create configmap my-config --from-file=path/to/my/file

### update configmap
    kubectl edit configmap <configmap-name>
    # or
    kubectl delete configmap <configmap-name>
    kubectl create configmap my-config --from-file=path/to/my/file

### 使用configmap file

    spec:
      containers:
      - name: my-container
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
      volumes:
      - name: config-volume
        configMap:
          name: my-config

#### 指定子文件
    kubectl create configmap my-config --from-file=my-key=path/to/my/file

    $ cat deploy.yaml
    # 容器 my-container 可以访问 /etc/config/my-file 文件
    volumes:
      - name: config-volume
        configMap:
          name: my-config
          items:
          - key: my-key
            path: my-file

## get configmap

    # 1. find configmap name
    kubectl describe deployment <deployment-name>

    # 2. get configmap content by name
    kubectl get configmap <configmap-name> -o yaml
    kubectl describe configmap <configmap-name> -o yaml
        kubectl describe configmap myconf-file
