---
title: Posgtre Var
date: 2019-06-20
private:
---
# math operations
## Bit Operation

    2&1 //0
    2|1 //3
    ~1 //-2

## math function

    3^3 //27

### floor function

	FLOOR(RAND() * 401) + 100

## 交集
http://www.postgresqltutorial.com/postgresql-intersect/

    SELECT employee_id FROM keys
    INTERSECT
    SELECT employee_id FROM hipos;
    //out:
    employee_id
    -------------
            5
            2

# Number

	2e30
	2+3*3
	10%3

What the exactly number if value over range?

> If number is above the range, the value mysql store will be the max value.
> If number is below the range, the value mysql store will be the min value.

What does the number in parenthesis mean?

> int(2) will generate an INT with minimum display width of 2. It's up to mysql client.
In most clients, if a colume specified with `INT(2) ZEROFILL`, the number 6 will be displayed as '06'.
> `DECIMAL(M,D)、FLOAT(M,D)、DOUBLE(M,D)` M是显示长度，D是可存的小数位数

### pg number
decimal 与numeric  是一样的

    smallint	2 bytes	small-range integer	-32768 to +32767
    integer	4 bytes	typical choice for integer	-2147483648 to +2147483647
    bigint	8 bytes	large-range integer	-9223372036854775808 to 9223372036854775807
    decimal	variable	user-specified precision, exact	up to 131072 digits before the decimal point; up to 16383 digits after the decimal point
    numeric	variable	user-specified precision, exact	up to 131072 digits before the decimal point; up to 16383 digits after the decimal point
    real	4 bytes	variable-precision, inexact	6 decimal digits precision
    double precision	8 bytes	variable-precision, inexact	15 decimal digits precision
    serial	4 bytes	autoincrementing integer	1 to 2147483647
    bigserial	8 bytes	large autoincrementing integer	1 to 9223372036854775807

### mysql INT

	### TINYINT
	Their signed value range is (-128,127) , and unsigned range (0,255)。

	#### BOOL & BOOLEAN
	They are TINYINT(1) alias

	### SMALLINT [(M)] [UNSIGNED] [ZEROFILL]
	Their unsigned range is (0,2^16-1)。

	### MEDIUMINT [(M)] [UNSIGNED] [ZEROFILL]
	Their unsigned range is (0,2^24-1)。

	### INT [(M)] [UNSIGNED] [ZEROFILL]
	Their unsigned range is (0,2^32-1)。

	### BIGINT [(M)] [UNSIGNED] [ZEROFILL]
	Their unsigned range is (0,2^64-1)。

for postgre:

    Oracle	NUMBER(3,0), -103-1 to 103-1
    MySQL	TINYINT, Signed: -128 to 127, Unsigned: 0 to 255
    PostgreSQL	SMALLINT, -32768 to 32767

### Float

#### DECIMAL ([M,D]) [UNSIGNED] [ZEROFILL]
以字符串存储浮点数。

	DECIMAL(4,1);//只能存储4位字符，小数部分1位(不含小数点和负号). 即-999.9~ 999.9 或 0.0 ~ 999.9
	DECIMAL; //Same as DECIMAL(10,0)

####  FLOAT([M,D]) [UNSIGNED] [ZEROFILL]

	FLOAT(4,1);//Same as DECIMAL(4,1). Storage as string

	FLOAT;
		//参照c 语言的IEEE 754 double 32位存储 signed: +/- 10^38, unsigned: 0~10^38

####  DOUBLE([M,D]) [UNSIGNED] [ZEROFILL]

	DOUBLE(4,1);//Same as DECIMAL(4,1). Storage as string

	DOUBLE;
		//参照c 语言的IEEE 754 double 64位存储 signed: +/- 10^308, unsigned: 0~10^308
