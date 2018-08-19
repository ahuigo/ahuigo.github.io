---
layout: page
title: coder试题:有几个bing?	
category: blog
description: 
---

# 有几个bing?

[题目](http://hero.csdn.net/question/details?id=215&examid=210)

题目详情
本届大赛由微软必应词典冠名，必应词典(http://cn.bing.com/dict/?form=BDVSP4&mkt=zh-CN&setlang=ZH)是微软推出的新一代英语学习引擎，里面收录了很多我们常见的单词。但现实生活中，我们也经常能看到一些毫无规则>的字符串，导致词典无法正常收录，不过，我们是否可以从无规则的字符串中提取出正规的单词呢？
例如有一个字符串"iinbinbing"，截取不同位置的字符‘b’、‘i’、‘n’、‘g’组合成单词"bing"。若从1开始计数的话，则‘b’ ‘i’ ‘n’ ‘g’这4个字母出现的位置分别为(4,5,6,10) (4,5,9,10),(4,8,9,10)和(7,8,9,10)，故总共可以
组合成4个单词”bing“。
咱们的问题是：现给定任意字符串，只包含小写‘b’ ‘i’ ‘n’ ‘g’这4种字母，请问一共能组合成多少个单词bing?

字符串长度不超过10000，由于结果可能比较大，请输出对10^9 + 7取余数之后的结果。

我用的是递归穷举，还没有想到更好的方法.

	#include<stdio.h>
	#include<string.h>
	int countChar(char *str, char c, int pos);
	int countWord (char* str, char* needle) {
		int strLen = 0,
			needleLen = 0,
			nC1 = 0,
			count = 0;
		char *newNeedle;
		needleLen = strlen(needle);

		if(*str == '\0'){
			return 0;
		}

		//search char
		if(needleLen <= 1){
			return countChar(str, *needle, 0);  
		}

		//search string
		char c1 = *needle,c2 = *(needle+1);
		newNeedle = needle+2;
		while(*str != '\0'){
			if(*str == c1){
				++nC1;      
			}else if(*str == c2 && nC1){
				if(needleLen == 2){
					count += nC1;       
				}else{
					count += nC1 * countWord(str+1, newNeedle);         
				}
			}
			str++;  
		}

		return count;
	}
	int countChar(char *str, char c, int pos){
		int n = 0;
		str+=pos;
		while(*str != '\0'){
			if(*str++ == c) n++;
		}
		return n;
	}
	int main()
	{
		char str[] = "iinbinbing", 
			needle[] = "bing";
		int pos = 0;
		printf("%d", countWord(str,needle));
	}
