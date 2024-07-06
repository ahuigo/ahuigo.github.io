---
title: github 使用
date: 2024-06-17
private: true
---
# github 功能
- Github token: PAT(personal access token) https://github.com/settings/tokens?type=beta
    - Fine-grained token(细颗粒)
    - token(classic) 不能select repo
        - token 一直放在项目的secrets 中，比如GITHUB_TOKEN
    - github token permission: 自带的${{ secrets.GITHUB_TOKEN }}
        https://docs.github.com/en/actions/security-guides/automatic-token-authentication#modifying-the-permissions-for-the-github_token

- Github action: 支持cicd workflow 
- Github packages: 发布和安装各种语言和平台的软件包，比如 npm、RubyGems、Docker 等。
- Github App: https://github.com/settings/apps 充当机器人，用来对repo操作issues, pr等
    - webhook
- OAuth App: https://github.com/settings/developers 提供三方登录
- 项目相关
    - Github Environments: 用于管理项目的不同部署环境, 例如环境保护规则（例如需要特定的人员审查和批准部署）、环境变量
    - Actions secrets and variables


# Github packages
发布和安装各种语言和平台的软件包，比如 npm、RubyGems、Docker 等。

## 发packages /release 包权限
两种token:
- 如果你用github atciton workflow : use `GITHUB_TOKEN` to publish, install, delete, and restore packages in GitHub Packages without needing to store and manage a personal access token(PAT).
- 否则，使用PAT token(classic): 给 read/write/delete:packages　权限

## container registry
打label：

    LABEL org.opencontainers.image.source=https://github.com/octocat/my-repo
    LABEL org.opencontainers.image.description="My container image"
    LABEL org.opencontainers.image.licenses=MIT
    $ docker build \
    --label "org.opencontainers.image.source=https://github.com/octocat/my-repo" \
    --label "org.opencontainers.image.description=My container image" \
    --label "org.opencontainers.image.licenses=MIT"

如果使用PAT token(classic): https://github.com/settings/tokens/new?scopes=write:packages

    export CR_PAT=YOUR_TOKEN
    $ echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
    docker push ghcr.io/NAMESPACE/IMAGE_NAME:latest
