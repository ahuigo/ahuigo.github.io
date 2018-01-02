---
layout: page
title:	计算机结构
category: blog
description:
---
# Preface

本文描述的是现代的计算机所采用的冯诺伊曼(Von Neumann)结构: CPU(Central Procession Unit) + Memory + Device

# Memory & Address

# CPU
CPU 包含以下功能单元：

- Register 寄存器。 分为特殊寄存器(Special Purpose Register ), 通用寄存器( General Purpose Register)

- PC,Program Counter 程序计数器，它属于 Special Purpose Register
x86 所使用的PC, 叫eip, 有32位和64位之分。

- Instruction Decoder 指令解码器。将字节序列解析为具体的操作：加减乘除，读写...

- ALU, Arithmetic Logic Unit 算法逻辑单元。

- Bus, 分地址总线(ABus), 数据总线(DBus), 控制总线(Cbus)

# Device

## CPU 的两种I/O
有些设备是像内存一样， 连接到处理器的地址总线和数据总线。
还有些设备，是集成到处理器芯片中的：
- 很多体系下(如ARM), 这类设备和内存共用地址总线，但是各自有独立的内存地址范围，称为内存映射I/O(Memory-mapped I/O)
- 但是x86 比较特殊，其芯片内的集成设备有独立的端口地址空间，需要额外的地址线。 访问设备寄存器时用特殊的in/out 指令，而非和访问内存时用一样的指令，这种访问方式叫端口I/O(Port I/O)

CPU 只用内存I/O 和端口I/O 两种访问方式， 要么像内存一样访问，要么像用专用指令访问。

对于不同设备有不同的设备总线, 比如PCI, AGP, USB, 1394, SATA ..., CPU 是通过内存I/O 或者端口I/O 访问相应的总线控制器, 通过总线控制器再访问不同的设备。

## 硬盘设备类型
在X86 结构中，硬盘属于ATA, SATA 或SCSI 总线上的设备。CPU 将硬盘上的程序通过设备总线传到内存，这一过程叫加载(Load).	Load 完成后，内存中的程序就叫进程(Process).

## Interrupt 中断
有些设备不像内存那样，总是被动的等待读写。比如键盘，当用户输入一个字符，需要主动的告诉CPU，这是通过中断(Interrupt)实现的.

每个设备都有一条中断线,通过中断控制器连接到CPU.

- CPU 收到一个中断信号,CPU 会暂停当前的工作
- CPU 根据中断信号值，将pc 跳到对应的中断服务程序(ISR, Interrupt Service Routine) 并执行。ISR 是由内核代码提供的, 它会根据设备不同调用设备驱动的中断处理函数(Interrupt Handler)
- 继续当前的工作。

不同的设备，需要不同的设备驱动（Device Driver）, 这些驱动一般是内核中的一组函数, 包括对设备的: 读写, 初始化, 中断处理函数(供ISR 调用).
Linux 内核集成了绝大部分设备驱动.

# MMU
现在的计算机一般采用虚拟内存管理(Virtual Memory Management), 这需要MMU(Memory Management Unit, 内存管理单元) .
有些嵌入式没有MMU, 就不能运行依赖VMM的操作系统.

MMU 有什么用呢?
如果直接访问物理内存(Physical Address, PA), 内存的申请, 空余空间的判断, 或者相对地址管理, 内存保护 都非常复杂. MMU 通过虚拟地址(Virtual Address, VA) 这么一个中间层, 简化了这种复杂性.

MMU 将虚拟地址VA 映射到物理地址PA 是以页(Page) 为单位的, 对于32 位CPU 一般是4KB/Page.
比如将虚拟地址的一页0xb7001000~0xb7001fff 映射到物理地址的 一页0x2000~0x2fff.
物理地址中的页称为物理页面或页帧(Page Frame). VA 与 PA 间的页映射关系, 保存在页表中(Page Table). Page Table 本身位于物理内存中.

MMU 管理内存时,大致过程为:

- 操作系统初始化, 或者分配/释放内存时, 会执行一个指令在物理内存中填写页表; 然后用指令设置MMU, 告诉MMU 页表在物理内存中的什么位置.
- 设置好了后, CPU 每次访问内存时, 都会触发MMU 做查表(包括权限)和地址转换(硬件实现的, 不需要用指令去控制MMU)

## 作用

### 进程间的地址不会冲突
程序实际执行时,使用的虚地址, MMU 保证了各进程间不会出现地址冲突: 比如两个进程都使用了相同的虚拟地址0xff20, MMU会把虚拟地址映射到不同的物理地址.

### 内存保护
各种体系结构都有用户模式(User Mode ) 和 特权模式(Privileged Mode). 操作系统可以设定每个内存页面的访问权限. 有些页面在用户模式下,可读,可写,可执行, 有些却只能在特权模式下只读不可写不可执行. 如果MMU 检查出权限错误, 会给CPU 发一个内存访问越界的异常(Exception), 不是中断哦.

#### 用户空间 和 内存空间
一般OS 把4G 内存 划分为用户空间内核空间, x86 平台的虚拟地址0x0000 0000 ~ 0xbfff ffff 为用户空间, 0xc000 0000 ~ 0xffff ffff 为内核空间.
这保护了内核, 当一个进程访问了非法地址, 最多导致进程崩溃, 而不是导致其它进程 或者 内核崩溃. 此时, 越界异常会自动切换用户模式到特权模式, 执行异常服务程序, 或者中断服务程序.

所有内核的代码都是由中断或异常服务程序组成的, 并且使用的内核空间.

我们来看一个实际的段错引发的异常.

1. 程序访问VA 被MMU 发现无权访问
2. MMU抛出 异常, CPU 从用户模式 转 到特权模式, 开始执行 内核代码中对应的异常服务程序
3. 异常服务程序发现这是段错误, 把引发异常的进程给杀死 内核和其它进程 虚惊一场.

# Memory Hierarchy
为什么要对Memory 做层次分级(Hierarchy)呢?
因为我们能造出速度很快, 容量很小的存储器, 也能造出速度很慢, 但是容量很大的存储器. 我们却不能造出容量大速度也快的存储器.
于是, 就衍生了不同层级的存储器: Cpu register(1ns), 1 level Cache(5~10ns), 2 level Cache(40~60ns),  Memory(100~150ns), Hard Disk(3~15ms)

| Register| 几十个|触发器|1ns|
| 1 Level| 数十KB | SRAM, Static Radom Memory|5~10ns|
| 2 Level|100K ~ xMB|SRAM, Static Radom Memory|40~60ns|
| Memory |xGB |DRAM, Dynamic Radom Memory|100~150ns|
| Hard Disk | TB, x00GB |机械,固态|3~15ms, 0.x ms|
