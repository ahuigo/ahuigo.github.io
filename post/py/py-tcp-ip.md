---
title: python tcp ip
date: 2020-05-21
private: true
---
# python tcp ip
## ip
### get dns

    try:
        ips = socket.gethostbyname_ex(host) #('bing.com', [], ['13.107.21.200', '204.79.197.200'])
        ip = socket.gethostbyname(host)     # '13.107.21.200'
    except socket.gaierror:
        ips=[]

### ipinfo
    >>> socket.getaddrinfo('bing.com',80)
    [(<AddressFamily.AF_INET: 2>, <SocketKind.SOCK_DGRAM: 2>, 17, '', ('13.107.21.200', 80)), (<AddressFamily.AF_INET: 2>, <SocketKind.SOCK_STREAM: 1>, 6, '', ('13.107.21.200', 80)), (<AddressFamily.AF_INET: 2>, <SocketKind.SOCK_DGRAM: 2>, 17, '', ('204.79.197.200', 80)), (<AddressFamily.AF_INET: 2>, <SocketKind.SOCK_STREAM: 1>, 6, '', ('204.79.197.200', 80))]
