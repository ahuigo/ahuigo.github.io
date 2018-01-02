---
layout: page
title: 删除mavericks 10.9 自带的输入法	
category: blog
description: 
---
# Preface
如果你想删除mavericks 10.9 自带的输入法, 目前只能通过 修改~/Library/Preferences/com.apple.HIToolbox.plist
plist文件是二进制的, 你可以通过plist/xcode编辑器修改
Download: [plist pro](http://pan.baidu.com/s/1dDEE0UH)

# Edit plist

## 首先备份你的plist 

	cp ~/Library/Preferences/com.apple.HIToolbox.plist ~/com.apple.HIToolbox.plist.bak

## 编辑plist文件

	$ plutil -convert xml1  ~/Library/Preferences/com.apple.HIToolbox.plist
	$ vim  ~/Library/Preferences/com.apple.HIToolbox.plist

Remove the input source or input sources you want to disable from the AppleEnabledInputSources dictionary. If there is an AppleDefaultAsciiInputSource key, remove it.

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

# Reboot
注销再登录就可以了
