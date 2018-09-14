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

## LaTeX with markdown
Mathematics Stack Exchange uses `MathJax` to render LaTeX. You can use single dollar signs to delimit inline equations, and double dollars for blocks:

	The *Gamma function* satisfying $\Gamma(n) = (n-1)!\quad\forall
	n\in\mathbb N$ is via through the Euler integral

	$$
	\Gamma(z) = \int_0^\infty t^{z-1}e^{-t}dt\,.
	$$

or

    无理数: $\sqrt {2}$,
    圆周: \\( \pi *r= circumference\\)

# Api && Lib
[google api](http://chart.apis.google.com/chart?cht=tx&chl=O%28%5Clog+n%29)

## MathJax
这是一个js 库. 用法如`$a^2=b$` as in-line or `$$a^2=b$$` as block
1. 还有：kaTex
2. web app: markx(pageDown), stackedit

http://docs.mathjax.org/en/latest/misc/mathjax-in-use.html 全局渲染

    src="MathJax.js?config=TeX-AMS-MML_HTMLorMML"
    //via getElementsByTagName("script").filter MathJax 找到config

### katex

    katex.render(String.raw`c = \pm\sqrt{a^2 + b^2}`, element);
    var html = katex.renderToString("c = \\pm\\sqrt{a^2 + b^2}");

### MathJax+markdown
1. MathJax 与 Markdown 的究极融合 https://yihui.name/cn/2017/04/mathjax-markdown/
1. 支持markdown 的库: showdown/pageDown/marked

marked:

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
    marked*(text)

# 函数、符号、及字符
http://www.cnblogs.com/houkai/p/3399646.html

## Label

    ${\overline a}_{n}$
    ${\bar a}$

${\overline a}_{n}$
${\bar a}$

## limit
    \displaystyle \lim_{u \rightarrow \infty}

## Vectors, 向量

    $\vec{a}$

另`\overrightarrow `和`\overleftarrow`在定义从A 到B 的向量时非常有用:
$\overrightarrow{AB}$ 和 $\overleftarrow{AB}$

## Greece, 希腊字符
http://blog.sina.com.cn/s/blog_5e16f1770100lxq5.html
https://bcc16.ncu.edu.tw/7/latex/math_tex/2-html/

    \alpha产生字符α;\beta产生字符β；\gamma产生字符γ；\delta产生字符δ;
    \epsilon产生字符ε; \zeta产生字符ζ；
    \eta产生字符η;
    \iota I产生字符ι,I；
    \kappa产生字符κ；
    \1ambda产生字符λ；\mu产生字符μ；\xi产生字符ξ：
    \nu产生字符ν；\o产生字符o； \pi产生字符π；
    \rho P产生字符ρ,P；
    \sigma \Sigma产生字符σ, Σ(⌥+w)；
    \varsigma ς
    \tau产生字符τ;
    \upsilon产生字符υ；
    \theta \Theta  øΘ(⌥ +o)
    \phi \Phi产生字 𝛗ϕΦ
    \psi \Psi产生字 ψΨ；
    \chi X产生字符χ,Χ；
    \omega $\omega$产生字符ω,Ω
    \pi \Pi 得到: π, Π


Α	α	Alpha	a
Β	β	Beta	b
Γ	γ	Gamma	g
Δ	δ	Delta	d
Ε	ε	Epsilon	e
Ζ	ζ	Zeta	z
Η	η	Eta	h
Θ	θ	Theta	th
Ι	ι	Iota	i
Κ	κ	Kappa	k
Λ	λ	Lambda	l
Μ	μ	Mu	m
Ν	ν	Nu	n
Ξ	ξ	Xi	x
Ο	ο	Omicron	o
Π	π	Pi	p
Ρ	ρ	Rho	r
Σ	σ,ς *	Sigma	s
Τ	τ	Tau	t
Υ	υ	Upsilon	u
Φ	φ	Phi	ph
Χ	χ	Chi	ch
Ψ	ψ	Psi	ps
Ω	ω	Omega	o

### Mathematical Symbols, 数学符号
https://www.howtotype.net/category/all_symbols/

    √ (square root): OPTION + v
    ÷ (division): OPTION + ?
    ≤ (less than or equal to): OPTION + <
    ≥ (greater than or equal to): OPTION + >
    ^ (circumflex): OPTION + i
    ≠ (not equal to): OPTION + =
    ≈ (almost equal to): OPTION + x
    ± (plus-minus): OPTION + shift + =
    ∞ (infinity): OPTION + 5
    ø (empty set): OPTION + o
    ∑ (N-ary summation or Sigma): OPTION + w
    ƒ (function): OPTION + f
    ∫ (integral): OPTION + b
    ∂ (partial differential): OPTION + d

	Asymptotic	≈
 	Degree symbol	°
 	Delta	Δ
 	Division sign	÷
 	Fraction 1/2	½
 	Fraction 1/4	¼
 	Fraction 3/4	¾
 	Greater than	>
 	Greater than or equal	≥
 	Infinity symbol	∞
 	Left Angle Bracket	〈
 	Less than	<
 	Less than or equal	≤
 	Micro	µ
 	Multiplication sign	×
 	not symbol	¬
 	Ohm sign	Ω
 	Per Mille (1/1000) sign	‰
 	Pi symbol	π
 	Plus/minus sign	±
 	Right Angle Bracket	〉
 	square root radical sign	√
 	Sum sign	∑
 	Superscript one	¹
 	Superscript three - cubed	³
 	Superscript two - squared	²

### Input Symbols, 常用输入符号

	⌥ +K 
	⌥ +R ‰
	⌥ += ≠
	⌥ ++ ±
	⌥ +@ €
	⌥ +2 ™
	⌥ +3 £
	⌥ +5 ∞
	⌥ +6 §
	⌥ +( ·
	⌥ +z Ω
	⌥ +o ø
	⌥ +O Ø
	⌥ +p π
	⌥ +v √
	⌥ +w ∑
	⌥ +b ∫
	⌥ +r ®
	⌥ +g ©
	⌥ +, ≤
	⌥ +. ≥
	⌥ +j ∆
	⌥ +x ≈
	⌥ +m µ
	⌥ +f ƒ
    苹果标志 （Shift+Option+K）
    Copyright © (Option+G)
    美元 $ (Shift+4)
    美分 ￠ (Option+4)
    英镑 ￡ （Option+3)
    日元 ￥(Option+Y)
    欧元 €（Shift+Option+2）
    破折号 –(Option+-)
    约等于 ≈（Option+X)
    度 °(Shift+Option+8)
    除号 ÷（Option+/)
    循环 ∞（Option+5）
    小于等于≤（Option+,)
    大于等于≥（Option+.)
    不等于≠（Option+=）
    Pi π（Option+P）
    正负号 ±(Shift+Option+=)
    平方根√（Option+V)
    求和 ∑（option+w）
    产品标识 ™（Option+2)

	¶•ªº–≠
	`⁄€‹›ﬁﬂ‡°·‚—±

	œ∑®†¥øπ“‘«
	Œ„´‰ˇÁ¨ˆØ∏”’»

	åß∂ƒ©˙∆˚¬…æ
	ÅÍÎÏ˝ÓÔÒÚÆ

	Ω≈ç√∫∫µ≤≥÷
	¸˛Ç◊ı˜Â¯˘¿

For more details,refer to [Type Symbols](http://www.wikihow.com/Type-Symbols-Using-the-ALT-Key)

### Latex符号

	\pi 表示希腊字母 π，\infty 表示 ∞。更多的符号请参见：Special Symbols 。
	\sqrt{被开方数} 表示平方根。另外，\sqrt[n]{x} 表示 n 次方根。
	_{下标} 和 ^{上标} 可以用在任何地方。如果上下标只是一个字符，可以省略 { 和 } 。
	此外，\ldots 和 \cdots 都表示省略号，前者排在基线上，后者排在中间。
	还有：\pm：±、\times：×、\div：÷ 。

	\sum_{下标}^{上标} 表示求和符号。
	\prod{i=0}^N x_i 表示乘积符号，
	\int_{-N}^{N} e^x\, dx 表示积分符号。
	\iint_{D}^{W} \, dx\,dy	双重积分

	\pi 表示希腊字母 π，\infty 表示 ∞。更多的符号请参见：Special Symbols 。
	\frac{分子}{分母} 表示分数。另外，\tfrac{分子}{分母} 表示小号的分数。
	\sqrt{被开方数} 表示平方根。另外，\sqrt[n]{x} 表示 n 次方根。
	\sum_{下标}^{上标} 表示求和符号。另外，\prod 表示乘积符号，\int 表示积分符号。
	_{下标} 和 ^{上标} 可以用在任何地方。如果上下标只是一个字符，可以省略 { 和 } 。
	此外，\ldots 和 \cdots 都表示省略号，前者排在基线上，后者排在中间。
	还有：\pm：±、\times：×、\div：÷ 。

## 函数
	\sin a
    \sin^{2}x + \cos^{2}x = 1
    \cos b
    \tan c
	O(\log n)

## 对数, logarithmic

    \log_{a}{b}

## 根

	\sqrt{x} \sqrt[n]{x}

## 上下标
	a^2
	a_2

# 分数fraction、矩阵和多行列式

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
