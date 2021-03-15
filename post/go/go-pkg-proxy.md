---
title: golang import package
date: 2020-04-20
private: true
---
# proxy
## go pkg proxy
via goproxy

    GOPROXY="https://127.0.0.1:8888" 
    GOPROXY="https://name:pass@xx.com/artifactory/api/go/go"

via HTTP_PROXY

    HTTP_PROXY=socks5://127.0.0.1:1080 go get  github.com/gin-gonic/gin

## 404
因为使用私有的repo 时，无法用sum.golang.org 进行checksum校验.

请加上：

    $ export GONOSUMDB="github.com/mycompany/*,github.com/secret/*"
    # 或
    $ export GOSUMDB=off

    # Dockerfile
    ENV GOSUMDB=off