---
title: Postgre User and Authentication
date: 2018-09-27
---
# Postgre User and Authentication
vim /var/lib/pgsql/10/data/pg_hba.conf

    host    all             all             127.0.0.1/32            md5
    host    all             all             0.0.0.0/0               md5

auth method:
1. Peer : use kernel os system user name, only supported on local connections.
2. indent:  client's operating system user name, only supported on TCP/IP connections,  *for a local (non-TCP/IP) connection, peer is used instead*
3. password: 独立的帐号密码

## password method(md5)
password method 使用独立的帐号，使用ROLE管理

# User Role

    psql DBNAME USERNAME
    psql -U user_name -d database_name -h 127.0.0.1 -W
        \W prompt enter password

Non interactive password:

1. vim ~/.pgpass:
    `hostname:port:database:username:password`
    支持通配符`hostname:port:*:username:password`
2. PGPASSWORD=pass1234 psql -U MyUsername myDatabaseName
3. URI: https://www.postgresql.org/docs/current/static/libpq-connect.html#LIBPQ-CONNSTRING


    psql postgresql://
    psql postgresql://localhost
    psql postgresql://localhost:5433
    psql postgresql://localhost/mydb
    psql postgresql://user@localhost
    psql postgresql://user:secret@localhost
    psql postgresql://other@localhost/otherdb?connect_timeout=10&application_name=myapp
    psql postgresql://host1:123,host2:456/somedb?target_session_attrs=any&application_name=myapp

## create
两种
1.$ createuser --interactive
2.psql: CREATE ROLE new_role_name;

    CREATE ROLE role_name WITH optional_permissions;

`create user` 默认带login 权限(唯一区别):

    create user demo_role
    # give ability to ligin in
    CREATE ROLE demo_role WITH LOGIN;

通过shell: creat super user

    sudo -u postgres createuser --superuser dbuser

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


## delete
DROP ROLE role_name;
DROP ROLE IF EXISTS role_name;

## alter

    ALTER ROLE role_name WITH attribute_options;
    ALTER ROLE demo_role WITH NOLOGIN;

## query roles

    \du

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

# Grant Permissions
1. GRANT permission_type ON table_name TO role_name|PUBLIC;
1. GRANT permission_type ON DATABASE db_name TO role_name|PUBLIC;
2. REVOKE permission_type ON table_name FROM user_name;

hello：

    GRANT UPDATE ON demo TO demo_role;
    GRANT ALL ON demo TO demo_role;
    # to everyone
    GRANT INSERT ON demo TO PUBLIC;

To view the grant table

    \z