---
layout: page
title:	密码安全
category: blog
description: 
---
# Preface
本文总结了密码学(cryptography) 中的密码安全与签名安全

# Signature, 签名
MAC(Message Authentication Code) 与 hash 的区别: http://stackoverflow.com/questions/2836100/what-is-the-difference-between-a-hash-and-mac-message-authentication-code

- HASH 验证消息(message)没有被篡改 `hash = hash(message)`
- MAC 不仅验证消息没有被篡改，还通过一个`private key`验证*谁*加密的消息, 用`key` 保证消息真实性 `mac = hash(key + message)`. 
这个key 类似于salt, 但是意义不一样，key 是需要严格保密的, salt 是用于加固弱密的

MAC 是用于身份认证的，并且依靠其中的密钥来防止攻击者篡改消息。如果攻击者无需知道密钥和消息，也能构造出包含`key + message + extra` 的一个有效的哈希值, 也就破解了身份验证。

破解MAC 方法主要有：

- Length Extension attacks, 长度扩展攻击: 针对普通的md5/sha1/sha2

## Crack MAC, 破解MAC

### Length Extension attacks, 长度扩展攻击 
本节参考：
http://anquan.baidu.com/bbs/thread-117372-1-1.html
http://zh.wikipedia.org/wiki/%E9%95%BF%E5%BA%A6%E6%89%A9%E5%B1%95%E6%94%BB%E5%87%BB

####  Length Extension attacks principle, 长度扩展攻击原理
长度扩展攻击（Length extension attacks）是指针对某些*允许包含额外信息*的加密散列函数的攻击手段。

普通哈希摘要算法，如md5/sha1/sha2，都是基于Merkle–Damgård结构的。
这类结构有一个特点：如果你知道message 的hash 摘要; 只需要再知道message 长度(也可以猜这个长度)，那在message 后面加一些相应的`extra message` 你也能计算出相应的 摘要值。

	h1 = hash(msg)
	h2 = hash(pad(msg) + extra)

也就是你只知道h1，并猜出或者得到msg 长度，就可以算出加extra 后的新摘要h2. 
这是因为这类Merkle–Damgår 结构的摘要算法是以区块为单位的，MD5, SHA1, SHA256的区块长度是512 bits. 

mac 的具体应用场景：给如下的url 加一个md5 签名

	Url: http://hilojack.com?redirect=wiki.hilojack.com
	Origin Signature: 6d5f807e23db210bc254a28be2d6759a0f5f5d99

攻击者不知道md5 签名密钥key。但可以通过猜测得到消息的长度，进而填充`\x00`以得到一个完整的区块(512bits)；再增加伪造的信息(forge message)，并基于大原始签名(origin sign)计算出新的合法签名:

	Forge Message: &redirect=forge.hilojack.com
	Url: http://hilojack.com?redirect=wiki.hilojack.com\x00\x00\x00&redirect=forge.hilojack.com
	New Signature: 0e41270260895979317fff3898ab85668953aab2

> md5 Implemention in php: http://github.com/ahui132/php-lib/hash/md5.php

因为这种攻击只能用于添加扩展字符的场景，比如上例的增加新的query, 还比如下例的攻击w3c 的子资源完整性(Subresource Integrity, supported by chrome and firefox in 2015)

	<script src="https://example.com/example-framework.js"
		integrity="sha256-C6CB9UYIS9UJeqinPHWTHVqh/E1uhG5Twh+Y5qFQmYg="
		crossorigin="anonymous"></script>

> 但是这无法防止中间人，采用https 才是王道

#### Implementions
- HashPump: Which based on Openssl and supports the Length Extension Attack for MD5, SHA1, SHA256, SHA512. 
	But SHA224 and SHA384 are not vulnerable to this attack due to their reduced output of their state variables, instead of all their state variables
- Hash Extender

#### How To Defend Against This Attack(hmac)
解决这个漏洞的办法是使用HMAC算法, 大概是这样 MAC = hash(key + hash(key + message))
具体HMAC的工作原理有些复杂，由于这种算法进行了双重摘要，密钥不再受本文中的长度扩展攻击影响。HMAC最先是在1996年被发表，之后几乎被添加到每一种编程语言的标准函数库中。

# 密码库被拖风险
密码库被盗是会引起以下严重的安全问题, 很多网站开发者对这些问题没有引起足够的重视:

1. 破解密码库，并进一步获取用户隐私数据. 如果使用明文存储密码，连破解这一步都可以省去
2. 撞库. 一般从使用频率最高的密码开始撞。被撞网站的应对方法就是限制ip 登录次数（但是攻击者可通过购买大量肉鸡伪造ip）

# 破解密码的方法
主要包括：

1. 对hash 进行破解
2. 对密码 本身破解
2. 利用手里的密码库进行撞库
3. 通过电话、社交工具等人为方法骗取密码

## Crach Password
破解密码本身的方法有：

- 字典或者暴力尝试
- Remote Timing Attacks: https://crypto.stanford.edu/~dabo/papers/ssl-timing.pdf
- 基于社工信息猜测

Remote Timing Attacks 攻击是基于密码特征和响应时间的高相关性。

典型的例子是，使用明文存储密码的网站会使用字符串比较验证密码：`input_passwd === db_passwd`. 

攻击者先尝试256位的字符串作密码，不断改变第一个字符(a-z0-0)。如果第一个字符与密码是匹配的，比较函数会继续比较第二个字符(响应最慢)，否则直接响应失败。找出导致最慢响应的输入，其第一字节就是正确的密码的第一位。
继续改变第2字节，以找到合法密码的第2位...


## Crack hash, 破解hash
对于14位数字字母组合，`62^14=1.2e25`(12亿亿亿) , 其破解方法有：

- Dictionary attacks, 字典法: 

	字典法使用有限的密码集完成破解。
	它基于大量用户会使用简单或者短小的密码, 按密码的使用频率从高到低依次比对密文，就能很快破解弱密
	字典法的时间空间复杂度随字典大小线性增长，字典大小与可破解的密码复杂度呈负相关，所以它很难破解复杂的密码

- Brute-force attacks, 暴力法: 

	暴力法通过比较所有的密码完成破解。所以当字典法的密码集是完备的，字典法就变成暴力法。不过暴力法不需要存储密码集，
	暴力法的性能：
		时间复杂度极大，空间复杂度极小。对于14位字母数字组合，如果以1纳秒尝试一个密码(2015年的pc 还做不到, 高端的显卡GPU 可以)需要40亿亿年. 

- Looup Tables, 查表法

	查表法是事先生成字典中单词的hash, 然后按hash 排序(做索引)。字典集越大，耗时越大。
		这样字典改成查表法又叫 Pre-computed Dictionary attack
		这样暴力法改成查表法又叫 Pre-computed Brute-force attack
		破解时的时间复杂度就变成了O(1)
	查表法的性能：
		空间复杂度极大，时间复杂度极小。对于14位数字字母的完备组合，如果100块钱1TB 硬盘能存储10^11 条hash，那需要1.2 亿亿软妹币. 
		同时预处理时间极大(视字典大小)，因为预处理的时间是一次性的

- Rainbow_table, 彩虹表

> 还有一种反向查表法(Reverse Lookup Tables, 利用手里字典表库反查拖到的库). 这并不是查特定的hash，而是在拖到的库中通过反查筛选出所有的弱密. 这有点像撞库

### Rainbow Tables, 彩虹表
本节参考 : 

- 彩虹表原理： http://www.ha97.com/4009.html http://en.wikipedia.org/wiki/Rainbow_table
- 彩虹表主页： http://www.project-rainbowcrack.com/

#### Background
彩虹表是一张预先计算好的表，它使用内存-时间平衡算法（ Time-Memory Trade-Off ), 它的时间空间效率都介于暴力法和查表法

在每一次尝试都计算的暴力破解中使用更少的计算能力和更多的储存空间，但却比简单的每个输入一条散列的翻查表使用更少的储存空间和更多的计算性能。

http://zh.wikipedia.org/wiki/%E5%BD%A9%E8%99%B9%E8%A1%A8

#### Rainbow Principle
对于弱密来说，使用暴力法或字典法就可以破解, 但是对于大型的密码库来说，这就显得非常困难。

为了解决大型密码库带来的困难，需要引入储存相对较小，但可以逆向形成长链密码的散列值的逆向查找函数R。虽然这样会花费更多的计算时间来破解单个的密码，但是这会使整体的字典小得多，因而可以储存密码更长的散列值。

彩虹表是基于改进的哈希链技术，哈希链的定义如下，
首先需定义一个与H 哈希函数逆向的函数P=`R(Q)` (并非真的与H 逆向). 形成一个函数`R(H(p))`, 
然后再选择密码集合一个子集，将子集中每条明文密码代入函数，并且迭代K 次，这样就形成长度为 `2K+1` 的哈希与密码交替的哈希链

	p0 -H-> c1 -R-> p1 -H-> c2 -R-> p2 （2 reduction functions, 迭代2次）
	p0 -H-> c1 -R-> p1 -H-> c2 -R-> p2 ....p(n-1) -H-> cn -R-> pn （n reduction functions, 迭代n次）

哈希链只保留起点和终点：

	p0 -> pn

对于一个哈希值c，我们要寻找其原始的密码p. 方法是:

1. 将c 代入函数`R`，得到的值`R(c)`与`pn` 比较，如果相同，说明`p(n-1)` 很可能就是原文`p`(这需要从p0 开始重新生成哈希链找到`p(n-1)`)
2. 如果不同，再代入归约函数`R(H(p))`, 再比较`pn`(最多代入k次), 如果相同，那么`p(n-2)` 就有可能是我们要找的原文`p`
3. 上一步迭代k 次后都还没有找到与`pn` 相等的哈希链接，代表破解失败(Rainbow Table 不够大, 或者潜在的明明文不够均匀)

每一条唋希链只有一个起点和终点，但是它却隐含了k 个哈希值、k 个明文，哈希值的前向结点就是原始密码。

- 当k 越大，计算速度越慢，表空间越小。产生的潜在明文密码就越多
- 当k 越小，计算速度越快，表空间越大。它就越接近查表法

但是哈希链有存在一些问题：

1. R导致的碰撞问题：因为R 需要尽可能的产生潜在明文密码，又不能让这些明文密码出现碰撞. 当两哈希链的点碰撞(值相同的点)后，其后续的点就会重合. 这将导致付出同样的计算代价后却不能使表尽可能多的覆盖密码。H 作为哈希函数是不太可能出现碰撞的(哈希函数的设计就是要避免碰撞)
2. 设计一个能匹配明文期望分布的R函数非常困难

彩虹表改进了简单的*哈希链*， 提供一种称为碰撞链的解决方案的密码破解工具。
它采用*衰减函数列* `R1...Rk`代替单一*衰减函数* `R`, 极大降低了简单哈希的出现碰撞的概率: 
	如果两个哈希链发生碰撞并且重合，那么它们的碰撞必定发生在相同的位置，从而它们的终点也将相同。
	这时，我们可以通过后处理来对哈希链进行排序，从而找出并移除所有终点相同，因而可能是重复的链，并生成新的链来将整个表补充完整。这样得到的表中的链可能有碰撞的部分，但它们不会发生链的重合，从而大幅降低了碰撞的次数。(如果移出重复的链接？这段话来自于wiki, 但没有来源出处，这里我也没有搞明白, 我想发生重复时)

破解示意图出自维基

![](/img/rainbow_table1.png)
![](/img/rainbow_table2.png)

#### 彩虹表工具
一般不自己生成彩虹表，因为就算生成几G 彩虹表，普通的PC 也需要花几天的时间.

彩虹表下载：

	Ophcrack彩虹表 官方下载地址：
	http://ophcrack.sourceforge.net/

	120G彩虹表BT下载
	http://www.ha97.com/code/tables.rar

常用到的彩虹表工具有Ophcrack、rcracki_mt、Cain等：

	Cain: 
		http://www.onlinedown.net/soft/53494.htm

	Free Rainbow Tables
		官方网址：http://www.freerainbowtables.com/en/tables/
		镜像下载：http://tbhost.eu/rt.php
		支持HASH类型：LM，MD5，NTLM，SHA1，HALFLMCHALL
		扩展名：rti. .rti 比.rt 新，使用了索引和压缩，所以速度更快，体积更小，而且支持分布式破解。

	Ophcrack
		官网网址：http://ophcrack.sourceforge.net/tables.php
		最常用的，界面友好，与众不同，压缩储存，有自己独特的彩虹表结构，还有Live CD。
		支持的HASH类型：LM，NTLM

		高级的表要花钱买，免费的表有（推荐只下2和5，要求高的可以下载3和5）：
		1.XP free（LM表：包含大小写+数字）380MB（官网免费下载）
		2.XP free fast（和前一个一样，但是速度更快）703MB（官网免费下载）
		3.XP special（LM表：大小写+数字+所有符号包括空格）7.5G
		4.Vista free （NTLM表：包含常用密码）461MB（官网免费下载）
		5.Vista special（NTLM表：包含6位的全部可打印字符，7位的大小写字母数字，8位的小写和数字）8G

	RainbowCrack
		官网网址：http://project-rainbowcrack.com/table.htm
		通用的，一般的破解软件如saminside都支持，命令行界面，黑客的最爱，支持CUDA。
		可以自己生成表，不要钱，传说中的120G就来自于此。
		支持HASH类型：LM, NTLM, MD5, SHA1, MYSQLSHA1, HALFLMCHALL, NTLMCHALL.
		扩展名：rt

LM 与NTLM 区别：

	LM: LM（Lan Manage）加密: XP/98 使用. 它每7位做一分割。也就相当于密码长度只有7位，破解相当容易
	NTLM 加密（New Technology Lan Manage）: 用于替换不安全的LM
		采用MD4+RSA存储. 应用于NT系统。但是为了兼容, 2000、2003和XP中的口令同时保存了两份，一份LM一份NTLM
		vista/win7/win8 去掉了LM, NTLM 哈希密码时不像LM 是按7位分块的，口令可以无限长，破解难度巨大

#### 破解彩虹表
使用加盐的 hash 函数可以使彩虹表攻击难以实现。

#### 特点
1. 性能超高. 普通PC上辅以NVidia CUDA技术，对于NTLM算法可以达到最高每秒103,820,000,000次明文尝试（超过一千亿次），对于广泛使用的MD5也接近一千亿次
2. 对于任何哈希算法都有效, 这一点类似暴力破解

## 安全的哈希
不要使用 不安全的哈希函数

	过时的函数，比如MD5或SHA1
	不安全的crypt()版本（$1$，$2$，$2x$，$3$）
	任何你自己设计的加密算法。只应该使用那些在公开领域中的，并且被密码学家完整测试过的技术

应该使用：

	OpenWall的Portable PHP password hashing framework
	hash_pbkdf2 通过增加hash 迭代因子实现的慢哈希
	任何先进的、被良好测试过的哈希加密算法，比如SHA256，SHA512，RipeMD，WHIRLPOOL，SHA3等等
	设计良好的密钥扩展算法，如PBKDF2，bcrypt，scrypt
	安全的crypt()版本（$2y$，$5$，$6$）

php 请使用 password_hash，它是php 提供的最强的hash 算法，它兼容crypt()

	$hash = password_hash("secret-passwd", PASSWORD_DEFAULT);
	echo password_verify('bad-passwd', $hash) ? 'valid passwd' : 'invalid passwd';

### slow hash, 慢哈希函数
加盐使攻击者无法采用特定的查询表和彩虹表快速破解大量哈希值，但是却不能阻止他们使用字典攻击或暴力攻击。
高端的显卡（GPU）和定制的硬件可以每秒进行数十亿次哈希计算，因此这类攻击依然可以很高效。

为了降低攻击者的效率，我们可以使用一种叫做密钥扩展的技术。

密钥扩展的实现是依靠一种CPU密集型哈希函数。不要尝试自己发明简单的迭代哈希加密，如果迭代不够多，是可以被高效的硬件快速并行计算出来的，就和普通哈希一样。应该使用标准的算法，比如PBKDF2或者bcrypt。这里可以找到PBKDF2在PHP上的一种实现。

这类算法使用一个安全因子或迭代次数作为参数，这个值决定了哈希函数会有多慢

### 密钥哈希
也就是对哈希与密钥结合，除非得到密钥，否则就解不出哈希，更解不出hash 对应的密码
实现方法有：

- 用密钥加密哈希
- 将密钥包含到哈希字符串中. 比如HMAC，简单的实现有`hash(key+hash(key+password))`. (key 与盐不一样，作为密钥 key 是需要保密的)

### Salting Hash
本节refer:
http://blog.jobbole.com/61872/

#### 加盐能应对的风险
查表和彩虹表的方式之所以有效是因为, 任一密码都是用相同的方式加密的, 这存在的风险包括

1. 弱密码风险：因为彩虹表包含了大量弱密的hash
2. 相同的密码风险: 如果两个用户的密码相同，那么一定他们的密码hash也一定相同。一个用户密码被破解了，另一个用户的密码也会被破解

> 第2 个风险是依赖于第一个风险. 所以第2个风险是次要的

我们可以通过让每一个hash随机化:` hash("passwd" + rand())` 避免这两个风险

1. 通过加salt, 让弱密变成强密. 
2. 即使是相同的密码，因为salt 是随机的, 最后得到的hash 还是不同的. 这个随机的salt 作为hash 的一部分，也需要保存到数据库中, 因为核对密码时还需要这个salt

还有组合哈希函数的风险：

	md5(sha1(password))
	md5(md5(salt) + md5(password))
	sha1(sha1(password))
	sha1(str_rot13(password + salt))
	md5(sha1(md5(md5(password) + sha1(password)) + md5(password)))
	
攻击可以通过很多方式得到这种组合方式(除非是“标准的”组合哈希函数，比如HMAC)，然后通过字典暴力破解组合哈希：

1. 通过攻击拿到服务器上的源码得到组合方式
2. 通过特征猜测组合方式
3. 可能带来函数间互相影响的问题

#### 加salt 时要避免：

1. 短盐，导致弱密加salt 后的密码强度不高. 盐长度应该不小于哈希函数的输出长度
2. 相同的盐，如果盐被泄露或者猜出了, 攻击者可以使用字典暴力破解; 因为salt 是固定的，攻击者也可以制作相应的彩虹表(改进的字典)进行破解。 一定要使用随机的盐

盐值应该使用基于加密的伪随机数生成器（Cryptographically Secure Pseudo-Random Number Generator – CSPRNG）来生成。CSPRNG和普通的随机数生成器有很大不同，如C语言中的rand()函数。物如其名，CSPRNG专门被设计成用于加密，它能提供高度随机和无法预测的随机数。我们显然不希望自己的盐值被猜测到，所以一定要使用CSPRNG。下面的表格列出了当前主流编程语言中的CSPRNG方法：

	PHP	mcrypt_create_iv, openssl_random_pseudo_bytes
	Java	java.security.SecureRandom
	Dot NET (C#, VB)	System.Security.Cryptography.RNGCryptoServiceProvider
	Ruby	SecureRandom
	Python	os.urandom
	Perl	Math::Random::Secure
	C/C++ (Windows API)	CryptGenRandom
	Any language on GNU/Linux or Unix	Read from /dev/random or /dev/urandom


