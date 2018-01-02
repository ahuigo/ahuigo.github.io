---
layout: page
title:
category: blog
description:
---
# Preface
- SQLAlchemy: ORM
- AioMysql
- Mysql and MysqlDB: 功能少
- SQLite

# SQLAlchemy：
为了将数据与属性名等信息关联，可以使用ORM,Object-Relational Mapping， 比较有名的就是 sqlalchemy

	pip install sqlalchemy

## 定义User, 并初始化DBSession：
```
# 导入:
from sqlalchemy import Column, String, create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

# 创建对象的基类:
Base = declarative_base()

# 定义User对象:
class User(Base):
    # 表的名字:
    __tablename__ = 'user'

    # 表的结构:
    id = Column(String(20), primary_key=True)
    name = Column(String(20))

# 初始化数据库连接: 数据库类型+数据库驱动名称://用户名:口令@机器地址:端口号/数据库名'
engine = create_engine('mysql+mysqlconnector://root:password@localhost:3306/test')
# 创建DBSession类型:
DBSession = sessionmaker(bind=engine)
```
以上代码完成SQLAlchemy的初始化和具体每个表的class定义。如果有多个表，就继续定义其他class，例如School：

```
class School(Base):
    __tablename__ = 'school'
    id = ...
    name = ...
create_engine()用来初始化数据库连接。SQLAlchemy用一个字符串表示连接信息：
```
## add user
由于有了ORM，我们向数据库表中添加一行记录，可以视为添加一个User对象：
```
# 创建session对象:
session = DBSession()
# 创建新User对象:
new_user = User(id='5', name='Bob')
# 添加到session:
session.add(new_user)
# 提交即保存到数据库:
session.commit()
# 关闭session 连接:
session.close()
```

## query user
如何从数据库表中查询数据呢？有了ORM，查询出来的可以不再是tuple，而是User对象。SQLAlchemy提供的查询接口如下：
```
# 创建Session:
session = DBSession()
# 创建Query查询，filter是where条件，最后调用one()返回唯一行，如果调用all()则返回所有行:
user = session.query(User).filter(User.id=='5').one()
# 打印类型和对象的name属性:
print('type:', type(user))
print('name:', user.name)
# 关闭Session:
session.close()
运行结果如下：

type: <class '__main__.User'>
name: Bob
```

可见，ORM就是把数据库表的行与相应的对象建立关联，互相转换。

## 一对多
由于关系数据库的多个表还可以用外键实现一对多、多对多等关联，相应地，ORM框架也可以提供两个对象之间的一对多、多对多等功能。

例如，如果一个User拥有多个Book，就可以定义一对多关系如下：

```
class User(Base):
    __tablename__ = 'user'

    id = Column(String(20), primary_key=True)
    name = Column(String(20))
    # 一对多:
    books = relationship('Book')

class Book(Base):
    __tablename__ = 'book'

    id = Column(String(20), primary_key=True)
    name = Column(String(20))
    # “多”的一方的book表是通过外键关联到user表的:
    user_id = Column(String(20), ForeignKey('user.id'))
```
当我们查询一个User对象时，该对象的books属性将返回一个包含若干个Book对象的list。

## two simple modles
two simple models question and choice: http://aiohttp.readthedocs.io/en/stable/tutorial.html#database
```
import sqlalchemy as sa

meta = sa.MetaData()

question = sa.Table(
    'question', meta,
    sa.Column('id', sa.Integer, nullable=False),
    sa.Column('question_text', sa.String(200), nullable=False),
    sa.Column('pub_date', sa.Date, nullable=False),

    # Indexes #
    sa.PrimaryKeyConstraint('id', name='question_id_pkey'))

choice = sa.Table(
    'choice', meta,
    sa.Column('id', sa.Integer, nullable=False),
    sa.Column('question_id', sa.Integer, nullable=False),
    sa.Column('choice_text', sa.String(200), nullable=False),
    sa.Column('votes', sa.Integer, server_default="0", nullable=False),

    # Indexes #
    sa.PrimaryKeyConstraint('id', name='choice_id_pkey'),
    sa.ForeignKeyConstraint(['question_id'], [question.c.id],
                            name='choice_question_id_fkey',
                            ondelete='CASCADE'),
)
```

# aiomysql
see [/demo/aiomysql](/demo/py-app/orm.py)
```
async def create_pool(loop, **kw):
    logging.info('create database connection pool...')
    global __pool
    __pool = await aiomysql.create_pool(
        host=kw.get('host', 'localhost'),
        port=kw.get('port', 3306),
        user=kw['user'],
        password=kw['password'],
        db=kw['db'],
        charset=kw.get('charset', 'utf8'),
        autocommit=kw.get('autocommit', True),
        maxsize=kw.get('maxsize', 10),
        minsize=kw.get('minsize', 1),
        loop=loop
    )
```


# SQLite
SQLite是一种嵌入式数据库，它的数据库就是一个文件。由于SQLite本身是C写的，而且体积很小，所以，经常被集成到各种应用程序中，甚至在iOS和Android的App中都可以集成。

在使用SQLite前，我们先要搞清楚几个概念：

1. 表是数据库中存放关系数据的集合，一个数据库里面通常都包含多个表，比如学生的表，班级的表，学校的表，等等。表和表之间通过外键关联。
2. 要操作关系数据库，首先需要连接到数据库，一个数据库连接称为Connection；
3. 连接到数据库后，需要打开游标，称之为Cursor，通过Cursor执行SQL语句，然后，获得执行结果。

Python定义了一套操作数据库的API接口，任何数据库要连接到Python，只需要提供符合Python标准的数据库驱动即可:
	由于SQLite的驱动内置在Python标准库中，所以我们可以直接来操作SQLite数据库。

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
>>> conn = sqlite3.connect('test.db')
>>> cursor = conn.cursor()

>>> cursor.execute('select * from user where id=?', '1')
<sqlite3.Cursor object at 0x10f8aa340>

>>> values = cursor.fetchall()
[('1', 'Michael')]

>>> cursor.close()
>>> conn.close()
```

使用Python的DB-API时，只要搞清楚Connection和Cursor对象，打开后一定记得关闭，就可以放心地使用。
1. 使用Cursor对象执行`insert，update，delete`语句时，执行结果由`cursor.rowcount`返回影响的行数，就可以拿到执行结果。
2. 使用Cursor对象执行`select`语句时，通过`featchall()`可以拿到结果集。结果集是一个`list`，每个元素都是一个`tuple`，对应一行记录。

如果SQL语句带有参数，那么需要把参数按照位置传递给execute()方法，有几个?占位符就必须对应几个参数，例如：

	cursor.execute('select * from user where id=?', '1')

如何才能确保出错的情况下也关闭掉Connection对象和Cursor对象呢？请回忆try:...except:...finally:...的用法。

# Mysql
SQLite的特点是轻量级、可嵌入，但不能承受高并发访问，适合桌面和移动应用。而MySQL是为服务器端设计的数据库，能承受高并发访问，同时占用的内存也远远大于SQLite。

## 安装MySQL驱动
由于MySQL服务器以独立的进程运行，并通过网络对外服务，所以，需要支持Python的MySQL驱动来连接到MySQL服务器。MySQL官方提供了mysql-connector-python驱动，

	pip3 install mysql-connector-python

## use mysql
我们演示如何连接到MySQL服务器的test数据库：

```
	# 导入MySQL驱动:
	>>> import mysql.connector
	# 注意把password设为你的root口令:
	>>> conn = mysql.connector.connect(user='root', password='password', database='test')
	>>> cursor = conn.cursor()
	# 创建user表:
	>>> cursor.execute('create table user (id varchar(20) primary key, name varchar(20))')
	# 插入一行记录，注意MySQL的占位符是%s:
	>>> cursor.execute('insert into user (id, name) values (%s, %s)', ['1', 'Michael'])
	>>> cursor.rowcount
	1
	# 提交事务:
	>>> conn.commit()
	>>> cursor.close()
	# 运行查询:
	>>> cursor = conn.cursor()
	>>> cursor.execute('select * from user where id = %s', ['1'])
	>>> values = cursor.fetchall()
	>>> values
	[('1', 'Michael')]
	# 关闭Cursor和Connection:
	>>> cursor.close()
	True
	>>> conn.close()
```

由于Python的DB-API定义都是通用的，所以，操作MySQL的数据库代码和SQLite类似。

## return Grammar
如果要返回k=>v这种格式的数据

	cursor = conn.cursor(dictionary=True)