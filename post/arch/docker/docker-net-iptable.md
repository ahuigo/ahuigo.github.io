---
title: container iptable
date: 2022-04-09
private: true
---
# container use iptables
## config
需要开启网络管理权限, 参考docker-privilege 以及 https://stackoverflow.com/questions/41706983

    docker run --cap-add=NET_ADMIN --cap-add=NET_RAW 

    --cap-add=NET_ADMIN 
        which will allow net admin
    --cap-add=NET_RAW 
        which will allow internal iptables.
