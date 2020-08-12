---
title: netcat
date: 2018-09-28
---
# netcat,
[nc](http://www.oschina.net/translate/linux-netcat-command?p=2#comments)

# nc
Netcat 或者叫 nc 是 Linux 下的一个用于调试和检查网络工具包。可用于创建 TCP/IP 连接，最大的用途就是用来处理 TCP/UDP 套接字。

- 它能通过TCP和UDP在网络中读写数据。通过与其他工具结合和重定向，你可以在脚本中以多种方式使用它。
- netcat所做的就是在两台电脑之间建立链接并返回两个数据流，在这之后所能做的事就看你的想像力了。你能建立一个服务器，传输文件，与朋友聊天，传输流媒体或者用它作为其它协议的独立客户端。

下面是一些使用netcat的例子.

    [A(172.31.100.7) B(172.31.100.23)]

## install ncat

    yum install nmap-ncat

## 端口扫描
端口扫描经常被系统管理员和黑客用来发现在一些机器上开放的端口，帮助他们识别系统中的漏洞。

  $ nc -z -v -n 172.31.100.7 21-25

可以运行在TCP或者UDP模式，默认是TCP，-u参数调整为udp.

    -z 参数告诉netcat, 连接成功后立即关闭连接，不进行IO数据交换
    -u  udp, 默认是tcp
    -t  使用-t选项模拟Telnet客户端，
    -v 参数指使用冗余选项
    -n 参数告诉netcat 不要使用DNS反向查询IP地址的域名
    21-25
        这个命令会打印21到25 所有开放的端口。

Banner是一个文本，Banner是一个你连接的服务发送给你的文本信息。当你试图鉴别漏洞或者服务的类型和版本的时候，Banner信息是非常有用的。但是，并不是所有的服务都会发送banner。
一旦你发现开放的端口，你可以容易的使用netcat 连接服务抓取他们的banner。

    $ nc -v 172.31.100.7 21

netcat 命令会连接开放端口21并且打印运行在这个端口上服务的banner信息。

## tcp Server(-l)
netcat提供了这样一种方法，创建一个Chat服务器，一个预先确定好的端口，这样子别人就可以联系到你了。

server: netcat 命令在1567端口启动了一个tcp 服务器，所有的标准输出和输入会输出到该端口。输出和输入都在此shell中展示:

  $ nc -l 1567
  $ nc -l 127.0.0.1 5000

### tcp client
Client 访问1567:

  $ nc 127.0.0.1 1567
  或者用curl 访问
  $ curl 127.0.0.1:1567/a/b/c/d

不管你在机器B上键入什么都会出现在机器A上。

## udp
不要用localhost

    echo -n "$1" | nc -4u -w1 $HOST $PORT
    echo "hi" | nc -cu 127.0.0.1 8000
        -c close (mac osx)
        -u udp
        -w wait timeout

    echo -n "hello" >/dev/udp/remotehost/8000


## 文件传输
有很多种方法，比如FTP,SCP,SMB等等，但是当你只是需要临时或者一次传输文件，真的值得浪费时间来安装配置一个软件到你的机器上嘛。

假设，你想要传一个文件file.txt 从A 到B。A或者B都可以作为服务器或者客户端，以下，让A作为服务器，B为客户端。

A Server

  $nc -l 1567 < file.txt

B Client

  $nc -n 172.31.100.7 1567 > file.txt

这里我们创建了一个服务器在A上并且重定向netcat的输入为文件file.txt，那么当任何成功连接到该端口，netcat会发送file的文件内容。

没有必要创建文件源作为Server，我们也可以相反的方法使用。像下面的我们发送文件从B到A，但是服务器创建在A上，这次我们仅需要重定向netcat的输出并且重定向B的输入文件。

B作为Server

  $nc -l 1567 > file.txt

Client

  nc 172.31.100.23 1567 < file.txt

## 4，目录传输
发送一个文件很简单，但是如果我们想要发送多个文件，或者整个目录，一样很简单，只需要使用压缩工具tar，压缩后发送压缩包。

如果你想要通过网络传输一个目录从A到B。

  Server
  $tar -cvf – dir_name | nc -l 1567

  Client
   $nc -n 172.31.100.7 1567 | tar -xvf -

如果想要节省带宽传输压缩包，我们可以使用bzip2或者其他工具压缩。

  Server
   $tar -cvf – dir_name| bzip2 -z | nc -l 1567
  通过bzip2压缩
  Client
   $nc -n 172.31.100.7 1567 | bzip2 -d |tar -xvf -

## 5. 加密你通过网络发送的数据
如果你担心你在网络上发送数据的安全，你可以在发送你的数据之前用如mcrypt的工具加密。

  服务端
  $mcrypt –flush –bare -F -q -m ecb < file.txt | nc -l 1567

  客户端
  $nc localhost 1567 | mcrypt –flush –bare -F -q -d -m ecb > file.txt

以上两个命令会提示需要密码，确保两端使用相同的密码。
这里我们是使用mcrypt用来加密，使用其它任意加密工具都可以。

## 6. 流视频
虽然不是生成流视频的最好方法，但如果服务器上没有特定的工具，使用netcat，我们仍然有希望做成这件事。

服务端

  $cat video.avi | nc -l 1567

这里我们只是从一个视频文件中读入并重定向输出到netcat客户端

  $ nc 172.31.100.7 1567 | mplayer -vo x11 -cache 3000 -

这里我们从socket中读入数据并重定向到mplayer。

## 打开一个shell
我们已经用过远程shell, 使用telnet和ssh，但是如果这两个命令没有安装并且我们没有权限安装他们，我们也可以使用netcat创建远程shell。

假设你的netcat支持 -c -e 参数(默认 netcat)

  # Server
  nc -l 1567 -e /bin/bash -i
  # Client
  nc 172.31.100.7 1567

这里我们已经创建了一个netcat服务器并且表示当它连接成功时执行/bin/bash

假如netcat 不支持-c 或者 -e 参数（openbsd netcat）,我们仍然能够创建远程shell

  #Server
  mkfifo /tmp/tmp_fifo
  cat /tmp/tmp_fifo | /bin/sh -i 2>&1 | nc -l 1567 > /tmp/tmp_fifo

这里我们创建了一个fifo文件，然后使用管道命令把这个fifo文件内容定向到shell 2>&1中。是用来重定向标准错误输出和标准输出，然后管道到netcat 运行的端口1567上。至此，我们已经把netcat的输出重定向到fifo文件中。

说明：

1. 从网络收到的输入写到fifo文件中
2. cat 命令读取fifo文件并且其内容发送给sh命令
2. sh命令进程受到输入并把它写回到netcat。
2. netcat 通过网络发送输出到client

至于为什么会成功是因为管道使命令平行执行，fifo文件用来替代正常文件，因为fifo使读取等待而如果是一个普通文件，cat命令会尽快结束并开始读取空文件。

在客户端仅仅简单连接到服务器

  Client
  $nc -n 127.0.0.1 1567

你会得到一个shell提示符在客户端

### 反向shell
反向shell是指在客户端打开的shell。反向shell这样命名是因为不同于其他配置，这里服务器使用的是由客户提供的服务。

  服务端
  $nc -l 1567

在客户端，简单地告诉netcat在连接完成后，执行shell。

  客户端
  $nc 172.31.100.7 1567 -e /bin/bash

现在，什么是反向shell的特别之处呢
反向shell经常被用来绕过防火墙的限制，如阻止入站连接。例如，我有一个专用IP地址为172.31.100.7，我使用代理服务器连接到外部网络。如果我想从网络外部访问 这台机器如1.2.3.4的shell，那么我会用反向外壳用于这一目的。

## 10. 指定源端口(-p port)

假设你的防火墙过滤除25端口外其它所有端口，你需要使用-p选项指定源端口。

  服务器端
  $nc -l 1567
  客户端
  $nc 172.31.100.7 1567 -p 25

该命令将在客户端开启25端口用于通讯，否则将使用随机端口。

## 11. 指定源地址(-s src)
假设你的机器有多个地址，希望明确指定使用哪个地址用于外部数据通讯。我们可以在netcat中使用-s选项指定ip地址。

  服务器端
  $ nc -u -l 1567 < file.txt
  客户端
  $ nc -u 172.31.100.7 1567 -s 172.31.100.5 > file.txt

该命令将绑定地址172.31.100.5。

这仅仅是使用netcat的一些示例。

## 其它用途有

    使用-t选项模拟Telnet客户端，
    HTTP客户端用于下载文件，
    连接到邮件服务器，使用SMTP协议检查邮件，
    使用ffmpeg截取屏幕并通过流式传输分享，等等。

只要你了解协议就可以使用netcat作为网络通讯媒介，实现各种客户端。

## 3. Netcat 支持超时控制

多数情况我们不希望连接一直保持，那么我们可以使用 -w 参数来指定连接的空闲超时时间，该参数紧接一个数值，代表秒数，如果连接超过指定时间则连接会被终止。

服务器:

  nc -l 2389

客户端:

  $ nc -w 10 localhost 2389

该连接将在 10 秒后中断。

注意: 不要在服务器端同时使用 -w 和 -l 参数，因为 -w 参数将在服务器端无效果。

## Netcat 支持 IPv6
netcat 的 -4 和 -6 参数用来指定 IP 地址类型，分别是 IPv4 和 IPv6：

服务器端：

  $ nc -4 -l 2389

客户端：

  $ nc -4 localhost 2389

然后我们可以使用 netstat 命令来查看网络的情况：

  $ netstat | grep 2389
  tcp        0      0 localhost:2389          localhost:50851         ESTABLISHED
  tcp        0      0 localhost:50851         localhost:2389          ESTABLISHED
接下来我们看看IPv6 的情况：

服务器端：

  $ nc -6 -l 2389

客户端：

  $ nc -6 localhost 2389

再次运行 netstat 命令：

  $ netstat | grep 2389
  tcp6       0      0 localhost:2389          localhost:33234         ESTABLISHED
  tcp6       0      0 localhost:33234         localhost:2389          ESTABLISHED

前缀是 tcp6 表示使用的是 IPv6 的地址。

## 在 Netcat 中禁止从标准输入中读取数据

该功能使用 -d 参数，请看下面例子：

  服务器端：

    $ nc -l 2389

  客户端：

    $ nc -d localhost 2389
    Hi

你输入的 Hi 文本并不会送到服务器端。



## 强制 Netcat 服务器端保持启动状态

如果连接到服务器的客户端断开连接，那么服务器端也会跟着退出。

服务器端：

  $ nc -l 2389

客户端：

  $ nc localhost 2389

服务器端：

  $ nc -l 2389

上述例子中，但客户端断开时服务器端也立即退出。

我们可以通过 -k 参数来控制让服务器不会因为客户端的断开连接而退出。

服务器端：

  $ nc -k -l 2389

客户端：

  $ nc localhost 2389

服务器端：

  $ nc -k -l 2389


## 配置 Netcat 客户端不会因为 EOF 而退出

Netcat 客户端可以通过 -q 参数来控制接收到 EOF 后隔多长时间才退出，该参数的单位是秒：

客户端使用如下方式启动：

  nc  -q 5  localhost 2389

现在如果客户端接收到 EOF ，它将等待 5 秒后退出。