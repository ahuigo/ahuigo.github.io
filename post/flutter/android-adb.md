---
layout: page
title:	Install ADB on Mac OSX	
category: blog
description: 
---
# Install android sdk Manager
	$ brew cask install android-sdk
    'export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"'
    android-sdk requires Java 8. You can install it with
        brew cask install caskroom/versions/java8
    -------------
	==> Caveats
	Now run the `android' tool to install the actual SDK stuff.
	" Bash completion has been installed to:

	  /usr/local/etc/bash_completion.d

## Install 
执行android 选择sdk：

	$ android

如果你只是想操作android手机或者刷机用，只需要勾选Platform-tools和Tools (这是ADT必须的)。
完成后就可以使用 adb（Android Debug Bridge）命令来调试手机了，输入： adb version 出现版本结果就大功告成。

# adb + fastboot
android debug bridge
ADB是android sdk里的一个工具, 用这个工具可以直接操作管理android模拟器或者真实的andriod设备. 它的主要功能有:

    运行设备的shell(命令行)
    管理模拟器或设备的端口映射
    计算机和设备之间上传/下载文件
    将本地apk软件安装至模拟器或android设备

## install adb and fastboot(platform-tools)
下载方法：

    # 1. 如果用android studio.app 下载android sdk会解压到：
    # 2. 或者 https://developer.android.com/studio/releases/platform-tools#download
    ~/Library/Android/sdk/platform-tools/

设定变量

    export ANDROID_SDK_ROOT=~/Library/Android/sdk
    export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:

## set phone debug mode
1. my advice -> 全部参数与信息-> miui version
1. Tap the About Phone option 
2. Then tap the Build Number option 7 times to enable Developer Mode. 
3. enable the USB Debugging mode option.

进入debug mode(miui14):
1. 更多设备->developer options -> enable debug

## 查看adb 设备
	$ adb devices #在手机上点authorized this device
	* daemon not running. starting it now on port 5037 *
	* daemon started successfully *
	List of devices attached
	034e5ae9828df5d1	unauthorized

## adb 常用命令
https://lifehacker.com/the-most-useful-things-you-can-do-with-adb-and-fastboot-1590337225

	$ adb shell # 交互
	$ adb shell [command]

    Copy files to phone
    $ adb push [source] [destination]
	$ adb push ~/file /sdcard/file

    Copy files from your phone to your computer.
	$ adb pull /sdcard/file

    adb install [source.apk]

reboot:

    adb reboot bootloader
    adb reboot recovery

### uninstall app
比如uninstall guard

    adb shell pm list package | grep com.miui.guardprovider
    adb uninstall --user 0 com.miui.guardprovider

如果有分身系统需要查看一下设备用户资料 ID 命令为

    adb shell pm list users

### backup
Function: Create a full backup of your phone and save to the computer.

    adb backup 

Function: Restore a backup to your phone.

    adb restore restorefile.zip

### ROM
adb sideload
Function: Push and flash custom ROMs and zips from your computer.

## fastboot
adb 不能访问bootloader 区，fastboot可以：

    fastboot oem unlock
    Function: Unlock your bootloader, making root access possible.
    fastboot oem lock

    fastboot devices
    Function: Check connection and get basic information about devices connected to the computer.
    This is essentially the same command as adb devices from earlier. However, it works in the bootloader, which ADB does not

    fastboot flash recovery
    Function: Flash a custom recovery image to your phone.

# 刷机
以nexus 5为例：

    hammerhead D820(H) 16G
    HW Version rev_11
    Bootloader version: HHZ12h
    BASEBAND VERSION: M8974A-2.0.50.2.26
    SECURE BOOT: enabled
    Lock state: unlocked (原来是locked)

1. platfrom sdk: adb+fastboot 
    0. PATH=$PATH:~/Download/n5/platform-tools
    1. adb devices
2. n5 connect to mac osx: set debug mode
3. install:
    5. adb reboot bootloader
    2. Fastboot OEM unlock
    3. install rom:
        1. via twrap recovery
            0. http://www.androiddevs.net/downloads/
            1. Inside TWRP -> Press wipe -> advance wipe -> enable cache, Dalvik cache, data, and system. 
            2. Tap on install and choose the downloaded ROM package 
            2. Now install Gapps (based on Android Nougat)
        2. via fastboot: 
            1. 到官网（http://developer.android.com/preview/setup-sdk.html）下载Android ROM file L/M/N/O整包，并解压。
            3. cd unzip_rom_dir && sh flash-all.sh 
        3. 其他方法： https://www.jianshu.com/p/e5e9ef0eec4b

## install twrp recovery
https://dl.twrp.me/hammerhead/

    fastboot flash recovery twrp-2.8.x.x-xxx.img

## fastboot 刷机命令
Fastboot 类似BIOS 固件。
1. fastboot可以将电脑上的recovery镜像（非手机上），加载到手机。
2. 不需要依赖于recovery，甚至linux底层刷坏了recovery模式
3. astboot模式其实是调用spl进行刷机的，所以如果刷spl坏了就变砖了
4. fastboot方法需要电脑上有fastboot程序，同时手机要进入fastboot模式才可以操作

另外
1. Recovery - wipe data/partition tool
1. Bootloader 更为原始的BIOS，然后选择进入fastboot还是recovery/rom


# Reference
- [adb on Mac][] 
- [android on mac]

[adb on Mac]: http://www.izhangheng.com/mac-os-x-homebrew-install-android-sdk/
[android on mac]: http://forum.xda-developers.com/showthread.php?t=1917237