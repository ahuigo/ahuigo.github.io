# Expression

## and or
and 优先级更高

    2 || 1 && 0 //2
    (2 || 1) && 0 //0
    0 && 1 || 3     //3
    0 && (1 || 3)     //0

## Condition 

	switch(n) { case 1: 'code block' ;break;}
	带类型匹配, 1 与'1'不同

## break label

	break [label]; 不支持break numer

	function foo () {
		dance:
		for(var k = 0; k < 4; k++){
			for(var m = 0; m < 4; m++){
				if(m == 2){
					break dance;
				}
			}
		}
	}

## for

	for(i in obj){obj[i]...} // PropertyIsEnumerable
	for(i=0;i<5;i++){...}


# 运算符

## Bits Operation 位运算

	num & num
	num | num
	~num 取反
	num ^ num	//xor
	#左右位移(有符号)
	1<<2 # 1<<34 == 1<<2
	a>>32 === a>>0 === a;
		#有符号右移(符号位不变)
		-4>>1; -2
		-4>>2; -1
		-4>>3; -1
		-4>>4; -1

		#有符号左移==无符号左移等价(但符号位会变)
		-1<<2; -4
		-1<<31 ; -2147483648
		1<<30 ; 1073741824
		1<<31 ; -2147483648

		#无符号移右移(高位变成0), 符号位会变,输出无符号数
		> -1>>>1; 2147483647
		> -1>>>0; 4294967295
		> -1>>>32; 4294967295

		#不存在有符号移左移
		1<<<3

## 逻辑

	!var
	var && var
		逻辑 AND 运算并不一定返回 Boolean 值：
			如果一个运算数是对象，另一个是 Boolean 值，返回该对象。
				1 && obj //return obj
				0 && obj // return 0
				obj1 && obj2 //return obj2(if obj1不为空)
			如果某个运算数是 null
				1 && null //return null
				0 && null //return 0
			如果某个运算数是 NaN
				1 && NaN //return NaN
				0 && NaN //return 0
	var || var
		逻辑 OR 运算并不一定返回 Boolean 值(同上)

