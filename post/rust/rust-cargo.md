---
title: rust cargo(pkg manager)
date: 2023-03-03
private: true
---
# rust cargo(pkg manager)
类似go mod

## new project

    $ cargo new proj1
    $ cd  proj1

## build & run
### debug:

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

## Cargo.toml 和 Cargo.lock
> 相当于go.mod和 go.sum

Cargo.toml 可定义各种依赖: https://course.rs/cargo/reference/specify-deps.html

    [dependencies]
    rand = "0.3"
    hammer = { version = "0.5.0"}
    color = { git = "https://github.com/bjz/color-rs" }
    geometry = { path = "crates/geometry" }