---
title: 键盘
date: 2020-05-08
private: true
---
# 键盘
HHKB-Pro2，是一款电脑键盘，重量0.53kg， 长29.4 x 宽11.0 x 高39.9mm 。
Niz Atom68 31.9*11.0

## mac osx 蓝牙
入手niz plum atom68，蓝牙连接重试了很多次，我的系统是mac osx 10.15.4 
https://detail.tmall.com/item.htm?id=614767798852&ali_refid=a3_430582_1006:1287450127:N:bui2pN2qjp4EgGD5qTW0sQ==:4e00821c9926bf888d2dd9e2ec80ec44&ali_trackid=1_4e00821c9926bf888d2dd9e2ec80ec44&spm=a230r.1.14.3&sku_properties=5919063:6536025

主要连接蓝牙键盘时，mac会弹出匹配数字:
1. 用蓝牙键盘要输入6个数字（输入时不回显，自己是看不到输入）
2. 蓝牙键盘按回车（回车不可少）
3. 再点“connect” 连接

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

# Karabiner 定制快捷键
## 按键
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

grave_accent_and_tilde 与esc 交换

    {
        "type": "basic",
        "from": { "key_code": "escape" },
        "to": { "key_code": "grave_accent_and_tilde" }
    },
    {
        "type": "basic",
        "from": { "key_code": "grave_accent_and_tilde" },
        "to": { "key_code": "escape" }
    }



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