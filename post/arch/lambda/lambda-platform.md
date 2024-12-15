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
doubao:
- firecracker(rust): 是一个轻量级的虚拟机监视器（VMM），由亚马逊开发并针对无服务器进行了优化应用，通过执行 VM 中的无服务器功能来提供高隔离级别，还提供了 VM 级快照，以便可以恢复 VM 级别的快照，并且可由多个 VM 实例共享.
- google gvisor(go+cplus): Application Kernel for Containers
- open-lambda(go+rust): An open source serverless computing platform

