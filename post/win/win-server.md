# smb
1. 防火墙端口打开: 139或445
2. 服务: windows server 服务要打开
3. 服务器管理角色要建立 存储
mount_smbfs -f 777 -d 777 //administrator:password@1.1.1.1/stock stock
