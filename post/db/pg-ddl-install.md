---
title: Postgre 安装\配置\管理
date: 2018-09-27
---
# Postgre 安装\配置\管理

## intall
centos:

    yum install postgresql-server postgresql-contrib -y
    sudo postgresql-setup initdb
    sudo systemctl start postgresql

mac:

    brew install postgresql

    # 初始化数据库（默认role `whoami`）
    initdb --locale=C -E UTF-8 /usr/local/var/postgres
    
    # run
    brew services start postgresql

    $ psql -U `whoami` postgres

    # log
    tail -f /usr/local/var/log/postgres.log

如果遇到：FATAL:  database files are incompatible with server

    brew services stop postgresql
    brew postgresql-upgrade-database
    brew services start postgresql

## auth
see db-user.md

    psql -U postgres -c 'SHOW all' |grep hba_file
    psql -U postgres -c 'SHOW hba_file'

    # mac
    /usr/local/var/postgres/pg_hba.conf        | Sets the server's "hba" configuration file.
    # centos
     /var/lib/pgsql/data/pg_hba.conf

## run & config

    if centos:
        sudo systemctl start postgresql
        # auto reboot
        sudo systemctl enable postgresql
    elif osx:
        # 手动
        # To have launchd start postgresql now and restart at login:
        brew services start postgresql

        # Or, if you don't want/need a background service you can just run:
        pg_ctl -D /usr/local/var/postgres start

        # 开机启动
        ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents

        cat <<MM >> ~/.zshrc
        # 开机启动
        alias pg-start="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"

        # 关闭开机启动 是rm plist
        alias pg-stop="launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
        MM


然后登录：

    psql -U role1 ahuigo

## debug

    ps aux| grep postgres

## login 
第一次默认安装后只有一个role： postgres(或者当前用户名), 只登录这个role

    $ sudo -u `whoami` -i 
    $ psql

或者：

    psql -U postgres postgres
    psql -U `whoami` postgres

## path
### log
mac log默认在

    /usr/local/var/log/postgres

### 数据文件
    $ ls /usr/local/var/postgres/PG_VERSION
    $ ls /usr/local/var/postgres@11/

### debug
#### 升级问题
    psql: error: could not connect to server: could not connect to server: No such file or directory
        Is the server running locally and accepting
        connections on Unix domain socket "/tmp/.s.PGSQL.5432"?

    $ tail /usr/local/var/postgres/server.log

    2020-02-28 13:00:12.285 CST [6972] FATAL:  database files are incompatible with server
    2020-02-28 13:00:12.285 CST [6972] DETAIL:  The data directory was initialized by PostgreSQL version 11, which is not compatible with this version 12.2.

方案1：

    $ brew postgresql-upgrade-database
    FATAL:  role "role2" does not exist

    pg_upgrade -U role1

方案2：

    https://olivierlacan.com/posts/migrating-homebrew-postgres-to-a-new-version/

寻求方案:

    https://github.com/Homebrew/homebrew-core/issues/new?template=bug.md
    https://github.com/Homebrew/homebrew-core/issues/47077

### conf path
mac conf:

    /usr/local/var/postgres/pg_hba.conf
    /usr/local/var/postgres/postgresql.conf

centos conf:

    /var/lib/pgsql/data/pg_hba.conf

### change listen host
1. postgres -h 0.0.0.0
2. vim /var/lib/pgsql/10/data/postgresql.conf
    `listen_addresses='*'`
    `listen_addresses='localhost'`
    'localhost,192.168.1.66'
    'port=5432'

show config 

    psql -U postgres -c 'SHOW config_file'
     /usr/local/var/postgres/postgresql.conf

#### via args
/lib/systemd/system/postgresql.service

    Environment=PGPORT=9898

then:

    # 先使配置生效
    systemctl daemon-reload
    # 再重启
    systemctl restart postgresql


# client
## output format

    # \x
    Expanded display is on.
    # \x
    Expanded display is off.
