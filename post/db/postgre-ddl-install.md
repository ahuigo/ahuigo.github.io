---
title: Postgre 安装\配置\管理
date: 2018-09-27
---
# Postgre 安装\配置\管理
    rpm -Uvh https://yum.postgresql.org/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
    yum install postgresql10-server postgresql10 -y
    # Create a new PostgreSQL database cluster:
    /usr/pgsql-10/bin/postgresql-10-setup initdb

## output formate

    # \x
    Expanded display is on.
    # \x
    Expanded display is off.

## auth
see db-user.md

    psql -U postgres -c 'SHOW all' |grep hba_file
    psql -U postgres -c 'SHOW hba_file'
    /usr/local/var/postgres/pg_hba.conf        | Sets the server's "hba" configuration file.

## run

    if centos:
        systemctl start postgresql-10.service
        systemctl enable postgresql-10.service
        #sudo systemctl start postgresql
        #sudo systemctl enable postgresql
    elif osx:
        # To have launchd start postgresql now and restart at login:
        brew services start postgresql
        # ps aux
        pg_ctl -D /usr/local/var/postgres start

        # 
        ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents

        cat <<MM >> ~/.zshrc
        alias pg-start="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
        alias pg-stop="launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
        MM

    createdb `whoami`

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

