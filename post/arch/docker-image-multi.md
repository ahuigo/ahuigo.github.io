---
title: docker 多阶段提交
date: 2019-12-06
private: true
---
# docker 多阶段提交
https://tonybai.com/2017/11/11/multi-stage-image-build-in-docker/

一次性地、更容易地构建出 size 较小的 image

    FROM golang:alpine as builder
    WORKDIR /go/src
    COPY httpserver.go .
    RUN go build -o myhttpserver ./httpserver.go

    From alpine:latest
    RUN apk update && \
    apk add ca-certificates && update-ca-certificates && rm -rf /var/cache/apk/*
    WORKDIR /root/
    COPY --from=builder /go/src/myhttpserver .
    RUN chmod +x /root/myhttpserver

    ENTRYPOINT ["/root/myhttpserver"]
