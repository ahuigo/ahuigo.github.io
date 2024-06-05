---
title: docker image shell
date: 2023-08-30
private: true
---
# docker image shell
build 的debug方式


    $ cat dockerfile-shell
    From alpine
    RUN echo go build -ldflags=-s -w -X common/types.BuildDate=$(date -I'seconds') -X common/types.BuildVer=$(git rev-parse HEAD)

## debug shell
通过 `--progress=plain` 展示shell输出，注意有docker cached 时不会输出

    $ docker build --progress=plain -t m -f dockerfile-shell .