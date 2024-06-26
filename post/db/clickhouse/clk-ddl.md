# ddl
## connect

    clickhouse client -h host --port 3306 -u username --password password 
    clickhouse client -h host --port 3306 -u username --password password -d database
    dev_clk='clickhouse client -h host --port 3306 -u username --password password -d database'

## database
    SHOW DATABASES;
    create database test;

show current database

    SELECT currentDatabase(); //default
    use test;
    SELECT currentDatabase(); //test

## table
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
