---
title: k8s helm
date: 2021-11-11
private: true
---
# k8s helm

## helm-chart 配置
以cadence 为例

    expose:
      enabled: true
      ports:
      - containerPort: 7933
        name: http
        protocol: TCP
      - name: http-7934
        containerPort: 7934
        protocol: TCP
    volumesPVC:
      enabled: true
      volumes:
      - name: cadence
        persistentVolumeClaim:
          claimName: cadence
      mounts:
      - name: cadence
        mountPath: /etc/cadence/config/dynamicconfig
    configMap:
      env:
        enabled: true
        data:
          CASSANDRA_SEEDS: host1,host2,host3
          CASSANDRA_PORT: '9042'
          KEYSPACE: cadence_dev
          SKIP_SCHEMA_SETUP: 'true'

文件映射：

    configMap:
      file:
        enabled: true
        data:
          conf.yaml: |
            env: dev
        mountPath: /config/conf.yaml
        subPath: conf.yaml

## azure cicd
 azure-pipelines.yml example

    stages:
    - stage: build
      jobs:
      - job: build
        steps:
        - bash: |
            targets="$(Build.DefinitionName)"
            IFS=" "
            arr=($targets)
    
            for s in ${arr[@]}
            do
              docker build -t "artifactory.xx.com/$(repository)/$s:$(Build.BuildNumber)" --build-arg APP_ENV=$(running_env) .
            done
    
            for s in ${arr[@]}
            do
              docker push "artifactory.xx.com/$(repository)/$s:$(Build.BuildNumber)"
            done
          displayName: 'docker build & push image for $(Build.BuildNumber)'

    - stage: dev
      displayName: dev
      dependsOn: build
      condition: and(succeeded(), eq(variables['build.sourceBranch'], 'refs/heads/dev'))
      jobs:
      - deployment:
        ....

## rancher
