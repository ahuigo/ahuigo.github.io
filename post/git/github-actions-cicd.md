---
title: github cicd
date: 2023-12-06
private: true
---
# github cicd
以golang 项目为例子: https://github.com/ahuigo/gofnext/tree/main/.github/workflows

# codecov
1. add repe secrets
https://github.com/ahuigo/gofnext/settings/secrets/actions/new

    CODECOV_TOKEN=xxx

2. add Codecov to your GitHub Actions workflow yaml file: `.github/workflows/[task].yml`

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
      using: 'node16'
      main: 'dist/index.js'
