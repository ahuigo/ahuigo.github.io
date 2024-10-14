---
title: gawk array
date: 2024-10-01
private: true
---
# array

	#awk 将 myarr["1"] 和 myarr[1] 指向同一元素, 这类似于索引php不区别引号
    # 索引从1开始
	myarray[1]="jim"
	myarray['name']="Ye"

## init

    gawk 'BEGIN{arr[1]="name"; for(k in arr)print arr[k]}'

## for-in

	for ( x in myarray ) { }# ok
	for (x in myarray) { # wrong!(无空白)
		print myarray[x]
		//continue; break;
	}
## push, pop, unshift

    function push(A,B) { A[length(A)+1] = B }

实现unshift 比较复杂: https://github.com/xfix/awk-plus-plus

    function unshift(arr, value, array) {
        clone(array, arr)
        empty(arr)
        push(arr, value)
        for (i = 1; i <= len(array); i++) {
            push(arr, array[i])
        }
    }
    function empty(array) {
        split("", array)
    }
    function clone(ret, array, key) {
        for (key in array) {
            ret[key] = array[key]
        }
    }
## delete

	delete arr[1]


## in_array
In array:

	if('Ye' in myarray){
		print "Yep! It's here!"
	}
	if('Ye' in myarray == 1){
		print "Yep! It's here!"
	}

Not in array

	!('Ye' in myarray){
		print "No in array"
	}
	('Ye' in myarray == 0){
		print "No in array"
	}

取两文件的差集(difference set)(ori.txt - filter.txt):

	awk -F'|' 'NR==FNR{check[$0];next} !($1 in check){print $0}' filter.txt ori.txt
	awk -F'|' 'NR==FNR{check[$0];next} $1 in check{print $0}' filter.txt ori.txt

	-F'|'
		-- sets the field separator
	'NR==FNR{check[$0];next}
		-- if the total record number matches the file record number (i.e. we're reading the first file provided), then we populate an array and continue.
	$2 in check
		-- If the second field was mentioned in the array we created, print the line (which is the default action if no actions are provided).
	file2 file1
		-- the files. Order is important due to the NR==FNR construct.

## sort
sort and keep association:

	//asort
	gawk 'BEGIN{
		arr["a"]=1;arr["b"]=5;arr["c"]=4;
		n=asort(arr);
		for(i in arr){
			print i,arr[i];
		}
	}'


sort via index

	n=asorti(arr, sorted)
	for (i=1; i<=n; i++) {
			print sorted[i] " : " arr[sorted[i]]
	}

sort via shell:

	for(i in arr) print arr[i] | "sort";
