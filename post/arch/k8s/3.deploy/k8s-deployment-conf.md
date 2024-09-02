---
title: k8s deployment config
date: 2024-07-26
private: true
---
# deployment strategy

    spec:
      replicas: 10
      minReadySeconds: 10
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 1
          maxSurge: 1

说明:

    minReadySeconds: 10 指在更新了一个 pod 后，需要在它进入正常状态后 10 秒再更新下一个 pod；
    maxUnavailable: 1 指同时处于不可用状态的 pod 不能超过一个；
        这样 Kubernetes 就会逐个替换 service 后面的 pod。
    maxSurge: 1 指更新过程中新pod 最大上限, 这里是只能新启一个, 默认是25%(即最多新启动25%)

# env && args && command

    spec:
      containers:
      - name: ginapp
        args:
        - -p
        - 4500
        command:
        - ginapp
        env:
        - name: TZ
          value: Asia/Shanghai

# specify log file
    spec:
      containers:
      - image: app1
        name: app1
        terminationMessagePath: /xx/termination-log
        terminationMessagePolicy: File
