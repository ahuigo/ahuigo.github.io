---
layout: page
title: safari
category: blog
description: 
date: 2018-09-27
---
# Preface

# clear passwd
option: 先删除：keychain access 中的passwords

# forget login keychain password
If you don't know your old password, the solution is to create a new login keychain.
1. 从“钥匙串访问”菜单中，选取“偏好设置”，然后在“偏好设置”窗口中点按“还原我的默认钥匙串”按钮。输入新密码后，“钥匙串访问”将创建无密码的空登录钥匙串。点按“好”以确认。
2. create empty "login" keychain with no password. please change via "edit - change password for keychain"

If you know your old password, use that password to update your existing login keychain:
Open the Keychain Access app
From the Edit menu, choose “Change Password for Keychain 'login.'”
Enter the old password of your user account in the Current Password field. This is the password you were using before the password was reset.
Enter the new password of your user account in the New Password field. This is the password you're now using to log in to your Mac. Enter the same password in the Verify field.
Click OK when done, then quit Keychain Access.