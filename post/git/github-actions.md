---
title: github actions
date: 2022-04-24
private: true
---
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

# on event
## exclude files
    on:
      push:
        branches:
          - "*"
        paths-ignore:
          - README.md

# jobs
## steps
### use other step rule

    docker:
      #uses: ./docker.yml
      uses: ahuigo/arun/.github/workflows/docker.yml@master
      with: 
        run_on: ubuntu-latest
