---
title: k8s helm
date: 2021-11-11
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

### helm charts
    - stage: dev
      displayName: dev
      dependsOn: build
      condition: and(succeeded(), eq(variables['build.sourceBranch'], 'refs/heads/dev'))
      jobs:
      - deployment:
        container: release
        displayName: deploy dev
        environment: 'map-dev'
        strategy:
          runOnce:
            deploy:
              steps:
              - checkout: hdmap-helm-charts
              - task: HelmDeploy@0
                inputs:
                  connectionType: 'Kubernetes Service Connection'
                  kubernetesServiceConnection: '$(kubernetes)-ack-dev'
                  namespace: 'dev'
                  command: 'upgrade'
                  chartType: 'FilePath'
                  chartPath: 'template-charts'
                  releaseName: '$(Build.DefinitionName)'
                  overrideValues: 'image.tag=$(Build.BuildNumber)'
                  valueFile: '$(Build.DefinitionName)/values_ack_dev.yaml'
                  arguments: '--debug'
                  failOnStderr: false


# helm command
    helm -h
    - helm search:    search for charts (workload)
    - helm pull:      download a chart to your local directory to view
    - helm install:   upload the chart to Kubernetes
    - helm list:      list releases of charts

## repo
    helm repo
    helm repo add - 添加chart仓库
    helm repo index - 基于包含打包chart的目录，生成索引文件
    helm repo list - 列举chart仓库
    helm repo remove - 删除一个或多个仓库
    helm repo update - 从chart仓库中更新本地可用chart的信息

## chart
    helm - 针对Kubernetes的Helm包管理器
    helm show all - 显示chart的所有信息
    helm show chart - 显示chart定义
    helm show crds - 显示chart的CRD
    helm show readme - 显示chart的README
    helm show values - 显示chart的values

## list all workloads

    helm list
    helm -n dev list
    helm -n dev list -h
    helm -n dev list --filter 'ara[a-z]+'

### remove workload
    helm -n dev uninstall <workload-name>
    helm -n dev uninstall cadence