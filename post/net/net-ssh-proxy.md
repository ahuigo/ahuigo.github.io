---
title: ssh proxy
date: 2018-09-28
private:
---
# ssh proxy

    man ssh
    -f Rquests ssh to go to background just before command execution.

## tcp port forwarding

### socks proxy forward
> socks4 不支持 udp 应用, 现在大家都用 socks5 了
建立一个 socks5, port:1080

	ssh -D 0:1080 hilo@remote-ip
	ssh -D 1080 hilo@remote-ip
	export http_proxy=socks5://127.0.0.1:1080 https_proxy=socks5://127.0.0.1:1080
	youtube-dl youtube.com/watch?V=3XjwiV-6_CA

    ssh -N -C -D1080 user@hostB &
    -N   Do not execute a remote command
    -T   Disable pseudo-terminal allocation.
    -C  Requests compression of all data(gzip)


### 本地端口转发
#### ssh over ssh
Tunnelling an ssh connection through an ssh connection:

    -L [bind_address:]port:host:hostport

    # if 100.100.100.100 跳板机，2201 端口转发到 192.168.25.100:22
    me% ssh user@100.100.100.100 -L 2201:192.168.25.100:22

then(本机的密码):

    me% ssh user2@localhost -p 2201
    实际访问% ssh user2@192.168.25.100 -p 22

#### http over ssh

    me% ssh user@100.100.100.100 -L 2201:baidu.com:80
    # curl localhost:2201

### 远端端口转发：reverse port forward

    # office to vps
    ssh -R <local port>:<remote host>:<remote port> <SSH vps-host>

    # vps
    ssh -p local-port user@localhost
    curl localhost:local-port

> http://superuser.com/questions/588591/how-to-make-ssh-tunnel-open-to-public

For instance, I use this sometimes so that I can create a reverse port 22 (SSH) tunnel so that I can reconnect through SSH to a machine that is behind *a firewall* once I have gone away from that network.

	-R [bind_address:]port:host:hostport
    ssh -R 8022:localhost:22 username@my.home.ip.address
    ssh -gfNTR 8022:localhost:22 username@my.home.ip.address
        bind_address: default loopback
            ssh -R '\*:8080:localhost:80' # all interfaces
            ssh -R 0.0.0.0:8080:localhost:80 # all Ipv4
            ssh -R "[::]:8080:localhost:80"
        hostport: 当前机器sshd的端口, 不是vps 的端口
        
        -g      Allows remote hosts to connect to local forwarded ports.
        -f Requests ssh to go to background just before command execution.
        -N   Do not execute a remote command
        -T      Disable pseudo-terminal allocation.

This will connect to my home machine and start listening on port 8022 there. Once I get home, I can then connect back to the machine I created the connection from using the following command:

    ssh -p 8022 username_company@localhost

Remember to use the right username for the machine that you started the tunnel from. It can get confusing. You also have to keep in mind that since you are connecting to the host called localhost, but its really a port going to a different SSH server, you may wind up with a different host key for localhost the next time you connect to localhost. In that case you would need to edit your .ssh/known_hosts file to remove the localhost line. You really should know more about SSH before doing this blindly.

As a final exercise, you can keep your reverse port forward open all the time by starting the connection with this loop:

    # > http://arondight.me/2016/02/17/%E4%BD%BF%E7%94%A8SSH%E5%8F%8D%E5%90%91%E9%9A%A7%E9%81%93%E8%BF%9B%E8%A1%8C%E5%86%85%E7%BD%91%E7%A9%BF%E9%80%8F/
    while true ; do ssh -R 8022:localhost:22 suso@my.home.ip.address ; sleep 60 ; done

When bind_address is omitted (as in your example), the port is bound on the loopback interface only. In order to make it bind to all interfaces, use

	-N Do not execute a remote command.
	#  binds to all interfaces individually
	ssh -R '\*:8080:localhost:80' -N root@example.com

	# a general IPv4-only bind
	ssh -R 0.0.0.0:8080:localhost:80 -N root@example.com

	# the port is accessible via IPv6 natively
	# and via IPv4 through IPv4-mapped IPv6 addresses (doesn't work on Windows, OpenBSD).
	ssh -R "[::]:8080:localhost:80" -N root@example.com
    
#### other

    -w local_tun[:remote_tun]
    -C 压缩数据传输
    -f 将 ssh 转到后台运行，即认证之后，ssh 自动以后台运行。不在输出信息
    -n 将 stdio 重定向到 /dev/null，与 -f 配合使用
    -N 不执行脚本或命令，即通知 sshd 不运行设定的 shell 通常与 -f 连用
    -T 不分配 TTY 只做代理用
    -q 安静模式，不输出 错误/警告 信息
    
Note:    

1. 不能使用 VPS (sshd server) 已占用的 22 端口，否则：Warning: remote port forwarding failed for listen port 22
2. 默认只能通过VPS 本地loopback访问tunnel, 否则你需要开通GatewayPorts

#### bind_address
By default, the listening socket on the server will be bound to the loopback interface only.  This may be overridden by specifying a bind_address.  An empty bind_address, or the address ‘*’, indicates that the remote socket should listen on all interfaces.  Specifying a remote bind_address will only succeed if the server's GatewayPorts option is enabled (see sshd_config(5)).

#### GatewayPorts
1. GatewayPorts `-R [bind_address:]port:host:hostport`
bind_address 参数默认值为空，等价于*:port:host:hostport 并不意味着任何机器，都可以通过 VPS 来访问 内网 机器。
建立连接后，只能在 VPS ( sshd server ) 本地 访问 「内网」 机器。
3. 要在办公网的笔记本上通过 VPS 映射的端口来访问 内网 机器，需要启用 VPS sshd 的 GatewayPorts 参数，允许任意请求地址，通过转发的端口访问内网机器。首先在中转机上(eg.aliyun)编辑sshd 的配置文件`/etc/ssh/sshd_config`，将*GatewayPorts* 开关打开：

    GatewayPorts yes
    
然后重启sshd：

    $ sudo systemctl restart sshd

下面是 man sshd_config 手册对 GatewayPorts 的解释：

    GatewayPorts
        Specifies whether remote hosts are allowed to connect to ports forwarded for the client.  By default, sshd(8) binds remote port forwardings to the loopback address.  This prevents other remote hosts from connecting to forwarded ports.  GatewayPorts can be used to specify that sshd should allow remote port forwardings to bind to non-loopback addresses, thus allowing other hosts to connect.  The argument may be “no” to force remote port forwardings to be available to the local host only, “yes” to force remote port forwardings to bind to the wildcard address, or “clientspecified” to allow the client to select the address to which the forwarding is bound.  The default is “no”.
        
启用 GatewayPorts 之后，才可以从办公室的笔记本访问 VPS 2222 端口，连接 内网 的机器：

    (APP) $ ssh -p 2222 ink@mantou.me    

### autossh
添加的一个-M 5678参数，负责通过5678端口监视连接状态，连接有问题时就会自动重连，去掉了一个-f参数，因为autossh本身就会在background运行。

    /bin/su -c '/usr/bin/autossh -M 5678 -NR 1234:localhost:2223 user1@123.123.123.123 -p2221' - user1

## ssh over socks
~/.ssh/config

	ProxyCommand /usr/bin/nc -X 5 -x 127.0.0.1:7777 %h %p
	ProxyCommand /usr/bin/nc -x 127.0.0.1:7777 %h %p

You are using 'connect' for HTTPS as your proxy version, this is from man nc:

	-X proxy_version Requests that nc should use the specified protocol when talking to the proxy server. Supported protocols are ''4'' (SOCKS v.4), ''5'' (SOCKS v.5) and 'connect' (HTTPS proxy). If the protocol is not specified, SOCKS version 5 is used.

Manual:

	ssh -o ProxyCommand='nc -X 5 -x 127.0.0.1:1080 %h %p' user@host 'curl http://1212.ip138.com/ic.asp'

# SSH through HTTP proxy
> http://www.zeitoun.net/articles/ssh-through-http-proxy/start

This article explains how to connect to a ssh server located on the internet from a local network protected by a firewall through a HTTPS proxy.

Requirement are :

1. Your firewall has to allow HTTPS connections through a proxy
2. You need to have root access to the server where ssh is listening

## Configure the ssh server
The ssh daemon need to listen on 443 port. To accomplish this, just edit this file (on debian system) `/etc/ssh/sshd_config` and add this line :

  Port 443

Then restart the daemon :

  sudo /etc/init.d/ssh restart

## Configure the client
I suppose you are on a Linux system (debian for example). First you have to compile the connect binary which will help your ssh client to use proxies (HTTPS in our case). Then you have to configure your ssh client to tell him to use HTTPS proxy when he tries to connect to your ssh server.

### Install the connect software :
On debian system, just install the connect-proxy package :

  sudo apt-get install connect-proxy

On other Linux systems, you have to compile it :

  cd /tmp/
  wget http://www.meadowy.org/~gotoh/ssh/connect.c
  gcc connect.c -o connect
  sudo cp connect /usr/local/bin/ ; chmod +x /usr/local/bin/connect

Configure your ssh client. Open or create your ~/.ssh/config file and add these lines :

Outside of the firewall, with HTTPS proxy

  Host my-ssh-server-host.net
    ProxyCommand connect -H proxy.free.fr:3128 %h 443

Inside the firewall (do not use proxy)

  Host *
     ProxyCommand connect %h %p

Then pray and test the connection :

  ssh my-ssh-server-host.net

SSH to another server through the tunnel
For example to connect to in ssh github.com :

  Host github.com
    ProxyCommand=ssh my-ssh-server-host.net "/bin/nc -w1 %h %p"