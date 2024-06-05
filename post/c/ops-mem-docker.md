---
title: docker 的内存指标
date: 2024-05-24
private: true
---
# docker 的内存指标
RSS: 只统计进程占用的物理内存，内核文件系统cache、slab fd、io　不算在RSS里面
1. max rss: RSS 指的是 Resident Set Size，即常驻集大小。Max RSS 表示自从进程启动以来所观察到的最大的物理内存RSS 值(含共享内存)。
2. working_set_bytes: 这个指标表示 Pod 当前正在使用的内存量+缓存（如文件系统缓存+临时文件）。但是，它不包括已经被驱逐（evicted）且能够被重新调入的swap页面


working_set_bytes 有时会比 max rss 大，因为它还包含了 rss＋所有的缓存＋临时文件: (参考ops-process-ps 中#MEM)

    1. 文件系统缓存（Page Cache）：
    操作系统为了提高磁盘访问速度，会将读取的数据缓存在内存中。这种机制使得频繁访问的文件不需要每次都从慢速的磁盘读取，而可以直接从快速的 RAM 中获取，大幅提升性能。文件系统缓存通常会占据大量的内存空间。

    2. Slab 分配器缓存：
    Linux 内核使用 slab 分配器来管理内核对象（如进程描述符、文件对象等）的内存分配和回收。Slab 缓存可以提高内存分配的效率，并减少内存碎片。

    3. Buffers：
    Buffers 是内核用来存放有关 I/O 操作的原始块设备数据的内存区域。比如说，在写入数据到磁盘之前，数据可能会先被暂存到 buffers 中。

    4. 临时文件（tmpfs/shm）：
    如果应用程序使用共享内存（例如 POSIX 共享内存）或者 tmpfs（一种基于内存的文件系统），这些内存映射的文件和共享内存段也会被包括在 working_set_bytes 中。
