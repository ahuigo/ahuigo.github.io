---
title: zero copy
date: 2025-10-15
private: true
---
# zero copy
https://www.cnblogs.com/MuXinu/p/18711921

技术	适用场景	减少的拷贝次数	适用版本
sendfile()	文件 → Socket	2 次	Linux 2.1+
mmap() + write()	文件 → Socket	1 次	Linux 2.1+
splice()	文件/管道 → Socket	2 次	Linux 2.6.17+
vmsplice()	用户缓冲区 → 管道	1 次	Linux 2.6.17+
MSG_ZEROCOPY	TCP 传输	1 次	Linux 4.14+
io_uring	异步文件/Socket I/O	2 次	Linux 5.1+

总结：
高效文件传输：sendfile()（兼容性好，性能高）
管道数据流处理：splice()（高吞吐）
用户态数据直接发送：MSG_ZEROCOPY（适用于 TCP 传输）
最先进的方案：io_uring（适用于现代异步 I/O）