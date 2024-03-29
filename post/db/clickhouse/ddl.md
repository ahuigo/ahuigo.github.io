# dump

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

## copy table
在目标实例云数据库ClickHouse中，通过如下SQL进行数据迁移。

    INSERT INTO <new_database>.<new_table> SELECT * FROM remote('old_endpoint', <old_database>.<old_table>, '<username>', '<password>');

20.8版本优先使用remoteRaw函数进行数据迁移，如果失败可以申请小版本升级。

    INSERT INTO <new_database>.<new_table> SELECT * FROM remoteRaw('old_endpoint', <old_database>.<old_table>, '<username>', '<password>');

# restore
    clickhouse-client -n < "${OUTDIR}/${db}_${table}_schema.sql"
    cat "${OUTDIR}/${db}_${table}_schema.sql" | clickhouse-client -n 

## grant 
    GRANT ALL ON *.* TO default WITH GRANT OPTION
    GRANT ALL ON mydb.* TO default WITH GRANT OPTION
    GRANT ALL ON mydb.mytable TO user1;

### copy role to user

    GRANT  role [,...] TO {user | another_role | CURRENT_USER} 
    GRANT  privilege[(column_name [,...])]  ON {db.table|db.*|*.*|table|*} TO {user | role | CURRENT_USER} ;


### grant table
    GRANT SELECT(timestamp, env, serviceName, httpCode, count) ON mydb.mytable TO 'user1'
### grant table:select
    GRANT SELECT(timestamp, env, serviceName, httpCode, count) ON mydb.mytable TO 'user1'

