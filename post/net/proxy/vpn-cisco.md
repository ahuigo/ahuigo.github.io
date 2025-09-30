---
title: cisco secure client
date: 2025-09-30
private: true
---
# cisco secure client(原anyconnect)
如果只是想使用cisco secure client连接vpn，可以参考以下步骤：
1. 下载并安装cisco secure client, 只选vpn

如果选择错了，就要重新安装：https://www.cnblogs.com/jinzhenzong/p/12246608.html
```
find  /opt/cisco/secureclient/ -name '*.sh'
sudo bash /opt/cisco/secureclient/bin/cisco_secure_client_uninstall.sh
pkgutil --pkgs|grep com.cisco
sudo bash /opt/cisco/secureclient/bin/dart_uninstall.sh
sudo pkgutil --forget com.cisco.pkg.anyconnect.dart
sudo pkgutil --forget com.cisco.pkg.anyconnect.vpn
sudo pkgutil --forget com.cisco.pkg.anyconnect.websecurity
sudo pkgutil --forget com.cisco.pkg.anyconnect.nvm
sudo pkgutil --forget com.cisco.pkg.anyconnect.fireamp
sudo pkgutil --forget com.cisco.pkg.anyconnect.dart
sudo pkgutil --forget com.cisco.pkg.anyconnect.iseposture
sudo pkgutil --forget com.cisco.pkg.anyconnect.posture
sudo pkgutil --unlink com.cisco.pkg.anyconnect.dart

pkgutil --pkgs 显示已经安装在系统上的软件包
pkgutil --files PKGID 显示某个软件包安装的文件列表
pkgutil --unlink PKGID 删除该软件包创建的文件（但不会从包管理数据库中移除软件包信息）
pkgutil --forget PKGID 从包管理数据库中移除软件包信息（但不会删除该软件包创建的文件）
```
# 连接vpn时
如果出现是否允许过滤网络，可选择不允许(Not Allow)
> “Cisco Secure Client - Socket Filter” Would Like to Filter Network Content