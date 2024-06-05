---
title: docker timezone
date: 2020-04-28
private: true
---
# docker timezone
给docker scratch 加时区

    FROM alpine:latest AS build-env
    RUN apk --no-cache add tzdata

    FROM scratch
    COPY --from=build-env /usr/share/zoneinfo /usr/share/zoneinfo
    ENV TZ=Asia/Shanghai

# alpine:latest
    FROM alpine:latest

    RUN apk add -U tzdata
    ENV TZ=America/Santiago
    RUN cp /usr/share