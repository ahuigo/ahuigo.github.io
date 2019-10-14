---
title: help
date: 2018-09-28
---
# help
http://initd.org/psycopg/docs/cursor.html

# psycopg2
## conn

    import psycopg2
    import psycopg2.extras
    conn = psycopg2.connect(database="testdb", user="postgres", password="pass123", host="127.0.0.1", port="5432")
    conn.set_session(readonly=True, autocommit=True)
    # cursor = conn.cursor()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        row = cursor.fetchone()
        row[0],row['id'] 都可以

## cursor
postgre 是用cusor 去执行+缓存数据

    cursor.executemany(sql, seq_of_parameters)
    cursor.callproc(procname[, parameters])
    cursor.rowcount
    cursor.connection.rollback()
    cursor.connection.commit()
    cur.query # return sql query string

### execute insert
cursor.execute, conn.commit,close 查询fetch 
如果没有修改数据，不需要commit

    cursor.execute("insert into  prices values(%s,%s,%s)", ['20170930', 'sh0001', 10.0])

#### exception
execute 永远返回None.
如果异常，你需要手动try-catch(上层做、底层做，完全看业务需求)

#### batch execute
executemany(recommend):

    tup = [(1,'x'), (2,'y')]
    cur.executemany("INSERT INTO table VALUES(%s,%s,)", tup)

method2:

    args_str = ','.join(cur.mogrify("(%s,%s,)", x) for x in tup)
    cur.execute("INSERT INTO prices VALUES " + args_str) 

method3:

    data = [(1,'x'), (2,'y')]
    insert_query = 'insert into t (a, b) values %s'
    psycopg2.extras.execute_values (
        cursor, insert_query, data, template=None, page_size=100
    )

#### bind params
1. 关键字用：sql.Identifier
2. 普通数据先自己用%s 拼好，再bind_param

execute 支持变量绑定: %s 针对任何类型

    >>> SQL = "INSERT INTO authors (name) VALUES (%s);" # Note: no quotes
    >>> data = ("O'Reilly", )
    >>> cur.execute(SQL, data) # Note: no % operator

table name 这些则不支持，应该使用:

    # This works, but it is not optimal
    cur.execute( "insert into %s values (%%s, %%s)" % ext.quote_ident('table_name'), [10, 20])

推荐使用:

    from psycopg2 import sql
    cur.execute( sql.SQL("insert into {} values (%s, %s)") .format(sql.Identifier('my_table')), [10, 20])

### select fetch

#### cur.query
    >>> cur.execute("INSERT INTO test (num, data) VALUES (%s, %s)", (42, 'bar'))
    >>> print(cur.query)
    "INSERT INTO test (num, data) VALUES (42, E'bar')"

#### fetch iter

    cur.execute("SELECT id, name, address, salary from COMPANY")
    for row in cur: print(row)

#### fetchall

    cur = conn.cursor()
    cur.execute("SELECT id, name, address, salary from COMPANY")
    for row in cur.fetchall()

#### fetchall as dataframe
    DataFrame(cur.fetchall(), columns=['instrument', 'price', 'date'])

#### fetchone,fetchmany:

    row = cursor.fetchone()
    rows = cursor.fetchmany([size=cursor.arraysize])
    if row is None:
    if rows == []:

## ddl
### databases
    \l
    cursor.execute('SELECT datname FROM pg_database;')

### tables
    \dt
    cursor.execute("""SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'""")
    for table in cursor.fetchall():
        print(table)

## import

    cur = conn.cursor()
    cur.copy_from(open('a.csv'), 'table_name', null="", columns=df.keys()) # null values become ''
    conn.commit()

copy_to

    cur.copy_to(open('out.csv','w'), 'table')

