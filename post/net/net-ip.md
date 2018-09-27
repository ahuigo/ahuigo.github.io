---
title: get public ip
date: 2018-09-28
---
# get public ip
http://whatismyip.akamai.com/

#  renew ip

    # release
    sudo dhclient -r
    # renew
    sudo dhclient -r

To renew or release an IP address for the eth0 interface, enter:

    $ sudo dhclient -r eth0
    $ sudo dhclient eth0
    $ sudo dhclient -v eth0

other

    # ifdown eth0
    # ifup eth0
    ### RHEL/CentOS/Fedora specific command ###
    # /etc/init.d/network restart

# static ip
```s
    # Configure eth0
    # vi /etc/sysconfig/network-scripts/ifcfg-eth0
    DEVICE="eth0"
    NM_CONTROLLED="yes"
    ONBOOT=yes
    HWADDR=A4:BA:DB:37:F1:04
    TYPE=Ethernet
    UUID=5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03
    NAME="System eth0"
    BOOTPROTO=static
    IPADDR=192.168.1.44
    NETMASK=255.255.255.0


    ## Configure Default Gateway
    #
    # vi /etc/sysconfig/network
    NETWORKING=yes
    HOSTNAME=centos6
    GATEWAY=192.168.1.1


    ## service network restart
    /etc/init.d/network restart

    ## Configure DNS Server
    # vi /etc/resolv.conf
    nameserver 8.8.8.8      # Replace with your nameserver ip
    nameserver 192.168.1.1  # Replace with your nameserver ip
```

# disable ipv6
Append below lines in /etc/sysctl.conf:
```s
    # net.ipv6.conf.[interface].disable_ipv6 = 1
    net.ipv6.conf.all.disable_ipv6 = 1
    net.ipv6.conf.default.disable_ipv6 = 1
```
then:

    sudo sysctl -p