---
title: docker 多阶段提交
date: 2019-12-06
private: true
---
# docker 多阶段提交
https://tonybai.com/2017/11/11/multi-stage-image-build-in-docker/

生成更小的image

    //github.com/bigwhite/experiments/multi_stage_image_build/multi_stages/Dockerfile

    FROM golang:alpine as builder
    WORKDIR /go/src
    COPY httpserver.go .
    RUN go build -o myhttpserver ./httpserver.go

    From alpine:latest
    WORKDIR /root/
    COPY --from=builder /go/src/myhttpserver .
    RUN chmod +x /root/myhttpserver

    ENTRYPOINT ["/root/myhttpserver"]