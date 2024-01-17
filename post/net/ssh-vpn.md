---
layout: page
title:	vpn tool
category: blog
private: true
---
# vpn 
## openconnect
cisco anyconnect 相同

    sudo openconnect vpn.xxx.com:8443

有时连接不上，注意重置dns

    sudo networksetup -setdnsservers Wi-Fi 223.5.5.5 8.8.8.8
    sudo networksetup -setdnsservers Wi-Fi Empty
    sudo networksetup -getdnsservers Wi-Fi