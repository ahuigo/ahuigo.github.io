---
title: 几个让你编辑效率提升数倍的小技巧(mac osx)
date: 2020-05-08
---
# 使用mac osx 所支持的readline 快捷键
可能很少有人知道mac 是支持全局readline快捷键的.

mac osx 大部分app 是支持常规的readline 或变种的, 但是支持得并不完整

## 移动快捷键

    方向键(字符)
        相当于readline的 ctrl+f/b/n/p
    alt+ 左右方向键(单词)
        相当于readline的 alt+f/b
    cmd+方向键(行)
        相当于readline的 ctrl+a/e:

mac 不支持的有

    ctrl+n/p
    alt+f/b

## 删除back/del 相关的快捷键
    删除字符：
        backspacke/del
        相当于ctrl+h/d
    删除单词：
        alt+backspacke
        相当于ctrl+w
    删除行：
        cmd+backspacke/del
        相当于ctrl+u/k 

mac 不支持的有

    ctrl+w
    ctrl+u

## 选中文字的快捷键
    Shift + 方向键 选中文字
    Shift +alt+ 方向键 选中单词
    Shift +cmd+ 方向键 选中全部

# Karabiner 定制快捷键
![](/img/shell/keyboard/karabiner-keyboard-list.png)

## karabiner log
如果karabiner 没有生效，可以查看相关日志

    /var/log/karabiner/grabber.log
    /var/log/karabiner/observer.log
    ~/.local/share/karabiner/log/console_user_server.log

## 按键绑定
官方提供了别人写好的按按键绑定集 https://ke-complex-modifications.pqrs.org/

先了解一下karabiner 定义的基本按键

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

了解基本按键，我自己可以编写快捷键映射规则了
如果我们想`ctrl+k`映射到`command+delete`(向前删除到行末)：

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

对于mac osx内置键盘而言，我们最好交换一下`caps` 与`leftctrl`
![](/img/shell/keyboard/karabiner-readline1.png)

注意：你可以使用osx系统的keyboard 交换ctrl 与caps-lock, 不过不要选择 Apple internal，或者68ECS，因为键盘完成被karabiner 的vitualHIDKeyboard 完全接管了. 
导致下图的修改是没有意义的
![](/img/shell/keyboard/karabiner-mac-layout.png)
![](/img/shell/keyboard/karabiner-ecs68-layout.png)

## 全局readline 快捷键
我写了一份mac 下的readline 快捷键映射配置
https://github.com/ahuigo/a/blob/master/config/karabiner/assets/complex_modifications/niz.json 
它提供了mac osx所缺失的全局readline 支持

    ctrl+p up
    ctrl+n down
    ctrl+w delete word backward  (alt+delete)
    ctrl+u  delete from cursor to head line (cmd+delete)

将这份配置导入到karabiner 的complex modifications 即可生效。
如果导入不生效，原因可能是:
1. 可能是由于在系统键盘keyboard 内交换了 ctrl-caps, 无法识别`leftctrl`
1. 改成由karabiner 交换 leftctrl-caps 

### app 绑定
上面的readline 配置会在所有的app 生效。 如果我们想让karabiner keys只应用于某个app 怎么办呢？

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

注意，这个正则应该可以匹配多个app(不过我没有试过)

## iterm2 ctrl+u/w 问题
使用上面的readline 快捷键对iterm2是有影响的
1. 设置`ctrl+w` 映射到`option+DeleteBackward`. 此时iterm2会失效. 
2. 设置`ctrl+u` 映射到`cmd+DeleteBackward`. 此时iterm2会失效. 

### ctrl+w: option 映射esc
ctrl+w解决方法是设置option发送真正的escape：

    iTerm2 > Preferences > Profiles > Keys
    set your left ⌥ key to act as an escape character.

### ctrl+u: iterm2映射还原
https://apple.stackexchange.com/questions/89981/remapping-keys-in-iterm2

1. 利用appstore 的免费软件(key codes). 找到`ctrl+u`实际代码是`Unicode: 21/0x15`
2. 所以在iterm 修改 `iTerm2 > Preferences >Keys`. 将`cmd+backspace`映射到原本的`0x15`

![](/img/shell/keyboard/iterm-keys-map.png)


## iterm2 快捷键
1. 自用按键
![](/img/mac/iterm2-iterm2-keys.png)
2. 导出: a/conf/iterm2/iterm2.itermkeymap

3. 为了方便`Option+f`和`option+w`移动和删除，建议把　**profile=>keys** 选项卡中的`Left-Option` 按键设置成`ESC+` 
![](/img/mac/iterm2-shortcut.png)

### 注意
1. 需要在mac osx中的Security Privacy 中为 Karabiner 分配input monitor权限
2. 不建议用在系统keyboard 交换caplock 与ctrl(它无法区分left ctrl). 应该使用 Karabiner 来映射

## vim 快捷键
我想在iterm2中的vim 实现`command+s`保存，`command+a`全选
由于这几个键都被iterm2拦截了，突破方法是利用iterm2中keys 将按键映射到其它的keycodes. 
![](/img/vim/shortcut-iterm-conf.png)

如上图所示，我映射了以下几个按键:

    command+a  Esc+A+a
    command+c  Esc+A+c
    command+s  Esc+A+s

然后在vimrc 中用以上的绑定键做 map 操作:

    " Select whole content
    nnoremap <M-A>a ggVG
    " Copy
    vnoremap <M-A>c "+y
    " Save
    nnoremap <M-A>s :up<CR>
    inoremap <M-A>s <C-o>:up<CR>