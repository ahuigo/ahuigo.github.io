# ddl
## connect

    clickhouse client -h host --port 3306 -u username --password password 
    clickhouse client -h host --port 3306 -u username --password password -d database
    dev_clk='clickhouse client -h host --port 3306 -u username --password password -d database'

### format vertical

    clickhouse-client --format=Vertical
    clickhouse-client --format=Pretty

不退出ClickHouse CLI，加`\G` 类似pg `\x`

    SELECT * FROM your_table LIMIT 5 \G

## cluster
查看分片数、副本

    SELECT cluster,shard_num,replica_num,host_name,host_address,port,is_local FROM system.clusters;
    SELECT * FROM system.clusters;
    ┌─cluster─────────┬─shard_num─┬─replica_num─┬─host_name─────host───┬─port─┬─is_local─┐
    │ default         │         1 │           1 │ svc1.local│ 10.2.1.5 │ 3003 │        1 │
    │ default_replica │         1 │           1 │ svc1.local│ 10.2.1.5 │ 3003 │        1 │
    解释：
    1. 可以看到使用了一个分片shard_num、一个副本shard_num=1
    2. default_replica 与　default_replica　ip相同，是同一个物理节点

get current cluser:

    # 指定连接的cluster
    clickhouse client --cluster mycluster;
    SELECT DISTINCT cluster FROM system.clusters WHERE is_local = 1;

### 查询副本的同步状态
在 ClickHouse 中，你可以使用 system.replicas 表来查询副本的同步状态。这个表包含了每个副本的详细信息，包括它的同步状态。

    SELECT database, table, is_leader, is_replica, future_parts, parts_to_check, queue_size, inserts_in_queue, merges_in_queue, log_max_index, log_pointer, total_replicas, active_replicas FROM system.replicas WHERE active = 1;

## database
    SHOW DATABASES;
    create database test;

show current database

    SELECT currentDatabase(); //default
    use test;
    SELECT currentDatabase(); //test

### drop
    drop database  IF EXISTS $DB;create database $DB;
## table
### list table
    SHOW TABLES FROM <database_name>;
    SELECT database, name AS table_name, engine, is_replicated FROM system.tables WHERE database = '<database_name>'

### create table
    CREATE TABLE test.orders (
        `OrderID` Int64, `CustomerID` Int64, 
        `OrderDate` DateTime, `Comments` String, `Cancelled` Bool) 
    ENGINE = MergeTree PRIMARY KEY (OrderID, OrderDate)
    ORDER BY (OrderID, OrderDate, CustomerID)
    SETTINGS index_granularity = 8192;

drop

    DROP TABLE database_name.table_name;
    DROP TABLE table_name;

# dump & restore
## dump

```
alias clickhouse-client="clickhouse-client -h <host> --port <port> -u <username> --password <password> "
alias clickhouse-client="./clickhouse client -h <host> --port 9000 -u <username> --password <password> "


OUTDIR=./tmp
mkdir -p $OUTDIR

while read -r db ; do
  while read -r table ; do

  if [ "$db" == "system" ]; then
     echo "skip system db"
     continue 2;
  fi

  if [[ "$table" == ".inner."* ]]; then
     echo "skip materialized view $table ($db)"
     continue;
  fi

  echo "export table $table from database $db"

    # dump schema
    clickhouse-client -q "SHOW CREATE TABLE ${db}.${table}" > "${OUTDIR}/${db}_${table}_schema.sql" --format=TSVRaw

    # dump 
    clickhouse-client -q "SELECT * FROM ${db}.${table} FORMAT TabSeparated" | pigz > "${OUTDIR}/${db}_${table}_data.tsv.gz"

  done < <(clickhouse-client -q "SHOW TABLES FROM $db") 
done < <(clickhouse-client -q "SHOW DATABASES")
```
### dump a database:
```
OUTDIR=./tmp
mkdir -p $OUTDIR

DATABASE_NAME=$db
rm $OUTDIR/database_schema.sql
TABLES=$(clickhouse-client --database=$DATABASE_NAME --query="SHOW TABLES")
while read -r TABLE; do
    echo "/* Table: $TABLE */" >> $OUTDIR/database_schema.sql
    clickhouse-client --database=$DATABASE_NAME --query="SHOW CREATE TABLE $TABLE" --format=TSVRaw| gsed -r "s/$DATABASE_NAME\.//g" >> $OUTDIR/database_schema.sql
    echo $';\n' >> $OUTDIR/database_schema.sql
done <<< $TABLES

```


## copy table
在目标实例云数据库ClickHouse中，通过如下SQL进行数据迁移。

    INSERT INTO <new_database>.<new_table> SELECT * FROM remote('old_endpoint', <old_database>.<old_table>, '<username>', '<password>');

20.8版本优先使用remoteRaw函数进行数据迁移，如果失败可以申请小版本升级。

    INSERT INTO <new_database>.<new_table> SELECT * FROM remoteRaw('old_endpoint', <old_database>.<old_table>, '<username>', '<password>');

## restore
-n 才支持multiple sql:

    clickhouse-client -n < "${OUTDIR}/${db}_${table}_schema.sql"
    cat "${OUTDIR}/${db}_${table}_schema.sql" | clickhouse-client -n 
