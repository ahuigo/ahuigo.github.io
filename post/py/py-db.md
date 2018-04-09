---
layout: page
title:
category: blog
description:
---
# Preface
- SQLAlchemy: ORM 重量级 见雪峰老师的教程, filter(User.id==5)
- peewee: 极简ORM https://www.oschina.net/translate/sqlalchemy-vs-orms
- AioMysql
- Mysql and MysqlDB: 功能少
- SQLite

## Peewee
http://docs.peewee-orm.com/en/latest/peewee/quickstart.html

	from peewee import *

	db = SqliteDatabase('people.db')

    from playhouse.pool import PooledPostgresqlExtDatabase
    db = PooledPostgresqlExtDatabase(
        'my_database',
        max_connections=8,
        stale_timeout=300,
        user='postgres')

	class Person(Model):
		name = CharField()
		birthday = DateField()
		is_relative = BooleanField()
		class Meta:
			database = db # This model uses the "people.db" database.

	# person.pets 反向引用 backref='pets'
	class Pet(Model):
		owner = ForeignKeyField(Person, backref='pets')
		name = CharField()
		animal_type = CharField()
		class Meta:
			database = db # this model uses the "people.db" database

	# auto connect
	db.connect()

### create table
    if not Person.table_exists():
        # Person.create_table()
        Person._meta.database.create_tables([Person, Pet])
    with db.atomic() as tr:
        data = [{'name':'ahui'}]
        Person.insert_many(data).upsert().execute()

### pure sql
Peewee returns a cursor. Then you can use the db-api 2 to iterate over it:

	db = Tweets._meta.database
	cursor = db.execute_sql('select * from tweets where id=%s;', [123])
	for row in cursor.fetchall():
		print row

	cursor = db.execute_sql('select count(*) from tweets;')
	res = cursor.fetchone()
	print 'Total: ', res[0]

### insert.execute()
返回affected rows num

	User.insert(username='Mickey').execute()
	User.create(username='Charlie')
    #以下 这个无效, 不要用
	User(username='Bob').save() 

### delete.execute()

	Member.delete().where(Member.memid > 37).execute()
	Stock.get(Stock.id=='1002').delete_instance()

### update.execute()

	(Facility.update(num=10000)
			.where(Facility.name == 'Tennis Court 2'))
			.execute()

### select
select
	
	for person in Person.select(Person.name):
	for person in Person.select():
		print person.name, person.is_relative

where: Facility.select().where

	.where((Person.birthday < d1940) | (Person.birthday > d1960)))
		.where(Person.birthday.between(d1940, d1960)))

	# where facid IN (1, 5);
	.where(Facility.facid.in_([1, 5]))
	.where((Facility.facid == 1) | (Facility.facid == 5))

	# and or
	.where( (Facility.membercost > 0) &
             (Facility.membercost < (Facility.monthlymaintenance / 50))))

	# name like '%tennis%'
	.where(Facility.name ** '%tennis%')

get: fetchone()

	person = Person.select().where(Person.name == 'Grandma L.').get()
	person = Person.get(Person.name == 'Grandma L.')

join: selecting both Pet and Person, and adding a join.

	query = (Pet .select(Pet, Person) .join(Person)
			.where(Pet.animal_type == 'cat'))

	for pet in query:
		print pet.name, pet.owner.name

sort:

	for pet in Pet.select().where(Pet.owner == uncle_bob).order_by(Pet.name):
	for person in Person.select().order_by(Person.birthday.desc()):

result to dict:

	query = User.select()
	[row.__data__ for row in query]

	User.get().__data__

DoesNotExist:

    try:
        rtn = User.get(User.id==id).__data__
    except User.DoesNotExist as e:

### delete

	grandma.delete_instance() # return delete row number

### Aggregates and Prefetch
owner = ForeignKeyField(Person, backref='pets')

	for person in Person.select():
		print person.name, person.pets.count(), 'pets'

Once again we’ve run into a classic example of *N+1* query behavior. 
1. In this case, we’re executing an additional query for every Person returned by the original SELECT! 
2. We can avoid this by performing a JOIN and using a SQL function to aggregate the results.

	query = (Person
			.select(Person, fn.COUNT(Pet.id).alias('pet_count'))
			.join(Pet, JOIN.LEFT_OUTER)  # include people without pets.
			.group_by(Person)
			.order_by(Person.name))

	for person in query:
		# "pet_count" becomes an attribute on the returned model instances.
		print person.name, person.pet_count, 'pets'

	# prints:
	# Bob 2 pets
	# Grandma L. 0 pets
	# Herb 1 pets

if we were to do a `join` from `Person` to `Pet` then every person with multiple pets would be repeated, once for each pet. 
It would look like this:

	query = (Person
			.select(Person, Pet)
			.join(Pet, JOIN.LEFT_OUTER)
			.order_by(Person.name, Pet.name))
	for person in query:
		# We need to check if they have a pet instance attached, since not all
		# people have pets.
		if hasattr(person, 'pet'):
			print person.name, person.pet.name
		else:
			print person.name, 'no pets'

	# prints:
	# Bob Fido
	# Bob Kitty
	# Grandma L. no pets
	# Herb Mittens Jr

To accomodate the more common (and intuitive) workflow of listing a person and attaching a list of that person’s pets, we can use a special method called prefetch():

	query = Person.select().order_by(Person.name).prefetch(Pet)
	for person in query:
		print person.name
		for pet in person.pets:
			print '  *', pet.name

	# prints:
	# Bob
	#   * Kitty
	#   * Fido
	# Grandma L.
	# Herb
	#   * Mittens Jr

### other

	group_by()
	having()
	limit() and offset()

## Working with existing databases
autogenerate peewee models using pwiz, a model generator.
 For instance, if I have a postgresql database named charles_blog, I might run:

	python -m pwiz -e postgresql charles_blog > blog_models.py

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