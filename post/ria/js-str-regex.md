---
title: js regex
date: 2022-02-24
private: true
---
# String's regex function
### match(regx.exec)

	//return 存放匹配结果的数组
	stringObject.match(searchvalue)

	stringObject.match(regexp)
	matches = "1 2 3 ".match(/\d+/g); //[1,2,3]
	"1 2 3".match(/(\d) s/g); //return null

#### match group
如果regexp没有g, 则会匹配子模式

    "first 1 second 1".match(/(\w+) 1/);  [ 'first 1', 'first', index: 0, input: 'first 1 second 1']
        matches.index //0 相当于indexOf返回的位置

如果regexp有g, 则会返回数组

    "first 1 second 1".match(/(\w+) 1/g); // [ 'first 1', 'second 1' ]

如果需要group name:

    /name="(?<name>\w+)"/.exec(`name="ahui"`).groups.name

> 如果需要同时支持regExp global 及 子表达式, 请使用RegExp.prototype.exec
> match 成功后，`RegExp.$1~$9` 代表子组，`RegExp.$0` 不存在

### search(regex.test)
返回字符位置, 不支持regexp global; 这个像indexOf()

	str.search('string') equal to str.indexOf('string'); //返回字符位置
	str.search(/Hilo/i);

### replace
支持regexp global.

	str = stringObject.replace(substr,replacement); //once
	str = stringObject.replace(/substr/g,replacement); //all

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

#### str2unicode
    function str2unicode(s='中'){
        return s.replace(/[^\u0000-\u00FF]/g, function ($0) { 
            return escape($0)
            //return escape($0).replace(/(%u)(\w{4})/gi, "&#x$2;")
        });
    }

# RegExp
Create RegExp：test, exec

	/pattern/attributes
	/str/igm
	new RegExp('pattern', 'attributes');
	new RegExp("str",'igm')
	new RegExp("^str$",'igm')
	new RegExp("(^|&)str$",'igm')

### raw string as regex
    RegExp.escape = function(string) {
        return string.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&')
    };
    var hostname = 'makandra.com';
    new RegExp(RegExp.escape(hostname));

### unicode

	/\u1321/.test('\u1321');//true
	/\x31/u.test('\x31');//true

### group name

    /name="(?<name>\w+)"/.exec(`name="ahui"`).groups.name

非global 模式的match, 也可以显示groups

    "first 1 second 1".match(/(?<x>\w+) 1/).groups.x

global 模式的match, 结果只有数组

### zero-width 断言
js 对断言支持得非常好
正向断言，假定该位置后跟的是X

	(?<=X)	zero-width positive lookbehind
	(?=X)	zero-width positive lookahead

	(?<!X)	zero-width negative lookbehind>
	(?!X)	zero-width negative lookahead

限制无前缀

    > 'my pre-word'.match(/my.*(?<!pre-)word/)
    null
    > 'my pre1-word'.match(/my.*(?<!pre-)word/)
    my pre1-word

必须是`/a$` or `/a/.*`

    '/a/b'.match(/^\/a(?=\/|$)/)
    '/a'.match(/^\/a(?=\/|$)/)

    '/a/b'.replace(new RegExp('^/a(?=$|/)'), '/base')

## regxp func

    regx.test()  bool
    regx.exec()  match

### test

	test	检索字符串中指定的值。返回 true 或 false。
	str=' 1 2 3';
	r=/\d/igm;
	while(r.test(str) === true){
		console.log(r.lastIndex);//2 4 6 下次要匹配的字符串起始位置
	}

### compile

	r.compile(/\d/); //改变正则表达式

### exec 
like python findall/finditer(返回分组)

while 时必须开启global, 否则会死循环(reg 的cursor不会变)

	str=' 1ing 2ing 3ing';
	r=/\d(ing)/igm;
	while((match = r.exec(str)) !== null){
		console.log(match,r.lastIndex);
		//第1次输出 ["1ing", "ing", index: 1, input: " 1ing 2ing 3ing"] 5
		//第2次输出 ["2ing", "ing", index: 6, input: " 1ing 2ing 3ing"] 10
		//第3次输出 ["3ing", "ing", index: 11, input: " 1ing 2ing 3ing"] 15
	}