---
title: php str
date: 2018-10-04
---
# encoding
## internal encoding
mb_internal_encoding('UTF-8');
echo mb_internal_encoding();
ini_get('default_charset')

## detect order
var_dump(mb_detect_order());

## detect encoding
string mb_detect_encoding ( string $str [, mixed $encoding_list = mb_detect_order() 

# print

    var_dump()
    var_export($a, true)
    print_r($a,true)

# String

## range string

	function rangeChar($lower, $upper) {
		++$upper;
		for ($i = $lower; $i !== $upper; ++$i) {
			yield $i;
		}
	}
	foreach (rangeChar('hilojack', 'hilojacz') as $v)

	range('A', 'Z')
	array_merge(range('A', 'Z'), range('a', 'z'));

## wildcard

	bool fnmatch('*.weibo.cn', $host, FNM_CASEFOLD);//Caseless match

## csv

	str_getcsv("a,b\n\n");//忽略\n

## preg

	preg_quote('\\1'); \1 -> \\1

preg multiple group capture:(last one)

	php > echo preg_replace('#(\w)*#i', '\1', "abcd");
	d
	php > echo preg_replace('#((\w)*)_((\w)*)#i', '\1-\2-\3-\4', "ab_cd");
	ab-b-cd-d

## split

	array str_split ( string $string [, int $split_length = 1 ] )

## DOM
Operation html string like jquery

https://code.google.com/p/phpquery/

[php-dom](/p/php-dom)

## ini

	parse_ini_file('a.ini')
	parse_ini_string('a.ini')

	get_defined_constants($categorize = true)['user']
	parse_ini_file('a.ini') + get_defined_constants(true)['user']

### Create ini

	$arr = ['country'=> [1=>'北京\'"']];
	echo array2ini($arr);
	function array2ini($arr, $key_prefix = ''){
		$key_prefix = $key_prefix === '' ? '' : $key_prefix . '.';
		$ini = '';
		foreach($arr as $k=>$v){
			if(is_array($v)){
				$ini .= array2ini($v, "$key_prefix$k");
			}else{
				$ini .= "$key_prefix$k = \"" . str_replace('"', '\"', $v) . "\"\n";
			}
		}
		return $ini;
	}

## Double Quote

	"$str"
	"${str}"
	"{$str}"

	"$arr[0]"
	"${arr[0]}"
	"{$arr[0]}"

	"$arr['hello']" //fatal error
	"${arr['hello']}"
	"{$arr['hello']}"
	"$arr[hello]"	//notice
	"${arr[hello]}" //notice
	"{$arr[hello]}" //notice

	"$obj->key";		equal with {$obj->key}
	"{$obj->key}";
	"${obj->key}";		return value as variable name

	"{func()}";//literal
	"${func()}";//exec func(), then use the func's return value as variable name

	"${$obj->func()}" 	return value as variable name
	"${$obj->$p}" 		return value as variable name

> `\`` 反引号(grave accent)的规则同双引号一样

## heredoc & nowdoc
php 中的heredoc 与 nowdoc 和 shell 不一样，使用的是三个`<`打头，即以`<<<` 打头, 结果标记后还需要有分号`;`

	$var = <<<MM
	...
	MM;
	$var = <<<'MM'
	...
	MM;
    
### double quote 双引号
    \[0-7]{1,3}	符合该正则表达式序列的是一个以八进制方式来表达的字符
    \x[0-9A-Fa-f]{1,2}	符合该正则表达式序列的是一个以十六进制方式来表达的字符

## in string

	echo strspn("$", 'abc$');//Finds the length of the initial segment of a string within a given mask

## 大小写

	ucfirst('word word');//Word word
	ucwords('word word');//Word Word
	strtoupper();
	strtolower();

## strstr
Alias to strchr

	strstr('a@qq.com', '@qq');//@qq.com
	strstr('a@qq.com', '@qq', true);//a

## html

	nl2br
	htmlentities: encode all characters
	htmlspecialchars : encode only necessary characters
	strip_tags

Example:

	echo htmlentities('<Il était une fois un être>.');
	// Output: &lt;Il &eacute;tait une fois un &ecirc;tre&gt;.
	//                ^^^^^^^^                 ^^^^^^^

	echo htmlspecialchars('<Il était une fois un être>.');
	// Output: &lt;Il était une fois un être&gt;.
	//                ^                 ^

> http://htmlpurifier.org/ 提供了强大的html 数据清洗库

## diff
	strspn($str1, '0123456789');//求相同
	strcspn($str1, $str2);//求不同

equal:

	(ord($c) ^ 0x31) === ($c === "\x31")

## replace
strtr — Translate characters or replace substrings

	strtr($str, $arr) === str_replace(array_keys($arr), array_values($arr), $str);

	strtr($str, $from, $to);
	echo strtr('a', 'abc', 'ABC');//A

## split

	count_chars('ab',1 ); //array(97=>1, 98=>1)
	| php -r 'var_dump(array_filter(count_chars(file_get_contents("php://stdin"))));'
	| php -r 'var_dump(count_chars(file_get_contents("php://stdin"))[9]);'

## repeat

	str_repeat($str, $num);

## pad
	str_pad($str, $len, $pad, $type);
		$type = STR_PAD_RIGHT，STR_PAD_LEFT 或 STR_PAD_BOTH

## preg regx

	int preg_match ( string $pattern , string $subject);
	array preg_grep ( string $pattern , array $input);

## format

### parse format
	// get author info and generate DocBook entry
	$auth = "24\tLewis Carroll";
	$n = sscanf($auth, "%d\t%s %s", $id, $first, $last);

	//parse rgb
	list($r, $g, $b) = sscanf('0x00ccff', '0x%2x%2x%2x');


### sprintf

	sprintf($format, $var1, $var2);
	printf($format, $var1, $var2);

## 统计字符

### substr_count

	substr_count($str, $word);

### count_chars
	count_chars($str, $mode=0)

Depending on mode count_chars returns one of following:

- 0 - an array with the byte-value as key and the frequency of every byte as value;

### strword_count
	str_word_count

## nowdoc & heredoc
heredoc 会解释变量

	echo <<<EOT
	My name is "$name". I am printing some $foo->foo.
	Now, I am printing some {$foo->bar[1]}.
	This should print a capital 'A': \x41
	EOT;

而nowdoc 不会解释变量(原样输出）

	echo <<<'EOT'
	My name is "$name". I am printing some $foo->foo.
	Now, I am printing some {$foo->bar[1]}.
	This should print a capital 'A': \x41
	EOT;

# pack & unpack

	string pack ( string $format [, mixed $args [, mixed $... ]] )
	chr(31)
	ord('A')

Note the distinction between signed and unsigned values only affect unpack function, where as function pack() gives the same result for signed and unsigned format codes.

	$format
	a	NUL-padded string
	A	SPACE-padded string

	bin2hex(pack('a3', '1'));//"310000"
	bin2hex(pack('A3', '1'));//"312020"

	h	Hex string, low nibble first
	H	Hex string, high nibble first

	bin2hex(pack('H', 0x4));	//4 -> 4 -> 0x40
	bin2hex(pack('H', 0x12));	//18 -> 1 -> 0x10
	bin2hex(pack('H', 0x15));	//21 -> 2 -> 0x21
	bin2hex(pack('H2', 0x15));	//21 -> 21 -> 0x21
	bin2hex(pack("H2", "21")); //"21" ->21 -> "21"
	bin2hex(pack("H*", "123")); //"123"-> 12 3 -> "1230"

	unpack("H", "\x12\x3");//["1"]
	unpack("H2", "\x12\x3");//["12"]
	unpack("H3", "\x12\x3");//["120"]
	unpack("H*", "\x12\x3");//["1203"]
	unpack("h", "\x12\x3");//["2"]
	unpack("h2", "\x12\x3");//["21"]
	unpack("h3", "\x12\x3");//["213"]
	unpack("h*", "\x12\x3");//["2130"]

	bin2hex(pack('h', 0x15));//21 -> 2 -> 0x02
	bin2hex(pack('h', 0x12));//18 -> 1 -> 0x01
	bin2hex(pack('h2', 0x15));//21 -> 21 -> 0x12
	bin2hex(pack('h', "\x31"));//"1" -> 1 -> "01"
	bin2hex(pack('h2', "123"));//"123" -> 12 -> "21"
	bin2hex(pack('h*', "123"));//"123" -> 12 3-> "2103"

	c	signed char
	C	unsigned char
	bin2hex(pack('c', 10));//10 -> 0x0a
	unpack('c', "\x0a"));//0x0a -> [10]
	unpack('c', "\xff"));//0x0a -> [-1]
    unpack('c4', hex2bin("31323334")); // [1=>49, 2=>50, 3=>51,4=> 52]
    unpack('c5H23', hex2bin("31323334"));
        // ['H231'=>49, 'H232'=>50, 'H233'=>51, 'H234'=>52]

	s	signed short (always 16 bit, machine byte order)
	S	unsigned short (always 16 bit, machine byte order)
	bin2hex(pack('s', 10));//10 -> 0x0a00
	bin2hex(pack('s', 0x1234));//0x1234 -> 0x3412
	bin2hex(pack('s', 0xffff));//0xffff -> 0xffff

	dechex(unpack('s', "\x34\x12")[1]);	//0x3412 -> 0x1234
	unpack('s', "\xff\xff")[1];	//0xffff -> -1
	unpack('S', "\xff\xff")[1];	//0xffff -> 65536

	n	unsigned short (always 16 bit, big endian byte order)
	v	unsigned short (always 16 bit, little endian byte order)
	bin2hex(pack('n', 0x1234));//0x1234 -> 0x1234
	bin2hex(pack('v', 0x1234));//0x1234 -> 0x3412

	i	signed integer (machine dependent size and byte order)
	I	unsigned integer (machine dependent size and byte order)
	l	signed long (always 32 bit, machine byte order)
	L	unsigned long (always 32 bit, machine byte order)
	bin2hex(pack('i', 0x1234));//0x1234 -> 0x34120000 my 32bit
	bin2hex(pack('l', 0x1234));//0x1234 -> 0x3412

	N	unsigned long (always 32 bit, big endian byte order)
	V	unsigned long (always 32 bit, little endian byte order)
	bin2hex(pack('N', 0x1234));//0x1234 -> 0x00001234
	bin2hex(pack('V', 0x1234));//0x1234 -> 0x34120000

	new in php 5.6
	q	signed long long (always 64 bit, machine byte order)
	Q	unsigned long long (always 64 bit, machine byte order)
	J	unsigned long long (always 64 bit, big endian byte order)
	P	unsigned long long (always 64 bit, little endian byte order)
	f	float (machine dependent size and representation)
	d	double (machine dependent size and representation)
	x	NUL byte
	X	Back up one byte
	Z	NUL-padded string (new in PHP 5.5)
	@	NUL-fill to absolute position

combine

    $binarydata = "\x04\x00\xa0\x00";
    $array = unpack("cchars/nint", $binarydata);
        Array ( [chars] => 4 [int] => 160)
    $array = unpack("c2chars/nint", $binarydata);
        [chars1] => 4 [chars2] => 0 [int] => 40960

Be aware that if you do not name an element, an empty string is used. If you do not name more than one element, this means that some data is overwritten as the keys are the same such as in:

    $binarydata = "\x32\x42\x00\xa0";
    $array = unpack("c2/n", $binarydata);
          1=> int(50) 2=> int(66) wrong
          1=> int(160) 2=> int(66) n overwritten on c1