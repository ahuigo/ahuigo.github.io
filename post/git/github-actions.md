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

    on:
      push:
        branches:
          - "*"
        paths-ignore:
          - README.md
      pull_request:
        branches: [master]

# 内变量

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
