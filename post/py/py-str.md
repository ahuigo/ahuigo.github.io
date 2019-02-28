---
title: Python 字符处理
date: 2017-08-09
---
# Python 字符处理
- serialize
见/py/py-serial.md

# String
same as js:

	print "a\nb" ;# The character here "\n" is new line
	print 'a\nb'
	print '\x30\x31'; 01

	'\x87' == '\u0087' == b'\xc2\x87'.decode() ; #表示的是双位unicode
    '\x87' == bytes([0xc2,0x87]).decode() == chr(0x87)

## ord/chr(unicode)

	ord('A'); 65
        'A'.encode()[0]
	chr(65); 'A'

## multi line

	s=("str1"
		"str2" )

## string number
    int: 123
        str.isdecimal()
        str.isdigit() 
        str.isnumeric()

    float:
        .isalnum() 123.43
	.isalpha

## format
https://pyformat.info/

old

	>>> print 'This is (%r) (%s)' % ("Hilojack\"", "Blog")
	This is ('Hilojack"') (Blog)
	>>> print '''This is (%r) (%s)''' % ("Hilojack\"", "Blog")
	This is ('Hilojack"') (Blog)

> %r displays the "raw" data

### f-string
    x=1; user={'name':'ahui'};
    f'x={x}, user["name"]={user["name"]}, id(user)={id(user)}'
        'x=1, user["name"]=ahui, id(user)=4500547264'

    f'{{"str"}}'
        {"str"}
    '{0}'.format('{')

raw string

    f'{str!r}'

### string Template

    from string import Template
    Template('$who likes $what').substitute(who='Tom', what='cat')
    Template('$who').substitute({'who':1})

### tab length(to space)
'\t'.expandtabs(4)

## format()
### value type
```
'{:s}'.format('str')
'{:d}'.format(123)
'{:f}'.format(123.0)
```

### value conversion(str & repr)
```
class Data0(object):
    def __repr__(self):
        return 'räpr'
class Data1(object):
    def __str__(self):
        return 'str'

//Old
'%s %r %a' % (Data0(), Data1())
//New: !r 代表 repr, !s 代表 str, !a 代表repr
'{1!s} {0!r} {0!a}'.format(Data0(), Data1())
```
Output
```
str räpr r\xe4pr
```

### Padding and aligning strings

    # align left
    '%-10s' % ('test')
    '{:10}'.format('test')
    '{:<10}'.format('test')

    # align center
    '{:^10}'.format('test')

    # align right
    '%5s' % ('test',)
    '{:>5}'.format('test')
    ' test'

string default left, number/float default right:

    >>> '{:5s}'.format('a')
    'a    '
    >>> '{:5d}'.format(3)
    '    3'

padding with _

    '{:_<10}'.format('test')
    '{:_^10}'.format('test')
    '{:_>10}'.format('test')

padding with space(default)

    >>> '%6.2f' % (3.141592653589793,)
    >>> '{:6.2f}'.format (3.141592653589793,)
    '  3.14'

padding with zero

    >>> '%06.2f' % (3.141592653589793,)
    '003.14'
    >>> '{:06.2f}'.format (3.141592653589793,)
    '003.14'

padding with signed number(`=`没啥用)

    >>> '{:+07.2f}'.format (+3.141592653589793,)
    '+003.14'
    >>> '{:=+07.2f}'.format (+3.141592653589793,)
    '+003.14'

padding with signed number position:

    >>> '{:+6d}'.format (3)
    '    +3'
    >>> '{:=+6d}'.format (3)
    '+    3'


### Truncating long strings
```
>>> '%-.2s' % '12345'
>>> '{:.2}'.format('12345')
'12'
>>> '%-3.2s' % '12345'
>>> '{:3.2}'.format('12345')
'12 '
```
Truncating float
```
'{:.6f}'.format(123.0)
'123.000000'
```

combining truncating and padding
```
'{:12.2f}'.format(123.0)
'      123.00'
```

### named placeholder
```
'hello, {name} {obj["a"]} {{literal}}'.format(name='Wang')
'hello, {0}-{1}'.format('Wang', 'Kang')
'{p[first]} {p[last]}'.format(p={'first':1, 'last':2})
```
with object:
```
'{p.type}'.format(p=Plant())
```
### datetime
```
from datetime import datetime
'{:%Y-%m-%d %H:%M}'.format(datetime(2001, 2, 3, 4, 5))
```
### parametrized formats
```
'{:^10}'.format('test')
'{:{align}{width}}'.format('test', align='^', width='10')

'%2,2f' % ( 2.7182)
'%*.*f' % (5, 2, 2.7182)
'{:{width}.{prec}f}'.format(2.7182, width=5, prec=2)

'{:{dfmt} {tfmt}}'.format(dt, dfmt='%Y-%m-%d', tfmt='%H:%M')
```

### custom objects
```
class HAL9000(object):
    def __format__(self, format):
        if (format == 'open-the-pod-bay-doors'):
            return "I'm afraid I can't do that."
        return 'HAL 9000'
'{:open-the-pod-bay-doors}'.format(HAL9000())
```

## encoding
python 内存中string 全部是以unicode编码的，而bytes则可以任何特定的编码

### unicode
以下三个等价, 且都是 class str

	>>> '中'
    >>> "\u4e2d"
	>>> u'中'
    >>> u"\u4e2d"
    '中'

    >>> ord('A')
    65
    >>> ord('中') \x4e2d = 20013
    20013
    >>> chr(66)
    'B'
    >>> chr(25991)
    '文'

### Bytes
bytes对象b'\xa420'只是一堆比特位而已。define bytes

    >>> '\x00\x01\x61'.encode()
    >>> bytes([0, 1, 0x61])
    b'\x00\x01a'

	>>> type(b'abc')
	<class 'bytes'>
	>>> type('abc')
	<class 'str'>

    >>> 'abc'[0]
    'a'
    >>> 'abc'.encode()[0]
    97

对于字符串操作，我们并不关心它们内部编码。除非需要字节包用于传输时
1. str 是关编码的unicode: utf8,gbk, 是纯字符串表示: python3 采用unicode
1. bytes 是无关编码: utf8,gbk, 是纯字符经过编码过后的二进制数据

#### string to bytes:
ascii 不变, 其它则用16进制表示

	'abc'.encode('ascii')
		b'abc'
	'中国'.encode() # 默认utf8
		b'\xe4\xb8\xad'
	'中国'.encode('GB2312')
		b'\xd6\xd0'

	b'\xd6\xd0'.decode('GB2312')
		'中'

detect bytes encoding:

    >>> chardet.detect('中国人民'.encode())
    {'encoding': 'utf-8', 'confidence': 0.938125, 'language': ''}

#### utf8声明源码
1. 第二行注释是为了告诉Python解释器，按照UTF-8编码读取源代码
2. 编辑器要without BOM

e.g

    #!/usr/bin/env python3
    # -*- coding: utf-8 -*-

### raw string
string literals: r'...', r'''...''', r"...", r"""...""" are all literal strings for regex

    >>> r'a\n\t'
    'a\\n\\t'
    >>> r'''start
     end'''
    
for var

    >>> print('%r' % '\n')
    '\n'
    >>> print(r'\n')
    \n

## len
python3:

	len('中'); 1
	len('中'.encode('utf8')); 3
	len('ab'); 2
	len('ab'.encode('utf8')); 2


## Access String
like list

	'hilojack'[4:]
	'hilo' in 'hilojack'

## string func

	## substring count
	'hilo hilo'.count('hilo')

	## capitalize
	'hilo'.capitalize()
	'hilo'.upper()
	'hilo'.lower()

	## len
	len('abc')

## split
'ab cd'.split(' ') # ['ab', 'cd']
'word1 word2 word3'.split(' ', 1) # 'word2 word3'

	## sorted
	sorted('a zx') # [' ', 'a', 'x', 'z']

## search replace

	'hilojack'.find('jack');//4
	'hilo' in 'hilojack'
	str.replace(needle, word, 1); //replace the first needle with word

    'ab'.replace(['a','b'], ['A','B']) # wrong

replace with dict(不能出现干扰的边界字符`%{}`)

    address = "123 %(direction)s anywhere street"
    address % {"direction": "N"}

    '{direction}'.format(**{'direction':'Y'})

### translate

    str.maketrans('abc','ABC') 
        # {97: 65, 98: 66, 99: 67}
    >>> 'a2'.translate(str.maketrans('abc','ABC'))
    'A2'
    >>> 'a2'.translate(str.maketrans({'a':'A', 'b':'B'}))
    'A2'
    >>> 'a2'.translate(str.maketrans({97:65}))
    'A2'

python2:

    string.maketrans('','')  // equal to python3: bytes(range(0, 0x100))

    string.maketrans('a','B')  
    // equal to python3: 
    trans = str.maketrans('a','B')  
    bytes(c if c not in trans else trans[c] for c in range(0, 0x100))

### bytes translate
python3 reverse translate for bytes:

    b'abc'.translate(str.maketrans('abc','ABC'))
    b'ABC'.translate(str.maketrans('ABC','abc'))

python2 bytes translate reverse:

    >>> enc = string.maketrans('\x00\x01\x02', '\x01\x02\x00')
    >>> dec = string.maketrans(enc, string.maketrans('', ''))


### startwith

    aString.startswith("hello")
    aString.startswith(tuple(["hello", 'hi']))

	if any(map(l.startswith, x)):
	if any([l.startswith(s) for s in x])

### endswith

    'abc'.endswith('bc')
    'abc'.endswith(('bd', 'bc')) # tuple only

### find and index
### rfind and rindex

    str.find(substr, start=0, end=len(string))
        Index if found and -1 otherwise.
         S.index(sub[, start[, end]]) -> int
         Like S.find() but raise ValueError when the substring is not found.

## pad- zfill

	$ print '1'.zfill(2);
	01

## repeat
```
	'pad'*2
	'.'.join(['pad']*2)
```

## trim
包括\n, ' ', '\t\r'

	'a\n  '.strip() + ',end'
    s.lstrip()

left:

    '00a00'.lstrip('0')
    '00a00'.rstrip('0')

keep one zero:

    '00'.lstrip('0') or '0'

## Concat String

	>>> print 'a'+'b'+'c'	# with no space
	abc	# "abc\n"
	>>> print 'a' 'b' 	'c'   # with no space
	>>> print 'a''b''c'   # with no space
	abc # "abc\n"
	>>> print var1 var2   # syntax error
	>>> print '-'*6
	------
	>>> print '-' * 6
	------

long delimiter `"""` and `'''`(same): `\n` is still transfered by python

	print """
	a\nbc
	"""
	print """ab\nc"""
	print '''ab\nc'''

### Escape Sequences

	\n	ASCII linefeed (LF)
	\N{name}	Character named name in the Unicode database (Unicode only)
	\r ASCII	Carriage Return (CR)
	\uxxxx	Character with 16-bit hex value xxxx (Unicode only)
	\Uxxxxxxxx	Character with 32-bit hex value xxxxxxxx (Unicode only)
	\v	ASCII vertical tab (VT)
	\ooo	Character with octal value ooo
	\xhh	Character with hex value hh

#### not Escape
use repr encode

	>>> string = "abc\ndef"
	>>> print (repr(string))
	>>> 'abc\ndef'

	>>> print(repr("\n"))
	'\n'
	>>> print(r"\n")
    \n
    repr(obj, /)
        Return the canonical string representation of the object.

### print

	>>> print('a', 'b', 'c') # with space and new line
	a b c	# "a b c\n"
	>>> print('.', end='') # with space only, no new line

	# If you are having trouble with buffering, or with: sys.stdout.flush()
	>>> print('.', end='', flush=True) 

with no space and new line:

	>> sys.stdout.write('string')
	string

# list string

## string like list

	print "abc"[-1]
	for in "abc"

## chunk
利用range+step:

    def ChunkStr1(string, length):
        return (string[i:i+length] for i in range(0, len(string), length))

    # 利用regex:
    import re
    def ChunkStr2(string, length):
    	return re.findall('.{1,%d}' % length,string)

    list(ChunkStr1(s,10))


## random choice
    import secrets
    import string
    alphabet = string.ascii_letters + string.digits
    password = ''.join(secrets.choice(alphabet) for i in range(20))