---
title: golang http close
date: 2020-05-21
private: true
---
# golang http close
> Refer: https://studygolang.com/articles/3138
这个服务中，我们会定期向一个HTTP服务器发起POST请求，因为请求非常不频繁，所以想采用短连接的方式去做。请求代码大概长这样：

    func dialTimeout(network, addr string) (net.Conn, error) {
        return net.DialTimeout(network, addr, time.Second*POST_REMOTE_TIMEOUT)
    }

    func DoRequest(URL string) xx, error {
       transport := http.Transport{
                Dial: dialTimeout,
        }

        client := http.Client{
                Transport: &transport,
        }

        content := "body"
        postStr, err := json.Marshal(content)
        if err != nil {
                return nil, err
        }

        resp, err := client.Post(URL, "application/json", bytes.NewBuffer(postStr))
        if err != nil {
                return nil, err
        }

        defer resp.Body.Close()
        body, err := ioutil.ReadAll(resp.Body)
        if err != nil {
                return nil, err
        }

        // receive body, handle it
    }

运行这段代码一段时间后会发现:
1. 该进程下面有一堆ESTABLISHED状态的连接（用lsof -p pid查看某进程下的所有fd），因为每次DoRequest函数被调用后，都会新建一个TCP连接，如果对端不先关闭该连接（对端发FIN包）的话，
2. 我们这边即便是调用了resp.Body.Close()函数仍然不会改变这些处于ESTABLISHED状态的连接。为什么会这样呢？只有去源代码一探究竟了。

Golang的net包中client.go, transport.go, response.go和request.go这几个文件中实现了HTTP Client。当应用层调用client.Do()函数后，
1. transport层会首先找与该请求相关的已经缓存的连接（这个缓存是一个map，map的key是请求方法、请求地址和proxy地址，value是一个叫persistConn的连接描述结构），
2. 如果已经有可以复用的旧连接，就会在这个旧连接上发送和接受该HTTP请求，否则会新建一个TCP连接，然后在这个连接上读写数据。

当client接受到整个响应后，
1. 如果没有调用response.Body.Close()函数: 就会`重新建立TCP连接，重新分配persistConn结构, 且不被释放`
    1. 对端关闭了连接（对端的HTTP服务器向我发送了FIN），这个请求相关的TCP连接的状态`一直处于 CLOSE_WAIT 状态`
    1. 对端不关闭连接，这个请求相关的TCP连接的状态`一直处于 ESTABLISHED 状态`
2. 调用了response.Body.Close(): 只保证了自己`主动FIN`, 不保证server`主动FIN`
   1. 如果对端的HTTP服务器没有关闭连接，那么这个连接会一直处于ESTABLISHED状态。
   2. 否则正常结束(read body后？)

如果不是全局`Client`, 建议加上`CLOSE`(并开启`DisableKeepAlives`, 自己主动FIN)+ `timeout`(防对方不发FIN)+  
在transport分配时将它的DisableKeepAlives参数置为true，像下面这样：

        // ...
        transport := http.Transport{
                Dial:              dialTimeout,
                DisableKeepAlives: true,
        }

        client := http.Client{
                Transport: &transport,
        }
        // ...

　　从transport.go:L908可以看到，当应用层调用resp.Body.Close()时，如果DisableKeepAlives被开启，那么transport自动关闭本端连接。而不将它加入到连接缓存中。
 
补充一下，在dialTimeout函数中disable tcp连接的keepalive选项是不可行的，它只是设置TCP连接的选项，不会影响到transport中对连接的控制。

    func dialTimeout(network, addr string) (net.Conn, error) {
        conn, err := net.DialTimeout(network, addr, time.Second*POST_REMOTE_TIMEOUT)
        if err != nil {
            return conn, err
        }

        tcp_conn := conn.(*net.TCPConn)                                                                                                  
        tcp_conn.SetKeepAlive(false)                                                                                                     

        return tcp_conn, err
    }

## 实验一下
todo: 
1. nginx 建立一个支持keepalive 的http listener
2. go run http
3. netstat | grep established | wc -l