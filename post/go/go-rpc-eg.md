---
title: go rpc example
date: 2021-11-20
private: true
---
# go rpc example
https://levelup.gitconnected.com/writing-an-rpc-server-in-go-eb9afd56d1e1
https://medium.com/swlh/using-grpc-and-protobuf-in-golang-9c218d662db3
https://github.com/sumiet/medium_webserver_series/tree/master/4

## install

    $ brew install protobuf
    $ apt install -y protobuf-compiler
    $ protoc --version  # Ensure compiler version is 3+

## build proto.go
    go get google.golang.org/protobuf/cmd/protoc-gen-go
    go get google.golang.org/grpc/cmd/protoc-gen-go-grpc

then

    cd 5
    protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative proto/user.proto
    $ ls proto/
    proto/user.pb.go
    proto/user_grpc.pb.go

exec

    go run main.go
