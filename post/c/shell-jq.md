---
title: jq
date: 2020-06-24
private: true
---
# jq
> 最近同事用jq 配合做压测，做一个笔记

常规用法

    jq -ncM '{key:"v"}'

jq 参数：

    -n 无输入
    -c 紧凑输出（无换行）
    -M 输出无终端color

## 随机数据

    jq -ncM 'while(true; .+1) | {method: "POST", body: {"num":("num"+(.|tostring))}}'

    while(true; .+1) 中对.这个变量进行自增

## 管道
jq 支持管道，比如我们利用管道生成base64

    > jq -ncM '{body: "data" | @base64 }'
    {"body":"ZGF0YQ=="}
    > jq -ncM 'while(true; .+1) | {method: "POST", body: {"num":("num"+(.|tostring))} | @base64 }'

### select

    curl -s https://api.github.com/repos/go-swagger/go-swagger/releases/latest | \
    jq -r '.assets[] | select(.name | contains("'"$(uname | tr '[:upper:]' '[:lower:]')"'_amd64")) | .browser_download_url'


note:

    $ echo "$(uname | tr '[:upper:]' '[:lower:]')" 
    darwin