---
layout: page
title:	c 语言的正则库
category: blog
description: 
---
# Preface

c 语言的posix 正则库参考: man 3 regex, 不过我更喜欢用pcre, 可参考 `man 3 pcreapi`

以下是两个例子

# Posix Regex
这个posix regex 例子来自于:  
http://blog.csdn.net/sahusoft/article/details/4196342

它使用了regcomp 和 rgeexec

	#include <stdio.h>
	#include <string.h>
	#include <regex.h>
	
	#define SUBSLEN 10              /* 匹配子串的数量 */
	#define EBUFLEN 128             /* 错误消息buffer长度 */
	#define BUFLEN 1024             /* 匹配到的字符串buffer长度 */

	int main() {
			size_t          len;
			regex_t         re;             /* 存储编译好的正则表达式，正则表达式在使用之前要经过编译 */
			regmatch_t      subs [SUBSLEN];     /* 存储匹配到的字符串位置 */
			char            matched   [BUFLEN];     /* 存储匹配到的字符串 */
			char            errbuf    [EBUFLEN];    /* 存储错误消息 */
			int             err, i;

			char            src       [] = "111 <title>Hello World</title> 222";    /* 源字符串 */
			char            pattern   [] = "<title>(.*)</title>";    /* pattern字符串 */

			printf("String : %s\n", src);
			printf("Pattern: %s\n", pattern);

			/* 编译正则表达式 */
			err = regcomp(&re, pattern, REG_EXTENDED);

			if (err) {
					len = regerror(err, &re, errbuf, sizeof(errbuf));
					printf("error: regcomp: %s\n", errbuf);
					return 1;
			}
			printf("Total has subexpression: %lu \n", re.re_nsub);
			/* 执行模式匹配 */
			err = regexec(&re, src, (size_t) SUBSLEN, subs, 0);

			if (err == REG_NOMATCH) { /* 没有匹配成功 */
					printf("Sorry, no match ...\n");
					regfree(&re);
					return 0;
			} else if (err) {  /* 其它错误 */
					len = regerror(err, &re, errbuf, sizeof(errbuf));
					printf("error: regexec: %s\n", errbuf);
					return 1;
			}

			/* 如果不是REG_NOMATCH并且没有其它错误，则模式匹配上 */
			printf("\nOK, has matched ...\n\n");
			for (i = 0; i <= re.re_nsub; i++) {
					len = subs[i].rm_eo - subs[i].rm_so;
					if (i == 0) {
							printf ("begin: %lld, len = %lud  ", subs[i].rm_so, len); /* 注释1 */
					} else {
							printf("subexpression %d begin: %lld, len = %lud  ", i, subs[i].rm_so, len); 
					}
					memcpy (matched, src + subs[i].rm_so, len);
					matched[len] = '\0';
					printf("match: %s\n", matched);
			}

			regfree(&re);   /* 用完了别忘了释放 */
			return (0);
	}

Results:

	String : 111 <title>Hello World</title> 222
	Pattern: <title>(.*)</title>
	Total has subexpression: 1

	OK, has matched ...

	begin: 4, len = 26d  match: <title>Hello World</title>
	subexpression 1 begin: 11, len = 11d  match: Hello World

# PCRE Regex
pcre 比posix 功能更强大，效率更高。它使用了pcre_compile 和pcre_exec

	/* Compile thuswise:    
	*   gcc -Wall pcre.c -I/usr/local/include -L/usr/local/lib -lpcre
	*  On Mac OSX:
	*  	gcc pcre.c -lpcre
	*/     
	#include <stdio.h>
	#include <string.h>
	#include <pcre.h> 
	                
	#define OVECCOUNT 40
	#define EBUFLEN 128            
	#define BUFLEN 1024           
	        
	int main() {               
		pcre *re; 
		const char *error;
		int  erroffset;
		int  ovector[OVECCOUNT];
		int  rc, i;
		
		char src[] = "111 <title>Hello pcre World</title> 222";
		char pattern[] = "<title>(.*)</title>";
				
		printf("String : %s\n", src);
		printf("Pattern: %s\n", pattern);
		

		//re = pcre_compile(pattern, PCRE_DOTALL, &error, &erroffset, NULL);//PCRE_DOTALL 表示"."匹配回车换行
		re = pcre_compile(pattern, 0, &error, &erroffset, NULL);
		if (re == NULL) {
			printf("PCRE compilation failed at offset %d: %s\n", erroffset, error);
			return 1;
		}

		rc = pcre_exec(re, NULL, src, strlen(src), 0, 0, ovector, OVECCOUNT);
		if (rc < 0) {
			if (rc == PCRE_ERROR_NOMATCH) printf("Sorry, no match ...\n");
			else    printf("Matching error %d\n", rc);
			free(re);
			return 1;
		}

		printf("\nOK, has matched ...\n\n");

		for (i = 0; i < rc; i++) {
			char *substring_start = src + ovector[2*i];
			int substring_length = ovector[2*i+1] - ovector[2*i];
			printf("%2d: %.*s\n", i, substring_length, substring_start);
		}

		free(re);
		return 0;
	}

Result:

	String : 111 <title>Hello pcre World</title> 222
	Pattern: <title>(.*)</title>

	OK, has matched ...

	 0: <title>Hello pcre World</title>
	 1: Hello pcre World
