# todo
HTML 5 视频直播一站式扫盲
原创 2016-06-30 吕鸣 腾讯Bugly
https://mp.weixin.qq.com/s?__biz=MzA3NTYzODYzMg==&mid=2653577297&idx=1&sn=a292ff3b499168f4eb589e40b7aa6d13&scene=1&srcid=0705scHDgAgC2pzL3iRQcBNy&key=77421cf58af4a65354e22e6228cf8e3f09e42893d53f6137005b62d8b73e151b6e3f102c1fef3724427b4ff547eba775&ascene=0&uin=NzEzNzkxMDIw&devicetype=iMac+MacBookAir6%2C2+OSX+OSX+10.11.5+build(15F34)&version=11020201&pass_ticket=fqec8dW4sn3HhOuDlWZnqbgAeu0AuzrfTBZgFZUPtJF%2BtBu8adCc223c1G7o2dhP

# rtmp protocol
> https://en.wikipedia.org/wiki/Real_Time_Messaging_Protocol

公有协议推流的时候基本上都是采用RTMP协议，他是基于TCP协议封装的格式
他的默认端口是1935。RTMP也可以用来拉流，但是因为他的默认端口是1935，在中国的复杂网络条件下，穿透性不如 flv的80端口，所以主流直播一般`拉流`不采用RTMP。

## OBS
OBS（Open Broadcaster Software）是开源的推流器软件， 支持 rtmp 推流(串流->自定义流媒体服务器)

# FLV(Flash Video)
flv 也是应用层协议，不过是基于HTTP 长连接, 穿透性较好。
视频里边的原始图像数据会采用 H.264 (added to MP4 and FLV)编码格式进行压缩，音频采样数据会采用 AAC 或者 MP3编码格式进行压缩

FLV协议是公有协议拉流播放的主流选择: http://domain.com/xx.flv

# HLS(HTTP Live Streaming)

  Filename extension	.m3u8
  Internet media type	application/vnd.apple.mpegurl[1]
  Developed by	Apple Inc.
  Initial release	May 2009
  Type of format	Playlist
  Extended from	extended M3U

HLS是苹果推出的一种视频协议，他是在H5端采用的一种去flash化的视频协议，
他的原理是: 对视频采取很小的ts切面，m3u8是视频切片的索引。
他的优势是非常明显的: 切片后，只需要搭建静态下载服务器就能支撑hls的播放，对服务器的环境依赖很小。

# 优化
移动直播技术秒开优化经验（含PPT） 徐立
出处：http://chuansong.me/n/304413951548
QQ空间直播秒开优化实践
出处：http://bugly.qq.com/bbs/forum.php?mod=viewthread&tid=1204
