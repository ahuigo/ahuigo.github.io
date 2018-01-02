---
layout: page
title:	linux 文件系统
category: blog
description:
---
# Todo
shell - filesystem
http://billie66.github.io/TLCL/book/zh/chap16.html

# Preface
linux 的文件系统主要包括ext2,ext3, 以及目前使用最广泛的ext4. 它们的基本格式和设计思想是一样的，本文基于ext2 作一下介绍。

查看文件系统：

	$ file -s /dev/vd*
	$ blkid /dev/vda1
		/dev/vda1: UUID="421094ce-1586-4296-b276-f456f9d25e44" TYPE="ext4"

partition's system id :

	83 Various filesystem types like xiafs, ext2, ext3, reiserfs, etc. all use ID 83. Some systems mistakenly assume that 83 must mean ext2.
	82 linux swap
	5  Extended
	07 Windows NT NTFS
	af MacOS X HFS
		Used by Apple for the MacOS X filesystem HFS or HFS+ on Intel.


# Ext2 文件系统

## ext2 存储布局
文件系统的最小单位是block 块(mke2fs -b 设定block 大小，比如4096)，一个分区的文件系统将存储区布局如下（由一个Boot Block 和 多个Block Group 组成）：

![文件系统布局](http://akaedu.github.io/book/images/fs.ext2layout.png)

Boot Block 是PC 标准所规定的，是不能被文件系统所使用的.

## Block Group
每一个Block Group 由Super Block, GDT, Block Bitmap, inode Bitmap, inode Table, Data Block 组成。
其中，为了防步数据丢失或者异常，Super Block, GDT 在每个Block Group 中都是相同的拷贝. 如果某一块（一般查第0 块）拷贝与其它不同，分区自检时可以被纠正。

### Supuer Block 超级块
超级块描述的是文件系统信息：块大小，文件系统版本号，上次mount 时间, 分区UUID。

### GDT, Group Descriptor Table 块组描述符
GDT 描述了*所有的块组*信息(分区有多少块组，就有多少块组信息)：

- Block Bitmap 从哪里开始，
- inode Bitmap 从哪里开始，
- inode 表从哪里开始，
- data block 数据块从哪里开始
- 空闲的inode和数据块有多少.
- ...

### Block Bitmap 块位图
描述：该块组中的各个块是否被占用(0 或 1). 比如数据块，GDT 等占用了一个或者多个块，就需要在一个或者多个对应的bit 上 设1.
Block Bitmap 只占用一个block: 如果block 有B 个字节，那么块组最多只能有8B 个块。整个块组会占用 $8B^2$ 字节.

df : df 命令查看分区占用，就是扫描的所有块组的Bitmap 或者 GDT

> 一个分区有多少块组？ 如果一个块占B 字节，那么块组占用 8B^2 字节，如果分区是S 字节，那么，分划分S/(8B^2) 个块组.
如果B=4096, 那么一个块组有8B^2 (128M). 可以通过`dumpe2fs /dev/sda1` 这样的命令查看文件系统信息

## inode Bitmap, inode 位图
与Block Bitmap 一样，只占用一个块

## inode Table, inode 表
- 存储文件描述信息：文件类型(目标，常规，符号链接，Pipe...)，文件大小，修改时间，权限,所有者，所有组 ... 这此信息存储在inode 中，而不是数据块中。
- 每个块组的inode 数量：在格式化时就要确定，mke2fs 默认块组有多少个8Kb 就分配多少inode. 因为数据块占用了绝大部分空间，如果文件平均的大小是8kb, 那么inode 就被充分利用了。可用mke2fs的-i参数手动指定每多少个字节分配一个inode。

## Data Block, 数据块
数据块是由多个Block 组成的。根据不同的文件类型，有以下几种情况：

- 常规文件 数据存储在数据块中，可能数据不是连续的，所以文件的fseek/lseek 寻址时，不是随机的，时间复杂度不能为O(1), 如果按树形结构存储数据，那么其seek的时间复杂度可以达到O(logX(n)): http://stackoverflow.com/questions/21658364/is-lseek-o1-complexity
- 目录 文件名和目录名保存在数据块中。
- 符号链接文件 目标路径名短就存到inode中，否则存储到数据块中。
- 设备文件 主设备号(内核中的驱动), 及次设备号，保存到inode中
- FIFO和socket 等 没有数据块

# 创建文件系统

## 创建分区或者文件

	$ dd if=/dev/zero of=fs count=256 bs=4K

## 格式化文件系统
格式化命令如：

	//for ext2
	$ mke2fs <block_device>
	//for ext2 ext3 ext4 ...
	$ mkfs -t ext4 <block_device>
	$ mkfs.ext4 <block_device>

为刚才的fs 做ext2 系统

	$ mke2fs fs

*可以选择设置 partition label*

	$ e2label <block_device> <label>
	$ e4label <block_device> <label>


### 用od & dumpe2fs 查看文件系统的数据结构
整个系统是1MB, 一共有1024 个block. block 0 号是启动块，block 1~1023 属于Group 0.

![](/img/linux-fs-block.1.png)
从图中可以看到0x~0x3ff(block 0) 是1kb启动块。

0x400~0x7ff(block 1) 是1kb超级块

从0x800 (block 2~5)开始是块组描述符GDT, 这个文件系统小，只有一个块组描述符.
块组描述符指出:
- block bitmap 位于block 6
- inode bitmap 位于block 7,
- inode table 位于block 8-23. 因为格式化时每个block group 设定了128 个inode， 每个inode 占用128 个字节，一共占用16个块(8+15=23)
- data block 位于block 24~1023，块组描述符指出:986 free blocks(文件系统占用24-37), 117 free inodes(已经有11个inode被使用，前10个是系统保留，其中inode 2是根目录，inode 11是普通的lost+found), 2 directories
  Free blocks: 38-1023
  Free inodes: 12-128


![](/img/linux-fs-block-gdt.png)

	$ dumpe2fs fs
	...
	Group 0: (Blocks 1-1023)
	  Primary superblock at 1, Group descriptors at 2-2
	  Reserved GDT blocks at 3-5
	  Block bitmap at 6 (+5), Inode bitmap at 7 (+6)
	  Inode table at 8-23 (+7)
	  986 free blocks, 117 free inodes, 2 directories
	  Free blocks: 38-1023
	  Free inodes: 12-128
	...

## 用debugfs 搜索文件
debugfs 是一个交互式的命令, stat / 可以查看 根目录的inode的信息

	$ test  debugfs fs
	$ debugfs 1.41.12 (17-May-2010)
	> debugfs:  stat /
	Inode: 2   Type: directory    Mode:  0755   Flags: 0x0
	Generation: 0    Version: 0x00000000
	User:     0   Group:     0   Size: 1024
	File ACL: 0    Directory ACL: 0
	Links: 3   Blockcount: 2
	Fragment:  Address: 0    Number: 0    Size: 0
	ctime: 0x543cdceb -- Tue Oct 14 16:20:59 2014
	atime: 0x543ceaaa -- Tue Oct 14 17:19:38 2014
	mtime: 0x543cdceb -- Tue Oct 14 16:20:59 2014
	BLOCKS:
	(0):24
	TOTAL: 1

对比一下od 查看到的 *根目录的inode 表结构*：
![](/img/linux-fs-block-inode-table.png)

上图中，st_mode 体育馆和文件类型和文件权限，最高污染的4表示类型为目录，低位的755表示权限. links=3 表示目录有三个硬连接，分别是根目录上的".",".."和"lost+found"目录下的".."(目录的硬链接只能是"."和".."). blockcount=2 表示两个sector 扇区(512*2=1kb).

根目录的数据块由blocks[0] 指出，也就是block 24, 实际地址是24*0x400 = 0x6000.  如果一个数据块不够，它还会再找一个空闲块，并把空闲块的块号写到block[1]. inode可以存放有限的block标号, 所以一个目录下有多少文件也是有限的(取决于文件名长度等多种因素)
用od 找到0x6000 开始的目录类型的数据结构：

根目录的数据块结构:

![](/img/linux-fs-block-data-dir.png)

目录的数据块由许多不定长的记录组成，每条记录描述该目录下的一个文件，在上图中用框表示。第一条记录描述inode号为2的文件，也就是根目录本身，该记录的总长度为12字节，其中文件名的长度为1字节，文件类型为2（见下表，注意此处的文件类型编码和st_mode不一致），文件名是.。

目录数据块中的文件类型编码(与inode中的st_mode不同):

	|编码	|文件类型|
	|0	|Unknown|
	|1	|Regular file|
	|2	|Directory|
	|3	|Character device|
	|4	|Block device|
	|5	|Named pipe|
	|6	|Socket|
	|7	|Symbolic link|

第二条记录描述的也是inode2(根目录)，记录长度12字节，其中文件名长度2字节(".."), 文件类型2, 文件名是"..".
第三条记录描述的是inode11(lost+found), 记录长度1000字节，文件类型2，文件名"lost+found". 如果要在根目录下文件名太多，block 不足, 则会分配一个新的block，block编号写到inode 的block[1] .

debugfs也提供了cd、ls等命令，不需要mount就可以查看这个文件系统中的目录

## 挂载
挂载后可以看到目录下有三个文件，".", "..", "lost+found". "lost+found" 目录由e2fsck 使用，如果磁盘检查时发现有错误的块，就会把错误的块放到这个目录，这些块的资料不知道是谁的，就放到这里“失物招领”了。

	$ mount -o loop fs /mnt
	$ ls -la /mnt
	.
	..
	lost+found

# 数据块寻址
如果一个文件有多个数据块，这些数据块很可能不是连续存放的，应该如何寻址到每个块呢？根据上面的分析，根目录的数据块是通过其inode中的索引项Blocks[0]找到的，事实上，这样的索引项一共有15个，从Blocks[0]到Blocks[14]，每个索引项占4字节。前12个索引项都表示块编号，例如上面的例子中Blocks[0]字段保存着24，就表示第24个块是该文件的数据块，如果块大小是1KB，这样可以表示从0字节到12KB的文件。如果剩下的三个索引项Blocks[12]到Blocks[14]也是这么用的，就只能表示最大15KB的文件了，这是远远不够的，事实上，剩下的三个索引项都是间接索引。

索引项Blocks[12]所指向的块并非数据块，而是称为间接寻址块（Indirect Block），其中存放的都是类似Blocks[0]这种索引项，再由索引项指向数据块。设块大小是b，那么一个间接寻址块中可以存放b/4个索引项，指向b/4个数据块。所以如果把Blocks[0]到Blocks[12]都用上，最多可以表示b/4+12个数据块，对于块大小是1K的情况，最大可表示268K的文件。如下图所示，注意文件的数据块编号是从0开始的，Blocks[0]指向第0个数据块，Blocks[11]指向第11个数据块，Blocks[12]所指向的间接寻址块的第一个索引项指向第12个数据块，依此类推。

图 数据块的寻址

![](/img/linux-fs-block-data-address.png)


从上图可以看出，索引项Blocks[13]指向两级的间接寻址块，最多可表示(b/4)2+b/4+12个数据块，对于1K的块大小最大可表示64.26MB的文件。索引项Blocks[14]指向三级的间接寻址块，最多可表示`(b/4)^3+(b/4)^2+b/4+12`个数据块，对于1K的块大小最大可表示16.06GB的文件。

可见，这种寻址方式对于访问不超过12个数据块的小文件是非常快的，访问文件中的任意数据只需要两次读盘操作，一次读inode（也就是读索引项）一次读数据块。而访问大文件中的数据则需要最多五次读盘操作：inode、一级间接寻址块、二级间接寻址块、三级间接寻址块、数据块。实际上，磁盘中的inode和数据块往往已经被内核缓存了，读大文件的效率也不会太低。

# 文件和目录操作的系统函数
常用的文件操作命令如ls、cp、mv等是基于系统函数来实现的。

## stat
stat(2)函数读取文件的inode，然后把inode中的各种文件属性填入一个struct stat结构体传出给调用者。stat(1)命令是基于stat函数实现的。
stat需要根据传入的文件路径找到inode，假设一个路径是/opt/file，则查找的顺序是：

1. 读出inode表中第2项，也就是根目录的inode，从中找出根目录数据块的位置
1. 从根目录的数据块中找出文件名为opt的记录，从记录中读出它的inode号
1. 读出opt目录的inode，从中找出它的数据块的位置
1. 从opt目录的数据块中找出文件名为file的记录，从记录中读出它的inode号
1. 读出file文件的inode

还有另外两个类似stat的函数：
1. fstat(2)函数*传入一个已打开的文件描述符*，传出inode信息，
2. lstat(2)函数*像stat*传出inode信息，但是和stat函数有一点不同，当文件是一个符号链接时，stat(2)函数传出的是它所指向的目标文件的inode，而*lstat函数传出的就是符号链接文件本身*的inode。

	struct stat statbuf;
	stat(path, &statbuf);
	S_ISSOCK(statbuf.st_mode);//是否是socket 文件(statbuf.st_mode | S_IFSOCK)

shell 下也有stat 命令


	$ file owner
	$ stat -c '%U' dir; # linux
	hilojack
	$ stat -f '%Su' dir; # FreeBSD/Mac OSX
	hilojack
	$ ls -ld dir | awk '{print $3}'
	hilojack

	$ file size in bytes
	stat -c %s file ;# linux

## access
access(2)函数检查执行当前进程的用户是否有权限访问某个文件，传入文件路径和要执行的访问操作（读/写/执行），access函数取出文件inode中的st_mode字段，比较一下访问权限，然后返回0表示允许访问，返回-1表示错误或不允许访问。

## chmod
chmod(2)和fchmod(2)函数改变文件的访问权限，也就是修改inode中的st_mode字段。这两个函数的区别类似于stat/fstat。chmod(1)命令是基于chmod函数实现的。

## chown
chown(2)/fchown(2)/lchown(2)改变文件的所有者和组，也就是修改inode中的User和Group字段，只有超级用户才能正确调用这几个函数，这几个函数之间的区别类似于stat/fstat/lstat。chown(1)命令是基于chown函数实现的。

## utime
utime(2)函数改变文件的访问时间和修改时间，也就是修改inode中的atime和mtime字段。
touch(1)命令是基于utime函数实现的。

## truncate
truncate(2)和ftruncate(2)函数把文件截断到某个长度，如果新的长度比原来的长度短，则后面的数据被截掉了，如果新的长度比原来的长度长，则后面多出来的部分用0填充，这需要修改inode中的Blocks索引项以及块位图中相应的bit。这两个函数的区别类似于stat/fstat。

## link
link(2)函数创建硬链接，其原理是在目录的数据块中添加一条新记录，其中的inode号字段和原文件相同。
symlink(2)函数创建一个符号链接，这需要创建一个新的inode，其中st_mode字段的文件类型是符号链接，原文件的路径保存在inode中或者分配一个数据块来保存。ln(1)命令是基于link和symlink函数实现的。

## unlink
unlink(2)函数删除一个链接。如果是符号链接则释放这个符号链接的inode和数据块，清除inode位图和块位图中相应的位。如果是硬链接则从目录的数据块中清除一条文件名记录，如果当前文件的硬链接数已经是1了还要删除它，就同时释放它的inode和数据块，清除inode位图和块位图中相应的位，这样就真的删除文件了。
unlink(1)命令和rm(1)命令是基于unlink函数实现的。

     int
     unlink(const char *path);

     int
     unlinkat(int fd, const char *path, int flag);

## rename
rename(2)函数改变文件名，需要修改目录数据块中的文件名记录，如果原文件名和新文件名不在一个目录下则需要从原目录数据块中清除一条记录然后添加到新目录的数据块中。mv(1)命令是基于rename函数实现的，因此在同一分区的不同目录中移动文件并不需要复制和删除文件的inode和数据块，只需要一个改名操作，即使要移动整个目录，这个目录下有很多子目录和文件也要随着一起移动，移动操作也只是对顶级目录的改名操作，很快就能完成。但是，如果在不同的分区之间移动文件就必须复制和删除inode和数据块，如果要移动整个目录，所有子目录和文件都要复制删除，这就很慢了。

## readlink
readlink(2)函数读取一个符号链接所指向的目标路径，其原理是从符号链接的inode或数据块中读出保存的数据，这就是目标路径。

## mkdir
mkdir(2)函数创建新的目录，要做的操作是在它的父目录数据块中添加一条记录，然后分配新的inode和数据块，inode的st_mode字段的文件类型是目录，在数据块中填两个记录，分别是.和..，由于..表示父目录，因此父目录的硬链接数要加1。mkdir(1)命令是基于mkdir函数实现的。

## rmdir
rmdir(2)函数删除一个目录，这个目录必须是空的（只包含.和..）才能删除，要做的操作是释放它的inode和数据块，清除inode位图和块位图中相应的位，清除父目录数据块中的记录，父目录的硬链接数要减1。rmdir(1)命令是基于rmdir函数实现的。

## chdir
chdir(2) Chang Current Directory. The shell command `ls` calls this system call.

     int chdir(const char *path);
     int fchdir(int fildes);
	 //return 0 -1

## opendir/readdir/closedir
opendir(3)/readdir(3)/closedir(3)用于遍历目录数据块中的记录。opendir打开一个目录，返回一个DIR *指针代表这个目录，它是一个类似FILE *指针的句柄，closedir用于关闭这个句柄，把DIR *指针传给readdir读取目录数据块中的记录，每次返回一个指向struct dirent的指针，反复读就可以遍历所有记录，所有记录遍历完之后readdir返回NULL。结构体struct dirent的定义如下：

	struct dirent {
		ino_t          d_ino;       /* inode number */
		off_t          d_off;       /* offset to the next dirent */
		unsigned short d_reclen;    /* length of this record */
		unsigned char  d_type;      /* type of file */
		char           d_name[256]; /* filename */
	};


这里的d_type 与inode中的st_mode 一致(8 进制，可通过man 2 stat 查看):

	 #define        S_IFIFO  0010000  /* named pipe (fifo) */
     #define        S_IFCHR  0020000  /* character special */
     #define        S_IFDIR  0040000  /* directory */
     #define        S_IFBLK  0060000  /* block special */
     #define        S_IFREG  0100000  /* regular */
     #define        S_IFLNK  0120000  /* symbolic link */
     #define        S_IFSOCK 0140000  /* socket */
     #define        S_IFWHT  0160000  /* whiteout */

这里的文件名d_name被库函数处理过，已经在结尾加了'\0'，而 “根目录的数据块”中的文件名字段不保证是以'\0'结尾的，需要根据前面的文件名长度字段确定文件名到哪里结束。

## 递归列出目录中的文件列表

	#include <sys/stat.h>
	#include <stdio.h>
	#include <dirent.h>
	#include <string.h>
	void dirwalk(char * file, void (*func)(char *)){
		char name[100];
		DIR *dfd;
		dfd = opendir(file);
		struct dirent * dp;
		while((dp = readdir(dfd)) != NULL){
			if(strcmp(dp->d_name, ".") != 0 && strcmp(dp->d_name, "..") != 0){
				sprintf(name, "%s/%s", file, dp->d_name);
				(*func)(name);
			}
		};
		closedir(dfd);
	}
	void fsize(char * file){
		struct stat stbuf;
		if(stat(file, &stbuf) == -1){
			fprintf(stderr, "fsize: can't access %s\n", file);
		}

		if(stbuf.st_mode & S_IFDIR){
			dirwalk(file, fsize);
		}else{
			printf("%8lld %s\n", stbuf.st_size, file);
		}

	}
	int main(){
		char dir[] = ".";
		fsize(dir);
		return 1;
	}

# VFS
为了支持不同的文件系统:ext2,ext3,ext4,reiserfs, ntfs,fat... linux 内核在文件系统之上做了一个fs 抽像层，即VFS(Virtual File System, 虚拟文件系统)

## VFS 在内存中的数据结构
![](/img/linux-fs-vfs.png)

* 文件描述符指向的是file 结构体*
在linux 中，每个进程在PCB（Process Control Block）中都保存着一份文件描述符表，文件描述符就是这个表的索引，每个表项都有一个指向已打开文件的指针，现在我们明确一下：已打开的文件在内核中用file结构体表示，文件描述符表中的指针指向file结构体。

### file->f_flags 打开模式
在file结构体中维护File Status Flag（file结构体的成员f_flags）和当前读写位置（file结构体的成员f_pos）。在上图中，进程1和进程2都打开同一文件，但是对应不同的file结构体，因此可以有不同的File Status Flag和读写位置。file结构体中比较重要的成员还有f_count，表示引用计数（Reference Count），后面我们会讲到，dup、fork等系统调用会导致多个文件描述符指向同一个file结构体，例如有fd1和fd2都引用同一个file结构体，那么它的引用计数就是2，当close(fd1)时并不会释放file结构体，而只是把引用计数减到1，如果再close(fd2)，引用计数就会减到0同时释放file结构体，这才真的关闭了文件。

### file->file_operations 文件操作函数
每个file结构体都指向一个file_operations结构体，这个结构体的成员都是函数指针，指向实现各种文件操作的内核函数。比如在用户程序中read一个文件描述符，read通过系统调用进入内核，然后找到这个文件描述符所指向的file结构体，找到file结构体所指向的file_operations结构体，调用它的read成员所指向的内核函数以完成用户请求。在用户程序中调用lseek、read、write、ioctl、open等函数，最终都由内核调用file_operations的各成员所指向的内核函数完成用户请求。file_operations结构体中的release成员用于完成用户程序的close请求，之所以叫release而不叫close是因为它不一定真的关闭文件，而是减少引用计数，只有引用计数减到0才关闭文件。对于同一个文件系统上打开的常规文件来说，read、write等文件操作的步骤和方法应该是一样的，调用的函数应该是相同的，所以图中的三个打开文件的file结构体指向同一个file_operations结构体。如果打开一个字符设备文件，那么它的read、write操作肯定和常规文件不一样，不是读写磁盘的数据块而是读写硬件设备，所以file结构体应该指向不同的file_operations结构体，其中的各种文件操作函数由该设备的驱动程序实现。

### file->dentry 目录项缓存
每个file结构体都有一个指向dentry结构体的指针，“dentry”是directory entry（目录项）的缩写。我们传给open、stat等函数的参数的是一个路径，例如/home/akaedu/a，需要根据路径找到文件的inode。为了减少读盘次数，内核缓存了目录的树状结构，称为dentry cache，其中每个节点是一个dentry结构体，只要沿着路径各部分的dentry搜索即可，从根目录/找到home目录，然后找到akaedu目录，然后找到文件a。dentry cache只保存最近访问过的目录项，如果要找的目录项在cache中没有，就要从磁盘读到内存中。

### file->inode 权限大小所有者
每个dentry结构体都有一个指针指向inode结构体。inode结构体保存着从磁盘inode读上来的信息。在上图的例子中，有两个dentry，分别表示/home/akaedu/a和/home/akaedu/b，它们都指向同一个inode，说明这两个文件互为硬链接。inode结构体中保存着从磁盘分区的inode读上来信息，例如所有者、文件大小、文件类型和权限位等。

### inode_operations 目录操作函数
每个inode结构体都有一个指向inode_operations结构体的指针，后者也是一组函数指针指向一些完成文件目录操作的内核函数。和file_operations不同，inode_operations所指向的不是针对某一个文件进行操作的函数，而是影响文件和目录布局的函数，例如添加删除文件和目录、跟踪符号链接等等，属于同一文件系统的各inode结构体可以指向同一个inode_operations结构体。

### inode->super_block inode所属的文件系统
inode结构体有一个指向super_block结构体的指针。super_block结构体保存着从磁盘分区的超级块读上来的信息，例如文件系统类型、块大小等。super_block结构体的s_root成员是一个指向dentry的指针，表示这个文件系统的根目录被mount到哪里，在上图的例子中这个分区被mount到/home目录下。
inode 值是所属文件系统确定的，必须通过super_block 才能找到inode的确定位置。

file、dentry、inode、super_block这几个结构体组成了VFS的核心概念。对于ext2文件系统来说，在磁盘存储布局上也有inode和超级块的概念，所以很容易和VFS中的概念建立对应关系。而另外一些文件系统格式来自非UNIX系统（例如Windows的FAT32、NTFS），可能没有inode或超级块这样的概念，但为了能mount到Linux系统，也只好在驱动程序中硬凑一下，在Linux下看FAT32和NTFS分区会发现权限位是错的，所有文件都是rwxrwxrwx，因为它们本来就没有inode和权限位的概念，这是硬凑出来的。

## dup 和dup2 函数
两次open 同一个文件打开的是两个数据相同file 结构体.
dup(2)/dup2(2) 用于复制现存的文件描述符，使两个文件描述符指向同一个file 结构体。
file 结构中的f_count（引用计数）加1 变成2 ，其它信息如: File Status Flag，读写位置等都保持不变。

	#include <unistd.h>
	int dup(int oldfd);
	int dup2(int oldfd, int newfd);//newfd 指向oldfd 指向的文件
	//调用成功, 则返回新分配或者指定的文件描述符，失败则返回 -1

dup 返回的新文件描述符一定是该进程未使用的最小文件描述符，这一点和open类似。
dup2 可以用newfd参数指定新描述符的数值。
	如果newfd当前已经打开，则自动将其关闭再做dup2操作
	如果oldfd等于newfd，则dup2直接返回newfd而不用先关闭newfd 再复制

如果返回的值-1，就是错误, for details, refer to  `man dup2`

![](/img/linux-fs-dup.png)

	#include <unistd.h>
	#include <sys/stat.h>
	#include <fcntl.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	int main(void) {
		int fd, save_fd;
		char msg[] = "This is a test\n";

		fd = open("somefile", O_RDWR|O_CREAT, S_IRUSR|S_IWUSR);
		if(fd<0) {
			perror("open");
			exit(1);
		}
		save_fd = dup(STDOUT_FILENO);
		dup2(fd, STDOUT_FILENO);
		close(fd);
		write(STDOUT_FILENO, msg, strlen(msg));
		dup2(save_fd, STDOUT_FILENO);
		write(STDOUT_FILENO, msg, strlen(msg));
		close(save_fd);
		return 0;
	}

# Reference
- [linux fs] by 宋劲杉

[linux fs]: http://akaedu.github.io/book/ch29.html
[ext4]: https://ext4.wiki.kernel.org/index.php/Ext4_Disk_Layout#Inline_Data
