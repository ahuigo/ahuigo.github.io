# Array

## 像mysql 一样对多列数据排序

	$ar = array(
       array("10", 11, 100, 100, "a"),
       array(   1,  2, "2",   3,   1)
      );
	array_multisort($ar[0], SORT_ASC, SORT_STRING,
	                $ar[1], SORT_NUMERIC, SORT_DESC);
	var_dump($ar);

本例中在排序后，第一个数组将变成 "10"，100，100，11，"a"（被当作字符串以升序排列）。第二个数组将包含 1, 3, "2", 2, 1（被当作数字以降序排列）。

	array(2) {
	  [0]=> array(5) {
	    [0]=> string(2) "10"
	    [1]=> int(100)
	    [2]=> int(100)
	    [3]=> int(11)
	    [4]=> string(1) "a"
	  }
	  [1]=> array(5) {
	    [0]=> int(1)
	    [1]=> int(3)
	    [2]=> string(1) "2"
	    [3]=> int(2)
	    [4]=> int(1)
	  }
	}

## next end

	$transport = array('foot', 'bike', 'car', 'plane');
	$mode = current($transport); // $mode = 'foot';
	$mode = next($transport);    // $mode = 'bike';
	$mode = next($transport);    // $mode = 'car';
	$mode = prev($transport);    // $mode = 'bike';
	$mode = end($transport);     // $mode = 'plane';

## compact and extract

### compact
For each of these, `compact()` looks for a variable with that name in the current symbol table
and adds it to the output array such that the variable name becomes the key and the contents of the variable become the value for that key.
In short, it does the opposite of extract().

	<?php
	$out1 = '234';
	$out2 = '234';
	function a(){
		$var1 = '1';
		$var2 = '2';
		var_dump(compact('var1', ['var2', 'out1', 'out2']));// not work for out
	}
	a();

Results:

	array(2) {
	  ["var1"]=> string(1) "1"
	  ["var2"]=> string(1) "2"
	}

### extract

	int extract ( array &$array [, int $flags = EXTR_OVERWRITE [, string $prefix = NULL ]] )
		Key as variable name, and val for that key as content of variable

	extract($var_array, EXTR_PREFIX_SAME, "prefix");

## Pointer, 指针
prev, current, next, reset, end

list($k, $v) = each($arr)

## Iterator
Interface for external iterators or objects that can be iterated themselves internally.(current/key/next/rewind/valid)

### array_keys array_values
array_keys 与 array_values 得到的元素顺序不会变
http://stackoverflow.com/questions/21092095/is-elements-order-the-same-after-array-being-split-by-array-keys-and-array-val

### walk

	//用于改变原数组 或者 通过闭包函数返回新的数组或者结果集
	bool array_walk ( array &$array , callable $callback [, mixed $userdata = NULL ] );//$callback(&$item, $key, $userdata = null). 始终返回true. 但是外部的$userdata 始终是按值传递进去的:&$userdata 是没有用的
	//用于生成新数组
	$b = array_map($func, $a, $b, ...);//返回一个数组：array($func($a_item,$b_item,...)); //$func 按引用传值 无效
	array_map('sum', $a, $b);

	//累积,累加,累...
	mixed array_reduce($arr, $func[, $init_value = null]); //sum($carry = $init_value, $item)  不支持传$key

### filter array
返回过滤后的数组

	array array_filter ( array $input [, callable $callback = "" ] );//1. bool $callback($v); true 保留 2. $callback 可以按引用传值

Example:

	$arr = ['a'=>1, 'b'=>0, 'c'=>false, 'd'=>''];
	var_dump(array_filter($arr));
	array(1) {
	  ["a"]=>
	  int(1)
	}

### filter array keys

	$arr = ['foo'=>'value1', 'bar' => 'value2'];
	$allowed = ['foo'];
	var_dump(array_intersect_key($arr, array_flip($allowed)));
		array(1) {
		  ["foo"]=>
		  string(6) "value1"
		}

	var_dump(array_diff_key($arr, array_flip($allowed)));
		  "bar"=> "value2"

### array_column

	$b = array_column([['a'=>1,'b'=>2], ['a'=>3,'b'=>4]],'b');
	print_r($b); //[2, 4]
	$b = array_column([['a'=>1,'b'=>2], ['a'=>3,'b'=>4]],'b', 'a');
	[1=>2, 3=>4]

## 统计频度

### array_count_values

	$array = array(1, "hello", 1, "world", "hello");
	print_r(array_count_values($array));//1=>2 hello=>2 world=>1

### array_unique

	array_unique();

## sort 排序
Trim index association

	sort($arr)
	rsort
	usort
	shuffle

Maintain index association

	asort
	ksort
	natsort

	uasort
	uksort

With no params reference:

	array_reverse
	array_flip

array_flip 跟array_merge 一样，后面的key 会覆盖前面的

	var_dump(array_flip(['a'=>'b', 'c'=>'b']));
	array(1) {
	  ["b"]=>
	  string(1) "c"
	}

## 合并-拆分

	array_combine($keys, $values)
	array_merge(["k"=>1, 2=>3], ["k"=>0, 4=>5]); //Array ( [k] => 0 [0] => 3 [1] => 5)
	["k"=>1, 2=>3]+["k"=>0, 2=>5]; //不覆盖 Array ( [k] => 1 [2] => 3)
	array_slice($arr, $start, $length, $preserve_key = false)
	array_splice

## array_remove

	array_diff($array, [$element]);
	or
	if(($key = array_search($del_val, $arr)) !== false) {
		unset($arr[$key]);
	}


## array intersection Difference Union 交差并集

### array union 并

	var_dump(['a'=>1]+['a'=>2]);
	array(1) {
	  ["a"]=>
	  int(1)
	}

### 交差

	array_intersect();		# inte value only
	array_intersect_assoc();# inte value and key
	array_intersect_key();# inte key only
	array_diff(); 			# diff value only
	array_udiff(); 			# diff value only via user defined function
	array_diff_assoc();		# diff value and key
	array_diff_key();		# diff key only

array_remove_key

	array_diff_key($data, array_flip($bad_keys));

array_keep_key

	function array_keep_key($data, $keep_keys) {
        $arr = [];
        foreach ($keep_keys as $k) {
            //isset($data[$k]) && $arr[$k] = $data[$k];
            array_key_exists($k, $data) && $arr[$k] = $data[$k];
        }
        return $arr;
    }
	function array_keep_key($data, $keep_keys){
		array_diff_key($data,array_flip(array_diff(array_keys($data), $keep_keys)));
	}


## rand

	array_rand($arr[, $num = 1]);//返回rand_key or rand_keys
	shuffle()

## range

	range(1, 10);//1,2,3...10
	range(1, 5, 3);//1,4

## 求和

	array_sum

## chunk(split)

	array_chunk($array, $size)
    array_partition($array, $num); //costum by php-lib/lib/array.php

## fill & pad

	Array array_fill($start, $num, $value);
		 var_dump(array_fill(5, 2, '?'));
		array(2) {
		  [5]=>
		  string(1) "?"
		  [6]=>
		  string(1) "?"
		}
	Array array_pad($arr, $len, $value);
