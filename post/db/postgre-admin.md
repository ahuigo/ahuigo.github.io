---
title: Postgre 安装\配置\管理
date: 2018-09-27
---
# Postgre 安装\配置\管理
```bash
rpm -Uvh https://yum.postgresql.org/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
yum install postgresql10-server postgresql10 -y
# Create a new PostgreSQL database cluster:
/usr/pgsql-10/bin/postgresql-10-setup initdb
```

## output formate

    # \x
    Expanded display is on.
    # \x
    Expanded display is off.

## auth
see db-user.md
vim /var/lib/pgsql/data/pg_hba.conf

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

#### via args
/lib/systemd/system/postgresql.service

    Environment=PGPORT=9898

then:

    # 先使配置生效
    systemctl daemon-reload
    # 再重启
    systemctl restart postgresql


## client
1. 默认同时支持 unix domain socket + ip/port net socket
    1. unix domain soket 的地址可通过port 指定：sudo -u postgres psql -p 6379

psql postgresql://t1:1@47.96.1.162:6379/template1

### exec

    $ psql -h 127.0.0.1 -p 5930 -c "select 1"
    $ psql -h 127.0.0.1 -p 5930 -f a.sql

#### exec sql file
psql -f exec.sql
pg_dump dbname > outfile

psql [dbname] < exec.sql

## backup

    # only schema
    pg_dump -U [db_username] -s  -f [filename.sql] [db_name]
    # data+schema
    pg_dump                      -f [filename.sql] [db_name]

    -F format
        -Fc custom, Output a custom-format archive suitable for input
        -Fp plain 默认

## restore
custom-format archive:

    # schema
    pg_restore -s -d [db_name] [filename.sql]
    # data
    pg_restore -a -d [db_name] [filename.sql]
    # schema and data
    pg_restore -d [db_name] [filename.sql]

# help
`\h CREATE ROLE`