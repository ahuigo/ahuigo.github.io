---
layout: page
title:	algorithm crypt
category: blog
description:
---
# Preface

# Symmetric-key Cryptography 对称密钥加密
1. 对称密钥加密，又称对称加密、私钥加密、共享密钥加密，与非对称密钥相比它快得多
1. 分组加密（Block cipher，又称分块加密、块密码），是一种对称密钥算法。
它将明文分成多个等长的模块（block），使用确定的算法和对称密钥对每组分别加密解密。

其中典型的块加密有：

1. DES: 早期的DES 作为美国政府核定的标准加密算法.
2. AES: 标准高级加密标准（AES）被美国国家标准与技术研究院（NIST）采纳，即将逐渐取代DES目前的位置。
3. blowfish: 加密算法在加密速度上就超越了DES加密算法, 而且它没有注册专利，不需要授权。

其它如 IDEA、RC5、RC6 属于对称加密，但是不是块加密

目前为止AES比Blowfish有更广的知名度。

## 块密码模式
参考[Block_cipher_mode_of_operation]

- ECB (Electronic Code Book): 确定的块Block， 得到的密文是确定的
优点：
	1.简单；
	2.有利于并行计算；
	3.误差不会被传送；
缺点:
	1.不能隐藏明文的模式；
	2.可能对明文进行主动攻击；

- CBC (Chipher Block Chaining): 密码分组链接，它使用前一块block的密文作为下一块的初始向量IV. 加密只能串行，而解密可以并行(解密时，密文中一位的改变只会导致其对应的平文块完全改变和下一个平文块中对应位发生改变，不会影响到其它平文的内容。)
优点：
	1.不容易主动攻击,安全性好于ECB,适合传输长度长的报文,是SSL、IPSec的标准。

缺点：
	1.不利于加密并行计算；
	2.误差传递；
	3.需要初始化向量IV

- CFB (Chipher Feed Back): 密码反馈，类似CBC, 也需要IV, 解密可并行化，支持更小的密码块,
优点：
	1.隐藏了明文模式;
	2.分组密码转化为流模式;
	3.可以及时加密传送小于分组的数据;
缺点:
	1.不利于并行计算;
	2.误差传送：一个明文单元损坏影响多个单元;
	3.唯一的IV;

- OFB (Output Feed Back): 输出反馈，同样需要IV; 每个使用OFB的输出块与其前面所有的输出块相关，因此无论是加密还是解密都不能并行化
优点:
	1.隐藏了明文模式;
	2.分组密码转化为流模式;
	3.可以及时加密传送小于分组的数据;
缺点:
	1.不利于并行计算;
	2.对明文的主动攻击是可能的;
	3.误差传送：一个明文单元损坏影响多个单元;

## 3des
3次DES

### 3des example
见[php-lib/mcrypt.php](php-lib/mcrypt.php)

	/**
	 * if blocksize = 8, it is pkcs5
	 * mcrypt 默认的填充值为 null （'\0'），java或.NET 默认填充方式为 PKCS7, AES CBC blocksize = 16 bytes
	 */
	function pkcs7_pad($text, $blocksize) {
	   $pad = $blocksize - (strlen($text) % $blocksize);
	   return $text . str_repeat(chr($pad), $pad);
	}
	function encrypt($input,$key) {
	   //$key .= str_repeat(' ', 24 - strlen($key)); //Not necessary in php(There is an auto key padding in php)
	   $size = mcrypt_get_block_size(MCRYPT_TRIPLEDES, 'ecb');
	   $input = pkcs7_pad($input, $size);
	   $td = mcrypt_module_open(MCRYPT_TRIPLEDES, '', 'cbc', '');
	   //$iv = mcrypt_create_iv (mcrypt_enc_get_iv_size($td), MCRYPT_RAND);
	   $iv = str_repeat("\x00", 8);
	   mcrypt_generic_init($td, $key, $iv);
	   $data = mcrypt_generic($td, $input);
	   mcrypt_generic_deinit($td);
	   mcrypt_module_close($td);
	   $data = base64_encode($data);
	   return $data;
	}
	function pkcs7_unpad($text) {
	   $pad = ord($text{strlen($text)-1});
	   return substr($text, 0, -1 * $pad);
	}

	function decrypt($crypt,$key) {
	   //$key .= str_repeat(' ', 24 - strlen($key)); //not necessary
		$crypt = base64_decode($crypt);
		$td = mcrypt_module_open (MCRYPT_TRIPLEDES, '', 'ecb', '');
		$iv = mcrypt_create_iv (mcrypt_enc_get_iv_size($td), MCRYPT_RAND);//不会影响ecb 但会影响cbc
		mcrypt_generic_init($td, $key, $iv);
		$decrypted_data = mdecrypt_generic ($td, $crypt);
		mcrypt_generic_deinit ($td);
		mcrypt_module_close ($td);
		$decrypted_data = pkcs7_unpad($decrypted_data);
		$decrypted_data = rtrim($decrypted_data);
		return $decrypted_data;
	}

### DES
MCRYPT_TRIPLEDES => MCRYPT_DES

## PKCS
[pks5,pks7]: http://zhiwei.li/text/2009/05/%E5%AF%B9%E7%A7%B0%E5%8A%A0%E5%AF%86%E7%AE%97%E6%B3%95%E7%9A%84pkcs5%E5%92%8Cpkcs7%E5%A1%AB%E5%85%85/
https://chrismckee.co.uk/handling-tripledes-ecb-pkcs5padding-php/

http://crypto.stackexchange.com/questions/9043/what-is-the-difference-between-pkcs5-padding-and-pkcs7-padding

The difference between the PKCS#5 and PKCS#7 padding mechanisms is the block size;

1. PKCS#5 padding is defined for 8-byte block sizes,
2. PKCS#7 padding would work for any block size from 1 to 255 bytes.

This is the definition of PKCS#5 padding (6.2) as defined in the RFC:

> The padding string PS shall consist of 8 - (||M|| mod 8) octets all having value 8 - (||M|| mod 8).

The RFC that contains the PKCS#7 standard is the same except that it allows block sizes up to 255 bytes in size (10.3 note 2):

> For such algorithms, the method shall be to pad the input at the trailing end with k - (l mod k) octets all having value k - (l mod k), where l is the length of the input.

So fundamentally **PKCS#5 padding is a subset of PKCS#7 padding for 8 byte block sizes**. Hence, **PKCS#5 padding can not be used for AES. PKCS#5 padding was only defined with (triple) DES operation in mind**.

Many cryptographic libraries use an identifier indicating PKCS#5 or PKCS#7 to define the same padding mechanism. The identifier should indicate PKCS#7 if block sizes other than 8 are used within the calculation. Some cryptographic libraries such as the SUN provider in Java indicate PKCS#5 where PKCS#7 should be used - "PKSC5Padding" should have been "PKCS7Padding".

Note that both PKCS#5 and PKCS#7 are not standards for padding mechanisms. The padding part is only a small subset of the defined functionality. PKCS#5 is a standard for Password Based Encryption or PBE, and PKCS#7 defines the Cryptographic Message Syntax or CMS.


## BlowFish 算法
Blowfish加密算法在加密速度上就超越了DES加密算法, 而且它没有注册专利，不需要授权。
Blowfish 主要包括关键的几个S盒和一个复杂的核心变换函数。
每次加密一个64位分组，使用32位～448位的可变长度密钥，应用于内部加密。加密过程分为两个阶段：密钥预处理和信息加密。

> blowfish加密算法中使用两个盒key—pbox[18]和key—sbox[4][256]，以及一个核心的加密函数blowfish—encrypt（）。这两个盒所占存储空间为（18×32＋4×256×32）字节，即4186字节。加密函数blowfish—encrypt（）输入64位明文，输出64位密文。

	$fl = new flowfish();
	$key = '132aslkdjfsafjlsakdfjkal';
	$text = $fl->encrypt('hahasadfalskdjflsadkjfla;skjlvx;cvzxc.中国人民hahahahas32jkrlsdfjal;fjas;dfj;sdkfj;as;dfkjv.中你男', $key);
	$v = $fl->decrypt($text, $key);
	var_dump(base64_encode($text), $v);
	class flowfish {
		var $algorithm = MCRYPT_BLOWFISH;
		var $mode = MCRYPT_MODE_CFB;//MCRYPT_MODE_CBC ....
		var $cipher;
		var $iv;
		var $key = 'passwd';
		function __construct(){
			//$iv
			$this->iv = substr(md5('rand string'), 0, 8);

			//$chiper
			$this->cipher = mcrypt_module_open($this->algorithm, '', $this->mode, '');
		}
		function encrypt($text, $key){
			//初始化加密chiper
			if (mcrypt_generic_init($this->cipher, $key, $this->iv) == -1) {
				return false;
			}
			$text = mcrypt_generic($this->cipher, $text);
			mcrypt_generic_deinit($this->cipher);
			return $text;
		}
		public function decrypt($cipher_text, $key) {
			if (mcrypt_generic_init($this->cipher, $key, $this->iv) == -1) {
				return false;
			}
			$text = mdecrypt_generic($this->cipher, $cipher_text);
			mcrypt_generic_deinit($this->cipher);
			return $text;
		}
		function key($key){
			$size = mcrypt_get_block_size($this->algorithm, $this->mode);
			$span = $size - strlen($key)%$size;
			for ($i = 0; $i < $span; $i++) {
				//$key .= chr($span);
			}
			$this->key = $key;
		}
	}

## AES加密
See java-lib

	class AESMcrypt {

		public $iv = null;
		public $key = null;
		public $bit = 128;
		private $cipher;

		public function __construct($bit, $key, $iv, $mode) {
			if(empty($bit) || empty($key) || empty($iv) || empty($mode))
			return NULL;

			$this->bit = $bit;
			$this->key = $key;
			$this->iv = $iv;
			$this->mode = $mode;

			switch($this->bit) {
				case 192:$this->cipher = MCRYPT_RIJNDAEL_192; break;
				case 256:$this->cipher = MCRYPT_RIJNDAEL_256; break;
				default: $this->cipher = MCRYPT_RIJNDAEL_128;
			}

			switch($this->mode) {
				case 'ecb':$this->mode = MCRYPT_MODE_ECB; break;
				case 'cfb':$this->mode = MCRYPT_MODE_CFB; break;
				case 'ofb':$this->mode = MCRYPT_MODE_OFB; break;
				case 'nofb':$this->mode = MCRYPT_MODE_NOFB; break;
				default: $this->mode = MCRYPT_MODE_CBC;
			}
		}

		public function encrypt($data) {
			$data = base64_encode(mcrypt_encrypt( $this->cipher, $this->key, $data, $this->mode, $this->iv));
			return $data;
		}

		public function decrypt($data) {
			$data = mcrypt_decrypt( $this->cipher, $this->key, base64_decode($data), $this->mode, $this->iv);
			$data = rtrim(rtrim($data), "\x00..\x1F");
			return $data;
		}

	}

	$aes = new AESMcrypt($bit = 128, $key = 'abcdef1234567890', $iv = '0987654321fedcba', $mode = 'cbc');
	$c = $aes->encrypt('haowei.me');
	var_dump($aes->decrypt($c));

# Asymmetric Cryptography
Public-key Cryptography [公开密钥加密](http://zh.wikipedia.org/zh/%E5%85%AC%E5%BC%80%E5%AF%86%E9%92%A5%E5%8A%A0%E5%AF%86)，又称非对称加密(Asymmetric Cryptography)

公钥的一种表现形式就是数字证书

常见的公钥加密算法有:

1. RSA
2. EIGamal
3. 背包算法
4. Rabin （RSA 特例）
5. 迪菲-赫尔曼密钥交换(Diffie-Hellman key exchange, D-H)协议中的公钥加密
6. 椭圆曲线加密算法(Elliptic Curve Cryptography, ECC)

## RSA
> RSA Encryption: Java to PHP , please refer to : http://stackoverflow.com/questions/1662769/rsa-encryption-java-to-php

## openssl generate key
refer [openssl](/p/net-ssl-tool)
> 注意与ssh 的区别， `ssh-keygen -t rsa`

## sign 签名

### DSA/RSA sign
DSA（Digital Signature Algorithm）：数字签名算法，是一种标准的 DSS（数字签名标准）；
DSA是基于整数有限域离散对数难题的，其安全性与RSA相比差不多。DSA的一个重要特点是两个素数公开，这样，当使用别人的p和q时，即使不知道私钥，你也能确认它们是否是随机产生的，还是作了手脚。RSA算法却作不到。

> openssl 非对称加密DSA,RSA区别与使用介绍
http://www.51know.info/system_base/openssl.html

	//sign_alg or alias from openssl_get_md_methods(true);
	define ('OPENSSL_ALGO_SHA1', 1);//DSA-SHA1
	define ('OPENSSL_ALGO_MD5', 2);
	define ('OPENSSL_ALGO_MD4', 3);
	define ('OPENSSL_ALGO_MD2', 4);
	define ('OPENSSL_ALGO_DSS1', 5);
	define ('RSA-SHA1', 14);

	class openssl{
		public function setPrivKey($key_file) {
			$this->_privKey = openssl_get_privatekey(file_get_contents($key_file, true));
		}

		public function setPubKey($key_file) {
			$this->_pubKey = openssl_get_publickey(file_get_contents($key_file, true));
		}

		public function sign($data, $sign_alg) {
			openssl_sign($data, $sign, $this->_privKey, $sign_alg = OPENSSL_ALGO_SHA1);
			return $sign;
		}

		public function verify($data, $sign, $sign_alg) {
			return openssl_verify($data, $sign, $this->_pubKey, $sign_alg);
		}
	}

### sign hash 签名

	sha1()
	md5()

## openssl
http://www.51know.info/system_base/openssl.html

### RSA
1. openssl RSA 加解密
RSA是基于数论中大素数的乘积难分解理论上的非对称加密法,使用公私钥的方法进行加解密
公钥 用于加密，它是向所有人公开的 ; 私钥用于解密，只有密文的接收者持有
生成一个密钥(私钥)

	  [root@hunterfu ~]# openssl genrsa -out private.key 1024

注意: 需要注意的是这个文件包含了公钥和密钥两部分，也就是说这个文件即可用来加密也可以用来解密,后面的1024是生成密钥的长度.

通过密钥文件private.key 提取公钥

	  [root@hunterfu ~]# openssl rsa -in private.key -pubout -out pub.key

使用公钥加密信息

	  [root@hunterfu ~]# echo -n "123456" | openssl rsautl -encrypt -inkey pub.key -pubin >encode.result

使用私钥解密信息

	  [root@hunterfu ~]#cat encode.result | openssl rsautl -decrypt  -inkey private.key
	  123456

#### PHP RSA
Refer:
https://rietta.com/blog/2013/06/13/openssl-encrypt-data-with-rsa-key-with/

	function encryptData($dataToEncrypt) {
      // Will hold the encrypted data
      $sealed ="";
      $ekeys="";
      $pubKey[] =   openssl_pkey_get_public( file_get_contents( "public.pem" ) );
      $result = openssl_seal( gzcompress( $dataToEncrypt ), $sealed, $ekeys, $pubKey);

      /* Encrypt the Data using OpenSSL seal, which applies an RC4 cipher across the data and encrypts the session key with the array of envelope keys */

      return array( ‘encdata' => base64_encode($sealed) , ‘enckey' => base64_encode( serialize($ekeys)) );
    } // end encryptData

### DSA签名与验证
和RSA加密解密过程相反，在DSA数字签名和认证中，发送者使用自己的私钥对文件或消息进行签名，接受者收到消息后使用发送者的公钥来验证签名的真实性
DSA只是一种算法，和RSA不同之处在于它不能用作加密和解密，也不能进行密钥交换，只用于签名,它比RSA要快很多.

生成一个密钥(私钥)

	  [root@hunterfu ~]# openssl dsaparam -out dsaparam.pem 1024
	  [root@hunterfu ~]# openssl gendsa -out privkey.pem dsaparam.pem

生成公钥

	  [root@hunterfu ~]# openssl dsa -in privkey.pem -out pubkey.pem -pubout
	  [root@hunterfu ~]# rm -fr dsaparam.pem

使用私钥签名

	  [root@hunterfu ~]# echo -n "123456" | openssl dgst -dss1 -sign privkey.pem > sign.result

使用公钥验证

	  [root@hunterfu ~]# echo -n "123456"  | openssl dgst -dss1 -verify pubkey.pem -signature sign.result
	  Verified OK

至此，一次DSA签名与验证过程完成！

3. 总结及注意事项

注意: 由于信息经过加密或者签名后，都变成不可读模式,为了方便终端查看和传输使用(url提交数据,需要作urlencode操作)，可以使用base64进行编码

	openssl enc -base64 -A ：将加密后的信息使用base64编码
	openssl enc -d -base64 -A ： 将信息使用base64反编码

java中此私钥需要转换下格式才能使用:

	  [root@hunterfu ~]# openssl pkcs8 -topk8 -nocrypt -in private.key -outform PEM -out java_private.key

# php 支持的加密mode/algorithm

    $modes = mcrypt_list_modes();
    cbc
    cfb
    ctr
    ecb
    ncfb
    nofb
    ofb
    stream

    $  mcrypt_list_algorithms
    [0] => cast-128
    [1] => gost
    [2] => rijndael-128
    [3] => twofish
    [4] => arcfour
    [5] => cast-256
    [6] => loki97
    [7] => rijndael-192
    [8] => saferplus
    [9] => wake
    [10] => blowfish-compat
    [11] => des
    [12] => rijndael-256
    [13] => serpent
    [14] => xtea
    [15] => blowfish
    [16] => enigma
    [17] => rc2
    [18] => tripledes

# Reference
- [Block_cipher_mode_of_operation]
- [block chiper]
- [blowfish]
- [初始化向量iv]
- [详解ecb,cbc]
- [des]
- [des js]

[blowfish]: http://ihacklog.com/post/blowfish-cipher.html?lang=en-us
[初始化向量iv]: http://www.360doc.com/content/11/1012/16/5482098_155493376.shtml
[Block_cipher_mode_of_operation]: http://zh.wikipedia.org/wiki/%E5%9D%97%E5%AF%86%E7%A0%81%E7%9A%84%E5%B7%A5%E4%BD%9C%E6%A8%A1%E5%BC%8F#.E5.AF.86.E7.A0.81.E5.9D.97.E9.93.BE.E6.8E.A5.EF.BC.88CBC.EF.BC.89
[block chiper]: http://zh.wikipedia.org/wiki/%E5%88%86%E7%BB%84%E5%AF%86%E7%A0%81
[详解ecb,cbc]: http://www.cnblogs.com/happyhippy/archive/2006/12/23/601353.html
[des]: http://people.eku.edu/styere/Encrypt/JS-DES.html
[des js]: http://www.tero.co.uk/des/code.php
