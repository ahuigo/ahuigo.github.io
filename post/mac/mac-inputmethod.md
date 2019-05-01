---
title: 删除Mac mojave 自带的输入法	
date: 2019-04-26
category: blog
description: 
---
# 删除Mac mojave 自带的输入法	
如果你想删除mojave 10.14 自带的输入法, 需要 修改~/Library/Preferences/com.apple.HIToolbox.plist
plist文件是二进制的, 你可以通过plist/xcode编辑器修改. 我修改后的结果：https://github.com/ahuigo/a/tree/master/conf/com.apple.HIToolbox.plist
Download: [plist pro](http://pan.baidu.com/s/1dDEE0UH)

1. 重启，并按CMD+R 进入Recovery mode
2. 关闭mac osx 的SIP 保护：`$ csrutil disable`
3. 编辑你的plist： 本文的下面会介绍. 
4. 打开mac osx 的SIP 保护 `$ csrutil enable`

# Edit plist

## 首先备份你的plist 

	cp ~/Library/Preferences/com.apple.HIToolbox.plist ~/com.apple.HIToolbox.plist.bak

## 编辑plist文件

	plutil -convert xml1  ~/Library/Preferences/com.apple.HIToolbox.plist
	vim  ~/Library/Preferences/com.apple.HIToolbox.plist

Remove the input source or input sources you want to disable from the AppleEnabledInputSources dictionary. If there is an AppleDefaultAsciiInputSource key, remove it.

```xml
    <key>AppleEnabledInputSources</key>
    <array>
        <dict>
            <key>Bundle ID</key>
            <string>com.baidu.inputmethod.BaiduIM</string>
            <key>Input Mode</key>
            <string>com.baidu.inputmethod.wubi</string>
            <key>InputSourceKind</key>
            <string>Input Mode</string>
        </dict>
        <dict>
            <key>Bundle ID</key>
            <string>com.baidu.inputmethod.BaiduIM</string>
            <key>InputSourceKind</key>
            <string>Keyboard Input Method</string>
        </dict>
    </array>
```

# Reboot
注销再登录就可以了
