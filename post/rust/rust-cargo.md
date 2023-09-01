---
title: rust cargo(pkg manager)
date: 2023-03-03
private: true
---
# rust cargo(pkg manager)
类似go mod 包管理器

## new project

    $ cargo new proj1
    $ tree -L 1 proj1
    ├── Cargo.lock //go.sum
    ├── Cargo.toml  //go.mod/package.json
    ├── src
    └── target 

    $ cd  proj1

## build & run
### build
build 默认是debug 模式

    $ cargo build
    $ ./target/debug/world_hello
    Hello, world!

build + exec 合成一个就是run:

    cargo run

### release
默认是debug编译不优化，如果要compile 优化：

    cargo run --release
    cargo build --release

默认debug 时，这一句会被打印

    if cfg!(debug_assertions) {
        // 输出到标准错误输出
        eprintln!("debug: {:?} -> {:?}", record, fields);
    }

## cargo check
build前，快速的检查一下代码能否编译通过,能节省大量的编译时间:

    $ cargo check

# cargo 配置
## cargo 使用代理
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7891
## cargo 指定默认mirror
    $ cat ~/.cargo/config
    [source.crates-io]
    registry = "https://github.com/rust-lang/crates.io-index"
    replace-with = 'tuna'

    [source.tuna]
    registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

    [net]
    git-fetch-with-cli = true

### 给依赖指定mirror（可选）
增加mirror

    $ vi ~/.cargo/config.toml
    [registries]
    ustc = { index = "https://mirrors.ustc.edu.cn/crates.io-index/" }

在项目根 Cargo.toml 中使用以下方式引入:

    [dependencies]
    time = {  registry = "ustc" }
    #time = {  registry = "tuna" }

在重新配置后，初次构建可能要较久的时间，因为要下载更新 ustc 注册服务的索引文件，还挺大的...

## 包依赖配置
Cargo.toml 可定义各种依赖: https://course.rs/cargo/reference/specify-deps.html

    [dependencies]
    rand = "0.3"
    hammer = { version = "0.5.0"}
    color = { git = "https://github.com/bjz/color-rs" }
    geometry = { path = "crates/geometry" }

### 多项目依赖
假如创建了两个项目：

    cargo new crate1
    cargo new crate2

那么可以项目之间调用：

    [dependencies]
    crate2 = { path = "../crate2" }

    // create2/src/main.rs
    use crate2::my_function;
    fn main() {
        my_function();
    }

## 不要同时执行多个下载
    $ cargo build
        Blocking waiting for file lock on package cache
        Blocking waiting for file lock on package cache

该下载构建还锁住了当前的项目，导致你无法在另一个地方再次进行构建。 解决办法也很简单：

1. 耐心等待持有锁的用户构建完成
2. 强行停止正在构建的进程，例如杀掉 IDE 使用的 rust-analyzer 插件进程，然后删除 $HOME/.cargo/.package_cache 目录

