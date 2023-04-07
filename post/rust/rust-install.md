---
title: rust install
date: 2023-03-03
private: true
---
# rust install
    $ curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
    # or
    $ brew install rust

check

    $ rustc -V
    rustc 1.56.1 (59eed8a2a 2021-11-01)

    $ cargo -V
    cargo 1.57.0 (b2e52d7ca 2021-10-21)

# vscode
    brew install rustfmt

vscode 插件：

    rust-analyzer(社区)
    rust(官方：不要装，不好用)

# 配置
## cargo 使用代理
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7891
## cargo 使用mirror
增加mirror

    $ vi /.cargo/config.toml
    [registries]
    ustc = { index = "https://mirrors.ustc.edu.cn/crates.io-index/" }

Cargo.toml 中使用以下方式引入:

    [dependencies]
    time = {  registry = "ustc" }

在重新配置后，初次构建可能要较久的时间，因为要下载更新 ustc 注册服务的索引文件，还挺大的...

## 不要同时执行多个下载
    $ cargo build
        Blocking waiting for file lock on package cache
        Blocking waiting for file lock on package cache

该下载构建还锁住了当前的项目，导致你无法在另一个地方再次进行构建。 解决办法也很简单：

1. 耐心等待持有锁的用户构建完成
2. 强行停止正在构建的进程，例如杀掉 IDE 使用的 rust-analyzer 插件进程，然后删除 $HOME/.cargo/.package_cache 目录


