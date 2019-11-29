---
title: Posgtre Var Expression
date: 2019-06-20
private:
---
# variable
mysql 变量不区分大小写

	"set variable
	set @sum = 10,@i = 1;
	select id into @sum from table;

全局变量需要加前缀 `@`, 比如`@sum`
局部变量则不需要加前缀

Read `system variable` with `@@`:

	set autocommit=0;
	select @@AUTOCOMMIT;

## add

	set @i=0;// set @i:=0; //The := operator is never interpreted as a comparison operator
	SELECT (@i:=@i+1) AS rowNumber,id from t1;

## if

	select if(9<=7, '1-7', if(9=8, 8, 9));

## math

	select 1-3*2 as calc into @sum;//在存储例程中变量不需要加@
	select * from table where id in (3,4) or [name] in ('andy','paul');