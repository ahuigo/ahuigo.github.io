---
title: devops
date: 2023-05-17
private: true
---
# devops
## PAT(personal access tokens)

nbiwxqvspdmuegqp2ef4mbvuo25hxevmpypbq5k6jlbzf2opk5la
git clone with PAT:

    MY_PAT=yourPAT # replace "yourPAT" with ":PatStringFromWebUI"
    B64_PAT=$(printf "%s"":$MY_PAT" | base64)
    alias git='git -c http.extraHeader="Authorization: Basic '$B64_PAT'"'
    git -c http.extraHeader="Authorization: Basic ${B64_PAT}" clone https://dev.azure.com/yourOrgName/yourProjectName/_git/yourRepoName 

curl with PAT:

    curl -u :{PAT} https://dev.azure.com/{organization}/_apis/build-release/builds
