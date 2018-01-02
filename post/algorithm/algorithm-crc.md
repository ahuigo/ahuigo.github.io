---
layout: page
title:	crc 循环冗余校验
category: blog
description:
---
# Preface
CRC(Cyclic Redundancy Check, 循环冗余校验)

在数字通信中，信号难免会发生错误，为了检测信号错误，就出现了各种检验方法，常见的有奇偶校验(Parity Check)、CRC 校验(Cyclic Redundancy Check)。


	Quotient 商
	Reminder 余
	divisor(K) 除数
	dividend 被除数

# Parity Check, 奇偶校验
最简单的检验是奇偶校验位(Parity Bit)：

	奇检验：7bit 数据+ 检验位(1 的个数是奇数个 则为0)
	1000 000 0
	偶检验：7bit 数据+ 检验位(1 的个数是偶数个则为0)
	1000 000 1

# CRC, 循环冗余校验
循环冗余校验（英语：Cyclic redundancy check，通称“CRC”）是一种根据网络数据包或电脑文件等数据产生简短固定位数校验码的一种散列函數，主要用来检测或校验数据传输或者保存后可能出现的错误。

“错误纠正编码”（Error–Correcting Codes，简称ECC）常常和CRCs紧密相关，其语序纠正在传输过程中所产生的错误。这些编码方式常常和数学原理紧密相关。例如常见于通信或信息传递上BCH码、前向纠错、Error detection and correction等。

## 模2 运算
模2运算包括模2加减乘除4种，模2 运算与普通的加减乘法只有一点不同，它会忽略借位与进位.

比如: 模2加法运算为：1+1=0，0+1=1，0+0=0，无进位，也无借位；模2减法运算为：1-1=0，0-1=1，1-0=1，0-0=0，也无进位，无借位。因为这种特点，模2 加减法完全可以用XOR 异或来代替

模2 乘除是基于模2加减法的，当然也要忽略进位与借位。

> 这个和一般的进位运算不太一样，不必纠结进制的问题。定义就是如此

### 模2 运算性质
- 模2加减法满足交换率结合率
- `a+b+b=a`, `a-b-b=a`, 其实这就是XOR 的性质`a^b^b=a`

### 模2除法
想知道模2除法，只需要知道什么是异或运算就很容易算出。

多位模2除法采用模2减法，不带借位的二进制减法，因此考虑余数够减除数与否是没有意义的。运算过程如下：

            1011
        --------------
    1101|1111000
        |1101
        |--------
           1000
           1101
           --------
            1010
            1101
            --------
             111
    我们可以反过来，一样成立：1111000 = 1101 * 1011 + 111
        1101
    x   1011 (R=111)
    -----------
         111
        1101
       1101
     1101
     -------------
     1111000
             
例子2：
被校验的数据M(x)=1000，其选择生成多项式为G(x)=x^3+x+1,该数据的循环冗余校验和应为多少？
M(x)*x^3
            1111
        --------
    1011|1000000
         1011
         -------
           1100
           1011
           -------
            1110
            1011
            ----
             101
    T = 1000101B
    
### CRC 证明
假如生成多项式是G(x), 商是Q(x), 余数R(x)

发送方: $x^rM(x) = G(x)Q(x)+R(x)$

接收方收到加检验的R:
$T(x) = x^rM(x)+R(x)$
$T(x) = G(x)Q(x)+R(x)+R(x)=G(x)Q(x)$

由于模2加法相当于异或运算，于是接收方T除以G得到的商数为0，得证。



## CRC 计算

### 原始的CRC
对于消息M(m bits), 我们找一个除数K(n+1 bits, 又叫生成多项式), 然后我们需要计算检验码R(n bits)，计算方式如下：

	Ml = M << n
	R = Ml Mod2 K
	T = Ml | R 相当于 T = Ml + R

R 就是n bits 的校验码，则T 就是最后要传送的消息。T 由消息Ml 与 R 两部分构成
接收端收到消息T 后，`T mod2 K` 得到的余数应该是0， 如果不是0， 就说明Ml 一定出错了(R是正确的前提)

如果用多项式系数来表达Ml, R, T:

	Ml = M(x)*x^n
	R = R(x) = Ml mod2 K(x)
	T = M(x)*x^n + R(x) = Q(x)*K(x)

Example1:

	M = 111,  K = 11
	Ml = 111 << 1 = 1110
	R = 1110 mod2 11 = 1
	T = 1110 | 1 = 1110 + 1 = 1111

Example2:

	M = 1001 0111 K=11010
	R = 1010

以1 bit 计算模2余数

		 	   1111 0001 (Q)
		 ---------------
	11010|1001 0111 0000
		 |1101 0
		 --------
		   100 01
		   110 10
		   --------------
		    10 111
		    11 010
		    --------------
		     1 1011
		     1 1010
		     --------------
				  1 0000
		     	  1 1010
		     	------------
				  	1010 (R)

以4bits 计算模2 余数


		 	   1111 0001 (Q)
		 ------------------
	11010|1001 0111 0000
		 |1001 0110
		 ------------------
				  1 0000
				  1 1010
		 		-----------
					1010 (R)

在做多字节处理时，我们的cpu 更擅长以字节为单位处理数据, 所以CRC 算法主要是以8bit 为进行处理的

> 偶校验是CRC的一种，即CRC-1(11, 0x1) 是偶校验, 而(10,0x0) 即不是奇校验也不是偶校验

### 变体CRC
CRC有几种不同的变体

- shiftRegister可以逆向使用，这样就需要检测最低位的值，每次向右移动一位。这就要求polynomial生成逆向的数据位结果。实际上这是最常用的一个变体。
- 可以先将数据最高位读到移位寄存器，也可以先读最低位。在通信协议中，为了保留CRC的突发错误检测特性，通常按照物理层发送数据位的方式计算CRC。
- 移位寄存器可以初始化成1而不是0。同样，在用算法处理之前，消息的最初n个数据位要取反。这是因为未经修改的CRC无法区分只有起始0的个数不同的两条消息。而经过这样的取反过程，CRC就可以正确地分辨这些消息了。
- CRC在附加到消息数据流（Message stream）的时候可以进行字节取反。这样，CRC的检查可以用直接的方法计算消息的CRC、取反、然后与消息数据流中的CRC比较这个过程来完成，也可以通过计算全部的消息来完成。在后一种方法中，正确消息的结果不再是0，而是\sum_{i=n}^{2n-1} x^{i}除以K(x)得到的结果。这个结果叫作核验多项式C(x)，它的十六进制表示也叫作幻数。

	L(x) = ~(~0 <<n)
	Ml = M(x)*x^n + L(x)*x^m = (M << n) XOR (L << m)	/*Ml 前n位取反*/
	R = Ml mod2 K
	Rr = L + R = L XOR R								/*R 取反*/
	T = M(x)*x^n + Rr = M(x)*x^n + L + R

接收者收到消息T 后，得到M 和 R, 重新计算Ml+R，并对K 取模

	M = T>>n
	R = Rr + L = R+L+L = R
	Ml + R = M*x^n + L*x^m + R
	(Ml + R) mod2 K = (M*x^n + L*x^m + R) mod2 K == 0?

比如:

	M(x) = 011 K(x)=11 n=1
	# 对M(x)前n(n=1) 位取反
	Ml = M(x) XOR ~(~0 <<n)

# 错误检测能力
CRC的错误检测能力依赖于关键多项式的阶次以及所使用的特定关键多项式。误码多项式E(x)是接收到的消息码字与正确消息码字的异或结果。当且仅当误码多项式能够被CRC多项式整除的时候CRC算法无法检查到错误。

- 由于CRC的计算基于除法，任何多项式都无法检测出一组全为零的数据出现的错误或者前面丢失的零。但是，可以根据CRC的变体来解决这个问题。
- 所有只有一个数据位的错误都可以被至少有两个非零系数的任意多项式检测到。误码多项式是x^k，并且x^k只能被i \le k的多项式x^i整除。

当只有1bit 错误时：

	E(x) = ....1.... 它可以被1 整除(无法检测到错误)，但是不能被至少有两个非零系数的任意多项式整除(能检测到错误)

- CRC可以检测出间隔距离小于多项式阶次的双位错误，在这种情况下的误码多项式是

	E(x) = x^i + x^k = x^k \cdot (x^{i-k} + 1), \; i > k。

当i-k 小于 多项式K的阶次n 时，E 不能被K 整除. 它能被(x^{i-k}+1) 整除, 但不能被(x^{i-k+1}+1) 整除. 这个K 很容易就能找到

# generator polynomial, 生成多项式
常见的生成多项式有：

	名称	 生成多项式	简记式* 	标准引用
	CRC-4 	 x4+x+1	 3	 ITU G.704
	CRC-8	 x8+x5+x4+1	 0x31
	CRC-8	 x8+x2+x1+1	 0x07
	CRC-8	 x8+x6+x4+x3+x2+x1	 0x5E
	CRC-12	 x12+x11+x3+x+1	 80F
	CRC-16	 x16+x15+x2+1	 8005	 IBM SDLC
	CRC16-CCITT	 x16+x12+x5+1	 1021	 ISO HDLC, ITU X.25, V.34/V.41/V.42, PPP-FCS
	CRC-32	 X32+X26+X23+X22+X16+X12+X11+X10+X8+X7+X5+X4+X2+X1+X0	04C11DB7	 ZIP, RAR, IEEE 802 LAN/FDDI, IEEE 1394, PPP-FCS
	CRC-32c	 x32+x28+x27+...+x8+x6+1	 1EDC6F41	 SCTP

> 生成多项式最高位1 在简写时常略去。略去后的生成多项式位数就是位宽W

# source
以下源码来自：
http://www.simplycalc.com/crc32-source.php

	/*
	 * JavaScript CRC-32 implementation
	 */

	function crc32_generate(polynomial) {
		var table = new Array()
		var i, j, n

		for (i = 0; i < 256; i++) {
			n = i
			for (j = 8; j > 0; j--) {
				if ((n & 1) == 1) {
					n = (n >>> 1) ^ polynomial
				} else {
					n = n >>> 1
				}
			}
			table[i] = n
		}

		return table
	}

	function crc32_initial() {
		return 0xFFFFFFFF
	}

	function crc32_final(crc) {
		crc = ~crc
		return crc < 0 ? 0xFFFFFFFF + crc + 1 : crc
	}

	function crc32_compute_string(polynomial, str) {
		var crc = 0
		var table = crc32_generate(polynomial)
		var i

		crc = crc32_initial()

		for (i = 0; i < str.length; i++)
			crc = (crc >>> 8) ^ table[str.charCodeAt(i) ^ (crc & 0x000000FF)]

		crc = crc32_final(crc)
		return crc
	}

	function crc32_compute_buffer(polynomial, data) {
		var crc = 0
		var dataView = new DataView(data)
		var table = crc32_generate(polynomial)
		var i

		crc = crc32_initial()

		for (i = 0; i < dataView.byteLength; i++)
			crc = (crc >>> 8) ^ table[dataView.getUint8(i) ^ (crc & 0x000000FF)]

		crc = crc32_final(crc)
		return crc
	}


# Reference
- [CRC]
- [crc 校验-csdn]

[crc 校验-csdn]: http://blog.csdn.net/liyuanbhu/article/details/7882789
[CRC]: http://zh.wikipedia.org/wiki/%E5%BE%AA%E7%92%B0%E5%86%97%E9%A4%98%E6%A0%A1%E9%A9%97
[CRC-en]: http://en.wikipedia.org/wiki/Cyclic_redundancy_check
[CRC-calc]: http://en.wikipedia.org/wiki/Computation_of_cyclic_redundancy_checks
