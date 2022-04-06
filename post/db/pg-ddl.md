---
title: Posstgre shell+ddl
date: 2018-09-27
private:
---
# shell

## connect pg
首次安装后，默认数据库是postgres

    psql postgres

### shell 参数
默认同时支持 unix domain socket + ip/port net socket

    psql DBNAME USERNAME
    psql -U user_name -d database_name -h 127.0.0.1 -W
    psql -U user_name database_name -h 127.0.0.1 -W
        \W prompt enter password(可省略)
    psql postgresql://t1:1@47.96.1.162:6379/template1

### Non interactive password:

1. vim ~/.pgpass:
    `hostname:port:database:username:password`
2. PGPASSWORD=pass1234 psql -U MyUsername myDatabaseName
3. URI: https://www.postgresql.org/docs/current/static/libpq-connect.html#LIBPQ-CONNSTRING

e.g.

    psql postgresql://
    psql postgresql://user:secret@localhost:5432/mydb
    psql postgresql://other@localhost/otherdb?connect_timeout=10&application_name=myapp
    psql postgresql://host1:123,host2:456/somedb?target_session_attrs=any&application_name=myapp

.pgpass config(recommend):

    1) Create .pgpass file with content
        host:5432:somedb:someuser:somepass

    2) set the permissions using command
        sudo chmod 600 .pgpass

    3) Set the file owner as the same user using which you logged in(实际不需要) :
        sudo chown login_username:login_username .pgpass

    4) Set PGPASSFILE environment variable :
        export PGPASSFILE='/home/user/.pgpass'

    Now check by connecting to database :
        psql -h host -U someuser somedb

## exec sql

    $ psql -h 127.0.0.1 -p 5930 -c "select 1"
    $ psql -h 127.0.0.1 -p 5930 -f a.sql

### exec sql file
    psql -f exec.sql
    pg_dump dbname > outfile

    psql [dbname] < exec.sql
    cat exec.sql | psql [dbname] 


# import export
## pg_dump
    pg_dump help

### backup binary
tar 包更大

    pg_dump -Fc database_name_here > database.bak # compressed binary format
    pg_dump -Ft database_name_here > database.tar # tarball

Restore if database exists:

    pg_restore -Fc database.bak # restore compressed binary format
    pg_restore -Ft database.tar # restore tarball

Restore auto create database(-C)：

    # 指定-d any_db 是用于初始化连接db
    pg_restore -d any_db -Fc -C database.bak # restore compressed binary format
    pg_restore -d any_db -Ft -C database.tar # restore tarball

Restore to db1

    pg_restore -d db1 -Fc -C database.bak

### backup

    # only schema(-s)
    pg_dump -U db_username -s  -f [filename.sql] [db_name]
    # only data(-a)
    pg_dump -U db_username -a  -f [filename.sql] [db_name]
    # spcify table(-t)
    pg_dump -U db_username -t table_name -a  -f [filename.sql] [db_name]
    # data+schema(null)
    pg_dump                      -f [filename.sql] [db_name]

    -F format
        -Fc custom, Output a custom-format archive suitable for input
        -Fp plain 默认
    -U username

恢复：

    cat  filename.sql | psql  -U db_username

### restore
https://www.postgresql.org/docs/9.2/app-pgrestore.html

只用于自定的数据的恢复

    $ pg_dump -Fc mydb > db.dump
    $ dropdb mydb
    $ pg_restore -C -d postgres db.dump

custom-format archive:

    # schema
    pg_restore -s -d [db_name] [filename.sql]
    # data
    pg_restore -a -d [db_name] [filename.sql]
    # schema and data
    pg_restore -d [db_name] [filename.sql]

## copy db/table/result
### export db

    $ pg_dump -U username dbname > dbexport.pgsql
    $ psql -U username dbname < dbexport.pgsql

### export table:

    \copy my_table to 'my_table.csv' csv;
    \copy my_table FROM 'my_table.csv' DELIMITER ',' CSV;

### export table with bash:

    $ pg_dump \
    -h localhost \
    -p 5432 \
    -U user -W \
    --table="table-name" --data-only --column-inserts database-name > table.sql

    $ psql \
    -h localhost \
    -p 5432 \
    -U user \
    database-name \
    -f table.sql

### export sql result
copy (sql) to './out.csv' csv header;

    \copy (select * from my_table limit 10) TO './a.csv'; -- 空格分割
    \copy (select * from my_table limit 10) TO './a.csv' CSV ; -- CSV 分割
    \copy (select * from my_table limit 10) TO './a.csv' CSV HEADER
    \copy (select * from my_table limit 10) TO '~/Downloads/export.csv' CSV HEADER;
    copy (select * from my_table limit 10) TO stdout;

表：

    \COPY products_273 TO '/tmp/products_199.csv' WITH (FORMAT CSV, HEADER);
    COPY persons TO 'C:\tmp\persons_db.csv' DELIMITER ',' CSV HEADER;
    COPY persons(first_name,last_name,email) TO 'C:\tmp\persons_partial_db.csv' DELIMITER ',' CSV HEADER;

导入：

    COPY tmp_table (name, email) FROM './a.csv' DELIMITER ' ' CSV;

help: 

    \h copy

## import data
    psql dbname < tracks.sql
    DETAIL:  Key (id)=(25344571) already exists.

此时可以建立临时表，利用临时表去重后再导入数据

    # create tmp_table (基于旧表)
    CREATE TEMP TABLE tmp_table AS SELECT * FROM tracks;

    # import data
    COPY tmp_table (name, email) FROM stdin DELIMITER ' ' CSV;
    COPY tmp_table (name, email) FROM './a.csv' DELIMITER ' ' CSV;

    # clear table
    TRUNCATE tracks;
    # import unique data
    INSERT INTO tracks
        SELECT DISTINCT ON (email) * FROM tmp_table
        ORDER BY email, subscription_status;

# help
`\h CREATE ROLE`
`\? \l`

# crud
## database
help:

    \h alter DATABASE

create:

    $ createdb test1
    $ createdb -h pg.ahuigo.com -U postgres users_dev -p 5432
    > CREATE DATABASE ahuigo;
    > CREATE DATABASE yuzhi100 OWNER myuser;

drop db:

    $ dropdb -h host -p 5432 $dbname -U username
    > drop database <dbname>

rename db:

    ALTER DATABASE name RENAME TO new_name

list db:

    \l
        list all databases

### connect db:

    \c database_name
        \connect database_name

### current database

    SELECT current_database();

## table
### list all table 
in current database

    DO $$ 
      DECLARE 
        r RECORD;
    BEGIN
      FOR r IN 
        (
          SELECT table_name 
          FROM information_schema.tables 
          WHERE table_schema=current_schema()
        ) 
      LOOP
         EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.table_name) || ' CASCADE';
      END LOOP;
    END $$ ;

### show table scheme
describe table and sequence:

    \d
    \dt # with table_squence
    \dt [<table>]

show create table(只能用命令行): 利用pgdump  输出

    pg_dump -st tablename dbname
    pg_dump -st tablename dbname -h host -U username -p port 

    # 说明：-s 代理scheme only, -t 指定table

### create

    $ psql -f init.sql
    create table myusers(
        id serial primary key, 
        name varchar, 
        age int
    );
    CREATE TABLE playground (
        id serial PRIMARY KEY,
        uid int UNIQUE,
        name varchar (50) NOT NULL,
        location varchar(25) check (location in ('north', 'south', 'west', 'east',  'northwest')),
        install_date date
    );

#### create table as
create table :

    CREATE TABLE films_recent AS
        SELECT * FROM films WHERE date_prod >= '2002-01-01';

create temp table:
1.automatically drops the temporary tables at the end of a session or a transaction.
2.The TEMP and TEMPORARY keywords are equivalent

    CREATE TEMP TABLE uid_tmp AS 
        SELECT id FROM users where id<10;

#### show create table

    pg_dump -st tablename dbname

#### copy table struture
    CREATE TEMP TABLE tmp_table AS SELECT * FROM tracks;
    CREATE TABLE tmp_table AS SELECT * FROM tracks;

#### create view table
	create view t_view as
		select s1,s2,t1.id from t1,t2 where t1.id=t2.id order by s2;

	create view t_view_alias (seg1, seg2, id) as
		select s1,s2,t1.id from t1,t2 where t1.id=t2.id order by s2;

### rename table
    ALTER TABLE table_name RENAME TO new_table_name;
### drop

    drop TABLE [IF EXISTS ] xxx
    drop TABLE xxx1,xx2

## Alter
ALTER TABLE table_name `<action>`:

    column:
        ADD COLUMN column_name VARCHAR [not null  default 3];
        DROP COLUMN column_name;
        ALTER COLUMN location TYPE VARCHAR,
            ALTER COLUMN asset_no TYPE INT USING asset_no::integer;
            ALTER COLUMN column_name [SET DEFAULT value | DROP DEFAULT]
            ALTER COLUMN column_name [SET NOT NULL| DROP NOT NULL]
        RENAME COLUMN column_name TO new_column_name;

    check:
        ADD CHECK (target IN ('_self', '_blank', '_parent', '_top'));
    tablename:
        RENAME TO new_table_name;
    constraint:
        ADD CONSTRAINT constraint_name constraint_definition

### default value
To set a new default for a column, use a command like:

    ALTER TABLE products ALTER COLUMN price SET DEFAULT 7.77;

To remove any default value, use:

    ALTER TABLE products ALTER COLUMN price DROP DEFAULT;

### add/del column
    ALTER TABLE player drop id;
    ALTER TABLE player drop column id;
    ALTER TABLE player ADD COLUMN id SERIAL PRIMARY KEY;

    Alter table domains add column "desc" text not null default '';

### alter column
    \h alter TABLE
    ALTER TABLE player ALTER COLUMN TYPE data_type;
    ALTER TABLE the_table ALTER COLUMN col_name TYPE integer USING (col_name::integer);


### autoincrement
删除id, 再重建

    ALTER TABLE player drop column id;
    ALTER TABLE player ADD COLUMN id SERIAL PRIMARY KEY;

也可不删除id, 创建自增序列：

    create sequence player_id_seq;
    alter table player alter playerid set default nextval('player_id_seq');
    Select setval('player_id_seq', 2000051 ); --set to the highest current value of playerID

#### 修改autoincrement id
id seq　一般保存在`<table>_id_seq`中，可以通过`\d`查看, 或者：

    # nextval
    SELECT nextval('oauth_tokens_id_seq'::regclass);  -- 每次insert 就是调用的insert id values(nextval)
    # 当前的val
    select currval('oauth_tokens_id_seq');
    select last_value from oauth_tokens_id_seq;

setval 用法：

    SELECT setval('users_id_seq', 42);           Next nextval will return 43
    SELECT setval('users_id_seq', 42, true);     Same as above
    ALTER SEQUENCE users_id_seq RESTART WITH 42; Same as above
    SELECT setval('users_id_seq', 42, false);    Next nextval will return 42

一键完成:

    // method2(推荐)
    select setval('oauth_tokens_id_seq', (select max(id) from oauth_tokens));

动态添加：


    do $$
    declare
        table_name  varchar:= 'task_checks';
    begin
        PERFORM setval(table_name||'_id_seq',(select max(id) from task_checks));
    end $$;

#### add increment id(serial)
	// alter table mytable add column item_id serial;
	// 相当于
	// CREATE SEQUENCE mytable_item_id_seq OWNED BY mytable.item_id;
	// ALTER TABLE mytable ALTER item_id SET DEFAULT nextval('mytable_item_id_seq');