---
title: custom tcpip packet
date: 2021-11-27
private: true
---
# custom tcpip packet

## get send/recv packet buffer

    # ss -ntmp
    State      Recv-Q Send-Q Local Address:Port  Peer Address:Port
    ESTAB      0      0      10.xx.xx.xxx:22     10.yy.yy.yyy:12345  users:(("sshd",pid=1442,fd=3))
            skmem:(r0,rb369280,t0,tb87040,f4096,w0,o0,bl0,d92)

ss -m is given in the source:

        printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
               skmeminfo[SK_MEMINFO_RMEM_ALLOC],
               skmeminfo[SK_MEMINFO_RCVBUF],
               skmeminfo[SK_MEMINFO_WMEM_ALLOC],
               skmeminfo[SK_MEMINFO_SNDBUF],
               skmeminfo[SK_MEMINFO_FWD_ALLOC],
               skmeminfo[SK_MEMINFO_WMEM_QUEUED],
               skmeminfo[SK_MEMINFO_OPTMEM]);

        if (RTA_PAYLOAD(tb[attrtype]) >=
                (SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
                printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);

        if (RTA_PAYLOAD(tb[attrtype]) >=
                (SK_MEMINFO_DROPS + 1) * sizeof(__u32))
                printf(",d%u", skmeminfo[SK_MEMINFO_DROPS]);

        printf(")");

## golang version
    conn, err := net.ListenIP("ip4:tcp", netaddr)
    if err != nil {
        log.Fatalf("ListenIP: %s\n", err)
    }

# Rerference
- https://inc0x0.com/tcp-ip-packets-introduction/tcp-ip-packets-3-manually-create-and-send-raw-tcp-ip-packets/