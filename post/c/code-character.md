---
layout: page
title:	字符编码简介
category: blog
description: 
---

#序
本文试图理清字符编码系统的整体结构.如有理解不对请指正.

# 字符编码
按照[现代的编码模型],字符编码的主要概念分为：有哪些字符(字符表)、它们的编号(编码字符集)、这些编号如何编码成一系列的“码元”(字符编码表)、这些码元如何组成八位字节流(字符编码方案).

![character-code-1.png](/img/character-code-1.png)

## 字符表(Character Repotire)
一个系统所有抽象字符的集合,包括我们看得见的汉字/数字/符号和看不见的控制字符.unicode系统所使用的字符集是通用字符集[UCS] ,由ISO 10646所定义.

## 编码字符集(CCS:Coded Character Set)
将字符集C映射到非负整数(码位:编码字符的位置).如unicode[字符平面映射].即完成对字符的编号.

>unicode系统中的码位也叫unicode编码. 比如“刘”这个字的uinicode的编码是0x5218 .Tips: 在vim 用ga就可以查询到对应字符的unicode编码

## 字符编码表(CEF:Caracter Encoding Form)
将码位转换成有限比特长度的整数值(码元/码值:字符编码的值)

>在unicode系统中,其码位可被转换成8位串行的UTF-8,或者16位串行的UTF-16等等.也就说同一码位对应多个码值.
>码元（Code Unit，也称“代码单元”）是指一个已编码的文本中具有最短的比特组合的单元。对于UTF-8来说，码元是8比特长；对于UTF-16来说，码元是16比特长；对于UTF-32来说，码元是32比特长。编码长度是码元的整数倍,如UTF-16的长度就是2字节/4字节(一对码元)

我们平时所说的UTF-8,UTF-16都处于字符编码表(CEF)的层面.

> Tips: 有vim中通过`g8`可以查询到“刘”这个字的utf8编码（码值）为：0xe58898

## 字符编码方案(CES:Caracter Encodeing Scheme)
定义如何将码值对应到8位组的串行,以便网络传输和文件存储.
这里有两个大背景:

1. 对于多字节的UTF-16来说,windows是先读高字节再读低字节,而MAC则相反.为了标识字节顺序,就选择了一个字节序列标记(BOM:Byte Order Mark)来指定大端序(UTF-16 BE)和小端序(UTF-16).见[UTF-16]的编码模式
2. 有些复杂的编码需要特别的方案:如ISO/IEC 2022需要使用转义串行,如SCSU、BOCU和Punycode需要压缩

>在vim中,:%xxd 可查看相关字符的编码 :set fileencoding=**可对字符进行编码转换

# unicode编码体系
[unicode]又名统一码、万国码、单一码、标准万国码

## 意义
因多语言环境的需要而诞生,它对应于ISO 10646通用字符集[UCS],包括了其它所有字符集/已知语言的所有字符.

## unicode与iso 10646
史上存在两个尝试创立单一字符集的组织:

1. 国际标准化组织ISO——开发了ISO/IEC 10646项目
2. 统一码联盟Unicode Consortium——开发了统一码项目

1991年前后，两个项目的参与者都认识到，世界不需要两个不兼容的字符集。于是，它们开始合并双方的工作成果，并为创立一个单一编码表而协同工作.

到现在两个项目仍都存在，两者使用同一字符集，但二者本质上是不同的标准——unicode标准更为丰富，它额外定义了许多与字符相关的语义符号学，并且部分样例字形与iso 10646有显著区别。

## unicode的编码和实现

一般,unicode编码系统分为编码方式(CCS)和实现方式(CEF/CES ...).

![character-code-1.png](/img/character-code-1.png)

### unicode编码方式(CCS) 

统一码(unicode)的编码方式使用的是通用字符集[UCS]. unicode字符的平面映射本质上就是CCS码位映射,即对字符的编号(ISO/IEC 10646-1所定义) (CCS)
这个码位就叫unicode编码.

1. UCS-2:包含[字符平面映射]中的基本多文种平面,占16位,可表达2^16=65536个字符.2. UCS-4:其中已经定义了16个辅助平面.标准规定的UCS-4会占用32个字节,最高字节恒为0,可表达2^31个字符.

<table class="wikitable"> <tbody><tr> <th>平面</th> <th>始末字符值</th> <th>中文名称</th> <th>英文名称</th> </tr> <tr> <td>0号平面</td> <td>U+0000 - U+FFFF</td> <td><b>基本多文种平面</b></td> <td>Basic Multilingual Plane, 简称 <b>BMP</b></td> </tr> <tr> <td>1号平面</td> <td>U+10000 - U+1FFFF</td> <td><b>多文种补充平面</b></td> <td>Supplementary Multilingual Plane, 简称 <b>SMP</b></td> </tr> <tr> <td>2号平面</td> <td>U+20000 - U+2FFFF</td> <td><b>表意文字补充平面</b></td> <td>Supplementary Ideographic Plane, 简称 <b>SIP</b></td> </tr> <tr> <td>3号平面</td> <td>U+30000 - U+3FFFF</td> <td><b>表意文字第三平面</b>（未正式使用<sup id="cite_ref-1" class="reference"><a href="#cite_note-1">[1]</a></sup>）</td> <td>Tertiary Ideographic Plane, 简称 <b>TIP</b></td> </tr> <tr> <td>4号平面<br> 至<br> 13号平面</td> <td>U+40000 - U+DFFFF</td> <td>（尚未使用）</td> <td></td> </tr> <tr> <td>14号平面</td> <td>U+E0000 - U+EFFFF</td> <td><b>特别用途补充平面</b></td> <td>Supplementary Special-purpose Plane, 简称 <b>SSP</b></td> </tr> <tr> <td>15号平面</td> <td>U+F0000 - U+FFFFF</td> <td>保留作为<b>私人使用区（A区）</b><sup id="cite_ref-PUA_2-0" class="reference"><a href="#cite_note-PUA-2">[2]</a></sup></td> <td>Private Use Area-A, 简称 <b>PUA-A</b></td> </tr> <tr> <td>16号平面</td> <td>U+100000 - U+10FFFF</td> <td>保留作为<b>私人使用区（B区）</b><sup id="cite_ref-PUA_2-1" class="reference"><a href="#cite_note-PUA-2">[2]</a></sup></td> <td>Private Use Area-B, 简称 <b>PUA-B</b></td> </tr> </tbody></table> 

### 实现方式(CEF/CES ...)
在unicode编码体系中unicode码位转为实际存储的编码(码值)可以有不同实现方式.比如UTF8/UTF-16/UTF-32
>在unicode体系中码位是唯一的,所以字符编码转换程序 在转码时 一般把码值转为unicode再转为其它的编码.

#### 字节顺序标记(BOM)
[BOM][wiki_bom]是用来标记字节序的. 在windows/mac中,UTF-16高低字节的存储顺序是不同的,为了以示区别,特别定义的大尾序和小尾序.同时在文件头部加入一个BOM头(Byte Order Mark).
对于UTF-8来说,它只是一个UTF-8编码记号(不建议使用,它会干扰很多程序的执行)
>建议在编辑器中取消bom,比如在vim设置:set nobomb

<table class="wikitable"> <tbody><tr> <th>编码</th> <th>表示 (<a href="/wiki/%E5%8D%81%E5%85%AD%E9%80%B2%E4%BD%8D" title="十六进制" class="mw-redirect">十六进制</a>)</th> <th>表示 (<a href="/wiki/%E5%8D%81%E9%80%B2%E4%BD%8D" title="十进制" class="mw-redirect">十进制</a>)</th> </tr> <tr> <td><a href="/wiki/UTF-8" title="UTF-8">UTF-8</a></td> <td><code>EF BB BF</code></td> <td><code>239 187 191</code></td> </tr> <tr> <td><a href="/wiki/UTF-16" title="UTF-16">UTF-16</a>（<a href="/wiki/%E5%AD%97%E8%8A%82%E5%BA%8F#.E5.A4.A7.E7.AB.AF.E5.BA.8F" title="字节序">大端序</a>）</td> <td><code>FE FF</code></td> <td><code>254 255</code></td> </tr> <tr> <td><a href="/wiki/UTF-16" title="UTF-16">UTF-16</a>（<a href="/wiki/%E5%AD%97%E8%8A%82%E5%BA%8F#.E5.B0.8F.E7.AB.AF.E5.BA.8F" title="字节序">小端序</a>）</td> <td><code>FF FE</code></td> <td><code>255 254</code></td> </tr> <tr> <td><a href="/wiki/UTF-32" title="UTF-32">UTF-32</a>（大端序）</td> <td><code>00 00 FE FF</code></td> <td><code>0 0 254 255</code></td> </tr> <tr> <td><a href="/wiki/UTF-32" title="UTF-32">UTF-32</a>（小端序）</td> <td><code>FF FE 00 00</code></td> <td><code>255 254 0 0</code></td> </tr> <tr> <td><a href="/wiki/UTF-7" title="UTF-7">UTF-7</a></td> <td><code>2B 2F 76</code>和以下的<em>一个</em>字节：<code>[ 38 | 39 | 2B | 2F ]</code></td> <td><code>43 47 118</code>和以下的<em>一个</em>字节：<code>[ 56 | 57 | 43 | 47 ]</code></td> </tr> <tr> <td><a href="//en.wikipedia.org/wiki/UTF-1" class="extiw" title="en:UTF-1">en:UTF-1</a></td> <td><code>F7 64 4C</code></td> <td><code>247 100 76</code></td> </tr> <tr> <td><a href="//en.wikipedia.org/wiki/UTF-EBCDIC" class="extiw" title="en:UTF-EBCDIC">en:UTF-EBCDIC</a></td> <td><code>DD 73 66 73</code></td> <td><code>221 115 102 115</code></td> </tr> <tr> <td><a href="//en.wikipedia.org/wiki/Standard_Compression_Scheme_for_Unicode" class="extiw" title="en:Standard Compression Scheme for Unicode">en:Standard Compression Scheme for Unicode</a></td> <td><code>0E FE FF</code></td> <td><code>14 254 255</code></td> </tr> <tr> <td><a href="//en.wikipedia.org/wiki/BOCU-1" class="extiw" title="en:BOCU-1">en:BOCU-1</a></td> <td><code>FB EE 28</code> <i>及可能跟随着</i><code>FF</code></td> <td><code>251 238 40</code> <i>及可能跟随着</i><code>255</code></td> </tr> <tr> <td><a href="/wiki/GB-18030" title="GB-18030" class="mw-redirect">GB-18030</a></td> <td><code>84 31 95 33</code></td> <td><code>132 49 149 51</code></td> </tr> </tbody></table> 


<table class="wikitable"> <tbody><tr> <th colspan="7">使用UTF-16编码的例子</th> </tr> <tr> <th rowspan="2">编码名称</th> <th rowspan="2">编码次序</th> <th colspan="5">编码</th> </tr> <tr> <th>BOM</th> <th>朱</th> <th>,</th> <th>聿</th> <th><span style="cursor:help; border-bottom:1px dotted" title="字符描述：四个“龍”字　 ※此字在您的系统上可能无法显示，因而变成空白、方块或问号。"></span></th> </tr> <tr> <td>UTF-16LE</td> <td>小尾序</td> <td></td> <td>31 67</td> <td>2C 00</td> <td>7F 80</td> <td>69 D8 A5 DE</td> </tr> <tr> <td>UTF-16BE</td> <td>大尾序</td> <td></td> <td>67 31</td> <td>00 2C</td> <td>80 7F</td> <td>D8 69 DE A5</td> </tr> <tr> <td>UTF-16</td> <td>小尾序，包含BOM</td> <td>FF FE</td> <td>31 67</td> <td>2C 00</td> <td>7F 80</td> <td>69 D8 A5 DE</td> </tr> <tr> <td>UTF-16</td> <td>大尾序，包含BOM</td> <td>FE FF</td> <td>67 31</td> <td>00 2C</td> <td>80 7F</td> <td>D8 69 DE A5</td> </tr> </tbody></table> 

# UTF-16/UCS-2
UTF-16是Unicode字符集的一种转换方式(Unicode Transfomation Format),它把unicode码位转为16比特长的码元.
字符长度:基本平面的字符占用2个字节(16比特), 辅助平面的字符占用4个字节(32比特码元)

UCS-2是UTF-16的子集,仅支持Unicode[字符平面映射]中的基本多文平面.占2个字节.

Js 开发时，还没有UTF-16, 所以js 只支持UCS-2 子集，它不能处理4个字节的字符。见阮一峰的[](http://www.ruanyifeng.com/blog/2014/12/unicode.html)

## 字符编码表(CEF) 
对于unicoe基本多文平面(0x0000~0xffff).UTF-16的编码为一个16比特:

	UTF-16 == Unicode(0x0~0xffff) #不含(0xd800~0xdfff),这个区保留给UTF-16的前导代理和后导代理

对于uncide辅助平面(0x10000~0x10ffff),UTF-16的编码为一对16比特字符串,由前导代理(lead surrogates)和后导代理(trail surrogates)组成.
	
	将unicode码元(0x10000~0x10ffff)减去0x10000得到20位比特:0x0~0xfffff,这20位比特分高10位A(0~0x3ff)和低10位B(0~0x3ff)
	UTF-16(lead surrogates) == A+0xd800 #值范围(0xd800~0xdbff)
	UTF-16(trail surrogates) == B+0xd800 #值范围(0xdc00~0xdfff)

## UTF-16字符匹配正则
根据UTF-16的CEF规则,我们可以得到关于匹配UTF-16字符的正则伪代码(这个正则是无法执行的,可执行的正则可比这个可复杂多了):
	
	'#[\x{0000}-\x{d7ff}]
	|[\x{e000}-\x{ffff}]
	|([\x{d800}-\x{dbff}][\x{dc00}-\x{dfff}])#'
	

# UTF-8
utf8以8位为单元对[UCS]进行编码,编码会占用1~4字节.与utf16所编码的英文字符相比,它的编码长度减少一半.

## UTF-8 字符编码表CEF
<table class="wikitable"> <tbody><tr> <th style="width: auto;">代码范围<br> <a href="/wiki/%E5%8D%81%E5%85%AD%E9%80%B2%E5%88%B6" title="十六进制" class="mw-redirect">十六进制</a></th> <th style="width: auto;">标量值（scalar value）<br> <a href="/wiki/%E4%BA%8C%E9%80%B2%E5%88%B6" title="二进制" class="mw-redirect">二进制</a></th> <th style="width: auto;">UTF-8<br> <a href="/wiki/%E4%BA%8C%E9%80%B2%E5%88%B6" title="二进制" class="mw-redirect">二进制</a>／<a href="/wiki/%E5%8D%81%E5%85%AD%E9%80%B2%E5%88%B6" title="十六进制" class="mw-redirect">十六进制</a></th> <th style="width: 25%;">注释</th> </tr> <tr> <td rowspan="2">000000 - 00007F<br> <small>128个代码</small></td> <td>00000000 00000000 0zzzzzzz</td> <td>0zzzzzzz(00-7F)</td> <td rowspan="2">ASCII字符范围，字节由零开始</td> </tr> <tr> <td><small>七个z</small></td> <td><small>七个z</small></td> </tr> <tr> <td rowspan="2">000080 - 0007FF<br> <small>1920个代码</small></td> <td>00000000 00000yyy yyzzzzzz</td> <td style="text-align: left;">110yyyyy(C0-DF) 10zzzzzz(80-BF)</td> <td rowspan="2" align="top">第一个字节由110开始，接着的字节由10开始</td> </tr> <tr> <td><small>三个y；二个y；六个z</small></td> <td><small>五个y；六个z</small></td> </tr> <tr> <td rowspan="2">000800 - 00D7FF<br> 00E000 - 00FFFF<br> <small>61440个代码 <sup class="reference" id="ref_D800Note_1"><a href="#endnote_D800Note_1">[Note 1]</a></sup></small></td> <td>00000000 xxxxyyyy yyzzzzzz</td> <td style="text-align: left;">1110xxxx(E0-EF) 10yyyyyy 10zzzzzz</td> <td rowspan="2" align="top">第一个字节由1110开始，接着的字节由10开始</td> </tr> <tr> <td><small>四个x；四个y；二个y；六个z</small></td> <td><small>四个x；六个y；六个z</small></td> </tr> <tr> <td rowspan="2">010000 - 10FFFF<br> <small>1048576个代码</small></td> <td>000wwwxx xxxxyyyy yyzzzzzz</td> <td style="text-align: left;">11110www(F0-F7) 10xxxxxx 10yyyyyy 10zzzzzz</td> <td rowspan="2">将由11110开始，接着的字节由10开始</td> </tr> <tr> <td><small>三个w；二个x；四个x；四个y；二个y；六个z</small></td> <td><small>三个w；六个x；六个y；六个z</small></td> </tr> </tbody></table> 

## UTF-8优缺点
*优点*

1. 保证搜索时一个字符的字符串不会出现在另一个字符的串里面.
1. 兼容ASCII
1. 抗干扰和稳定性好:一段两字节随机串行碰巧为合法的UTF-8而非ASCII的机率为32分1。对于三字节串行的机率为256分1，对更长的串行的机率就更低了

*缺点*

1. 与UTF-16/gbk 想比，处理CJK字符串,编码长度不占优势

##　UTF-8正则匹配
当使用Perl时，可用以下的表达式测试页面是否使用了UTF-8编码：

	m/\A(
		[\x09\x0A\x0D\x20-\x7E]            # ASCII
		| [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte
		|  \xE0[\xA0-\xBF][\x80-\xBF]        # excluding overlongs
		| [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte
		|  \xED[\x80-\x9F][\x80-\xBF]        # excluding surrogates
		|  \xF0[\x90-\xBF][\x80-\xBF]{2}     # planes 1-3
		| [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15
		|  \xF4[\x80-\x8F][\x80-\xBF]{2}     # plane 16
	)*\z/x;

## utf8_unicode_ci和utf8_general_ci区别

	ci - case insensitive
	cs - case sensitive

这是两种校对与比较规则(COLLATE)

There are at least two important differences:

- *Accuracy of sorting*

	utf8_unicode_ci is based on the Unicode standard for sorting, and sorts accurately in a very wide range of languages.

	utf8_general_ci comes close to correct Unicode sorting in many common languages, but has a number of limitations: in some languages, it won't sort correctly at all. In others, it will merely have some quirks.

- *Performance*

	utf8_general_ci is faster at comparisons and sorting, because it takes a bunch of performance-related shortcuts.

	utf8_unicode_ci uses a much more complex comparison algorithm which aims for correct sorting according in a very wide range of languages. This makes it slower to sort and compare large numbers of fields.

Unicode defines complex sets of rules for how characters should be sorted. These rules need to take into account language-specific conventions; not everybody sorts their characters in what we would call 'alphabetical order'.

- As far as Latin (ie "European") languages go, there is not much difference between the Unicode sorting and the simplified utf8_general_ci sorting in MySQL, but there are still a few differences:

	For examples, the Unicode collation sorts "ß" like "ss", and "Œ" like "OE" as people using those characters would normally want, whereas utf8_general_ci sorts them as single characters (presumably like "s" and "e" respectively).

- In non-latin languages, such as Asian languages or languages with different alphabets, there may be a lot more differences between Unicode sorting and the simplified utf8_general_ci sorting. The suitability of utf8_general_ci will depend heavily on the language used. For some languages, it'll be quite inadequate.

Some Unicode characters are defined as ignorable, which means they shouldn't count toward the sort order and the comparison should move on to the next character instead. utf8_unicode_ci handles these properly.

utf8_general_ci是一个遗留的 校对规则，仅部分支持Unicode校对规则算法, 一些字符还是不能支持。并且，不能完全支持组合的记号, 主要影响越南和俄罗斯的一些少数民族语言。

utf8_unicode_ci 的最主要的特色是支持扩展，即当把一个字母看作与其它字母组合相等时。例如，在德语和一些其它语言中‘ß’等于‘ss’。

这意味着utf8_general_ci校对规则进行的比较速度很快，但是与使用utf8_unicode_ci的校对规则相比，比较正确性较差）。

Refer to http://stackoverflow.com/questions/766809/whats-the-difference-between-utf8-general-ci-and-utf8-unicode-ci

# 其它UTF

## UTF-7
UTF-7是一种可变长度的字符编码方式,用以将UTF-16字符以ASCII编码.也就是说用修改的Base64（Modified Base64）去编码UTF-16字符.

因为SMTP作为基本邮件传输标准,只允许传输ASCII字符,过去很多邮件传输都使用UTF-7.自从[MIME]扩展了电子邮件标准之后,SMTP支持了其它字符集.现在绝大多数邮件服务商都使用UTF-8/GB2312/GB18030作为邮件字符编码.

>严格来说 UTF-7 不能算是 Unicode 所定义的字符集之一，较精确的来说， UTF-7 是提供了一种将 Unicode 转换为 7 比特 US-ASCII 字符的转换方式
>Modified Base64 与Base64的主要区别是结尾不会有"="

UTF-7由于安全性薄弱,已经走入历史.

>Gmail中文用户默认外发邮件编码(content-type)是GB2312(可改为UTF-8).其传输编码(Content-Transfer-Encoding)会按数据最短的原则选择: quoted-printable/base64或者不用.
>腾讯邮箱用户默认的外发邮件编码是gb18030(可改为UTF-8).其传输编码使用的是base64.

## UTF-32
UTF-32 是一个 UCS-4 的子集，使用32-比特的码值，只在0到10FFFF的字码空间（百万个码位）

# 内容传输编码(Content-Transfer-Encoding)
CTE由[MIME]定义,用于email数据传输.包括“7bit”，“8bit”，“binary”，“quoted-printable”，“base64”.其中常见的传输码为Base64/quoted-printable

## Base64
Base64不是字符编码方案,而是一种基于64个可打印字符来表示二进制数据的表示方法.6bit(2^6=64)为一单元,对应一个可打印的字符.三个字节有24个位元.对应4个Base64字符.

### 编码规则
将二进制流/文本流以每6bit为一单元,3个字节为一组.以6bit(2^6=64)的数字大小为位置对应以下字符中的一个:

	ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/

如果最后剩余2个或1个字节,按以下方式补0:

<table class="wikitable"> <tbody><tr> <th scope="row">文本</th> <td colspan="8" align="center"><b>M</b></td> <td colspan="8" align="center"><b>a</b></td> <td colspan="8" align="center"><b>n</b></td> </tr> <tr> <th scope="row">ASCII编码</th> <td colspan="8" align="center">77</td> <td colspan="8" align="center">97</td> <td colspan="8" align="center">110</td> </tr> <tr> <th scope="row">二进制位</th> <td>0</td> <td>1</td> <td>0</td> <td>0</td> <td>1</td> <td>1</td> <td>0</td> <td>1</td> <td>0</td> <td>1</td> <td>1</td> <td>0</td> <td>0</td> <td>0</td> <td>0</td> <td>1</td> <td>0</td> <td>1</td> <td>1</td> <td>0</td> <td>1</td> <td>1</td> <td>1</td> <td>0</td> </tr> <tr> <th scope="row">索引</th> <td colspan="6" align="center">19</td> <td colspan="6" align="center">22</td> <td colspan="6" align="center">5</td> <td colspan="6" align="center">46</td> </tr> <tr> <th scope="row">Base64编码</th> <td colspan="6" align="center"><b>T</b></td> <td colspan="6" align="center"><b>W</b></td> <td colspan="6" align="center"><b>F</b></td> <td colspan="6" align="center"><b>u</b></td> </tr> </tbody></table> 

最后,如果剩下两个字节，在编码结果后加1个“=”；如果最后剩下一个字节，编码结果后加2个“=”；如果没有剩下任何数据，就什么都不要加，这样才可以保证资料还原的正确性。

## Quoted-printable
可打印字符引用编码(Quoted-printable，或QP encoding).
它使用ASCII字符表示各种字符编码--以便能个7bit or 8bit 数据通路上传输数据.
此编码为是[MIME]中 content transfer encoding的一种,用于email.(与base64并列为两种基本的邮件传输编码)

### 编码规则
Quoted-printable以8bit为单位进行编码,规则如下:

	一般的8bit编码为"="加两个十六进制值,如"\x7A"编码为"=7A"
	对于可打印的ascii码:0x21-0x7E("="号:0x3D除外),可用ASCII码直接表示
	但是,如果水平制表符和空格符出现在行尾,必须用OP编码表示为"=09"(tab)和"=20"(space)
	如果QP编码的数据每行长度超过76个字符,QP编码结果的每行结尾加一个软换行("=")

Gmail在发送以下字符时所使用的Content-Transfer-Econding正是QP,如果将其ContentType设置为:UTF-8.并发送邮件内容("新"的utf8编码为\xe696b0):
	
	新This is a test!
	If you believe that truth=beauty, then surely mathematics is the most beautiful branch of philosophy.
	
那么,经过QP编码后的邮件text/plain原文为:

	=E6=96=B0This is a test!
	If you believe that truth=3Dbeauty, then surely mathematics is the most bea=
	utiful branch of philosophy.

你很可能看到的是这个(因为你的邮件文本编辑器做format字符时就在most处断行了,使得单行不超过76个字符):

	=E6=96=B0This is a test!
	If you believe that truth=3Dbeauty, then surely mathematics is the most
	beautiful branch of philosophy.

还有一个text/html原文.
	

>与base64相比,如果Content-Type编码与ASCII是兼容的,那么QP编码后的邮件原文中ASCII是可读的.


# GB相关的编码
本小节主要归纳汉字相关的编码:GB2312,GBK,GB18030.他们的关系

    GB18030 > GBK > GB2312
    GB2312 是最高的汉字集
    GBK(CP936) 是完全包括GB2312
    GB18030是对GBK 的扩展, 但是不完全兼容

如图所示,GB18030基本兼容GBK.

## GB2312
GB2312,也叫GB2312-80,于1981年推出.

### 特点
1. 收录6763个汉字

### 编码结构
先对汉字进行分区(得到的编码叫区位码).

1. 01-09区为特殊符号。
1. 16-55区为一级汉字，按拼音排序。
1. 56-87区为二级汉字，按部首／笔画排序。

编码:
对于ascii(0x00-0x7f)保持不变.
对于汉字和符号,使用两个字节表示:“高位字节”使用了0xA1-0xF7（把01-87区的区号加上0xA0），“低位字节”使用了0xA1-0xFE（把01-94加上0xA0）

>"啊"的区位码是0x1001,对应的gb2312就是0xb0a1


## GBK

### 背景
因为原GB2312字符不足, 厂商微软利用GB 2312-80未使用的编码空间，收录GB 13000.1-93全部字符制定了GBK编码.

### 编码结构
对于GB2312字符保持不变,仅对Gb2312未使用的编码区进行了扩充.
对于双字节来说:第一字节的范围是81–FE（也就是不含80和FF），第二字节的一部分领域在40–7E，其他领域在80–FE.

<table class="wikitable"> <caption>GBK的编码范围</caption> <tbody><tr> <th>范围</th> <th>第1字节</th> <th>第2字节</th> <th>编码数</th> <th>字数</th> </tr> <tr> <td>水准 GBK/1</td> <td><code>A1</code>–<code>A9</code></td> <td><code>A1</code>–<code>FE</code></td> <td align="right">846</td> <td align="right">717</td> </tr> <tr> <td>水准 GBK/2</td> <td><code>B0</code>–<code>F7</code></td> <td><code>A1</code>–<code>FE</code></td> <td align="right">6,768</td> <td align="right">6,763</td> </tr> <tr> <td>水准 GBK/3</td> <td><code>81</code>–<code>A0</code></td> <td><code>40</code>–<code>FE</code> (<code>7F</code>除外)</td> <td align="right">6,080</td> <td align="right">6,080</td> </tr> <tr> <td>水准 GBK/4</td> <td><code>AA</code>–<code>FE</code></td> <td><code>40</code>–<code>A0</code> (<code>7F</code>除外)</td> <td align="right">8,160</td> <td align="right">8,160</td> </tr> <tr> <td>水准 GBK/5</td> <td><code>A8</code>–<code>A9</code></td> <td><code>40</code>–<code>A0</code> (<code>7F</code>除外)</td> <td align="right">192</td> <td align="right">166</td> </tr> <tr> <td>用户定义</td> <td><code>AA</code>–<code>AF</code></td> <td><code>A1</code>–<code>FE</code></td> <td align="right">564</td> <td></td> </tr> <tr> <td>用户定义</td> <td><code>F8</code>–<code>FE</code></td> <td><code>A1</code>–<code>FE</code></td> <td align="right">658</td> <td></td> </tr> <tr> <td>用户定义</td> <td><code>A1</code>–<code>A7</code></td> <td><code>40</code>–<code>A0</code> (<code>7F</code>除外)</td> <td align="right">672</td> <td></td> </tr> <tr> <th>合计:</th> <th></th> <th></th> <th align="right">23,940</th> <th align="right">21,886</th> </tr> </tbody></table>


### 按拼音排序
基于Gbk/Gb2312是按音序来编码的.可用此规则来对汉字进行拼音排序(以php为例)

	//按拼音首字母排序
	$arr = array(
		'北京'=>'010',
		'成都'=>'028',
	);
	ukrsort($arr, 'cmp');
	var_dump($arr);

	/**
	 *
	 * 比较拼音首字母(基于字符是按拼音顺序编码) 
	 */
	function cmp(&$a, &$b) {
		$a = iconv('utf-8', 'gbk', $a);
		$a = $a[0];
		$b = iconv('utf-8', 'gbk', $b);
		$b = $b[0];
		if ($a == $b) {
			return 0;
		}
		return ($a > $b) ? 1 : -1;
	}
	function ukrsort(&$arr, $func) {
		foreach ($arr as $k => $v) {
			if (is_array($arr[$k])) {
				ukrsort($arr[$k], $func);
			}
		}
		uksort($arr, $func);
	}

也可以通过编码找到绝大部分汉字的拼音首字母(以php为例)

	/**
	 * 获取汉字拼音首字母(基于字符是按拼音顺序编码)
	 */
	function getFirstLetter($str) {
		$fchar = ord($str{0});
		if ($fchar >= ord("A") and $fchar <= ord("z"))
			return strtoupper($str{0});
		if (!is_string($str)) {
			var_dump($str);
			return;
		}
		$s1 = @iconv("UTF-8", "gbk", $str);
		$s2 = @iconv("gbk", "UTF-8", $s1);
		if ($s2 == $str) {
			$s = $s1;
		} else {
			$s = $str;
		}

		$asc = ord($s{0}) * 256 + ord($s{1}) ;
		if ($asc >= 45217 and $asc <= 45252)
			return "A";
		if ($asc >= 45253 and $asc <= 45760)
			return "B";
		if ($asc >= 45761 and $asc <= 46317)
			return "C";
		if ($asc >= 46318 and $asc <= 46825)
			return "D";
		if ($asc >= 46826 and $asc <= 47009)
			return "E";
		if ($asc >= 47010 and $asc <= 47296)
			return "F";
		if ($asc >= 47297 and $asc <= 47613)
			return "G";
		if ($asc >= 47614 and $asc <= 48118)
			return "I";
		if ($asc >= 48119 and $asc <= 49061)
			return "J";
		if ($asc >= 49062 and $asc <= 49323)
			return "K";
		if ($asc >= 49324 and $asc <= 49895)
			return "L";
		if ($asc >= 49896 and $asc <= 50370)
			return "M";
		if ($asc >= 50371 and $asc <= 50613)
			return "N";
		if ($asc >= 50614 and $asc <= 50621)
			return "O";
		if ($asc >= 50622 and $asc <= 50905)
			return "P";
		if ($asc >= 50906 and $asc <= 51386)
			return "Q";
		if ($asc >= 51387 and $asc <= 51445)
			return "R";
		if ($asc >= 51446 and $asc <= 52217)
			return "S";
		if ($asc >= 52218 and $asc <= 52697)
			return "T";
		if ($asc >= 52698 and $asc <= 52979)
			return "W";
		if ($asc >= 52980 and $asc <= 53688)
			return "X";
		if ($asc >= 53689 and $asc <= 54480)
			return "Y";
		if ($asc >= 54481 and $asc <= 55289)
			return "Z";
		return null;
	}


## GB18030
GB 18030，全称：国家标准GB 18030-2005《信息技术　中文编码字符集》，是中华人民共和国现时最新的内码字集(2005年发布).
有以下特点:

>采用多字节编码，每个字可以由1个、2个或4个字节组成。
支持全部unicode([UCS])全部统一汉字.收录范围包含繁体汉字以及日韩汉字70244个
与GBK基本兼容,与GB 2312完全兼容

### 编码结构

1. 单字节，其值从0到0x7F。 
1. 双字节，第一个字节的值从0x81到0xFE，第二个字节的值从0x40到0xFE（不包括0x7F）。
1. 四字节，第一/三字节的值从0x81到0xFE，第二/四字节的值从0x30到0x39.

### 正则匹配
	
	'#[\x00-\x7f]|[\x81-\xfe][\x40-0xfe]|([\x81-0xfe][\x30-\x39]){2}#'
	
# c 语言对unicode 的支持
c 语言处理字符串都是按字节来的，但是有时候，我们需要计算一个字符有多少utf8 字符。为了解决这个问题c 语言定义了宽字符(Wide Character)类型wchar_t 和一些库函数。宽字符前面有一个L, 比如 `wchar_t c=L'你'` , 或者 `wchar_t c=L"你好"`, 这样wcslen 函数就可以获取宽字符串的字符数了

含宽字符的源码在编译时为目标文件中，宽字符被编码为UCS(每个字符4个字节), 按小端存储. 
L"你好" 会被编译器编译为 4个UCS编码0x00004f60 0x0000597d 0x0000000a 0x00000000保存在目标文件中，按小端存储就是60 4f 00 00 7d 59 00 00 0a 00 00 00 00 00 00 00, 可以用`od -tx1 `查看目标文件 和可执行文件

	#include <stdio.h>
	#include <locale.h>

	int main(void) {
		if (!setlocale(LC_CTYPE, "")) {
			fprintf(stderr, "Can't set the specified locale! "
				"Check LANG, LC_CTYPE, LC_ALL.\n");
			return 1;
		}
		printf("%ls", L"你好\n");//%ls 表示把后面的参数按宽字符解释，直到见到4字节的UCS 0 才结束。
		return 0;
	}

将宽字符write 到终端仍然要转换为UTF8 等多字节编码，这取决于运行时setlocale 获取到的当前系统的编译设置。一般，程序在做内部计算时常用宽字编码(UCS 编码), 存盘或者输出时用多字节编码。

# Latin-1 编码(西欧编码)
这是个编码是单字节编码(0~0xff), 是对ascii(0~127)的扩展

# 参考
1. 维基[UCS]
2. 维基[字符平面映射]
2. [utf_bom]
1. 维基[unicode]
2. 维基[现代编码模型]
2. 维基[UTF-16]
2. 维基[UTF-8]
2. 维基[GB2312]
2. 维基[GBK]
2. 维基[GB18030]

[UCS]:http://zh.wikipedia.org/wiki/%E9%80%9A%E7%94%A8%E5%AD%97%E7%AC%A6%E9%9B%86#Unicode.E5.92.8CISO_10646.E7.9A.84.E5.BC.82.E5.90.8C
[字符平面映射]: http://zh.wikipedia.org/wiki/Unicode%E5%AD%97%E7%AC%A6%E5%B9%B3%E9%9D%A2%E6%98%A0%E5%B0%84
[unicode]: http://zh.wikipedia.org/wiki/Unicode
[现代编码模型]:http://zh.wikipedia.org/wiki/%E5%AD%97%E7%AC%A6%E9%9B%86
[UTF-16]:https://zh.wikipedia.org/wiki/UTF-16#UTF-16.E7.9A.84.E7.B7.A8.E7.A2.BC.E6.A8.A1.E5.BC.8F
[ascii]:http://www.walu.cc/os-program/ascii-table.md
[utf_bom]:http://www.unicode.org/faq/utf_bom.html
[wiki_bom]:https://zh.wikipedia.org/wiki/%E4%BD%8D%E5%85%83%E7%B5%84%E9%A0%86%E5%BA%8F%E8%A8%98%E8%99%9F
[UTF-8]:https://zh.wikipedia.org/wiki/UTF-8
[GB2312]:http://zh.wikipedia.org/wiki/GB_2312
[GBK]:http://zh.wikipedia.org/wiki/GBK
[GB18030]:http://zh.wikipedia.org/wiki/GB_18030
[MIME]:http://zh.wikipedia.org/wiki/MIME
