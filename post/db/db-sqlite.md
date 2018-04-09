# shell command
$ sqlite3

## import db
sqlite3 /tmp/flaskr.db < schema.sql

## client

### .show 默认配置

    sqlite>.show
        echo: off
    explain: off
    headers: off
        mode: column
    nullvalue: ""
    output: stdout
    separator: "|"
        width:
    sqlite>

### 格式化

    sqlite>.header on
    sqlite>.mode column
    sqlite>.timer on
    sqlite>

上面设置将产生如下格式的输出：

    ID          NAME        AGE         ADDRESS     SALARY
    ----------  ----------  ----------  ----------  ----------
    1           Paul        32          California  20000.0
    2           Allen       25          Texas       15000.0
    3           Teddy       23          Norway      20000.0
    CPU Time: user 0.000000 sys 0.000000

### sqlite_master 表格
主表 sqlite_master 中保存数据库表的关键信息

    sqlite>.schema sqlite_master
    CREATE TABLE sqlite_master (
    type text,
    name text,
    tbl_name text,
    rootpage integer,
    sql text
    );

## 语法
### 注释
sqlite>.help -- This is a single line comment
sqlite>.help /* This is a single line comment */
### 结尾
所有的语句以分号（;）结束。命令.help，.show 等则不需要


## CRUD
### update 
默认编译的版本 update 不支持limit. 不过可以这样:

    UPDATE tbl_data SET ... limit 1; # wrong
    UPDATE tbl_data SET ... WHERE rowid IN (SELECT rowid
                    FROM tbl_data
                    WHERE ...
                    ORDER BY ...
                    LIMIT 1)

## DDL

### rename column
rename "colb" to "col_b":


    ALTER TABLE orig_table_name RENAME TO tmp_table_name;

    CREATE TABLE orig_table_name (
        col_a INT
        , col_b INT
    );

    INSERT INTO orig_table_name(col_a, col_b)
        SELECT col_a, colb FROM tmp_table_name;

    DROP TABLE tmp_table_name;

Wrapping all this in a `BEGIN TRANSACTION; and COMMIT;` is also probably a good idea.