---
title: k8s registry secret
date: 2024-07-25
private: true
---
# docker registry
如果　image　registry需要认证的话，就要配置secret

    kubectl create secret docker-registry ginappregcred --docker-server=registry.my.com --docker-username=myusername --docker-password=mypassword --docker-email=myemail

deployment.yml

    kind: Deployment
    metadata:
      name: ginapp
    spec:
      template:
        spec:
          containers:
          - name: ginapp
            image: ginapp
          imagePullSecrets:
          - name: ginappregcred