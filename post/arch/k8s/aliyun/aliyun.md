# aliyun ecs
https://ecs.console.aliyun.com/server/region/
https://ecs.console.aliyun.com

## g8a等规格
https://help.aliyun.com/zh/ecs/user-guide/overview-of-instance-families?spm=5176.ecscore_server.console-base_help.dexternal.4ebb4df5fF1V5A#i4
https://help.aliyun.com/zh/ecs/user-guide/configure-erdma-on-a-cpu-instance?spm=a2c4g.11186623.0.0.733078c5Mia4ax

## 弹性RDMA
（Elastic Remote Direct Memory Access，简称eRDMA）是阿里云自主研发的一种云上弹性RDMA网络技术。这项技术底层复用了VPC网络，并采用了全栈自研的拥塞控制算法，在保持传统RDMA网络高吞吐量和低延迟特性的同时，还支持秒级大规模组网。它不仅能够兼容传统的HPC应用程序，也适用于基于TCP/IP协议的应用程序。

## NVME
非易失性存储器标准接口NVMe（Non-Volatile Memory Express）是一种专为固态存储（如基于闪存的SSD）设计的高速接口协议，支持存储设备直接与CPU通信，无需经过传统存储接口和协议（如SATA、SAS）中必需的控制器，从而减少了数据传输过程中的延迟。
当ECS实例基于NVMe协议挂载云盘时，允许 盘直接与ECS实例的CPU通信，从而大大减少了数据传输路径，显著降低了I/O访问的延迟时间。


    ➜  ~ sudo fdisk -lu
    ~ lsblk
    NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    vda     252:0    0   40G  0 disk
    ├─vda1  252:1    0    1M  0 part
    ├─vda2  252:2    0  200M  0 part /boot/efi
    └─vda3  252:3    0 39.8G  0 part /
    nvme1n1 259:0    0  3.5T  0 disk
    nvme0n1 259:1    0  3.5T  0 disk
    nvme2n1 259:2    0  3.5T  0 disk
    nvme3n1 259:3    0  3.5T  0 disk
    nvme4n1 259:4    0  3.5T  0 disk
    nvme5n1 259:5    0  3.5T  0 disk
    nvme6n1 259:6    0  3.5T  0 disk
    nvme7n1 259:7    0  3.5T  0 disk