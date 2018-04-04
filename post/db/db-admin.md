# 安装\配置\管理

# install
```bash
rpm -Uvh https://yum.postgresql.org/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
yum install postgresql10-server postgresql10 -y
# Create a new PostgreSQL database cluster:
/usr/pgsql-10/bin/postgresql-10-setup initdb
```

## auth
see db-user.md
vim /var/lib/pgsql/data/pg_hba.conf

## run
    if centos:
        systemctl start postgresql-10.service
        systemctl enable postgresql-10.service
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
    elif osx:
        ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents

        cat <<MM >> ~/.zshrc
        alias pg-start="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
        alias pg-stop="launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
        MM

    createdb `whoami`

### change listen host
1. postgres -h 0.0.0.0
2. /var/lib/pgsql/10/data/
2. vim /var/lib/pgsql/data/postgresql.conf
    `listen_address='*'`
    `listen_address='localhost'`
    'localhost,192.168.1.66'
    'port=5432'

### via args
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

# admin
psql -f exec.sql

## backup
    # only schema
    pg_dump -U [db_username] -s -Fc -f [filename.sql] [db_name]
    # data+schema
    pg_dump                     -Fc -f [filename.sql] [db_name]

    -F format
        c custom, Output a custom-format archive suitable for input

## restore

    # schema
    pg_restore -s -d [db_name] [filename.sql]
    # data
    pg_restore -a -d [db_name] [filename.sql]
    # schema and data
    pg_restore -d [db_name] [filename.sql]

# help
`\h CREATE ROLE`
