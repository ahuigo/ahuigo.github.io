---
title: pb buffer 格式
date: 2021-11-24
private: true
---
# pb buffer 格式
参考：https://developers.google.com/protocol-buffers/docs/gotutorial

序列化有很多种：
1. gob:  https://golang.org/pkg/encoding/gob/ 仅限Golang
2. json: human readable, cross multiple languages, 但是很慢
3. pb buffer: binary fast, cross multiple languages, 但是not human readable

## Base Format
The base format syntax is:

```s
message <type_name>{
    <type_name> <property_name> = <tag_id>;
    [repeated]<type> <property_name> = <tag_id>;
}
```

Note：
1. message 或者说type_name 是可以嵌套的
2. tag_id用类型的唯一标识，pb buffer 中的常用类型一般用0-15表示(单个十六进制字节). 一般常用或重复的元素使用这些标记0-15，而对不常用的可选元素保留标记16或更高的标记。

> The " = 1", " = 2" markers on each element identify the unique "tag" that field uses in the binary encoding. Tag numbers 1-15 require one less byte to encode than higher numbers, so as an optimization you can decide to use those tags for the commonly used or repeated elements, leaving tags 16 and higher for less-commonly used optional elements. Each element in a repeated field requires re-encoding the tag number, so repeated fields are particularly good candidates for this optimization.



### enum
      enum PhoneType {
        MOBILE = 0;
        HOME = 1;
        WORK = 2;
      }

## message 嵌套-例子
    message Person {
      string name = 1;
      int32 id = 2;  // Unique ID number for this person.
      string email = 3;

      enum PhoneType {
        MOBILE = 0;
        HOME = 1;
        WORK = 2;
      }

      message PhoneNumber {
        string number = 1;
        PhoneType type = 2;
      }

      repeated PhoneNumber phones = 4;

      google.protobuf.Timestamp last_updated = 5;
    }

    message AddressBook {
      repeated Person people = 1;
    }

# grpc
## proto 文件定义

    syntax = "proto3";
    package users;

    option go_package = ".;user";

    // Users Service
    service Users {
      // GetUsers
      rpc GetUsers(EmptyReq) returns (GetUsersResponse) {};
    }

    // EmptyReq message
    message EmptyReq {}

    // GetUsersResponse message
    message GetUsersResponse {
      // User message
      repeated User users = 1;
    }

    // User message
    message User {
      // The user name
      string name = 1;
      // The user age
      int32 age = 2;
    }

### 定义描述
    syntax = "proto3";
    package tutorial;

    # 从外部引入类型定义：  google.protobuf.Timestamp last_updated = 5;
    import "google/protobuf/timestamp.proto";

#### 定义go_package
go_package 定义生成代码的包路径，如：

    option go_package = "github.com/protocolbuffers/protobuf/examples/go/tutorialpb";
    # 简写为相对路径
    option go_package = ".;tutorialpb";

#### 定义message

    message Person {
      string name = 1;
      int32 id = 2;  // Unique ID number for this person.
      string email = 3;

      enum PhoneType {
        HOME = 0;
        WORK = 1;
      }
      message PhoneNumber {
        string number = 1;
        PhoneType type = 2;
      }

      repeated PhoneNumber phones = 4;
      google.protobuf.Timestamp last_updated = 5;
    }

    message AddressBook {
      repeated Person people = 1;
    }

> Note: If a field value isn't set, a default value is used: zero for numeric types, the empty string for strings, false for bools.

## 生成go文件
#### 安装protoc
    $ brew install protobuf
    $ apt install -y protobuf-compiler
    $ protoc --version  # Ensure compiler version is 3+

    go get google.golang.org/protobuf/cmd/protoc-gen-go
    go get google.golang.org/grpc/cmd/protoc-gen-go-grpc

#### 执行protoc
Because you want Go code, you use the `--go_out` option – similar options are provided for other supported languages.

    protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative proto/user.proto

    protoc proto/user.proto
    protoc -I=$SRC_DIR --go_out=$DST_DIR $SRC_DIR/addressbook.proto

## 使用pbf api

    p := pb.Person{
        Id:    1234,
        Name:  "John Doe",
        Email: "jdoe@example.com",
        Phones: []*pb.Person_PhoneNumber{
                {Number: "555-4321", Type: pb.Person_HOME},
        },
    }

    // marshal
    book := &pb.AddressBook{}
    out, err := proto.Marshal(book)

    // unmarshal
    book := &pb.AddressBook{}
    err := proto.Unmarshal(out, book)