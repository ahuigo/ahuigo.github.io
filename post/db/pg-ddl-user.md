---
title: Postgre User and Authentication
date: 2018-09-27
---
# help
    \h alter
    ALTER ROLE name RENAME TO new_name

# Postgre User and Authentication
找到pg_hba.conf

    $ psql -U postgres -c 'SHOW all' |grep hba_file
    $ psql -U postgres -c 'SHOW hba_file'
    /usr/local/var/postgres/pg_hba.conf        | Sets the server's "hba" configuration file.
    /usr/share/pgsql/pg_hba.conf # centos

然后改配置：

    host    all             all             127.0.0.1/32            md5
    host    all             all             0.0.0.0/0               md5

    # "local" is for Unix domain socket connections only
    local   all             all                                     trust
    # IPv4 local connections:
    host    all             all             127.0.0.1/32            trust
    # IPv6 local connections:
    host    all             all             ::1/128                 trust


auth method:
1. Peer : use kernel os system user name, only supported on local connections.
2. indent:  client's operating system user name, only supported on TCP/IP connections,  *for a local (non-TCP/IP) connection, peer is used instead*
3. password: 独立的帐号密码
3. trust: 无密码

## password method(md5)
password method 使用独立的帐号，使用ROLE管理

# User Role

    psql DBNAME USERNAME
    psql -U user_name -d database_name -h 127.0.0.1 -W
        \W prompt enter password

## user login
### 通过cmd
Non interactive password:

1. vim ~/.pgpass:
    `hostname:port:database:username:password`
    支持通配符`hostname:port:*:username:password`
2. PGPASSWORD=pass1234 psql -U MyUsername myDatabaseName

### 通过URI
URI: https://www.postgresql.org/docs/current/static/libpq-connect.html#LIBPQ-CONNSTRING

pg:

    psql postgresql://
    psql postgresql://localhost
    psql postgresql://localhost:5433
    psql postgresql://localhost/mydb
    psql postgresql://user@localhost
    psql postgresql://user:secret@localhost
    psql postgresql://other@localhost/otherdb?connect_timeout=10&application_name=myapp
    psql 'postgresql://host1:123,host2:456/somedb?target_session_attrs=any&application_name=myapp'

    psql 'postgres://ahuigo.com:5432/dbname?sslmode=disable'

## create role/user
两种
1.$ createuser --interactive
2.psql: CREATE ROLE new_role_name;

    CREATE ROLE role_name WITH optional_permissions;

`create user` 默认带login 权限(唯一区别):

    # create 默认带login
    create user demo_role;
    # give ability to login in
    CREATE ROLE demo_role WITH LOGIN;

通过shell: creat super user

    sudo -u postgres createuser --superuser dbuser

### role with permission

    \h CREATE USER
    CREATE USER role1 with SUPERUSER CREATEROLE CREATEDB REPLICATION BYPASSRLS;

### password
By default, users are only allowed to login locally with the system username
如果用host 登录，则pg的帐号需要设定自己的密码：

    \password test_user

non interactive:

    ALTER USER postgres WITH PASSWORD 'newpassword';

### group user

    CREATE ROLE temporary_users;
    GRANT temporary_users TO demo_role;
    GRANT temporary_users TO test_user;
    > \z myTable
    > \du

       Role name    |                   Attributes                   |     Member of 
    ----------------------------------------------------------------------------------
    demo_role       |                                                | {temporary_users}
    temporary_users | Cannot login                                   | {}
    test_user       |                                                | {temporary_users}

Let a user the "inherit" group property with no need "set role" command:

    ALTER ROLE test_user INHERIT;

### swich role
    SET ROLE role_name;
    RESET ROLE;

比如如果你想用test_user, 或者用temporary_user 这个分组创建talble

    > set role temporary_user;
    > CREATE TABLE hello ( name varchar(25), start_date date); 
     Schema|      Name       |   Type   |      Owner
    -------+-----------------+----------+-----------------
    public | hello           | table    | temporary_users

### table role

    ALTER TABLE hello OWNER TO demo_role;

## delete role
    DROP ROLE role_name;
    DROP ROLE IF EXISTS role_name;

### rename role
ALTER ROLE name RENAME TO new_name

## query roles
current_user:

    SELECT current_user;

list roles

    \du

query table

    \z myTable

list of databases

    \l 

### default user
如果使用test1 帐号登录，psql 会默认以test1 连接数据库test1

    psql -d <dbname>
    psql -d postgres
    psql -d test1
    \conninfo

### super user
postgre 默认添加名为`postgres`的super user，到linux和postgre 帐户：

    sudo postgresql-setup initdb
    sudo su - postgres

# Role Attributes
list  role attr

    \du

## alter role attr

    \h ALTER ROLE
    ALTER ROLE role_name WITH attribute_options;
    ALTER ROLE demo_role WITH NOLOGIN;
    ALTER ROLE role1 WITH SUPERUSER;

# Permissions
## Grant Permissions
Grammar:
1. GRANT permission_type ON table_name TO role_name|PUBLIC;
1. GRANT permission_type ON DATABASE db_name TO role_name|PUBLIC;
2. GRANT role_name TO role_name [, ...] [ WITH ADMIN OPTION ]

hello：

    GRANT UPDATE ON demo TO demo_role;
    GRANT ALL ON demo TO demo_role;
    # to everyone
    GRANT INSERT ON demo TO PUBLIC;

To view the grant table

    \z

## remove permission
1. REVOKE permission_type ON table_name FROM user_name;