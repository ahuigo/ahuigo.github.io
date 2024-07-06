---
title: github cicd
date: 2023-12-06
private: true
---
# cicd示例
以golang 项目为例子: 
- https://github.com/ahuigo/gofnext/tree/main/.github/workflows
- https://github.com/ahuigo/selfhttps/tree/main/.github/workflows

# codecov
## 1. add repe secrets
https://github.com/ahuigo/gofnext/settings/secrets/actions/new

    #{{secrets.CODECOV_TOKEN}}
    CODECOV_TOKEN=xxx

## 2. add Codecov to your GitHub Actions workflow yaml file: `.github/workflows/[task].yml`

    - name: Upload coverage reports to Codecov
      uses: codecov/codecov-action@v3
      env:
        token: ${{ secrets.CODECOV_TOKEN }}
        file: ./cover.out
        flags: unittests
        verbose: true

uses action.yml 文件实际位于: https://github.com/codecov/codecov-action/blob/v3/action.yml
其中的runs 指明了执行的文件

    name: 'Codecov'
    description: 'uploads coverage reports for your repository to codecov.io'
    author: 'Codecov'
    inputs:
      verbose:
        description: 'Specify whether the Codecov output should be verbose'
        required: false
    branding:
      color: 'red'
      icon: 'umbrella'
    runs:
      using: 'node16' # 设置成node16环境(action主机会预先安装了node16)
      main: 'dist/index.js'

# docker
在secrets 中配置docker password

# gorelease package
## 选择github token 与权限
可使用两种TOKEN:
1. 创建PAT　token, 先在 https://github.com/settings/tokens 生成token(classic) 选择write package 等权限
2. 使用默认的`secrets.GITHUB_TOKEN`，如果写定需要发release 包，就要`contents: write` 权限

示例：在action 中发release包，需要`contents: write` 权限
    
    task1:
      #修改权限：https://docs.github.com/en/actions/security-guides/automatic-token-authentication
      #permissions: write-all
      permissions: 
      contents: write
      steps:
        - name: Run GoReleaser
          uses: goreleaser/goreleaser-action@v6
          with:
            distribution: goreleaser
            version: '~> v2'
            args: release --clean
          env:
            GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    
如果没有配置好权限就会出现：

    failed to publish artifacts: could not release: POST https://api.github.com/repos/ahuigo/selfhttps/releases: 403 Resource not accessible by integration 

## 配置.gorelease.yml
https://github.com/goreleaser/goreleaser-action?tab=readme-ov-file