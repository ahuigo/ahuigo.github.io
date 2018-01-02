---
layout: page
title:	Install ADB on Mac OSX	
category: blog
description: 
---
# Install android sdk Manager
	$ brew install android-sdk
	==> Caveats
	Now run the `android' tool to install the actual SDK stuff.

	" The Android-SDK location for IDEs such as Eclipse, IntelliJ etc is:
	  /usr/local/Cellar/android-sdk/22.0.5

	" You may need to add the following to your .bashrc:

	  export ANDROID_HOME=/usr/local/opt/android-sdk

	" Bash completion has been installed to:

	  /usr/local/etc/bash_completion.d

## Install 
执行android 选择sdk：

	$ android

如果你只是想操作android手机或者刷机用，只需要勾选Platform-tools和Tools (这是ADT必须的)。
完成后就可以使用 adb（Android Debug Bridge）命令来调试手机了，输入： adb version 出现版本结果就大功告成。

# adb

## 查看adb 设备
	$ adb devices #在手机上点authorized this device
	* daemon not running. starting it now on port 5037 *
	* daemon started successfully *
	List of devices attached
	034e5ae9828df5d1	unauthorized

## adb 常用命令
	$ adb shell # 交互
	$ adb push ~/file /sdcard/file
	$ adb pull /sdcard/file

# java sdk
/Library/Java/Home/lib/

# Reference
- [adb on Mac][] 
- [android on mac]

[adb on Mac]: http://www.izhangheng.com/mac-os-x-homebrew-install-android-sdk/
[android on mac]: http://forum.xda-developers.com/showthread.php?t=1917237


# root
http://www.androidrootz.com/2013/11/nexus-5-one-click-toolkit-for-mac.html

***************************************************************
								     
              One-Click Root for LG Nexus 5!		     
 							     
            Brought to you by AndroidRootz.com	     
								     
***************************************************************
             This script will: Root your Nexus 5!			     
           For more details go to AndroidRootz.com	     
 
Warning! This will do a factory reset on your phone! BACKUP your phone!
First make sure your in FASTBOOT MODE and phone is plugged in!
and then press enter to unlock your Bootloader and root your Nexus 5
< waiting for device >
...
FAILED (remote: Already Unlocked)
finished. total time: 0.001s
Use the volume up and power button to select Yes on your Nexus 5 screen
You now have an unlocked bootloader!
 
Now press the power button to start the device
Let your device boot up, complete the setup screen
Transfer UPDATE-SuperSU-v1.65.zip into your phone using Android File Transfer 
Download Android File Transfer for Mac: http://bit.ly/e2doAr
Press enter to continue
Enter back into FASTBOOT MODE and keep your phone plugged in!
Press enter to continue

Ready to install TWRP Recovery
1. TWRP Recovery
Enter 1 then press enter
/Users/hilojack/Downloads/nexus5/Root Nexus 5/Root.Nexus.5.tool: line 41: [: =: unary operator expected
Press the volume up key 2x to highlight Recovery Mode,
Use the power button to select it.
 
Once in recovery, select Install
Choose UPDATE-SuperSU-v1.65.zip, then slide to install
Once it finishes reboot your phone.
 
 
Press enter to continue
