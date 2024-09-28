---
layout: page
title:	hash
category: blog
description: 
---
# Preface

# hash in php
crc32() - Calculates the crc32 polynomial of a string
hash() - Generate a hash value (message digest)
    python默认算法是SipHash，这是一种加密哈希函数
md5() - Calculate the md5 hash of a string
sha1() - Calculate the sha1 hash of a string
crypt() - One-way string hashing
password_hash() - Creates a password hash

hash_file() - Generate a hash value using the contents of a given file
sha1_file() - Calculate the sha1 hash of a file
hash_hmac() - Generate a keyed hash value using the HMAC method

csdn 中有：使用JAVA实现PHP中hash_hmac 函数


# CRC 
参考：
http://www.metsky.com/archives/337.html

CRC全称Cyclic Redundancy Check，又叫循环冗余校验。它是一种散列函数（HASH，把任意长度的输入通过散列算法，最终变换成固定长度的摘要输出，其结果就是散列值，按照HASH算法，HASH具有单向性，不可逆性），用来检测或校验传输或保存的数据错误，在通信领域广泛地用于实现差错控制，比如通信系统多使用CRC12和CRC16，XMODEM使用CRC16等等（12、16、32等值均是指多项式的最高阶N次幂），天缘早前在做通信方面工作时也是最常用到这个校验方法，因为其编解码方法都非常简单，运算时间也很短。

但从理论角度，CRC不能完全可靠的验证数据完整性，因为CRC多项式是线性结构，很容易通过改变数据方式达到CRC碰撞，天缘这里给一个更加通俗的解释，假设一串带有CRC校验的代码在传输中，如果连续出现差错，当出错次数达到一定次数时，那么几乎可以肯定会出现一次碰撞（值不对但CRC结果正确），但随着CRC数据位增加，碰撞几率会显著降低，比如CRC32比CRC16具有更可靠的验证性，CRC64又会比CRC32更可靠，当然这都是按照ITU规范标准条件下。

正因为CRC具有以上特点，对于网络上传输的文件类很少只使用CRC作为校验依据，文件传输相比通信底层传输风险更大，很容易受到人为干预影响。


# MD5
MD全称Message Digest，又称信息摘要算法，MD5从MD2/3/4演化而来，MD5散列长度通常是128位， 也是目前被大量广泛使用的散列算法之一，主要用于密码加密和文件校验等。MD5的算法虽然非常“牢靠”，不过也已经被找到碰撞的方法，网上虽然出现有些碰撞软件，天缘没用过，但可以肯定，实际作用范围相当有限，比如，及时黑客拿到了PASSWORD MD5值，除了暴力破解，即使找到碰撞结果也未必能够影响用户安全问题，因为对于密码还要限定位数、类型等，但是如果是面向数字签名等应用，可能就会被破解掉，不过，MD5同下文的SHA1仍是目前应用最广泛的HASH算法，他们都是在MD4基础上改进设计的。

> 1996年后被证实存在弱点，可以被加以破解，对于需要高度安全性的数据，专家一般建议改用其他算法，如SHA-1。2004年，证实MD5算法无法防止碰撞，因此无法适用于安全性认证，如SSL公开密钥认证或是数字签章等用途。
> 2009年谢涛和冯登国仅用了220.96的碰撞算法复杂度，破解了MD5的碰撞抵抗，该攻击在普通计算机上运行只需要数秒钟[1]。

Refer to :
[](http://zh.wikipedia.org/wiki/MD5)

# SHA1
SHA全称Secure Hash Standard，又称安全哈希标准，SHA家族算法有SHA-1、SHA-224、SHA-256、SHA-384和SHA-512（后四者通常并称SHA2），原理和MD4、MD5原理相似，SHA是由美国国家安全局（NSA）所设计，由美国国家标准与技术研究院（NIST）发布。SHA可将一个最大2^64位（2305843009213693952字节）信息，转换成一串160位（20字节）的散列值（摘要信息），目前也是应用最广泛的HASH算法。同MD5一样，从理论角度，SHA1也不是绝对可靠，目前也已经找到SHA1的碰撞条件，但“实用”的碰撞算法软件还没出现。于是美国NIST又开始使用SHA2，研究更新的加密算法。

# bcrypt
bcrypt 可以控制hash 速度(DefaultCost)，越慢越安全：

    bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)