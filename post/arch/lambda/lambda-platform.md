---
title: lambda framework
date: 2024-07-01
private: true
---
# lambda fass 方案(k8s)
> https://www.reddit.com/r/aws/comments/10sqcnv/is_it_possible_to_selfhost_a_lambda_or_lamdalike/
> https://blog.cloudflare.com/workerd-open-source-workers-runtime/

## serverless functions on Kubernetes framework:
1. openfaas: https://www.openfaas.com/
2. podman: https://podman.io/get-started
2. Fission:
Fission is a framework for serverless functions on Kubernetes.

## lambda on worker platform
Deno Deploy是Deno公司的一个产品，它是一个全球分布式的JavaScript、TypeScript运行环境，类似于Cloudflare Workers或AWS Lambda

##　开源的lambda 方案
容器、虚拟机：
- firecracker(rust): 是一个轻量级的虚拟机监视器（VMM），由亚马逊开发并针对无服务器进行了优化应用，通过执行 VM 中的无服务器功能来提供高隔离级别，还提供了 VM 级快照，以便可以恢复 VM 级别的快照，并且可由多个 VM 实例共享.
- google gvisor(go+cplus): Application Kernel for Containers，　比k8s 轻量
- open-lambda(go+rust): An open source serverless computing platform

进程限制：在Linux系统中，有几种可能的方法来实现这种隔离:
1. chroot - 可以改变进程的根目录，限制文件系统访问。但这需要root权限，而且不能阻止调用其他命令。
2. namespaces - 内核特性，可以隔离各种系统资源。但配置比较复杂。
3. seccomp - 可以限制系统调用，阻止执行其他程序。但需要修改程序源码。
4. AppArmor/SELinux - 强制访问控制系统，可以精细控制权限。但配置较复杂。
5. firejail - 一个沙箱工具，结合了多种隔离技术，使用相对简单。