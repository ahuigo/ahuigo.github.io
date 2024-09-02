---
title: SWAP
date: 2018-09-27
---
# SWAP

## Verify if swap exists
After running that command you should see something similar to this output:

    free -m

    total              used       free     shared    buffers     cached
    Mem:               1840       1614     226       15          36       1340
    -/+ buffers/cache:            238      1602
    Swap:              0          0        0

If you see a value of `0` in the `Swap section`, then you can proceed to step 2.

Alternatively, you can run the following command to see if there is a configured swap file:

    swapon -s

If you do not see any output from swapon, then proceed to step 2.

## Step 2: Create swap file

    # or: dd if=/dev/zero of=/swapfile count=2048 bs=1M
    sudo fallocate -l 2G /swapfile # 创建 2G 空文件
    sudo mkswap /swapfile    # 转换为交换分区文件

## Step 3: Turn swap on
    $ sudo chmod 600 /swapfile # 修改权限为 600
    $ sudo swapon /swapfile    # 激活交换分区
    Setting up swapspace version 1, size = 2097148 KiB
    no label, UUID=ff3fc469-9c4b-4913-b653-ec53d6460d0e

    $ free -m # 查看当前内存使用情况(包括交换分区)


### Step 6: disable swap (if you need)
    sudo swapoff /swapfile
    rm -rf /swapfile

## Step 5: Enable swap on reboot
nano /etc/fstab, Add the following line at the end of the file:

    /swapfile   none    swap    sw    0   0

# summary

    dd if=/dev/zero of=/swapfile count=2048 bs=1M
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile   none    swap    sw    0   0' >> /etc/fstab
