---
title: chrome devtool network
date: 2024-03-11
private: true
---
# chrome devtool network
chrome 的time explanation

    Queued at 4.8min, Started at 4.8min 排队。浏览器在连接开始之前和以下时间对请求进行排队：
    1. Resource Scheduling/Queueing:
        1. There are higher priority requests.
        2. Max 6 TCP connections open for this origin. Applies to HTTP/1.0 and HTTP/1.1 only.
        2. The browser is briefly allocating space in the disk cache.  浏览器正在短暂分配磁盘缓存中的空间。
    2. Connection start:
        1. Stalled. The request could be stalled after connection start for any of the reasons described in Queueing.
            停滞。由于排队中所述的任何原因，请求可能会在连接启动后停止。
        2. DNS Lookup. The browser is resolving the request's IP address.
        3. Initial connection. The browser is establishing a connection, including TCP handshakes or retries and negotiating an SSL.
            浏览器正在建立连接，包括 TCP 握手或重试以及协商 SSL。
        4. Proxy negotiation. The browser is negotiating the request with a proxy server.
            代理协商。浏览器正在与代理服务器协商请求。
    3. resource/response:
        1. Request sent. The request is being sent.
        2. Waiting For server response (TTFB). The browser is waiting for the first byte of a response. 
            此计时包括 1 次往返延迟和服务器准备响应所花费的时间
        3. Content Download(Response body). 
            此值是读取响应正文所花费的总时间。大于预期的值可能表示网络速度较慢，或者浏览器正忙于执行其他工作，从而延迟读取响应。