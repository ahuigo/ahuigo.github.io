---
title: mac launchd
date: 2020-05-19
private: true
---
# mac launchd
## 启动脚本的格式
以 openresty 为例
cat ~/Library/LaunchAgents/homebrew.mxcl.openresty-debug.plist

    <key>Label</key>
    <string>homebrew.mxcl.openresty-debug</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/opt/openresty-debug/bin/openresty</string>
        <string>-g</string>
        <string>daemon off;</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/opt/homebrew</string>

说明:

    Label：对应的需要保证全局唯一性；
    Program：要运行的程序；
    ProgramArguments：命令语句
    StartCalendarInterval：运行的时间，单个时间点使用dict，多个时间点使用 array <dict>
    StartInterval：时间间隔，与StartCalendarInterval使用其一，单位为秒
    StandardInPath、StandardOutPath、StandardErrorPath：标准的输入输出错误文件
    定时启动任务时，如果涉及到网络，但是电脑处于睡眠状态，是执行不了的，这个时候，可以定时的启动屏幕就好了。

可以参考
1. [这篇blog](http://paul.annesley.cc/2012/09/mac-os-x-launchd-is-cool/)，
2. [苹果开发者中心的文章](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)。
3. 你也可以使用[Lingon应用](http://www.peterborgapps.com/lingon/)来完全取代命令行。

## launchd vs systemctl
launchd 是mac 下的系统服务管理器(类似systemd),

	# 类似于chkconfig add mysqld; chkconfig --level 2345 mysqld on
	# 或者 systemctl enable mysqld
    ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents


	# 类似于service mysqld start  或者 systemctl start mysqld
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist


	# 类似于service mysqld stop | systemctl stop mysqld
	launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

	# 类似于chkconfig --level 2345 mysql off | systemctl disable mysqld
	rm -Rf ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
	launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

launchctl管理OS X的启动脚本，控制启动计算机时需要开启的服务。也可以设置定时执行特定任务的脚本，就像Linux cron一样。

## 开机时自动
启动Apache服务器：

	$ sudo launchctl load -w /System/Library/LaunchDaemons/org.apache.httpd.plist
    # 其实是复制到 ~/Library/LaunchAgents/

## 关闭开机启动:

    launchctl unload -w /System/Library/LaunchAgents/com.apple.AddressBook.SourceSync.plist
    # 其实是删除 ~/Library/LaunchAgents/
## 其它命令
launchctl -h

    launchctl list
        显示当前的启动脚本。
    launchctl load [path/to/script.plist]
        -w 此项会将copy plist 复制到 ~/Library/LaunchAgents/
    launchctl unload [path/to/script.plist]
        停止正在运行的启动脚本
        再加上-w选项即可去除开机启动。
        用这个方法可以一次去除Adobe或Microsoft Office所附带的所有“自动更新”后台程序。

## plist

Launchd脚本存储在以下位置：

    ~/Library/LaunchAgents 由用户自己定义的任务项
    /Library/LaunchAgents 由管理员为用户定义的任务项
    /Library/LaunchDaemons 由管理员定义的守护进程任务项
    /System/Library/LaunchAgents 由Mac OS X为用户定义的任务项
    /System/Library/LaunchDaemons 由Mac OS X定义的守护进程任务项

# brew services
这是基于 launchctl/systemd。 但是仅限于brew 安装的包

    brew services
    # plist/service 文件
    /opt/homebrew/Cellar/postgresql/14.2_1/homebrew.mxcl.postgresql.plist
    /opt/homebrew/Cellar/postgresql/14.2_1/homebrew.postgresql.service

MySQL为例，使用launchctl开机启动:

    ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

如使用brew service可以简化为:

    brew services start mysql
    brew services restart postgresql

log:

    /usr/local/var/log/

## 常用命令

    brew services -h 
    [sudo] brew services [list] (--json)
    List information about all managed services for the current user (or root).

    [sudo] brew services info (formula|--all|--json)
    List all managed services for the current user (or root).

    [sudo] brew services run (formula|--all)
    Run the service formula without registering to launch at login (or boot).

    [sudo] brew services start (formula|--all|--file=)
    Start the service formula immediately and register it to launch at login (or boot).

    [sudo] brew services stop (formula|--all)
    Stop the service formula immediately and unregister it from launching at login (or boot).

    [sudo] brew services kill (formula|--all)
    Stop the service formula immediately but keep it registered to launch at login (or boot).

    [sudo] brew services restart (formula|--all)%

## 配置文件目录
    /Library/LaunchDaemons # 开机自启，需要sudo
    ~/Library/LaunchAgents # 用户登录后自启

# 定时任务
示例
$ cat ~/Library/LaunchAgents/ahuigo.boot.mycron.plist
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>ahuigo.boot.mycron</string>
    <key>RunAtLoad</key>
    <true/>
    <key>ProgramArguments</key>
    <array> 
        <string>/usr/local/bin/my.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>8</integer>
            <key>Minute</key>
            <string>58</string>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>8</integer>
            <key>Minute</key>
            <string>52</string>
        </dict>
    </array>
    <key>StandardOutPath</key>
    <string>/var/log/outlog</string>
    <key>StandardErrorPath</key>
    <string>/var/log/errorlog</string>
</dict>
</plist>
```
# watch path
类似fswatch, WatchPaths 实现了当path中文件修改时，命令重新运行

    <dict>
        <key>Label</key>
        <string>logger</string>
        <key>ProgramArguments</key>
        <array>
            <string>/usr/bin/logger</string>
            <string>path modified</string>
        </array>
        <key>WatchPaths</key>
        <array>
            <string>/Users/sakra/Desktop/</string>
        </array>
    </dict>
