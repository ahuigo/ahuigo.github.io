# client
str: blueimp-md5
file+str: spark-md5

# crypto: md5,sha1,...
1. update()方法默认字符串编码为UTF-8，也可以传入Buffer。
2. 支持hash: md5,sha1,sha256,sha512,..
2. 支持hash+salt: hmac
2. 支持对称: AES
2. 支持非对称: Diffie-Hellman

    const crypto = require('crypto');
    const hash = crypto.createHash('md5');

    // 可任意多次调用update():
    hash.update('Hello, world!');
    hash.update('Hello, nodejs!');

    console.log(hash.digest('hex')); // 7e1977739c748beac0c0fd14fd26a544

## Hmac
Hmac算法也是一种哈希算法，它可以利用MD5或SHA1等哈希算法。不同的是，Hmac还需要一个密钥：

    const crypto = require('crypto');
    const hmac = crypto.createHmac('sha256', 'secret-key');

    hmac.update('Hello, world!');
    hmac.update('Hello, nodejs!');

    console.log(hmac.digest('hex')); // 80f7e22570...

## AES
AES是一种常用的对称加密算法，加解密都用同一个密钥。
1. 支持不同的算法，如aes192，aes-128-ecb，aes-256-cbc等，
2. 可以指定IV（Initial Vector）
3. 加密结果通常有两种表示方法：hex和base64
4. final是为了获取剩余串

    const crypto = require('crypto');
    function aesEncrypt(data, key) {
        const cipher = crypto.createCipher('aes192', key);
        var crypted = cipher.update(data, 'utf8', 'hex');
        crypted += cipher.final('hex')
        return crypted;
    }

    function aesDecrypt(encrypted, key) {
        const decipher = crypto.createDecipher('aes192', key);
        var decrypted = decipher.update(encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return decrypted;
    }

    var data = 'Hello, this is a secret message!';
    var key = 'Password!';
    var encrypted = aesEncrypt(data, key);
    var decrypted = aesDecrypt(encrypted, key);

    console.log('Plain text: ' + data);
    console.log('Encrypted text: ' + encrypted);
    console.log('Decrypted text: ' + decrypted);


## DH算法，Diffie-Hellman
原理:
0. 选一个素数和一个底数，例如，素数p=23，底数g=5（底数可以任选）
1. 小明选择一个秘密整数a=6， 计算A=g^a mod p=8，然后大声告诉小红：p=23，g=5，(A=8)；(A/a是一对公私钥)
2. 小红也选一个秘密整数b=15，计算B=g^b mod p=19，并大声告诉小明：B=19；
3. 小明自己计算出s=B^a mod p=2，小红也自己计算出s=A^b mod p=2，因此，最终协商的密钥s为2。

在这个过程中，密钥2并不是小明告诉小红的，也不是小红告诉小明的，而是双方协商计算出来的。第三方只能知道p=23，g=5，A=8，B=19，由于不知道双方选的秘密整数a=6和b=15，因此无法计算出密钥2。

用crypto模块实现DH算法如下：

    const crypto = require('crypto');
    // xiaoming's keys:
    var ming = crypto.createDiffieHellman(512);
    var ming_keys = ming.generateKeys();

    // prime generator
    var prime = ming.getPrime();
    var generator = ming.getGenerator();
    console.log('Prime: ' + prime.toString('hex'));
    console.log('Generator: ' + generator.toString('hex'));

    // xiaohong's keys:
    var hong = crypto.createDiffieHellman(prime, generator);
    var hong_keys = hong.generateKeys();

    // exchange and generate secret:
    var ming_secret = ming.computeSecret(hong_keys);
    var hong_secret = hong.computeSecret(ming_keys);

    // print secret:
    console.log('Secret of Xiao Ming: ' + ming_secret.toString('hex'));
    console.log('Secret of Xiao Hong: ' + hong_secret.toString('hex'));

运行后，可以得到如下输出：

    $ node dh.js 
    Prime: a8224c...deead3
    Generator: 02
    Secret of Xiao Ming: 695308...d519be
    Secret of Xiao Hong: 695308...d519be

注意每次输出都不一样，因为素数的选择是随机的。