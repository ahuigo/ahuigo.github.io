# Preface
Mac使用pf命令可代替iptables, 而icefloor这个图形化的Mac防火墙，它是pf的GUI前端

    sudo pfctl -s rules
        Will show what rules are in place and a
    sudo pfctl -e
        will enable the rules.

## Throttling
可以通过pf/iptables 模拟弱网络(comcast 工具就是基于这个)

    $ comcast --device=eth0 --latency=250 --target-bw=1000 --default-bw=1000000 --packet-loss=10% --target-addr=8.8.8.8,10.0.0.0/24 --target-proto=tcp,udp,icmp --target-port=80,22,1000:2000 -dry-run

以下是模拟连接失败

    (sudo pfctl -sr 2>/dev/null; echo "block drop quick on en0 proto tcp from any to ahuigo.github.io port = 3306" ) | sudo pfctl -f - 2>/dev/null
    sudo pfctl -e
    sudo pfctl -d; # disable

## http-forwarding
如果想在mac 上做端口映射(`localhost:80 -> localhost:8080`), 可以用pfctl

    man pfctl
    man pf.conf

首先在 /etc/pf.anchors/ 新建一个 http 文件内容如下: 段落末尾一定要加上换行, 否则会报错(不知道pf 用的什么黑写法)

    rdr pass on lo0 inet proto tcp from any to any port 80 -> 127.0.0.1 port 8080
    rdr pass on lo0 inet proto tcp from any to any port 443 -> 127.0.0.1 port 4443
    rdr pass on en0 inet proto tcp from any to any port 80 -> 127.0.0.1 port 8080
    rdr pass on en0 inet proto tcp from any to any port 443 -> 127.0.0.1 port 4443

然后使用 pfctl 命令检测配置文件

    sudo pfctl -vnf /etc/pf.anchors/http

如果没有报错(正确的打印了配置信息, 没有明显的出错信息), 即修改pf的主配置文件/etc/pf.conf, 来引入这个转发规则:

    rdr-anchor "com.apple/*"
    # 添加如下 anchor 声明:
    rdr-anchor "http-forwarding"

pf.conf对指令的顺序有严格要求, 否则会报出 *Rules must be in order: options, normalization, queueing, translation, filtering* 的错误, 所以相同的指令需要放在一起.

    load anchor "com.apple" from "/etc/pf.anchors/com.apple"
    # 在com.apple 下, 添加 anchor 引入:
    load anchor "http-forwarding" from "/etc/pf.anchors/http"

最后, 导入并允许运行 pf

    sudo pfctl -ef /etc/pf.conf
        -e enable packet filter
        -d disable packet filter
        -f pf.conf

如果需要开机启动, 则需要为

    /System/Library/LaunchDaemons/com.apple.pfctl.plist

或者命令行:

    # 启动
    sudo pfctl -e
    # 关闭
    sudo pfctl -d
