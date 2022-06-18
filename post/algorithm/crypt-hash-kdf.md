---
title: key derivation functions 密码派生函数
date: 2022-06-17
private: true
---

# KDF(key derivation functions 密码派生函数)　

https://crypto.stackexchange.com/questions/6564/why-is-bcrypt-called-a-key-derivation-function
KDF 是从一个密钥派生出一个或多个密钥、更长。KDF可用于将密钥扩展为更长的密钥 特点

1. **Key separation**: This is the most basic use case for KDFs. Basically, you
   have one key, but need several. This might be e.g. because you're a server
   that needs to communicate with multiple clients using distinct keys for each,
   or simply because the algorithms you're using together (e.g. a cipher and a
   MAC) have only been proven secure under the assumption that they each have
   separate and independent keys. You can solve this problem by using a KDF
   (with different salts) to derive multiple (quasi-)independent subkeys from
   your original key. 密码隔离：比如加盐

2. **Key expansion**: Related to the above, some algorithms may require rather
   long keys for practical reasons, even though the desired security level
   against brute force guessing could be met with a shorter key. In such cases,
   you can use a KDF to effectively extend the length of your key. 密码长度扩展：比如加盐

3. **Key whitening**: Many encryption algorithms, such as block ciphers, require
   a key that consist of a fixed number of (effectively) random bytes. If you
   have a key that is not in the required format (such as an arbitrary-length
   passphrase, or a Diffie-Hellman shared secret), you can use a KDF that
   accepts arbitrary input key material to hash it into a byte string of
   suitable size. 密码白盒：不限制密码长度

4. **Key stretching**: This is the specific use case for which Bcrypt (and other
   "password-based" KDFs like PBKDF2 or scrypt) are designed for. Basically, say
   you have a user-entered passphrase that may have a relatively small amount of
   entropy (say, from 20 to 40 bits), in addition to all the other issues
   mentioned above (too short / too long, wrong format), and you want to use it
   to encrypt/decrypt some data (or to authenticate the user) while making it
   hard to break the encryption by guessing the passphrase by brute force.
   密码增强：增加迭代cost 次数

KDF 作用是利用伪随机数从`主密码、密码`派生出一个或多个`密钥`(保护密码的泄露)

1. KDF 比Hash+salt 更慢，更安全: 它在hash+salt 基础上上增加了迭代因子（迭代次数）
2. KDF 通过: 一个 `master key`（在 HTTPS
   中用的非常多）、`password`、`passphrase(salt)`（随机数生成器）生成一个或多个强壮的密钥
3. KDF 本质上属于 Key stretching、key strengthening，比如HTTPS 在握手阶段，HTTPS 将 Premaster
   Secret 和客户端服务器端的随机数导出为 Master Secret，然后再将 Master Secret 导出为多个密钥块，这些密钥块包含 AES
   的加密密钥或者初始化向量，用户后续通信数据的加密和完整性保护。
   [PBKDF2](https://www.jianshu.com/p/92c9ca0979ee)

## 安全性比较

KDF主要分几种实现派生函数: `PBKDF2(PBE)`,`bcrypt`,`scrypt`

1. PBKDF2(CPU): 主要依赖cpu,支持cpu/gpu并行, 可以用专用的ASIC的处理器提高破解速度 PBKDF2 is simply an
   iterated fast hash (i.e. still efficiently parallelizable). (It is a scheme
   which can be used with different base algorithms.
2. bcrypt: 对抗 GPU/ASIC 方面要优于 PBKDF2 (生成的密钥只能是24位)
   https://crypto.stackexchange.com/questions/6564/why-is-bcrypt-called-a-key-derivation-function
   Bcrypt needs some (4KB) working memory, and thus is less efficiently
   implementable on a GPU with less than 4KB of per-processor cache.
3. scrypt: 需要大量的内存,　最安全 Scrypt uses a (configurable) large amount of memory
   additionally to processing time, which makes it extremely costly to
   parallelize on GPUs or custom hardware, while "normal" computers usually have
   enough RAM available.

## PBKDF2

`PBKDF2`，又名`PKCS#5`，支持可插哈希函数，比如md5、sha256、HMAC、甚至嵌套bcrypt等等 PBE 算法标准定义在 RFC 2898
文档中，公式如下

    # 它是一个加入了迭代次数的hash
    DK = PBKDF2(hash, Password, Salt, cost, dkLen)
        hash 是一个伪随机函数，Hash 函数, 可以是md5, HMAC, sha256
        Password 表示口令 。
        Salt 表示盐值，一个随机数。
        cost 表示迭代次数(变慢的关键)
        dkLen 表示最后输出的密钥长度。

## scrypt 算法

    //Derive 256-bit key using BlockMix/ROMix/Sasls8 output as the "salt":
    String password = "correct battery horse staple";
    String salt = ROMix(password, GetRandom(16), 14, 8, 1);
    Byte[] key PBKDF2(password, salt, 32, 1); //32*8=256
