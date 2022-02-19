---
title: go net grpc
date: 2021-10-15
private: true
---
# go net grpc
https://grpc.io/docs/languages/go/quickstart/

https://levelup.gitconnected.com/lets-go-and-build-an-application-with-grpc-c5b754400f64

https://medium.com/swlh/using-grpc-and-protobuf-in-golang-9c218d662db3
    https://github.com/sumiet/medium_webserver_series/tree/master/5

## install

    $ brew install protobuf
    $ apt install -y protobuf-compiler
    $ protoc --version  # Ensure compiler version is 3+

    go get google.golang.org/protobuf/cmd/protoc-gen-go
    go get google.golang.org/grpc/cmd/protoc-gen-go-grpc

## build proto.go

    cd 5
    protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative proto/user.proto
    $ ls proto/
    proto/user.pb.go
    proto/user_grpc.pb.go

exec

    go run main.go

# demo
github.com/ahuigo/grpc-demo