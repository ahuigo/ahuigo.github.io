---
layout: page
title:	latex 数学公式
category: blog
description:
---
# Preface
数学公式：
- [latex 数学公式](http://zh.wikipedia.org/wiki/Help:%E6%95%B0%E5%AD%A6%E5%85%AC%E5%BC%8F)
- [常用数学公式](http://www.ituring.com.cn/article/32403)

# Learn latex
http://www.jianshu.com/p/e59aaac15088

## Mac OSX latex
http://www.zhihu.com/question/20928639

在 OS X 上，主流的 TeX 发行版是 MacTeX。这是一个基于 TeX Live 之上的封装，和 TeX Live 的主要区别是：
1. 采用 OS X 专用的方式打包，安装简便，不劳心配置；
2. 封装了一系列为 OS X 设计的工具（LaTeXit、TeXshop、TeX Live Utilities 等）

BasicTeX 和 MacTeX 类似，也是对 TeX Live 的封装。
> 不过，相比 MacTeX，BasicTeX 中缺少很多宏包。在使用的时候，需要先手工安装这些宏包，然后使用。对于新手来说，这又是个不小的工程。所以不推荐新手使用。

# Api && Lib
[google api](http://chart.apis.google.com/chart?cht=tx&chl=O%28%5Clog+n%29)

## MathJax
这是一个js 库. 用法如`$a^2=b$` as in-line or `$$a^2=b$$` as block
1. 还有：kaTex
2. web app: markx(pageDown), stackedit

http://docs.mathjax.org/en/latest/misc/mathjax-in-use.html 全局渲染

    src="MathJax.js?config=TeX-AMS-MML_HTMLorMML"
    //via getElementsByTagName("script").filter MathJax 找到config

## katex

    katex.render(String.raw`c = \pm\sqrt{a^2 + b^2}`, element);
    var html = katex.renderToString("c = \\pm\\sqrt{a^2 + b^2}");

## MathJax+markdown
marked 配置:

	marked.setOptions({
		//renderer: new marked.Renderer(),
		gfm: true,
		tables: true,
		breaks: true,
		pedantic: false,
		sanitize: false, 
		smartLists: true,
		smartypants: false,
		latexRender: katex.renderToString.bind(katex),
	});
    marked(text)

# 函数、符号、及字符
## 字符
    换行 $a\\b$
    tab $b \quad a$
    tab $b \qquad a$

## Label

    ${\overline a}_{n}$
    ${\bar a}$

${\overline a}_{n}$
${\bar a}$

## displaystyle

    \displaystyle \lim_{u \rightarrow \infty}

## Vectors, 向量

    $\vec{a}$

另`\overrightarrow `和`\overleftarrow`在定义从A 到B 的向量时非常有用:
$\overrightarrow{AB}$ 和 $\overleftarrow{AB}$

## Latex符号

    \, space
	\pi 表示希腊字母 π，\infty 表示 ∞。更多的符号请参见：Special Symbols 。
	\sqrt{被开方数} 表示平方根。另外，\sqrt[n]{x} 表示 n 次方根。
	\sum_{下标}^{上标} 表示求和符号。
        _{下标} 和 ^{上标} 可以用在任何地方。如果上下标只是一个字符，可以省略 { 和 } 。
	\frac{分子}{分母} 表示分数。另外，\tfrac{分子}{分母} 表示小号的分数。

	此外，\ldots 和 \cdots 都表示省略号，前者排在基线上，后者排在中间。
	还有：\pm：±、\times：×、\div：÷ 。

## 函数
	\sin a
    \sin^{2}x + \cos^{2}x = 1
    \cos b
    \tan c
	O(\log n)
    \lim_{u \rightarrow \infty}

The *Gamma function* satisfying
$$\Gamma(n) = (n-1) !\quad\forall n\in\mathbb N$$

$$
\Gamma(z) = \int_0^\infty t^{z-1}e^{-t}dt\,.
$$

### 对数, logarithmic

    \log_{a}{b}

### 根

    \sqrt {2}
	\sqrt{x} \sqrt[n]{x}

## 上下标
	a^2
	a_2

## 排列组合
    $\binom{n}{k}=\mathrm{C}_n^k$

	$\prod_{i=1}^{\infty} a_{i}$, $\prod$表示乘积符号，
	$\int_{-N}^{N} e^x,dx$, \int 表示积分符号。
    $\iint_{D}^{W} \, dx\,dy$	双重积分

## 分数fraction、矩阵和多行列式

	//分数
	\frac{2}{4}=0.5 2/4=0.5
	//分数嵌套
	\cfrac{2}{c + \cfrac{2}{d + \cfrac{2}{4}}} = a
	//
	\frac{分子}{分母} 表示分数。另外，\tfrac{分子}{分母} 表示小号的分数。


\frac{分子}{分母} 表示分数。另外，\tfrac{分子}{分母} 表示小号的分数。

\sqrt{被开方数} 表示平方根。另外，\sqrt[n]{x} 表示 n 次方根。

\sum_{下标}^{上标} 表示求和符号: $\sum_{i=1}^{2n} x^i$。另外，\prod 表示乘积符号，\int 表示积分符号。

_{下标} 和 ^{上标} 可以用在任何地方。如果上下标只是一个字符，可以省略 { 和 } 。
此外，\ldots 和 \cdots 都表示省略号，前者排在基线上，后者排在中间。
还有：\pm：±、\times：×、\div：÷ ****。

# table

    $$ 
    \begin{array}{|c|c|c|c|}
    \hline
    1& 1 > -1 & 1 & -1 \\ \hline
    & 3 & 55 & 44\\ \hline
    & 4 & 93 & 33\\ \hline
    & 5 & 6 &  22\\ \hline
    \end{array}$$

$$ 
\begin{array}{|c|c|c|c|}
\hline
1& 1 > -1 & 1 & -1 \\ \hline
& 3 & 55 & 44\\ \hline
& 4 & 93 & 33\\ \hline
& 5 & 6 &  22\\ \hline
\end{array}$$

# combination
$\binom m{n+1}=\binom mn+ \binom {m-1}n$
$(A\cup B)^{C}=A^{C}\cap B^{C}$

B的情况下A的概率	${\displaystyle P(A\mid B)={\frac {P(A\cap B)}{P(B)}}={\frac {P(B|A)P(A)}{P(B)}}}$
