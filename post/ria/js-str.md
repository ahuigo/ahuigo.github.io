# String

	'\x31'
	"\x31"

	'好' === '\u597D' // true
	'好' === '\u{597D}' // true

## es6 string
支持backquote 多行(es6):

	`multiple
	line`

### 模板字符

	name='ahui'
	`Hello, ${name}`

## 字符串是不可变的
```
var s = 'Test';
s[0] = 'X';
alert(s); // s仍然为'Test'
```

## function

	.charAt(pos) str[pos=0]
	.charCodeAt(pos) //返回unicode 十进制表示
	.fromCharCode(97)
	#搜索
	.indexOf(sub_string)
	.lastIndexOf(sub_str)
	#compare
	.localeCompare(str) //return 1 0 -1
	#截取
	.substr(start,[length])//start可为负
	.slice(start, [end]) //start, end可为负

###	case
	.toLowerCase() / .toUpperCase()

### .trim()
trim space only

	' a '.trim()

### for

	for(var i=0; i < str.length; i++ ){
		str[i];
	}

### base64

	btoa(str)
	atob(str)

### split
支持regexp

	stringObject.split(separator,[maxSize]);
	'1,2,3,4,5'.split(',', 3);//[1,2,3]
	'1,2,3,4,5'.split(/,/);//[1,2,3,4,5]

### font

	str.link(url)
	str.bold()
	str.sup() 上标
	str.sub() 下标 //"<sub>str</sub>"
	str.small() 小字号
	str.big()
	str.fontcolor('red') "<font color="red">s</font>"
	's'.fontsize('1px')

### Match

	//return 存放匹配结果的数组
	stringObject.match(searchvalue)

	stringObject.match(regexp)
	matches = ("1 2 3 ".match(/\d+/g); //[1,2,3]
	"1 2 3".match(/(\d) s/g); //return null

	//如果regexp没有g, 则会匹配子模式
	matches = "first 1".match(/(\w+) 1/);//如果没有g, 则返回包括子表达式  ["first 1", "first"]
	matches.index //0 相当于indexOf返回的位置

> 如果需要同时支持regExp global 及 子表达式, 请使用RegExp.prototype.exec

### search
返回字符位置, 不支持regexp global; 这个像indexOf()

	str.search('string') equal to str.indexOf('string'); //返回字符位置
	str.search(/Hilo/i);

### replace
支持regexp global.

	str = stringObject.replace(regexp/substr,replacement)
	replacement:
		string:
			字符	替换文本
			$1、$2、...、$99	与 regexp 中的第 1 到第 99 个子表达式相匹配的文本。
			$&	与 regexp 相匹配的子串。
			$`	位于匹配子串左侧的文本。
			$'	位于匹配子串右侧的文本。
			$$	$转义
		function:
			function(mathStr, first, second, ...){return replace;}

eg:

	//reference
	'funing smoking '.replace(/(\w+)ing/g, '$1');// "fun smok "
	//func
	card = '[card]google[/card]http://g.cn'; // to "<a href="http://g.cn">google</a>"
	card.replace(/\[card\](\w+)\[\/card\]([\w:\/.]+)/,function(ori,card,url){
		return '<a href="'+url+'">'+card+'</a>';
	})

## RegExp
Create RegExp：

	/pattern/attributes
	/str/igm
	new RegExp('pattern', 'attributes');
	new RegExp("str",'igm')
	new RegExp("^str$",'igm')
	new RegExp("(^|&)str$",'igm')


	/\u1321/.test('\u1321');//true
	/\x31/u.test('\x31');//true

### zero-width 断言
正向断言，假定该位置后跟的是X

	(?<=X)	zero-width positive lookbehind
	(?=X)	zero-width positive lookahead

	(?<!X)	zero-width negative lookbehind>
	(?!X)	zero-width negative lookahead

	'?_b=1&b=2'.match(/(?<=[?&])b=(\d+)/)

### test

	test	检索字符串中指定的值。返回 true 或 false。
	str=' 1 2 3';
	r=/\d/igm;
	while(r.test(str) === true){
		console.log(r.lastIndex);//2 4 6 下次要匹配的字符串起始位置
	}

### comile

	r.compile(/\d/); //改变正则表达式

### exec

	str=' 1ing 2ing 3ing';
	r=/\d(ing)/igm;
	while((match = r.exec(str)) !== null){
		console.log(match,r.lastIndex);
		//第1次输出 ["1ing", "ing", index: 1, input: " 1ing 2ing 3ing"] 5
		//第2次输出 ["2ing", "ing", index: 6, input: " 1ing 2ing 3ing"] 10
		//第3次输出 ["3ing", "ing", index: 11, input: " 1ing 2ing 3ing"] 15
	}
