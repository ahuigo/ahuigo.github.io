---
layout: page
title:	mac user manager
category: blog
description: 
---

# Preface
mac下没有adduser, 那如何在mac中添加用户/组?

# 命令行操作 

## 交互
从命令行进入交互模式：
 
	dscl localhost

进入组目录:

	cd /Local/Default/Groups

使用ls 你就可以看到所有的group，  同理在`/Local/Default/Users` 下可以看到所有的用户	
然后添加组及组内主用户:

	append <groupname> GroupMembership <username>

删除组及组内主用户:

	delete <groupname> GroupMembership <username>

## 非交互

### create Users

	dscl . -create /Users/luser
	dscl . -create /Users/luser UserShell /bin/bash
	dscl . -create /Users/luser RealName "Lucius Q. User"
	dscl . -create /Users/luser UniqueID "1010"
	dscl . -create /Users/luser PrimaryGroupID 80
	dscl . -create /Users/luser NFSHomeDirectory /Users/luser
	dscl . -delete /Groups/yourGroupName
	dscl . -delete /Users/yourname

### add group

	dscl . -append /Groups/admin GroupMembership luser
	dscl . append /Groups/vboxusers GroupMembership hilojack
	sudo dscl . delete /Groups/wheel GroupMembership hilojack
	#或者
	sudo dseditgroup -o edit -a hilojack -t user vboxusers #sudo usermod -a -G vboxusers hilojack

### change Passwd

	dscl . -passwd /Users/luser password

# 图形操作 

  "System preferences" -> "Accounts" -> "+" (as if you were adding new account) -> Under "New account" select "Group" -> Type in group name -> "Create group"

