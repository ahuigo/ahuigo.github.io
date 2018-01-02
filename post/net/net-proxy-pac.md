# pac(Proxy Auto Config)
iOS实际上支持socks代理的，但在 iPhone和iPad设备的`Setting -> WLAN` 下只能看到HTTP Proxy

用自动配置文件，就可以支持socks代理

    function FindProxyForURL(url, host)
    {
         return "SOCKS proxy_host:proxy_port";
    }

Safari (OSX, iOS)只认识SOCKS,虽然它默认也是使用SOCKS5协议

    SOCKS5 127.0.0.1:1080; SOCKS 127.0.0.1:1080; DIRECT

保存到 http://xxx.com/proxy.pac, 在 iPhone设备中，添加自动配置 URL 为上面的地址，就可以使用socks代理了

> PAC是一个javascript脚本，浏览器在每次请求一个URL之前，都会运行它． 用　file:///var/run/x.pac 这样的路径

# 规则

## Headers
为了完整性和最佳的兼容性，我们应该设置网页服务器(apache或者nginx,lighttpd等等)将这个pac文件的MIME类型声明为

    前者: 被更多的客户端所支持
    application/x-ns-proxy-autoconfig
    或者
    application/x-javascript-config

## 返回
FindProxyForURL的返回值，可以是以下３种之一，或者是它们的组合

    DIRECT
       直接连接，不使用代理

    PROXY host:port;host2:port
    　　　使用指定的http代理

    SOCKS host:port;host2:port
    　　　使用指定的SOCKS代理

## Function
http://findproxyforurl.com/pac-functions/

### isInNet(host_or_ip, pattern, mask)
isInNet 判断host 是否在一个网段
dnsResolve(host) 将host解析为ip地址

    if (isInNet(host, "192.168.1.0", "255.255.255.0"))
        return "DIRECT";
    if (isInNet(dnsResolve(host), "172.16.0.0", "255.240.0.0"))
        return "DIRECT";

    if (isInNet(myIpAddress(), "10.10.1.0", "255.255.255.0"))
        return "PROXY 10.10.5.1:8080";


    var resolved_ip = dnsResolve(host);
    if (isInNet(dnsResolve(host), "10.0.0.0", "255.0.0.0") ||
        isInNet(dnsResolve(host), "172.16.0.0",  "255.240.0.0") ||
        isInNet(dnsResolve(host), "192.168.0.0", "255.255.0.0") ||
        isInNet(dnsResolve(host), "127.0.0.0", "255.255.255.0"))
        return "DIRECT";

判断host的一级域名

    if (dnsDomainIs(host, ".google.com"))
        return "DIRECT";
