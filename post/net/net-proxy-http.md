---
title: http 代理实现
date: 2019-02-21
private:
---
# http 代理实现种类
分为两种：
1. 普通http proxy: 中间人，需要解析包
1. 普通http tunnel: 不解析包，直接透传

# http proxy
[示例](/demo/py-demo/socket/proxy-http.py)为get 请求的转发，单线程处理

    import socket
    from urllib.parse import urlparse
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class ProxyHandler(BaseHTTPRequestHandler):

        def _recv_data_from_remote(self, sock):
            data = b''
            while True:
                recv_data = sock.recv(4096)
                if not recv_data:
                    break
                data += recv_data
            sock.close()
            return data

        def do_GET(self):
            # 解析 GET 请求信息
            uri = urlparse(self.path)
            scheme, host, path = uri.scheme, uri.hostname, uri.path
            host_ip = socket.gethostbyname(host)
            port = 443 if scheme == "https" else 80

            # 为了简单起见，Connection 都为 close, 也就不需要 Proxy-Connection 判断了
            del self.headers['Proxy-Connection']
            self.headers['Connection'] = 'close'

            # 构造新的 http 请求
            send_data = "GET {path} {protocol_version}\r\n".format(path=path, protocol_version=self.protocol_version)
            headers = ''
            for key, value in self.headers.items():
                headers += "{key}: {value}\r\n".format(key=key, value=value)
            headers += '\r\n'
            send_data += headers

            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((host_ip, port))
            # 发送请求到目标地址
            sock.sendall(send_data.encode())
            data = self._recv_data_from_remote(sock)
            self.wfile.write(data)

    def main():
        try:
            server = HTTPServer(('', 8888), ProxyHandler)
            server.serve_forever()
        except KeyboardInterrupt:
            server.socket.close()


    if __name__ == '__main__':
        main()

一般只适用http 转发，https 转发需要证书(否则error 501)

    curl -x localhost:8888 'http://baidu.com'

# http tunnel
隧道代理的步骤如下
1.客户端发送一个 http CONNECT 请求

    CONNECT baidu.com:443 HTTP/1.1

2.代理收到这样的请求后，拿到目标服务器域名及端口，与目标服务端建立 TCP 连接，并响应给浏览器这样一个 HTTP 报文：

    HTTP/1.1 200 Connection Established

3.建立完隧道以后，客户端与目标服务器照之前的方式发送请求，代理节点只是做转发功能

[示例](/demo/py-demo/socket/proxy-http-tunnel.py):

    import socket
    import select
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class ProxyHandler(BaseHTTPRequestHandler):

        def send_data(self, sock, data):
            print(data)
            bytes_sent = 0
            while True:
                r = sock.send(data[bytes_sent:])
                if r < 0:
                    return r
                bytes_sent += r
                if bytes_sent == len(data):
                    return bytes_sent

        def handle_tcp(self, sock, remote):
            # 处理 client socket 和 remote socket 的数据流
            try:
                fdset = [sock, remote]
                while True:
                    # 用 IO 多路复用 select 监听套接字是否有数据流
                    r, w, e = select.select(fdset, [], [])
                    if sock in r:
                        data = sock.recv(4096)
                        if len(data) <= 0:
                            break
                        result = self.send_data(remote, data)
                        if result < len(data):
                            raise Exception('failed to send all data')

                    if remote in r:
                        data = remote.recv(4096)
                        if len(data) <= 0:
                            break
                        result = self.send_data(sock, data)
                        if result < len(data):
                            raise Exception('failed to send all data')
            except Exception as e:
                raise(e)
            finally:
                sock.close()
                remote.close()

        def do_CONNECT(self):

            # 解析出 host 和 port
            uri = self.path.split(":")
            host, port = uri[0], int(uri[1])
            host_ip = socket.gethostbyname(host)

            remote_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            remote_sock.connect((host_ip, port))
            # 告诉客户端 CONNECT 成功
            self.wfile.write("{protocol_version} 200 Connection Established\r\n\r\n".format(protocol_version=self.protocol_version).encode())

            # 转发请求
            self.handle_tcp(self.connection, remote_sock)

    def main():
        try:
            server = HTTPServer(('', 8888), ProxyHandler)
            server.serve_forever()
        except KeyboardInterrupt:
            server.socket.close()

    if __name__ == '__main__':
        main()

有一个 do_CONNECT 函数的处理，实现之前隧道的建立，然后 handle_tcp，代码和之前 socks5 代理是一样的

# Rerference
- 由浅入深写代理(6)-http-代理 https://zhuanlan.zhihu.com/p/28737960