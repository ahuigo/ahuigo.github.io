---
title: Docker slim vs alpine
date: 2019-12-06
private: true
---
# Docker slim vs alpine

## Alpine
dockerfile

    From alpine:latest
    WORKDIR /app/
    RUN ls /app/
    RUN apk add --no-cache bash && mkdir tmp && echo yxh > tmp/a.txt && cat tmp/a.txt

### alpine 装上bash

    RUN apk add --no-cache bash
