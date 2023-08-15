---
title: file sync(rclone)
date: 2019-02-27
private:
---
# rclone 
rclone支持 onedrive/dropbox/googledrive/...

    # brew 版本编译M1 可能会有问题：it requires the beta version of the Go compiler
    brew install rclone
    # 推荐直接用
    sudo -v; curl https://rclone.org/install.sh | sudo bash

# config onedrive
利用rclone 同步到onedrive

```bash
$ rclone config 
2023/08/08 22:31:33 NOTICE: Config file "~/.config/rclone/rclone.conf" not found - using defaults
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
```

# mount dir
例如我要把一个名为 myonedrive 的配置根目录/挂载到本地的 `~/onedrive` 目录，我可以这样写：

    # 最好不要加 --no-check-certificate
    mkdir ~/onedrive
    rclone mount myonedrive:/ ~/onedrive --copy-links --no-gzip-encoding --allow-other --allow-non-empty --umask 000
    # rclone mount myonedrive:/ ~/onedrive --copy-links --no-gzip-encoding --vfs-cache-mode=full --allow-other --allow-non-empty --umask 000

可能会报错：

    Fatal error: failed to mount FUSE fs: mount stopped before calling Init: mount failed: cgofuse: cannot find FUSE

解决办法是：install macFUSE (https://osxfuse.github.io/)

    $ rclone version
    brew install macfuse; # 或者官网 install from website
