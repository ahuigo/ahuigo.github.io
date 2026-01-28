---
title: devops
date: 2023-05-17
private: true
---
# devops
## PAT(personal access tokens)
> 利用PAT，可以在临时的开发机上访问devops 仓库

git clone with PAT:

    MY_PAT=yourPAT # replace "yourPAT" with ":PatStringFromWebUI"
    B64_PAT=$(printf "%s"":$MY_PAT" | base64)
    alias git='git -c http.extraHeader="Authorization: Basic '$B64_PAT'"'
    git -c http.extraHeader="Authorization: Basic ${B64_PAT}" clone https://dev.azure.com/yourOrgName/yourProjectName/_git/yourRepoName 

或git 全局配置：

    git config --global http.extraHeader "Authorization: Basic ${B64_PAT}"
    git config --global http.https://dev.azure.com/yourOrgName.extraHeader "Authorization: Basic ${B64_PAT}"

curl with PAT:

    curl -u :{PAT} https://dev.azure.com/{organization}/_apis/build-release/builds

