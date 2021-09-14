---
title: mac launchd
date: 2020-05-19
private: true
---
# mac launchd
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

例如，开机时自动启动Apache服务器：

	$ sudo launchctl load -w /System/Library/LaunchDaemons/org.apache.httpd.plist

关闭:

    launchctl unload -w /System/Library/LaunchAgents/com.apple.AddressBook.SourceSync.plist

运行launchctl list显示当前的启动脚本。sudo launchctl unload [path/to/script]停止正在运行的启动脚本，再加上-w选项即可去除开机启动。用这个方法可以一次去除Adobe或Microsoft Office所附带的所有“自动更新”后台程序。

Launchd脚本存储在以下位置：

	~/Library/LaunchAgents
	/Library/LaunchAgents
	/System/Library/LaunchAgents
	/Library/LaunchDaemons
	/System/Library/LaunchDaemons

启动脚本的格式可以参考
1. [这篇blog](http://paul.annesley.cc/2012/09/mac-os-x-launchd-is-cool/)，
2. [苹果开发者中心的文章](https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)。
3. 你也可以使用[Lingon应用](http://www.peterborgapps.com/lingon/)来完全取代命令行。

# brew services
> refer: data-warehouse.hdmap.momenta.works
MySQL为例，使用launchctl开机启动:

    ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist

如使用brew service可以简化为:

    brew services start mysql
    brew services restart postgresql

log:

    /usr/local/var/log/

## 常用命令

    brew services list  # 查看使用brew安装的服务列表
    brew services run formula|--all  # 启动服务（仅启动不注册）
    brew services start formula|--all  # 启动服务，并注册
    brew services stop formula|--all   # 停止服务，并取消注册
    brew services restart formula|--all  # 重启服务，并注册
    brew services cleanup  # 清除已卸载应用的无用的配置

## 配置文件目录
    /Library/LaunchDaemons # 开机自启，需要sudo
    ~/Library/LaunchAgents # 用户登录后自启
