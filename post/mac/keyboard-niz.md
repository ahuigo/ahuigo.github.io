---
title: Niz 键盘的配置
date: 2020-05-08
---
# Niz键盘上手
>　重置：同时按下键盘四角的4个键可以强制恢复出厂设置：Esc + Ctrl(左边的) + Delete + 方向右键→ 5秒后，键盘自动恢复出厂设置。

看上两款键盘:
1. HHKB-Pro2，是一款电脑键盘，重量0.53kg， 长29.4 x 宽11.0 x 高39.9mm 。
2. Niz Atom68 31.9*11.0

考虑到了hhkb的以下缺点(最后还是换成了niz)

1. hhkb的双桥不支持有线传输hhkb 数据线数据走线不灵活，只有一个方向. NIZ是三个方向
2. hhkb 官方版是没有锂电池的
2. hhkb只有一个60键盘布局。 niz 有66 68 84 87 108各种布局(我买的68)
3. hhkb 只有一个压力位。niz 有35g, 45g可选.
4. hhkb 只有6个开关提供定制功能，仅仅是交换Command键和Alt键或者交换Fn键. Niz 可以通过软件定制任意按键、快捷键
5. hhkb 太贵，NIZ 便宜性价比高

## Niz68: Office/program1/program2 三种模式
    Office 是固定按键。
    program2/1 模式下按键可定制

切换模式：按住 `Fn+M`1s：

    M 常亮.5s 是Office
    M 常亮10s 是Program1
    M 闪亮10s 是Program2
## Niz84: Office/program 模式
    Office 是固定按键。
    program 模式下按键可定制

切换模式：按住 `Fn+M`1s：

    M 亮10s熄灭 是Office
    M 瞬间熄灭 是Program模式

Program模式可独立设置两个Fn层, 左右两Fn 同时按3秒：

    闪2次: 右Fn层键值 与上层键值对调
    闪3次: 左Fn层键值 与上层键值对调
    闪1次: 恢复
 
## mac osx 蓝牙
入手niz plum atom68，蓝牙连接重试了很多次，我的系统是mac osx 10.15.4 
https://detail.tmall.com/item.htm?id=614767798852&ali_refid=a3_430582_1006:1287450127:N:bui2pN2qjp4EgGD5qTW0sQ==:4e00821c9926bf888d2dd9e2ec80ec44&ali_trackid=1_4e00821c9926bf888d2dd9e2ec80ec44&spm=a230r.1.14.3&sku_properties=5919063:6536025

主要连接蓝牙键盘时，mac会弹出匹配数字:
3. NIZ键盘长按3秒以上`fn+蓝牙1`(或者2/3) ,进入快闪连接
4. mac 开启蓝牙
5. mac 进入System Setting> keyboard, 点击Set Up Buletooth Keyboard. 找到键盘，点击connect
6. 蓝牙键盘要输入6个数字（输入时不回显，自己是看不到输入）
7. 蓝牙键盘按回车（回车不可少）
8. 再点“connect” 连接(如果6个数字码不对，会要求重新连接

Note: 
我一开始也遇到mac 蓝牙连接键盘连不上的问题。后来重启了mac（平时半年也不会重启），键盘fn+蓝牙1 长按3秒以上，重新连接就正常了。
据说升级到10.15.2 mac osx 不会有问题？我的没有升级，一直是用的10.15.0(the Xcode Command Line Tools 最新）

## 定制niz按键
niz所有的按键都可以定制
1. 首先下载: niz定制软件, 这个软件 https://drive.google.com/drive/folders/1CWGM9N1DIR4i6YdScP-Sr2yV9YhgItqL
2. 然后使用软件完成定制

比如，我想将`esc` 映射到``` `~```，就如下图这样，点ESC键，录制``` ` ```, 然后写入配置成功，就表示完成
![](/img/mac/keyboard-niz-custom-esc.png)

atom68缺少一个左Fn 不太方便，于是我通过`程控键`改了下按键：
1. 将左`ctrl&Caps` 映射为右FN
2. 将`右Alt`映射为ctrl/caps: `非FN` 时为`CapsLock`,`Fn`时为`Catl&Caps`交换键


## 通过karabiner 实现按键交换
也可通过 karabiner 交换 `esc` 与 `~`