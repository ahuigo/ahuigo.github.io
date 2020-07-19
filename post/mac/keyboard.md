---
title: Niz 键盘的配置
date: 2020-05-08
---
# 键盘
看上两款键盘:
1. HHKB-Pro2，是一款电脑键盘，重量0.53kg， 长29.4 x 宽11.0 x 高39.9mm 。
2. Niz Atom68 31.9*11.0

考虑到了hhkb的缺点, 入手了niz plum 

1. 双桥不支持有线传输hhkb 数据线数据走线不灵活，只有一个方向. NIZ是三个方向
2. hhkb 官方版是没有锂电池的贵hhkb只有一个60键盘布局。 niz 有66 68 84 87 108(我买的68，但想换成mini 84)
3. hhkb 只用一个压力位。niz 有35g, 45g可选.
4. hhkb 只有6个开关提供定制功能，仅仅是交换Command键和Alt键或者交换Fn键. Niz 可以通过软件定制任意按键、快捷键
5. hhkb 贵，NIZ 性价比太高了

## Office/program1/program2 三种模式
    Office 是固定按键。
    program2/1 模式下按键可定制

切换模式：按住 `Fn+M`1s：

    M 常亮.5s 是Office
    M 常亮10s 是Program1
    M 闪亮10s 是Program2
 
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

# 快捷键
    ctrl+f/b/n/p
        方向键 字符
    alt+f/b/n/p ?
        alt+ 方向键 单词
    ctrl+a/e: 
        cmd+ 方向键 选中全部

## 选中文字
    Shift + 方向键 选中文字
    Shift +alt+ 方向键 选中单词
    Shift +cmd+ 方向键 选中全部

## 删除back/del
    字符：
        backspacke/del
    单词：
        alt+backspacke/del
    全部：
        cmd+backspacke/del
        ctrl+u/k ?

## 定制niz按键
niz好像所有的按键都可以定制
1. 首先下载: niz定制软件, 这个软件 https://drive.google.com/drive/folders/1CWGM9N1DIR4i6YdScP-Sr2yV9YhgItqL
2. 然后使用软件完成定制

比如，我想将`esc` 映射到``` `~```，就如下图这样，点ESC键，录制``` ` ```, 然后写入配置成功，就表示完成
![](/img/mac/keyboard-niz-custom-esc.png)

atom68缺少一个左Fn 不太方便，于是我通过`程控键`改了下按键：
1. 将左`ctrl&Caps` 映射为右FN
2. 将`右Alt`映射为ctrl/caps: `非FN` 时为`CapsLock`,`Fn`时为`Catl&Caps`交换键

# F1-F12
## mac F1-F12
karabiner 

# Karabiner 定制快捷键
## 基本按键
https://ke-complex-modifications.pqrs.org/

    "modifiers.mandatory": 
        "control"
        "option"
        "command"
    key_code: 
        escape  esc
        "delete_or_backspace",
        "delete_forward",
        "up_arrow"
        "down_arrow"
        open_bracket
        close_bracket
        ` grave_accent_and_tilde


假如我要定义一个ctrl+k 向前删除到行末：

        {
          "type": "basic",
          "from": {
            "key_code": "k",
            "modifiers": {
              "mandatory": [
                "control"
              ]
            }
          },
          "to": [
            {
              "key_code": "delete_forward",
              "modifiers": [
                "command"
              ]
            }
          ]
        }

## ctrl+u/w
你可以设置ctrl+w/u 映射到`option/cmd+DeleteBackward`. 此时iterm会失效. 
解决方案如下：

### ctrl+w: option 映射esc
ctrl+w解决方法是option发送真正的escape：

    iTerm2 > Preferences > Profiles > Keys
    set your left ⌥ key to act as an escape character.

### ctrl+u: iterm2映射回来
https://apple.stackexchange.com/questions/89981/remapping-keys-in-iterm2

1. 利用appstore 的免费软件(key codes). 找到`ctrl+u`实际代码是`0x15`
2. 在iterm 修改keys. 将`cmd+backspace`映射到`0x15`

![](/img/shell/keyboard/iterm-keys-map.png)

## app 绑定
首先找到app 的bundle identifier

    $ osascript -e 'id of app "chrome"'
    $ osascript -e 'id of app "wechat"'
    com.tencent.xinWeChat
    $ mdls -name kMDItemCFBundleIdentifier -r /System/Volumes/Data/Applications/Charles.app
    com.xk72.Charles

再绑定app


    "manipulators": [
    {
        "conditions": [
            {
                "bundle_identifiers": [
                    "^com\\.apple\\.finder$"
                ],
                "type": "frontmost_application_if"
            }
        ],