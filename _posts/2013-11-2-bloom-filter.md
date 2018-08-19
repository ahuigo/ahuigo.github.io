---
layout: page
title: 一个bloom filter 的redis实现	
category: blog
description: 
---
# 问题

判断uid是否在一个uids集合中。假设uids集合有n=10^7(1k万)，同时假设uid最多10位，那么其值域范围是10^10(100亿)

# 方案

1. 使用哈希表（hash），至少占用10^7*4个字节
特点：0错误率，如果hash的后的uid使用4个字节存储，那么空间占用至少4n bytes. 但是考虑到hash表的存储结构(未利用的hash节点)和碰撞问题(链表消耗)，占用率可不只这么点。
比如用redis的集合实现的话，每个uid平均会耗用64个字节（redis: info memory），一千万的uid会耗用6.4亿bytes(0.64G)；

2. 使用bitmap. 每一个uid对应一个bit.
特点：0错误率.空间利用率低 空间利用效率=（集合大小/值域范围）× 100%，速度最快！
如果uid值域范围是100亿，那么需要12.5亿bytes(1.25G)

3. 使用bloom filter
特点：不适合0错误率场景，空间利用率极高
10^7个uid集合，在低于0.01错误率的情况下，耗用 10*10^7 bits < 2^27bits(16M bytes)
如果错误率低于0.001,空间耗用为15*10^8 bits < 2^28 bits(32M bytes)

# bloom filter错误率
如果元素数量是确定的n，位空间大小为m(其中m>n)，k为hash算法的个数，f为错误率,则当k=ln2*(m/n)时错误率f最小.此时k，f的计算公式为:

	k=	ln2*(m/n) 
	f = 0.5^k = 0.5^ (ln2*(m/n))
	1/f = 2^(ln2*(m/n))

如果想让错误率低于f,那么m,k分别满足：

	m>n * log2(1/f) / ln2 = n * log2(1/f) * log2(e)
	k=ln2*(m/n) > log2(1/f)

如果我想使错误率低于0.01 ，那么：

	m ~ 10*n, k ~ log2(1/0.01) ~ 7 

假使n=10^7(1k万),那么m可以取2^27(1.34亿)。



# bloomFilet的redis实现示例

	<?php

	/**
	 * bloomFilter
	 */
	class bloomFilter
	{
		public $redis;
		/**
		 * Index action is the default action in a controller.
		 */
		public function __construct($id, $module = null) {
			parent::__construct($id, $module);
			$this->redis = new Redis();
			$this->redis->connect('127.0.0.1');
		}
		public function __destruct(){
			$this->redis->close();
		}
		public function actionIndex()
		{
			$uid = rand();
			$str = (string)$uid;
			$this->setBloomBits($str);//写值
			var_dump($this->getBloomBits($str));//判断是否在集合内
		}
		private function setBloomBits($str) {
			foreach (array(7, 11, 13, 17, 19, 23, 29) as $seed) {
				$hash = $this->hash($str, $seed);
				$this->redis->setBit($key = 'uids', $hash, 1);
			}
		}

		private function getBloomBits($str) {
			foreach (array(7, 11, 13, 17, 19, 23, 29) as $seed) {
				$hash = $this->hash($str, $seed);
				$bit = $this->redis->getBit($key = 'uids', $hash);
				if($bit === 0){
					return false;
				}
			}
			return true;
		}

		/**
		 * 
		 * @param type $str
		 * @param type $seed 7,11,13,17,19,23,29
		 * @return type
		 */
		private function hash($str, $seed){
			$hash = 0;
			for($len = strlen($str),$i=0; $i<$len; $i++){
				$hash = $seed * $hash + ord($str{$i});
			}
			return $hash & 0x3FFFFFF;//2^27
		}
		
	}

# Implement

## Memcache bloom filter
何跃的[mc bloom filter](http://www.heyues.com/mc_bloom_filter/)

#参考
- [bloom filter]
- [hash]	
- [BloomFilter2]	
- [常见的Hash算法]	

[bloom filter]: http://blog.csdn.net/v_july_v/article/details/6685894
[BloomFilter2]: http://www.cnblogs.com/heaad/archive/2011/01/02/1924195.html
[hash]: http://blog.csdn.net/v_JULY_v/article/details/6256463
[常见的Hash算法]: http://blog.csdn.net/eaglex/article/details/6310727#t0
