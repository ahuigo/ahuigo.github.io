---
layout: page
title:	Octave 使用
category: blog
description: 
---
# Preface
Matlab 授权费太贵，也太重了。还是开源的gnu octave 比较适合我。本文就记录下octave 的使用。
本文参考：[学点octave]

# Install
加--without-docs, 否则它会要求你安装mactex， 这货是TeX Live的一个TeX分支，如果你不需要的话

	# 在mac 中 octave 使用plot 作图需要--qt (qt terminal) 或者 --wx (wxWidget terminal). 在gnuplot 中执行set term 可以查看它所支持的terminal
	brew install gnuplot --qt
	echo 'export GNUTERM=qt' >> ~/.zshrc
	# install octave
	brew install octave --without-docs

# 公式计算
	# logarithmic 对数
	log(e)
	log2(2)
	log10(10)
	log(x)/log(a) # 以a 为底 x 的对数

# Matrix 矩阵

## 生成
	x = [1 2 3 ];
	x = [1 2 3; 2 5 6 ];
	x = 1:5 ;#连续向量
	x = 1:0.1:5;
	linspace(start, end, N);# 
	linspace(start, end, N)产生N个均匀分布于start和end之间的向量。 在绘图时用于产生x坐标特别有用。

	logspace(start, end, N)产生N个指数分布于10^start和10^end之间的向量。 在绘图时用于产生x坐标特别有用。

	zeros(M, N)产生一个M行 x N列的值全为0的矩阵。
	zeros(N)

	ones(M, N)产生一个M行 x N列的值全为1的矩阵。
	ones(N)

	rand(M, N)产生一个M行 x N列的值位于0~1的随机数的矩阵。
	rand(N)

## 矩阵运算
	# 矩阵乘法 要求MxN维矩阵乘以NxL维矩阵, 得到的是MxL阶矩阵
	A*B
	# 矩阵点乘 要求MxN维矩阵乘以MxN维矩阵, 或者其中一个是纯数 得到的是同阶矩阵
	A.*B
	# 两种除法运算：左除（\）和右除（/）。
	# x=a\b是方程a*x =b的解，而x=b/a是方程x*a=b的解。
	a=[1  2  3; 4  2  6; 7  4  9]
	b=[4; 1; 2];
	x=a\b
	# 点除和点乘 一样，属于同阶运算
	A./B
	# 矩阵求幂 A*A*A 与 A.*A.*A
	A^3 
	A.^3 
	# eig求方阵A的特征值 与 特征向量
	octave:15> A = [1 2 3 ; 4 5 6 ; 7 8 9];
	octave:16> eig(A)
	ans =

	   1.6117e+01
	  -1.1168e+00
	  -1.3037e-15

	octave:17> [X D] = eig(A)
	X =

	  -0.231971  -0.785830   0.408248
	  -0.525322  -0.086751  -0.816497
	  -0.818673   0.612328   0.408248

	D =

	Diagonal Matrix

	   1.6117e+01            0            0
				0  -1.1168e+00            0
				0            0  -1.3037e-15


	# A 的QR分解
	[Q R] = qr(A)
	

# 变量

## 查看变量
	# 查看所有的变量
	octave:6> who
	# 查看变量值
	octave > disp(x)
	octave > x

# 常量
e,pi,Inf,NaN

# 显示
	octave> format long

# 工作区
	octave> save work1
	octave> load work1


# plot
octave 默认是使用gnuplot 的 aqua term 画图, 我用的是qt term. gnuplot 需要单独安装的。

	# 单条线
	x = linspace(0, 10, 1000);y=sin(x); plot(x,y);
	plot(x,y, 'ro'); //'ro' , '-'
	# 两条线
	z=cos(x);
	plot(x,y,x,z);
	
## 窗口说明
	> title('sin cos');
	> xlabel('x');
	> ylabel('y');
	> legend('sin(x)', 'cos(x)')

	# 加网格线
	> grid on

## 保存
	> print(‘/tmp/sin.png’, ‘-dpng’)
	> print(‘/tmp/sin.eps’, ‘-deps’)

## plot3
画曲线，比如以z为轴螺旋曲线

	z=0:0.1:4*pi; plot3(cos(z),sin(z), z);
	xlabel('x'); ylabel('y'); zlabel('z'); 
 
## surf & meshgrid
	x=-4:.2:4; y=-4:.2:4;
	[X,Y] = meshgrid(x,y); #定义栅格
	Z = X.^2+Y.^2; #椭圆锥
	Z = sqrt(X.^2+Y.^2); #圆锥
	surf(X,Y,Z);

	三维线条 plot3()；
	三维的条形图 stem3()；
	三维的面 surf()；
	三维的球 sphere()；
	三维的椭球 ellipsoid()；
	三维的柱面 cylinder()；

## Implicit function

### ezplot
画隐函数用ezplot
ezplot(f,[xmin,xmax,ymin,ymax])

	f=@(x,y)x.^2+y.^2-10000;
	ezplot(f,[-100,100,-100,100]);
	ezplot('x^2+y^2-3');

### 3d implicit function
如何画三维的图呢? 

	x^2+y^2=sin(z)^2.

You can use for instance the Matlab "ndgrid" and
"isosurface" functions to generate your 3D implicit plot.
The rendering is similar to the one obtained with the
"plotimplicit3d" Maple function. [1](http://www.mathworks.com/matlabcentral/newsreader/view_thread/152947)

	[Y,X,Z] = ndgrid(linspace(-2,2,15),linspace(-2,2,15),linspace(-2,2,15));
	V = Y.^2+Y.^2-(sin(Z)).^2; % evaluate your implicit function over the N-D grid
	p = patch(isosurface(X,Y,Z,V,0));
	isonormals(X,Y,Z,V,p);
	set(p,'FaceColor','b','EdgeColor','k','FaceAlpha',0.5); 

或者 将sin(z) 看作是常量。
You can also use 'surf' with a parametric representation of your surface.

	z = linspace(0:4*pi); % <-- Or whatever range you want for z
	t = linspace(0:2*pi);
	[Z,T] = meshgrid(z,t);
	X = sin(Z).*cos(T);
	Y = sin(Z).*sin(T);
	surf(X,Y,Z)


# Math Equation
http://math.stackexchange.com/editing-help
Mathematics Stack Exchange uses MathJax to render LaTeX. You can use single dollar signs to delimit inline equations, and double dollars for blocks:

http://www.ituring.com.cn/article/32403
这个公式解释如下：

\pi 表示希腊字母 π，\infty 表示 ∞。更多的符号请参见：Special Symbols 。
\frac{分子}{分母} 表示分数。另外，\tfrac{分子}{分母} 表示小号的分数。
\sqrt{被开方数} 表示平方根。另外，\sqrt[n]{x} 表示 n 次方根。
\sum_{下标}^{上标} 表示求和符号。另外，\prod 表示乘积符号，\int 表示积分符号。
_{下标} 和 ^{上标} 可以用在任何地方。如果上下标只是一个字符，可以省略 { 和 } 。
此外，\ldots 和 \cdots 都表示省略号，前者排在基线上，后者排在中间。
还有：\pm：±、\times：×、\div：÷ 。

[学点octave]: http://blog.chenming.info/blog/2012/07/15/learn-octave/
