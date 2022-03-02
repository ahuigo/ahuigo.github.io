---
layout: page
title:	linux perf(系统性能分析)
category: blog
description: 
---
# perf
性能领域的大师布伦丹·格雷格（Brendan Gregg）的linux perfformance tool:
![](/img/ops/perf-tool.png)
![](/img/ops/perf-tool.jpeg)

## bpf 工具(Bk package filter)
- 【BPF入门系列-1】eBPF 技术简介 https://www.ebpf.top/post/bpf_intro_blog/
- eBPF 与 Go，超能力组合（含视频） https://www.ebpf.top/post/ebpf_and_go/
- https://blog.cloudflare.com/bpf-the-forgotten-bytecode/
- [详细介绍了BPF程序编译生成字节码过程](https://www.cnblogs.com/lfri/p/15402973.html)
- [https://maao.cloud/2021/03/01/%E7%AC%94%E8%AE%B0-BPF-and-XDP-Reference-Guide-cilium/#LLVM](https://maao.cloud/2021/03/01/%E7%AC%94%E8%AE%B0-BPF-and-XDP-Reference-Guide-cilium/#LLVM)
- [技术|深入理解 BPF：一个阅读清单 (linux.cn)](https://linux.cn/article-9507-1.html)
- 最神奇的Linux技术 BPF入门: https://zhuanlan.zhihu.com/p/469860384

### mac bpf example
go-lib/net/packet/bpf