---
layout: page
title:	php-mysql
category: blog
description:
---
# Preface
php 使用mysql时，主要通过两种面向对象的扩展mysqli 和 pdo。mysqli 用于访问mysql, 而pdo 抽象层次更高，可用于其它数据库。
这两种扩展的特点是：

- 面向对象
- 准备语句，防止sql 注入
1. 调试功能
2. 主/从支持

# mysqli

The `mysql.default_socket` and `mysqli.default_socket` in php.ini should be equal to `socket` under `[mysqld]` in `my.cnf`. such as:

	mysql.default_socket = /tmp/mysql.sock
	mysqli.default_socket = /tmp/mysql.sock
	pdo_mysql.default_socket = /tmp/mysql.sock

在mysql 中:

- 使用`127.0.0.1`, 会走`TCP/IP`
- 使用`localhost`, 会走`UNIX socket` 更快

## connect & close

	$mysqli = new mysqli("localhost", "user", "password", "database", 3306);
	//or
	$mysqli = new mysqli();
	$mysqli->real_connect("localhost", "user", "password", "database", 3306);// With the mysqli::options() function you can set various options for connection.

	if ($mysqli->connect_errno) {
		echo "Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
	}

	//select_db
	$mysqli->select_db('database');

	//应该主动close，不要等待php 脚本结束再释放
	$mysqli->close()

> "Open connections (and similar resources) are automatically destroyed at the end of script execution. However, you should still close or free all connections, result sets and statement handles as soon as they are no longer required. This will help return resources to PHP and MySQL faster."

error:

	if($mysqli->errno){
		echo "Failed to connect to MySQL: (" . $mysqli->errno . ") " . $mysqli->error;
	}

connect info:

	$mysqli->host_info;

## query

	$res = $mysql->query('show tables', MYSQLI_STORE_RESULT);//default: MYSQLI_STORE_RESULT 结果集以缓存集返回(内存消耗大) MYSQLI_USE_RESULT 结果以非缓存集返回(性能好)
	while(list($table) = $res->fetch_row())
		echo "$table \n";

	//free result 释放结果集
	$res->free();

### query result(mysqli_result)

	//obj
	$row = $res->fetch_object();
	//assoc
	$row = $res->fetch_row(); $row = $res->fetch_assoc();
	//array
	$row = $res->fetch_array();
	//all
	$row = $res->fetch_all([ int $resulttype = MYSQLI_NUM ] )

### multi query & multi result

	mysqli = new mysqli("localhost", "root", "", "test", 3306);
	//$querys = 'select * from t1 where id > 100; select s2 from t2;';
	$querys = 'call loop_t';
	$mysqli->multi_query($querys);
	do{
		if($res = $mysqli->store_result()){
			while ($row = $res->fetch_row()) {
				var_dump($row);
			}
			$res->free();
		}
	}while($mysqli->more_results() && $mysqli->next_result());

### affected_rows

	echo $mysqli->affected_rows;

### bind params & results

stmt

	$stmt = $mysqli->stmt_init();
	$query = 'select user,age from ahui where id>? and name=?;
	$stmt->prepare($query);
	$id = 0; $name='hilo';
	$stmt->bind_param($types='is',$id,$name);//i:integer s:string d:double b:blob
	if(!$stmt->execute()){
		die('error!');
	}
	//bool $stmt->store_result();//取出查询的结果集，使用mysql cached
	//Data are transferred unbuffered without calling mysqli_stmt_store_result() which can decrease performance (but reduces memory cost).

output

	$stmt->bind_result($user,$age);//mysqli_stmt 必须绑定的
	while($stmt->fetch()){
		var_dump($user, $age);
	}
	var_dump($stmt->affected_rows, $stmt->error);

	$stmt->close();

## 事务

set auto commit to false(default it is true)

	$mysqli->autocommit(true);//auto
	$mysqli->autocommit(false);//noauto
	//check auto status via `SELECT @@autocommit;`

commit

	if($mysqli->affected_rows > N)
		$mysqli->commit();//true for succ. If you call commit now, there is no rollback of the successful statements
	else
		$mysqli->rollback();//true for succ

# PDO

## connect & close

	// 在此使用连接
	$dbh = new PDO('mysql:host=localhost;dbname=test;port=xx', $user, $pass);
	$pdo = new PDO("mysql:unix_socket=/tmp/mysql.sock;dbname=test");
	// 现在运行完成，在此关闭连接
	$dbh = null;

### init command

	$options = [PDO::MYSQL_ATTR_INIT_COMMAND=> 'set names utf8'];
	$dbh = new PDO('mysql:host=localhost;dbname=test;port=xx', $user, $pass, $options);

pdo default socket:

	pdo_mysql.default_socket= /tmp/mysql.sock

## use

	PDOStatement:
		query
		prepare (+ execute)

	int(affected_rows)
		exec

## return int
intall php5-mysqlnd, then

	Ensure that PDO::ATTR_EMULATE_PREPARES is false (check your defaults or set it):
	$pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

	Ensure that PDO::ATTR_STRINGIFY_FETCHES is false (check your defaults or set it):
	$pdo->setAttribute(PDO::ATTR_STRINGIFY_FETCHES, false);

## multi sqls
$sql 可以为多条:

	$sqls = "$sql1; $sql2; ";

	// works with the following set to 1. You can comment this line as 1 is default
	$pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, true);
	$pdo->prepare($sqls)

也可以不支持multi sqls

	// works regardless of statements emulation
	$pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
	$pdo->exec($sqls);//not work

### nextRowset

	$p = new PDO('mysql:unix_socket=/tmp/mysql.sock');
	$ret = $p->query('select "a";show databases;select sleep(2);');
	do{
		var_dump($ret->fetchAll());
	}while($ret->nextRowset());

## query
query 与prepare 返回的都是结果集PDOStatement. 它继承了ArrayObject 所以可通过`foreach` 遍历出结果, 也可以通过`fetch` 获取结果集

	$pdo = new PDO('sqlite:users.db');
	public PDOStatement PDO::query ( string $statement )

	foreach($pdo->query('SELECT * from FOO') as $row) {
        print_r($row); #assoc
    }
	$pdo->query($sql)->fetch()['key']

query all:

	$ret = $pdo->query($sql);
	//$ret->setFetchMode ( PDO::FETCH_ASSOC )
	return $ret->fetchAll();

query rowNumber

	$nrows = $db->query('select count(*) from table where x')->fetch(PDO::FETCH_NUM)[0];

## prepare(bindParam)
bind via `stmt->bindParam`

	$pdo = new PDO('sqlite:users.db');
	$pdo = new PDO("mysql:host=localhost;dbname=test","root","123456");
	$stmt = $pdo->prepare('SELECT name FROM users WHERE id = :id');
	$stmt->bindParam(':id', $_GET['id'], PDO::PARAM_INT); // <-- Automatically sanitized by PDO
	$stmt->execute();
	while($row = $stmt->fetch(PDO::FETCH_ASSOC))
		print_r($row);

bind via `stmt->execute(assoc)`:

	$calories = 150;
	$colour = 'red';
	$sth = $dbh->prepare('SELECT name, colour, calories
		FROM fruit
		WHERE calories < :calories AND colour = :colour');
	$sth->execute(array(':calories' => $calories, ':colour' => $colour));

bind via `stmt->execute(number array)`:

	$calories = 150;
	$colour = 'red';
	$sth = $dbh->prepare('SELECT name, colour, calories
		FROM fruit
		WHERE calories < ? AND colour = ?');
	$sth->execute(array($calories, $colour));

> stmt->execute 返回true/false

### $stmt

	$stmt->rowCount(); //update delete insert only

## exec

	int PDO::exec ( string $statement );//return line number of affected rows
	$count = $dbh->exec("DELETE FROM fruit WHERE colour = 'red'");

`PDO::exec()` 在一个单独的函数调用中执行一条 SQL 语句，返回受此语句影响的行数。
`PDO::exec()` 不会从一条 SELECT 语句中返回结果。

## lastInsertId

	pdo->lastInsertId();

## note
- `PDO::query()`对于在程序中只需要发出一次的 SELECT 语句，可以考虑使用 PDO::query()。
- `stmt->excute()`对于需要发出多次的语句，可用 PDO::prepare() 来准备一个 PDOStatement 对象并用 PDOStatement::execute() 发出语句。
