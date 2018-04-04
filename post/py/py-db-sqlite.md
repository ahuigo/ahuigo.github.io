# SQLite
SQLite是一种嵌入式数据库，它的数据库就是一个文件。由于SQLite本身是C写的，而且体积很小，所以，经常被集成到各种应用程序中，甚至在iOS和Android的App中都可以集成。

1. 连接到数据库后，需要打开游标，称之为Cursor，通过Cursor执行SQL语句，然后，获得执行结果。


我们在Python交互式命令行实践一下：
```
	# 导入SQLite驱动:
	>>> import sqlite3

	# 连接到SQLite数据库
	# 数据库文件是test.db
	# 如果文件不存在，会自动在当前目录创建:
	>>> conn = sqlite3.connect('test.db')
	# 创建一个Cursor:
	>>> cursor = conn.cursor()

	# 执行一条SQL语句，创建user表:
	>>> cursor.execute('create table user (id varchar(20) primary key, name varchar(20))')
	<sqlite3.Cursor object at 0x10f8aa260>

	# 继续执行一条SQL语句，插入一条记录:
	>>> cursor.execute('insert into user (id, name) values (\'1\', \'Michael\')')
	<sqlite3.Cursor object at 0x10f8aa260>
	# 通过rowcount获得插入的行数:

	>>> cursor.rowcount
	1
	# 关闭Cursor:
	>>> cursor.close()
	# 提交事务:
	>>> conn.commit()
	# 关闭Connection:
	>>> conn.close()
```

我们再试试查询记录：

    ```
    conn = sqlite3.connect('test.db')
    cursor = conn.cursor()
    cursor.execute('select * from user where id=?', '1')
    >>> cursor.fetchall()
    [('1', 'Michael')]

    >>> cursor.close()
    >>> conn.close()
    ```

使用Python的DB-API时，只要搞清楚Connection和Cursor对象，打开后一定记得关闭，就可以放心地使用。
1. `cursor.rowcount`返回影响的行数:`insert，update，delete`
3. 如果SQL语句带有占位位参数:


如何才能确保出错的情况下也关闭掉Connection对象和Cursor对象呢？请回忆try:...except:...finally:...的用法。

## insert many

	cursor.execute('select * from user where id=1')
	cursor.execute('select * from user where id=?', 1); # '123' 会被当成数组
	cursor.execute('select * from user where id=?, name=?', ('1', 'name'))

### insert many

    purchases = [('2006-03-28', 'BUY', 'IBM', 1000, 45.00),
                ('2006-04-05', 'BUY', 'MSFT', 1000, 72.00),
                ]
    c.executemany('INSERT INTO stocks VALUES (?,?,?,?,?)', purchases)


## fetch
2. `featchall()`结果集是一个`list`，每个元素都是一个`tuple`，对应一行记录:`select`
2. cur.fetchone()[0]

### fetch with dict

	def dict_factory(cursor, row):
		d = {}
		for idx, col in enumerate(cursor.description):
			d[col[0]] = row[idx]
		return d

	con.row_factory = dict_factory

## executescript

    import sqlite3
    db = sqlite3.connect('test.db')

    sqls = '''
        drop table if exists entries;
        create table entries (
            id integer primary key autoincrement,
            title text not null,
            'text' text not null);
        '''
    db.cursor().executescript(sqls)
    db.commit()