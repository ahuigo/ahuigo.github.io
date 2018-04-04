# help
http://initd.org/psycopg/docs/cursor.html

# conn

    conn = psycopg2.connect(database="testdb", user="postgres", password="pass123", host="127.0.0.1", port="5432")
    conn.set_session(readonly=True, autocommit=True)

# cursor

    curosr.executemany(sql, seq_of_parameters)
    curosr.callproc(procname[, parameters])
    cursor.rowcount
    cursor.connection.rollback()
    cursor.connection.commit()
    cur.query # return sql query string

## execute
cursor：execute, conn.commit,close 查询fetch 如果没有修改数据，不需要commit

### bind params
1. 关键字用：sql.Identifier
2. 普通数据先自己用%s 拼好，再bind_param
execute 支持变量绑定

    >>> SQL = "INSERT INTO authors (name) VALUES (%s);" # Note: no quotes
    >>> data = ("O'Reilly", )
    >>> cur.execute(SQL, data) # Note: no % operator

table name 这些则不支持，应该使用:

    # This works, but it is not optimal
    cur.execute(
        "insert into %s values (%%s, %%s)" % ext.quote_ident('table_name'),
        [10, 20])

推荐使用:

    from psycopg2 import sql
    cur.execute(
        sql.SQL("insert into {} values (%s, %s)") .format(sql.Identifier('my_table')),
        [10, 20])

## select fetch

### fetch iter

    for row in cur: print(row)

### fetchall

    cur = conn.cursor()
    cur.execute("SELECT id, name, address, salary from COMPANY")
    for row in cur.fetchall()

other:

    cursor.fetchone()
    cursor.fetchmany([size=cursor.arraysize])