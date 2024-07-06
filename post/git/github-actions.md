---
title: github actions
date: 2022-04-24
private: true
---
> refer：　ahuigo/arun/.github/workflows

# workflow结构
    on:
      push:
        branches:
          - "*"
        paths-ignore:
          - README.md
    
      pull_request:
        branches: [ main ]

    jobs:
        task1:
            ...
        task2:
            ...

## on event
> on push, on pull_request
https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#pull_request

### 触发push、pr 分支

    on:
      push:
        branches:
          - "*"
        paths-ignore:
          - README.md
      pull_request:
        branches: [master]

### 只触发tag 前缀
    on:
      push: 
        tags: 'v*'

### 触发所有
由于没有指定push tags/branches, 也没有指定pr branches, 所以push/pr 任何分支都会触发：参考github.com/ahuigo/gofnext

    on:
      push:
        tags:
        branches:
      pull_request:

# context

## Actions secrets and variables
新建secrets and variable：
- https://github.com/ahuigo/selfhttps/settings/secrets/actions/new

项目相关:
- 非Environments: secrets and variables
- Github Environments: 用于管理项目的不同部署环境(dev/prod/github_page), 例如环境保护规则（例如需要特定的人员审查和批准部署）、环境变量
    - 比如可以给github_page 建立一个独立的环境, 设置独立的**Environment secrets and variables**;
        - https://github.com/ahuigo/selfhttps/settings/environments/3196237909/edit

通常我们会放的secrets：

    secrets.DOCKERHUB_TOKEN
    secrets.CODECOV_TOKEN
    secrets.GITHUB_TOKEN(内置的) 

### GITHUB_TOKEN
secrets.GITHUB_TOKEN 是内置的:
- GITHUB_TOKEN as provided by **secrets** and requires **contents:write**

配置：https://docs.github.com/en/actions/security-guides/automatic-token-authentication

## env context

通过配置指定env 

    name: Hi Mascot
    on: push
    env:
      mascot: Mona
      super_duper_var: totally_awesome

    jobs:
      windows_job:
        runs-on: windows-latest
        steps:
          - run: echo 'Hi ${{ env.mascot }}'  # Hi Mona
          - run: echo 'Hi ${{ env.mascot }}'  # Hi Octocat
            env:
              mascot: Octocat

通过GIHTUB_ENV 文件指定ENV：https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables

      - name: Set GOVERSION
        run: echo "GOVERSION=$(go version | sed -r 's/go version go(.*)\ .*/\1/')" >> $GITHUB_ENV
      - name: Set AppVersion
        run: echo "VERSION=${GITHUB_REF#refs/tags/}" >> $GITHUB_ENV
      - name: Show version
        run: echo ${{ env.GOVERSION }} ${{ env.VERSION }}

    注意：
        shell 环境变量语法
            ${GITHUB_REF#refs/tags/} $GITHUB_ENV　
        github 变量语法
            ${{ env.VERSION }} 

注意以为语法独立于.gorelease.yaml 自造的语法: 

    # https://goreleaser.com/customization/templates/
    -X "main.BuildVersion={{.Version}}" # git tag version
    # https://goreleaser.com/customization/env/
    -X "main.GoVersion={{.Env.GOVERSION}}"

## vars context
github vars　context　示例(vars　设置见上面的secrets and variables)

    jobs:
      display-variables:
        name: ${{ vars.JOB_NAME }}
        # You can use configuration variables with the `vars` context for dynamic jobs
        if: ${{ vars.USE_VARIABLES == 'true' }}
        runs-on: ${{ vars.RUNNER }}
        environment: ${{ vars.ENVIRONMENT_STAGE }}
        steps:
        - name: Use variables
          run: |
            echo "repository variable : $REPOSITORY_VAR"
            echo "organization variable : $ORGANIZATION_VAR"
            echo "overridden variable : $OVERRIDE_VAR"
            echo "variable from shell environment : $env_var"
          env:
            REPOSITORY_VAR: ${{ vars.REPOSITORY_VAR }}
            ORGANIZATION_VAR: ${{ vars.ORGANIZATION_VAR }}
            OVERRIDE_VAR: ${{ vars.OVERRIDE_VAR }}

## 内置context
    github.event_name
    github.repository
    runer.os


### github context

    jobs:
      Explore-GitHub-Actions:
        runs-on: ubuntu-latest
        steps:
        - run: echo "${{ github.event_name }} event."
        - run: echo "${{ runner.os }} server hosted "
        - run: echo "${{ github.ref }} branch and repo ${{ github.repository }}."
        - name: Check out repository code
            uses: actions/checkout@v3
        - name: List files in the repository
            run: |
            ls ${{ github.workspace }}
        - run: echo "${{ job.status }}."

### runner context
      - name: condition 2
        if: runner.os != 'Windows'
        run: echo "The operating system on the runner is not Windows"

# jobs.task.steps
task 由steps构成

## task
### strategy
这是task局部的配置变量, 这里表示将会在 Redis 6 和 Redis 7 环境中各运行一次

    jobs:
      test:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            redis-version: [6, 7]
        steps:
        - uses: actions/checkout@v2
        - name: Start Redis
          uses: supercharge/redis-github-action@1.7.0
          with:
            redis-version: ${{ matrix.redis-version }}
        ....
### steps
#### use other step rule

    jobs:
      job-docker:
          #uses: ./docker.yml
          uses: ahuigo/arun/.github/workflows/docker.yml@master
          with: 
            run_on: ubuntu-latest

# action 权限设置
参考：https://github.com/ahuigo/selfhttps/settings/actions