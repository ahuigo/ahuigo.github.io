---
private: 
title: idea
date: 2018-09-27
---
# Preface
1. sideidea.com: http://sideidea.com/article/42
2. 失物招领: http://www.bjgaj.gov.cn/swzl/index.do
3. 付费问卷
3. 目标管理: 甘道图
1. 企业与知乎合作点评与反馈, 也就是企业Tag 接口
5. 群通知

# 语言：
deno 生态发展计划
    - Alephjs  css module
c sharp 生态计划 vs java/kotlin
golang

# 工具类
swagger in gonic:
    1. 通过comment 生成doc: gotestdoc 
    /* gotestdoc: md
        # title
        test case description
    */
ssl_ca_certificate_generator
    1. https://github.com/diafygi/acme-tiny
    2. local ca
readline-arg:
    via input,readline 重写argparse (python)
fsync: file transfer like rsync/netcat(nc)
    fsync -daemon -l 9999 -o dir [default output dir .]
    fsync -h 192.168.0.100:9999 
    1. client support both send+recv file
    2. check file via md5
    2. session verify via token 
tcpstat，tcpcapture: 
    go-lib/net/packet
    1. sniffer
    2. tcp packet report
    1. doc: net/tcp-sniffer.md
        1. https://inc0x0.com/tcp-ip-packets-introduction/tcp-ip-packets-3-manually-create-and-send-raw-tcp-ip-packets/
    2. https packet report
httpdump: like fiddler but without proxy
    1. httpdump -p port (dump body)
    2. httpdump -web
        1. alephjs web: 
            1. list all http req-response
            2. replay http
    3. http proxy support
    3. https proxy support
    3. support https/http2
        1. 写给工程师：关于证书（certificate）和公钥基础设施（PKI）的一切
        http://arthurchiao.art/blog/everything-about-pki-zh/
        1. certificate generate
        1. https packet parse
arun: 
    1. arun -p 4501 # a shell support command from vim/vscode/
    2. arun go run .
memstat/iotop:
    1. 参考 [PSS/USS 和 RSS 其实是一回事，吗？](https://changkun.de/blog/posts/pss-uss-rss/)
http request/response modifier like requestly
simple iptable:
    simple modify iptable
    route to http proxy: iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to 9090

# 全职
http://deepdevelop.com/
一早一晚: 自由工作社区
http://yizaoyiwan.com/discussions/460
medium.com
https://medium.com/%E5%86%99%E4%BD%9C%E4%B9%8B%E8%B7%AF/%E7%A8%8B%E5%BA%8F%E5%91%98%E5%A6%82%E4%BD%95%E5%9C%A8medium-com%E4%B8%8A%E9%80%9A%E8%BF%87%E5%86%99%E6%8A%80%E6%9C%AF%E5%8D%9A%E5%AE%A2%E8%B5%9A%E9%92%B1-6d47d82b03dd

## Remote Engineer
contact http://nvie.com/about/
https://stackoverflow.com/jobs/live-work-anywhere?utm_source=so-owned&utm_medium=email&utm_campaign=job-engage-work-live&utm_content=em-tips&utm_term=has-match-pref

## 投资
https://www.bmpi.dev/about/

# 反馈
类似于多说, 但是可以对未解决的进行排序
可以增加贴图

# 时间管理
做一个时间日志-优化级排序软件

1. 时间日志 - 每个小时都记, 看看看看时间花在什么地方了 -- 找出最浪费时间的事(时间瓶颈-性能瓶颈)
2. 任务优先级: 一定要先做最困难; 最重要的事
3. 不耻下问: 毫不犹豫寻求帮助
4. 一次完成: 不要给自己太多的时间, 给自己的时间越多, 浪费的时间越多
5. 继续前进: 完成了一件事, 无论好坏, 不要再想了
4. 坚决果断: 不要拖延, 不要放杂物
5. 不要想一口气做完所有的事情: 欲速则不达; 不要填满自己的日程: 也要花点时间锻炼; 忙碌与效率是成反比的(你没有时间反思: 变成了机器)
6. 养成惯性
7. 有效的时间: 二八定律 - 你的80%成就来自于20%的时间; 懂得放弃那些不重要的事!;
    一定要在学习最高效的时间学习; 运行最高效的时间运动; 吃完饭后困, 就做点家务
8. 集中精力: 排除杂乱的东西(房间-书桌); 远离互联网-qq-微博-手机
9. 不要同时处理多个任务: 专心做一件事; 遇到问题时就记下, 以后再查!! 不要绕不回来了
9. 空闲时间: 收藏的文章/冥想
9. 游戏-微博-电视: 节制!!!!!!

## 习惯
1. 只设一个目标: 精力-意志力 都是有限的;
2. 目标必须可行: 反复总结, 调整
2. 阻力最小化: 降低任务难度-直接进入状态; 比如回家就刷牙; 起床就洗脸吃饭t ; 吃完饭就洗碗; 然后迅速的干正事
3. 习惯安排在精力高峰期: 比如早饭容易睡觉, 可以干点家务
4. 精力不要浪费在: 手机, 电影, 微博, 知乎

## 阅读
1. 只读每一段第一个句子+黑体字
2. 读书时要出声音
3. 一次读完一段或几段: 不要再重读(除非错了)

# job
## 讲课
在线 - 麦子学院 - 慕课网
- golang 视频创作
- 10倍程序员
    1. mac book pro

## 做一个开源的im
qq, whats app 的接口是私有的

## Push sdk
To: weibo/zhihu-live/weixin

## 写作\公众号
    wb content
    push to: blog + weixin

类似为知: 但提供各种接口
推送到知乎, 微信

# app
## markdown 写作
## 反馈投票

# 大数据
## 预测金融风险:
p2p, 基金, 股票

## 统计与预测房价趋势

## 建一个理财网
预测股票走势图
