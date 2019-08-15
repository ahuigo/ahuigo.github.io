---
title: net-dns
date: 2018-09-28
---
# Preface

主机名.次级域名.顶级域名.根域名

  host.sld.tld.root

  A记录：服务器 IP
  AAAA：服务器 IPv6 的地址。
  CNAME记录： 你空间商给您提供的域名
  MX记录：您邮件服务器的IP地址或企业邮局给您提供的域名
  TXT记录：一般用于 Google、QQ等企业邮箱的反垃圾邮件设置
  显性URL记录：填写要跳转到的网址
  隐性URL记录：填写要引用内容的网址
  NS记录：不常用。系统默认添加的两个NS记录请不要修改。NS向下授权，填写dns域名，例如：f1g1ns1.dnspod.net
  SRV记录：不常用。
    格式为：优先级、空格、权重、空格、端口、空格、主机名，记录生成后会自动在域名后面补一个“.”，这是正常现象。例如：5 0 5269 xmpp-server.l.google.com.

## 根域名服务器
每一级域名都有自己的NS记录，NS记录指向该级域名的域名服务器。这些服务器知道下一级域名的各种记录。

1. 从"根域名服务器"查到"顶级域名服务器"的NS记录和A记录（IP地址）
2. 从"顶级域名服务器"查到"次级域名服务器"的NS记录和A记录（IP地址）
3. 从"次级域名服务器"查出"主机名"的IP地址

> 世界上一共有十三组根域名服务器，从A.ROOT-SERVERS.NET一直到M.ROOT-SERVERS.NET

  dig +trace math.stackexchange.com
  ;; global options: +cmd
  .			423356	IN	NS	d.root-servers.net.
  com.			172800	IN	NS	i.gtld-servers.net.
  stackexchange.com.	172800	IN	NS	ns-1832.awsdns-37.co.uk.
  math.stackexchange.com.	300	IN	A	151.101.65.69

查看 dns server

  $ dig ns math.stackexchange.com
  stackexchange.com.	866	IN	SOA	ns-1832.awsdns-37.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400

  # +short参数可以显示简化的结果。
  $ dig +short ns com
  $ dig +short ns stackexchange.com

## TTL
TTL 为缓存时间，数值越小，修改记录各地生效时间越快

## A记录
A记录是用来创建到IP地址的记录。

1、主机记录中填写@或者留空，则是不带 www 的 IP
2、`*.hiloack.com` 则表示所有的二级域名
3、同一个二级域名 可设置了多个A记录

在命令行下可以通过`nslookup -q=a ahuigo.github.io`来查看A记录。

  dig +trace math.stackexchange.com
  $ dig a github.com
  $ dig ns github.com
  $ dig mx github.com

## AAAA记录
AAAA记录是一个指向IPv6地址的记录。

  $ dig aaaa google.com
  $ nslookup  -q=aaaa google.com
  Non-authoritative answer:
  google.com	has AAAA address 200:2:2e52:ae44::

## MX（Mail Exchanger）记录
当发送邮件时，Mail 服务器先对域名进行解析，查找 mx 记录。

1. 先找权重数最小的服务器（比如腾讯的5），如果能连通，那么就将服务器发送过去；如果无法连通 mx 记录为 5 的服务器，才将邮件发送到权重为 10 的 mail 服务器上。
2. 权重 10 的服务器在配置上只是暂时缓存 mail ，当权重 10 的服务器能连通权重为 5 的服务器时，仍会将邮件发送的权重为 5 的 Mail 服务器上。当然，这个机制需要在 Mail 服务器上配置。

在命令行下可以通过 `nslookup -q=mx ` 来查看MX记录。

  $ nslookup -q=mx 58.com
    Non-authoritative answer:
    58.com	mail exchanger = 10 mxbiz2.qq.com.
    58.com	mail exchanger = 5 mxbiz1.qq.com.

## PTR
PTR：逆向查询记录（Pointer Record），只用于从IP地址查询域名

  dig -x 192.30.252.153
  153.252.30.192.in-addr.arpa. 3600 IN    PTR pages.github.com.

## CNAME
在命令行下可以使用`nslookup -q=cname ahuigo.github.io`来查看CNAME记录。

  $ nslookup  -q=cname ahuigo.github.io
  Non-authoritative answer:
  ahuigo.github.io	canonical name = hilojack.github.io.
  $ dig CNAME ahuigo.github.io

## TXT记录
两个作用:

1. TXT记录一般是为某条记录设置说明
2. TXT还可以用来验证域名的所有，比如你的域名使用了Google的某项服务，Google会要求你建一个TXT记录，然后Google验证你对此域名是否具备管理权限。

可以使用`nslookup -q=txt`来查看TXT记录。

    $ nslookup -q=TXT _spf.google.com 8.8.8.8
    Non-authoritative answer:
    _spf.google.com	text = "v=spf1 include:_netblocks.google.com include:_netblocks2.google.com include:_netblocks3.google.com ~all"

google ip range:

    $ nslookup -q=TXT _netblocks.google.com 8.8.4.4 | grep -Po '\d+\.\d+\.\d+.\d+\/\d+
    $ dig TXT +short @8.8.8.8 _netblocks.google.com
    dig TXT +short _netblocks{,2,3}.google.com

how many ip google has?

    total=0
    for slash in $(dig TXT +short _netblocks{,2,3}.google.com | tr ' ' '\n' | grep '^ip4:' | cut -d '/' -f 2); do
        total=$((total+$(echo "2^(32-$slash)" | bc -l)))
    done
    echo $total

## NS记录
NS记录是域名服务器记录，用来指定域名由哪台服务器来进行解析。

  $ nslookup -q=ns ahuigo.github.io
  Non-authoritative answer:
  ahuigo.github.io	nameserver = f1g1ns1.dnspod.net.
  ahuigo.github.io	nameserver = f1g1ns2.dnspod.net.

  $ dig ns stackexchange.com

## tcp

    dig +tcp baidu.com @208.67.220.220 

## 层级

  主机名.次级域名.顶级域名.根域名
  host.sld.tld.root

五、根域名服务器

  DNS服务器根据域名的层级，进行分级查询。
  需要明确的是，每一级域名都有自己的NS记录，NS记录指向该级域名的域名服务器。这些服务器知道下一级域名的各种记录。
  所谓"分级查询"，就是从根域名开始，依次查询每一级域名的NS记录，直到查到最终的IP地址，过程大致如下。
  从"根域名服务器"查到"顶级域名服务器"的NS记录和A记录（IP地址）
  从"顶级域名服务器"查到"次级域名服务器"的NS记录和A记录（IP地址）
  从"次级域名服务器"查出"主机名"的IP地址

六、分级查询的实例
  dig命令的+trace参数可以显示DNS的整个分级查询过程。

  $ dig +trace math.stackexchange.com
  上面命令的第一段列出根域名.的所有NS记录，即所有根域名服务器。


# resolve.conf
cat /etc/resolv.conf

    nameserver 10.233.0.3
    search default.svc.cluster.local svc.cluster.local cluster.local

Kubernetes 中，域名的全称，必须是 service-name.namespace.svc.cluster.local 这种模式
`curl b` 会查找：b.default.svc.cluster.local -> b.svc.cluster.local -> b.cluster.local ，直到找到为止

    // curl b，可以一次性找到（b +default.svc.cluster.local）
    b.default.svc.cluster.local

    // curl b.default，第一次找不到（ b.default + default.svc.cluster.local）
    b.default.default.svc.cluster.local
    // 第二次查找（ b.default + svc.cluster.local），可以找到
    b.default.svc.cluster.local

# DNS Utility:
1. `host <domain>` - DNS lookup Utility
1. `dig [@dns_server] <domain>` - DNS lookup Utility
1. `nslookup ahuigo.github.io [8.8.8.8]`

e.g.

	host baidu.com [dns_server]
	dig baidu.com
	dig @223.5.5.5 baidu.com

debug:

    nslookup -query=AAAA api.mch.weixin.qq.com -debug
    dig  api.mch.weixin.qq.com AAAA -debug

## list current dns
On Mac OSX:

	networksetup -getdnsservers Wi-Fi
	networksetup -getsearchdomains Wi-Fi

## set dns server
On Mac OSX

	networksetup -listallnetworkservices
	sudo networksetup -setdnsservers Wi-Fi 223.5.5.5 223.6.6.6

On Linux

	vi /etc/resolv.conf
	nameserver 8.8.8.8

## get ip
DNS查询，寻找域名domain对应的IP:

	$ host domain

## get own ip
find ip

	ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)