---
title: k8s etcd
date: 2024-04-15
private: true
---
# k8s etcd
在 Kubernetes 中，可以使用 StatefulSet 来部署一个由 10 个 etcd Pod 组成的集群。以下是配置示例：

    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: etcd
    spec:
      serviceName: "etcd"
      replicas: 10
      selector:
        matchLabels:
          app: etcd
      template:
        metadata:
          labels:
            app: etcd
        spec:
          containers:
          - name: etcd
            image: quay.io/coreos/etcd:v3.4.13
            ports:
            - containerPort: 2379
              name: client
            - containerPort: 2380
              name: server
            volumeMounts:
            - name: data
              mountPath: /var/run/etcd
            env:
            - name: ETCD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: ETCD_INITIAL_CLUSTER
              value: "etcd-0=http://etcd-0.etcd:2380,etcd-1=http://etcd-1.etcd:2380,etcd-2=http://etcd-2.etcd:2380,etcd-3=http://etcd-3.etcd:2380,etcd-4=http://etcd-4.etcd:2380,etcd-5=http://etcd-5.etcd:2380,etcd-6=http://etcd-6.etcd:2380,etcd-7=http://etcd-7.etcd:2380,etcd-8=http://etcd-8.etcd:2380,etcd-9=http://etcd-9.etcd:2380"
            - name: ETCD_INITIAL_CLUSTER_STATE
              value: "new"
            - name: ETCD_INITIAL_CLUSTER_TOKEN
              value: "etcd-cluster"
            - name: ETCD_LISTEN_PEER_URLS
              value: "http://0.0.0.0:2380"
            - name: ETCD_LISTEN_CLIENT_URLS
              value: "http://0.0.0.0:2379"
      volumeClaimTemplates:
      - metadata:
          name: data
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 1Gi