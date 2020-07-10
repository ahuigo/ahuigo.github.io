---
title: 计时攻击 Timing attrack
date: 2020-07-09
private: true
---
# 计时攻击 Timing attrack
hmac 校验伪代码为例：

    bool verify(message, digest) {
        my_digest = HMAC(key, message);
        return my_digest.equals(digest) ;
    }

我们可以通过[计时攻击](https://coolshell.cn/articles/21003.html) 尝试穷举伪造签名

# 防止计时攻击
我们要避免位穷举, 可以使用safeEqual，即每一位都要进行比较（异或）

    boolean safeEqual(String a, String b) {
        if (a.length() != b.length()) {
            return false;
        }
        int equal = 0;
        for (int i = 0; i < a.length(); i++) {
            equal |= a.charAt(i) ^ b.charAt(i);
        }
        return equal == 0;
    }

别外很多语言也提供了类似的比较函数，如php的 password_verify