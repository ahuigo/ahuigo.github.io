---
title: 安全的密码管理软件keepass
date: 2019-02-27
private:
---
# 安全的密码管理软件keepass
1. lastpass: 适合web 网站, 远端存储密码
2. keepass: 开源，需要自己在本地存储密码, 可以同步到网盘
    1. keepass 官方只有Windows版本(c#)，在linux系统上要借助mono运行
    2. keepassXC: 基于c++/qt 的跨平台开源版本
2. pass: standard unix password manager for cli terminal.
    1. brew install pass


# install keepassXC

    brew install keepassxc

# install rclone (support onedrive/googledrive)
利用rclone 同步到onedrive/googledrive

$ rclone config 
2023/08/08 22:31:33 NOTICE: Config file "/Users/ahui/.config/rclone/rclone.conf" not found - using defaults
No remotes found, make a new one?
n) New remote
s) Set configuration password
q) Quit config
n/s/q> n

Enter name for new remote.
name> myonedrive                                                  

Option Storage.
Type of storage to configure.
Choose a number from below, or type in your own value.
13 / Dropbox
   \ (dropbox)
17 / Google Cloud Storage (this is not Google Drive)
   \ (google cloud storage)
18 / Google Drive
   \ (drive)
30 / Microsoft Azure Blob Storage
   \ (azureblob)
31 / Microsoft OneDrive
   \ (onedrive)
32 / OpenDrive
   \ (opendrive)
Storage> 31

Option client_id.
OAuth Client Id.
Leave blank normally.
Enter a value. Press Enter to leave empty.
client_id> 

Option client_secret.
OAuth Client Secret.
Leave blank normally.
Enter a value. Press Enter to leave empty.
client_secret> 

Option region.
Choose national cloud region for OneDrive.
Choose a number from below, or type in your own string value.
Press Enter for the default (global).
 1 / Microsoft Cloud Global
   \ (global)
 2 / Microsoft Cloud for US Government
   \ (us)
 3 / Microsoft Cloud Germany
   \ (de)
 4 / Azure and Office 365 operated by Vnet Group in China
   \ (cn)
region> 1

Edit advanced config?
y) Yes
n) No (default)
y/n> 

Use web browser to automatically authenticate rclone with remote?
 * Say Y if the machine running rclone has a web browser you can use
 * Say N if running rclone on a (remote) machine without web browser access
If not sure try Y. If Y failed, try N.

y) Yes (default)
n) No
y/n>  

2023/08/08 22:34:50 NOTICE: If your browser doesn't open automatically go to the following link: http://127.0.0.1:53682/auth?state=xxx0
Option config_type.
Type of connection
Choose a number from below, or type in an existing string value.
Press Enter for the default (onedrive).
 1 / OneDrive Personal or Business
   \ (onedrive)
 2 / Root Sharepoint site
   \ (sharepoint)
   / Sharepoint site name or URL
 3 | E.g. mysite or https://contoso.sharepoint.com/sites/mysite
   \ (url)
 4 / Search for a Sharepoint site
   \ (search)
 5 / Type in driveID (advanced)
   \ (driveid)
 6 / Type in SiteID (advanced)
   \ (siteid)
   / Sharepoint server-relative path (advanced)
 7 | E.g. /teams/hr
   \ (path)
config_type> 1

Option config_driveid.
Select drive you want to use
Choose a number from below, or type in your own string value.
Press Enter for the default (7b2afjxxxxxxxxlke).
 1 /  (personal)
   \ (7b2afjxxxxxxxxlke)
config_driveid> 

Drive OK?

Found drive "root" of type "personal"
URL: https://onedrive.live.com/?cid=7b2afjxxxxxxxxlke

y) Yes (default)
n) No
y/n> 

Configuration complete.