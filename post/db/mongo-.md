# 不要用mongodb
http://coolshell.cn/articles/5826.html

# todo
http://www.tutorialspoint.com/mongodb/

# connect

## via shell

    usage: mongo [options] [db address] [file names (ending in .js)]
    db address can be:
      foo                   foo database on local machine
      192.169.0.5           foo database on 192.168.0.5 machine
      192.169.0.5/foo       foo database on 192.168.0.5 machine
      192.169.0.5:9999/foo  foo database on 192.168.0.5 machine on port 9999

example

    $ ./mongo
    MongoDB shell version: 3.0.6
    connecting to: test

mongod 即可以启动daemon, 也可以查看连接状态

    $ mongod
    2015-09-25T17:22:27.336+0800 I CONTROL  [initandlisten] allocator: tcmalloc
    2015-09-25T17:22:27.336+0800 I CONTROL  [initandlisten] options: { storage: { dbPath: "/data/db" } }
    2015-09-25T17:22:27.350+0800 I NETWORK  [initandlisten] waiting for connections on port 27017
    2015-09-25T17:22:36.012+0800 I NETWORK  [initandlisten] connection accepted from 127.0.0.1:37310 #1 (1 connection now open)  # 该行表明一个来自本机的连接

## php connect
连接本地数据库服务器，端口是默认的。

    mongodb://localhost
    $connection = new MongoClient( "mongodb://example.com" ); // connect to a remote host (default port: 27017)

    使用用户名fred，密码foobar登录localhost的admin数据库。
    mongodb://fred:foobar@localhost
    使用用户名fred，密码foobar登录localhost的baz数据库。
    mongodb://fred:foobar@localhost/baz
    连接 replica pair, 服务器1为example1.com服务器2为example2。
    mongodb://example1.com:27017,example2.com:27017
    连接 replica set 三台服务器 (端口 27017, 27018, 和27019):
    mongodb://localhost,localhost:27018,localhost:27019
    连接 replica set 三台服务器, 写入操作应用在主服务器 并且分布查询到从服务器。
    mongodb://host1,host2,host3/?slaveOk=true
    直接连接第一个服务器，无论是replica set一部分或者主服务器或者从服务器。
    mongodb://host1,host2,host3/?connect=direct;slaveOk=true
    当你的连接服务器有优先级，还需要列出所有服务器，你可以使用上述连接方式。
    安全模式连接到localhost:
    mongodb://localhost/?safe=true
    以安全模式连接到replica set，并且等待至少两个复制服务器成功写入，超时时间设置为2秒。
    mongodb://host1,host2,host3/?safe=true;w=2;wtimeoutMS=2000#

all connect:

    $allConnects = $mongo->getConnections();

# db help

    > db.help()
    > db.stats()

stats in php

    $stats=$con->dbName->command(array('dbStats' => 1));  // for db.stats()
    $stats=$con->dbName->command(array('collStats' => 'collection_name')); // for db.col

# db operaion

## create db
查看选择的库:

    db
    show databases;
    show dbs;

建库, 先用use 切换

    > use t1
    switched to db t1
    > db
    t1

插入数据后才新建db

    > db.users.insert({"name":"hilo"});
    > show dbs
    t1

有一些数据库名是保留的，可以直接访问这些有特殊作用的数据库。

    admin： 从权限的角度来看，这是"root"数据库。要是将一个用户添加到这个数据库，这个用户自动继承所有数据库的权限。
        一些特定的服务器端命令也只能从这个数据库运行，比如列出所有的数据库或者关闭服务器。
    local: 这个数据永远不会被复制，可以用来存储限于本地单台服务器的任意集合
    config: 当Mongo用于分片设置时，config数据库在内部使用，用于保存分片的相关信息

## drop db

    > use test
    > db.dropDatabase()

# Collections
集合相当于table, 但无固定结构 , 随便罗列一条

    db.col.findOne()

## Collection Operaion

### show collections
以下两个等价

    show collections
    show tables;
    db.getCollectionNames();//json

### drop collection

    db.COLLECTION_NAME.drop()

### create collection

    db.createCollection(name, options)
    db.createCollection("mycoll", {capped:true, size:100000})

options

    capped	Boolean
        If true, enables a capped collection.(fixed size collecction)
        that automatically overwrites its oldest entries when it reaches its maximum size.
    size	number
    	Specifies a maximum size in bytes for a capped collection.
    max	number
        Specifies the maximum number of documents allowed in the capped collection.
    autoIndexID Boolean
        If true, automatically create index on \_id field.s Default value is false.

MongoDB creates *collection/database* automatically, when you insert some document.

        db.collection_name.insert({"name" : "value"})


## Capped collections
> Capped collections 就是固定大小的collection。

它有很高的性能以及队列过期的特性(过期按照插入的顺序). 有点和 "RRD" 概念类似。

1. 它非常适合类似记录日志的功能
2. 你必须要显式的创建一个capped collection， 指定一个collection的大小，单位是字节。
3. Capped collections是高性能自动的维护对象的插入顺序。
4. collection的数据存储空间值提前分配的。

要注意的是指定的存储大小包含了数据库的头信息。

    db.createCollection("mycoll", {capped:true, size:100000})

在capped collection中，你能添加新的对象。但有限制:

1. 能进行更新，然而，对象不会增加存储空间。如果增加，更新就会失败 。
2. 数据库不允许进行删除。使用drop()方法删除collection所有的行。
3. 注意: 删除之后，你必须显式的重新创建这个collection。
4. 在32bit机器中，capped collection最大存储为1e9( 1X109)个字节。

## 元数据
数据库的信息是存储在集合中。它们使用了系统的命名空间：

    dbname.system.*

在MongoDB数据库中名字空间 <dbname>.system.* 是包含多种系统信息的特殊集合(Collection)，如下:

    集合命名空间	描述
    dbname.system.namespaces	列出所有名字空间。
    dbname.system.indexes	列出所有索引。
    dbname.system.profile	包含数据库概要(profile)信息。
    dbname.system.users	列出所有可访问数据库的用户。
    dbname.local.sources	包含复制对端（slave）的服务器信息和状态。

对于修改系统集合中的对象有如下限制。

1. 在{{system.indexes}}插入数据，可以创建索引。但除此之外该表信息是不可变的(特殊的drop index命令将自动更新相关信息)。
2. {{system.users}}是可修改的。 {{system.profile}}是可删除的。
