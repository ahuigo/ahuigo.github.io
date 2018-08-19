---
layout: page
title:	人民币大写转换
category: blog
description:
---



问题我是在德问上看到的。
角分就不说了，关于整数部分我想是这样
把数字每4个分为一组，大单位依次堆为空，万，亿，兆，京
对于4个数字，小单位依次为空，拾，佰，仟
关键是对于零的修正：

1. 对于203,我们不会读作：贰佰零拾叁，而是去掉拾，保留零——去掉单位。
2. 对于2003,我们不会读作：贰仟零零叁，而是——对于连续的零只保留一个零。
3. 对于2000,我们不会读作：贰仟零，而是——去掉末尾的零
4. 对于20003中的0003,我们应该诗作：零叁，所以——什么工作都不要做（3前面的零应该保留）
5. 如果全为0000(如200000000)，我们不应该读作：贰亿万，所以——全为零时，大单位也应该去掉

再归纳一下:

1. 对于2000 对于其中的：零，省略"零"及"单位"
2. 对于203 2030 20003 对于其中的非零数字3： 因为前面有一个零, 就加一个零, 得到"零叁"
3. 如果全为0000(如200000000)，我们不应该读作：贰亿万，所以——全为零时，大单位也应该去掉

总结完毕, 根据这三条归纳写代码吧:

	$num = $argv[1] or 2003.56;
	echo Rmb::getRmbNum($num);
	/**
	 *
	 * 	获取人民币的中文表示（>=php 5.3.0）
	 */
	class Rmb {

		private static $units = array('', '万', '亿', '兆', '京');
		private static $weights = array('', '拾', '佰', '仟');
		private static $numchars = array(
			'零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖',
		);

		static function getRmbNum($num = 12004213.234) {
			$num = strval($num);
			if ('' === $num || substr_count($num, '.') > 1 || strlen($num) != strspn($num, '0123456789.')) {
				return false;
			} elseif ('0' === $num) {
				return '零圆';
			}
			if (false === strpos($num, '.')) {
				$num.='.';
			}
			list($int, $dec) = explode('.', $num);

			$dec = self::getRmbNumDec($dec);
			$int = self::getRmbNumInt($int);
			$int && $int .= '圆';
			return $int . $dec;
		}

		static function getRmbNumDec($num) {
			$str = '';
			if (isset($num[0])) {
				$str.=self::$numchars[$num{0}] . '角';
				if (isset($num[1])) {
					$str.=self::$numchars[$num{1}] . '分';
				}
			}
			return $str;
		}

		static function getRmbNumInt($num) {
			static $init = false;
			if(empty($init)){
				$init = true;
				$filter = function(&$item, $k) {
						$item = strrev($item);
					};
				array_walk(self::$units, $filter);
				array_walk(self::$weights, $filter);
				array_walk(self::$numchars, $filter);
			}

			$num = strrev(strval($num));
			$num = str_split($num, 4);

			$zhNum = '';
			foreach ($num as $k => &$item) {
				$zhNumSub = '';
				for ($i = 0, $len = strlen($item); $i < $len; ++$i) {
					if ($digit = $item{$i}) {
						$weight = self::$weights[$i];
						$zhNumSub .= $weight . self::$numchars[$digit];
					}elseif(!empty($lastDigit)){//仅保留一个零(上一个数字是零时)
						$zhNumSub .= strrev('零');//不用再加单位weight
					}
					$lastDigit = $digit;
				}
				$zhNumSub && $zhNum .= self::$units[$k] . $zhNumSub;//去掉大单位
			}
			return strrev($zhNum);
		}
	}
