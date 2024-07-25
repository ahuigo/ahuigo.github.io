---
title: docker pull faq
date: 2024-07-25
private: true
---
# docker pull
    $ docker pull golang:1.22.5-alpine
    docker.io/library/golang:1.22.5-alpine

## error pulling image configuration: download failed after attempts=6: dial tcp xxx: connect: connection timed out
dns 不对:

    nameserver 8.8.8.8
    nameserver 8.8.4.4

## tls: failed to verify certificate: x509: certificate signed by unknown authority
证书不对，或dns 不对。如果只是证书不对，就下载证书

    sudo apt-get install -y ca-certificates
