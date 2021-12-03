---
title: custom tcpip packet
date: 2021-11-27
private: true
---
# custom tcpip packet

## golang version
    conn, err := net.ListenIP("ip4:tcp", netaddr)
    if err != nil {
        log.Fatalf("ListenIP: %s\n", err)
    }

# Rerference
- https://inc0x0.com/tcp-ip-packets-introduction/tcp-ip-packets-3-manually-create-and-send-raw-tcp-ip-packets/