---
layout: page
title:	
category: blog
description: 
---



# 问题
这个问题是在德问上看到的.

有两个字符串，比如：
$str1 = 'abcdef';
$str2 = 'efabcd';

[怎么快速比较两个字符串中字符完全相同呢](http://www.dewen.org/q/913/%E5%A6%82%E4%BD%95%E5%BF%AB%E9%80%9F%E6%AF%94%E8%BE%83%E4%B8%A4%E4%B8%AA%E5%AD%97%E7%AC%A6%E4%B8%B2%E4%B8%AD%E5%AD%97%E7%AC%A6%E5%AE%8C%E5%85%A8%E7%9B%B8%E5%90%8C%EF%BC%9F)，两个字符串的长度一样，只是字符排序不一样，有可能出现重复的字符。

大伙回答得有点意思,总结下.具体实例就不写了
	
对于两种字符串相同,我们定义两种规则:
>EqualRule-sensitive :str1与str2所包含的字符种类和每种字符出现的次数完全相同(对重复字符敏感)
>EqualRule-insensitive :str1与str2所包含的字符种类相同(对重复字符不敏感)

# 转为hashTable作比较
## sensitive
使用count_chars得到hashTable再比较(对重复字符敏感)
>EqualRule-sensitive <==> hashTableA == hashTableB
	
	<?php 
	$str1 = 'abcdef';
	$str2 = 'efabcd';
	count_chars($str1,1) === count_chars($str2,1)?'Y':'N';

## insensitive
使用count_chars得到hashTable再比较(对重复字符不敏感)
>EqualRule-insensitive <==> hashTableA == hashTableB
	
	<?php 
	$str1 = 'abcdef';
	$str2 = 'efabcd';
	array_keys(count_chars($str1,1)) === array_keys(count_chars($str2,1))?'Y':'N';


# 转为一个特征值再比较
## sensitive

>EqualRule-sensitive <==> F(str1)==F(str2) #F是一个公式,返回的是一个数(特征值)

@江南烟雨给出的思路是利用质数原理构成一个F.

>需要事先准备好足够的质数
> 给每个字符取一个独立唯一的质数:比如a->2 b->3 c->5 ....
> 对于每个字符串取的特征值为: 每个字符特征值的乘积.

比如:
	
	F('abc') = 2*3*5	


## insensitive
>EqualRule-insensitive <==> F(str1)==F(str2) #F是一个公式,返回的是一个数(特征值)

F表达式可以利用二进制定义:
>需要足够位数的数(或者通过字符串代替数)
>每个字符定义一个二进制数特征值(4字节): 如a->"0x01" b=>"0x01"<<1 ("0x02") c=>"0x01"<<2 ("0x04") ...
>遍历并与每个字符串的特征值相或.

比如:
	
	F('aabc') =F('a') | F('a') | F('b') | F('c') = "0x01" |"0x01"|"0x02"|"0x04" ="0x07" = "0111";


# 转为桶集判断
>EqualRule <==> 桶集判断
>相对以上算法,桶的效率最快.时间o(2n)->o(n),因为str1+str2包含有限的字符种数<有限的字符集总数,所以空间是o(1)
>本节定义的桶集本身就是一个hashTable.但只对str1生成一次hashTable.(放球到桶里)

@肥猫的主意
> 数组a，26个英文字母，当然，你要大小写区分用52个。大小写不区分位运算一下。 
扫描第一个数组扫描一次，然后buckets[s]++;s为你扫描到的那个字符(就叫往s桶放一个球吧) 
>再扫描第二个数组一次，然后buckets[s]--；s为扫描到的那个字符(s桶弄出一个球吧)
若两次扫描后，桶为空，则相等。

## sensitive
以下是示例. 我本想正则的*平衡组*应该也可以做充当这样的桶吧(冒充放球出球的动作),不过反向引用无法区分不同的桶(不同的字符),所以....
给一个php示例:

	<?php
		$str1= 'aba';
		$str2= 'baa';
		$buckets = array();//桶集
		$i = 0;
		while($k=$str1[$i++]){
			++$buckets[$k];//放一个球$str1[$i]
		}
		$i = 0;
		while($k=$str2[$i++]){
			--$buckets[$k];//拿一个球$str1[$i]
			if(0===$buckets[$k]){
				unset($buckets[$k]);//把空桶拿走吧	
			}
		}

		echo empty($buckets)?'Y':'N';



## insensitive
如果对重复的球不敏感,我就换一种说法吧,叫涂色(对桶来说,多次涂色不敏感)

	<?php
		$str1= 'aba';
		$str2= 'baa';
		$buckets = array();//桶集
		$throwBuckets = array();//被丢弃的桶集
		$i = 0;
		while($k=$str1[$i++]){
			$buckets[$k]=1;//给桶涂色$str1[$i](涂色不敏感)
		}
		$i = 0;
		while($k=$str2[$i++]){
			if(isset( $buckets[$k])){
				unset( $buckets[$k] );//把空桶拿走吧	
				$throwBuckets[$k] = 1;//丢弃的桶我们登记一下.	
			}elseif(!isset($throwBuckets[$k])){
				$buckets[$k] = 1;//如果找不到以前涂过色的桶,则清桶失败(str2有字符不被str1所包括)
				break;
			}

		}
		echo empty($buckets)?'Y':'N';

# 查找字符集
>EqualRule <==> 按定义:查找一方字符集是否完全出现在另一方(并集)
>EqualRule <==> 按定义:查找一方字符集是否完全不出现在另一方(差集)
>这个只是按定义求解.(时间o(n^2),空间o(1)). 

## insensitive
### 利用正则查找

	<?php
	$str1='abc';
	$str2='cab';
	echo preg_match('#^['.$str1.']*$#', $str2) ?'Y': 'N';//交集

也可以用差集:

	echo preg_match('[^'.$str1.']+', $str2) || preg_match('[^'.$str2.']+', $str1) ?'N': 'Y';//差集

$str1,$str2可能有"恶意的字符",可以先转为十六进制表示(或者转义特殊字符)

	$str1='a*bc#';
	$str2='#*cab';
	for($pattern1='',$i=0,$max=strlen($str1);$i<$max;$i++){
		$pattern1.='\x'.dechex(ord($str1[$i]));
	}
	echo preg_match('#^['.$pattern1.']*$#', $str2) ?'Y': 'N';

### 利用字符函数查找
php有strspn

	strlen($str1) === strspn($str1,$str2)?'Y':'N';//并集


# 字符排序再比较
>EqualRule <==> sortedStrCompare
排序效率应该是依赖于排序算法本身.
对排序后的两个字符串做比较可以有:*并运算* 或者 *字符全等*都可以比较

## sensitive
伪代码:
	
	(sort($str1) & sort($str2)) ? 'Y':'N';
	sort($str1) === sort($str2) ? 'Y':'N';
## insensitive
伪代码:
	
	unique(sort($str1)) === unique(sort($str2)) ? 'Y':'N';

php有现成的:

	<?php
	count_chars($str1,3) === count_chars($str2,3)?'Y':'N';
