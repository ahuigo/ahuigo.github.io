---
title: docker image shell
date: 2023-08-30
private: true
---
# image: call shell
build 的debug方式


    $ cat dockerfile-shell
    From alpine
    RUN echo go build -ldflags=-s -w -X common/types.BuildDate=$(date -I'seconds') -X common/types.BuildVer=$(git rev-parse HEAD)

## debug shell
通过 `--progress=plain` 展示shell输出，注意有docker cached 时不会输出

    $ docker build --progress=plain -t m -f dockerfile-shell .

## shell redirect

    # docker build -f d2 -t debug --build-arg COMMIT_ID=v1.12 .
    RUN echo $(echo commit_id: $COMMIT_ID; date) > a.txt