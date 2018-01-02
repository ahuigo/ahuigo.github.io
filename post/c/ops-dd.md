# dd
创建文件时,
1. 用count=n blocks, 会copy zero
2. 用seek 的话就不会copy 文件, 有些风险

create 1M

    dd if=/dev/zero of=10m.img bs=1024 count=0 seek=$[1024*10]
    dd if=/dev/zero of=1m.img bs=1024 count=$[1024*1]

create 1G

    dd if=/dev/zero of=1g.img bs=1 count=0 seek=1G
    dd if=/dev/zero of=1g.img bs=1 count=1G
