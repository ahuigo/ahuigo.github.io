---
layout: page
title:	sql injection
category: blog
description:
---
# Preface

# Blind SQL
不显示错误，盲注

# sql Injection
> https://www.owasp.org/index.php/SQL_Injection
> https://www.owasp.org/index.php/Testing_for_SQL_Injection_(OTG-INPVAL-005)

	select * from name = '$name'
		$name = "ahui' or 'a'='a"
		$name = "ahui' ;delete from t1; --"
		$name = "ahui' ;delete from t1; #"

## union

		$name = "ahui' UNION ALL SELECT ... #"

# Wide Charset Injection
> http://security.stackexchange.com/questions/9908/multibyte-character-exploits-php-mysql

1. Basic attacks on, e.g., UTF-8 and other character encodings by eating up extra backslashes/quotes introduced by the quoting function

2. Sneaky attacks on, e.g., GBK, that work by tricking the quoting function to introduce an extra quote for you

3. Attacks on, e.g., UTF-8, that conceal the presence of a quote by using an invalid non-canonical (over-long) encoding of the single quote:
Basically, the normal way of encoding a single quote has it fit into a single-byte sequence (namely, 0x27).
However, there are also multi-byte sequences that the database might decode as a single quote,
and that do not contain the 0x27 byte or any other suspicious byte value.

As a result, standard quote-escaping functions may fail to escape those quotes.

##  multi-byte characters
> https://vigilance.fr/vulnerability/MySQL-SQL-injection-via-multi-byte-characters-5885

(multi-byte). Here are three examples of character tables/encoding:

 - ISO-8859-1/LATIN1 (French)
 - UTF-8 (international, multi-byte)
 - SJIS, BIG5, GBK, GB18030, UHC (Asian, multi-byte)

A SQL string can contain the tick character. For example:

	SELECT ... WHERE var = 'abc\'def';
	SELECT ... WHERE var = 'abc''def';

The first vulnerability affects the `mysql_real_escape_string()` function family which does not reject invalid multi-byte characters:

For example, in UTF-8, the `"0xC8 ' ' attackersql"` or `"0xC8 \ ' attackersql"` string is converted to:
`"one_character ' attackersql"` (ignore spaces), `0xC8` will eat `\`. So, the query:

	  SELECT ... WHERE var = ' mysql_real_escape_string("0xC8 ' attackersql") '
	become :
	  SELECT ... WHERE var = ' 0xC8 ' ' attackersql '
	  SELECT ... WHERE var = 'one_character ' attackersql'

An attacker can therefore inject the attackersql command.

The second vulnerability only affects Asian encodings,
when they are used with simple escaping functions such as a regular expression replace of `' by \'`, PHP addslashes(), etc.
For example, in SJIS, the query:

	  SELECT ... WHERE var = ' addslashes("0x95 0x5C ' attackersql") '

becomes, because 0x5C is the backslash character(`0x95 0x5c` combines as `one_character`):

	  SELECT ... WHERE var = ' 0x95 0x5C \ \ ' attackersql '
	  SELECT ... WHERE var = 'one_character \\' attackersql'

An attacker can therefore inject the attackersql command.

## 在GBK宽字节中

	%df'
	%df%27
	%df%5c%27 # %df%5c 是gbk 中是一个汉字

	%5C \
	%27 '

	$sql = "select * from t where name='{$name}' and password='{$password}' limit 1";

构造$name:

	$name="\xbf\x27 or name=name /*"

addslash 后, `\xbf` will eat `\x5c`:

		$name="\xbf\x5c' or name=name /*"
		$name="\xbf\x5c' or name=name ;/*"
		$name="\xbf\x5c' or name=name ;#/*"

This type of attack is possible with any character encoding where there is a valid multi-byte character that ends in 0x5c, because addslashes() can be tricked into creating a valid multi-byte character instead of escaping the single quote that follows.
> UTF-8 does not fit this description.
