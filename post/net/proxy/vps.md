---
title: VPS 主机 5强
date: 2018-09-28
---
# VPS 主机 5强
https://zhuanlan.zhihu.com/p/31856700?group_id=922875663238262784

# 常用虚拟化技术
OpenVZ(容器)、XEN、KVM, Hyper-V(完全虚拟化,windows)
http://www.tennfy.com/3380.html

## openVZ
2、部分服务商不开启tun/ppp，导致不能用部分VPN协议。(OpenVZ的新技术支持)
3、如果“邻居”不安分守己，乱用CPU或者网络，比起虚拟化技术，容器受到的影响更大。虚拟化技术中主要是IO性能受到影响，其他的都能很好的隔离。
4、不能用lxc，docker，openvz等容器（不能在容器里创建容器）

## KVM
bwg 的 openVz 不值得买，建议买bwg 的kvm


# 入门级vps
大多数该价位的VPS都是OpenVZ虚拟化的，这种虚拟化由于不能安装锐速，速度不会很快，但就是便宜啊

http://www.laozuo.org/myvps
https://www.vpser.net/usa-vps
https://blog.deartanker.com/vps
vps recommand
https://www.v2ex.com/t/290552?p=1

2. alpharacks $8.00/year(128M/10G) https://www.alpharacks.com/myrack/cart.php?a=confproduct&i=0 
部分可以用
https://www.alpharacks.com/holiday
3. HostUS 和 XVMlab 的，感觉没有瓦工网络最好了
XVMlab: 比搬瓦工便宜
bandwagon 19.99$/year(256M/10G)
Linode:$10/月+日本+非常推荐
Vultr:$5/月+日本+云vps 稳定
Hostus:25刀/年+香港+速度快
DigitalOcean:5刀/月+云vps+稳定
Ramnode:15刀/年+稳定+低价精品(128M/12G) 
Oneasiahost:4刀/月+新加坡+相对便宜

## vpn 支持
ramnode/bandwagon 家的OpenVZ 支持vpn

## tcp 加速
上Youtube只能看720p甚至480p的视频，

可以用Finalspeed和锐速(锐速不支持Openvz！)这两种TCP加速工具，锐速是要钱的，Finalspeed免费，但是Finalspeed是需要客户端支持的，而且客户端需要Java支持，这就断绝了路由上挂载的可能。

### 锐速
https://github.com/91yun/serverspeeder

## ss合租与测试
https://www.ss100.pw/