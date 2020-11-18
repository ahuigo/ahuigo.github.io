---
title: Golang：Array and slice
date: 2018-09-27
---
# array vs slice
1. An array has fixed size, `[N]T`
2. a slice is a dynamically-sized. `[]T` 
3. slice assign/pass-arguments is Reference, point to original slice but not array

## define array slice
array:

    [N]Type
    [N]Type{value1, value2, ..., valueN}
    [...]Type{value1, value2, ..., valueN}

    [5]int{2: 100, 4:200} //指定索引号,len=cap=5
    [2][3]int{{1, 2, 3}, {4, 5, 6}}
    [...][2]int{{1, 1}, {2, 2}, {3, 3}} 

slice: 

    make([]Type, length, capacity)
    make([]Type, length)
    []Type{}
    []Type{value1, value2, ..., valueN}

array(slice1,slice2,....):

    [...][]int{{1, 1}, {2, 2}, {3, 3}}

# Arrays
The type `[n]T` is an array of `n` values of type `T`

    var a [10]int           //0,0,0,0,0....
    var a [2]string         //"","","",...
	primes := [30]int{2, 3} //2,3,0,0,0..
	fmt.Println(primes)

也可以通过initial确定size:

    b := [...]string{"Penn", "Teller"}

## array assign is not reference

    a_copy := a

## array pointer

    x,y := 1, 2
	var arr =  [...]int{5:2}
	//数组指针
	var pf *[6]int = &arr

	//指针数组
	pfArr := [...]*int{&x,&y}
	fmt.Println(pf)
	fmt.Println(pfArr)

## in array
    func arrayIndex(a string, list []string) (int) {
        for i, b := range list {
            if b == a {
                return i
            }
        }
        return -1
    }

用funk 代替：


    funk.Contains([]string{"foo", "bar"}, "bar") // true

    // slice of Foo ptr
    funk.Contains([]*Foo{f}, f) // true
    funk.Contains([]*Foo{f}, nil) // false

# Slices
slice 中的array 是C++隐式引用array:

    struct Slice {
        byte*    array;
        uintgo   len;
        uintgo   cap;
    };

len 读写不可以超过len: len = high-low
cap 是可扩容的最大容量: cap = max-low

    data := [...]int{0, 1, 2, 3, 4, 5, 6}
    s := data[1:4:5]                      // [low : high : max]; max 默认是len(array)
    println(len(s), cap(s))

             +-low      high-+   +-max
             |               |   |
         +---+---+---+---+---+---+---+
    data |  0|  1|  2|  3|  4|  5|  6| 
         +---+---+---+---+---+---+---+ 
             |<--- len ----->|   |
             |<----- cap ------->|

## create slice
A nil slice has a length and capacity of 0 and has `no underlying array`(no pointer):
但是常量 []int{}==nil 不成立，常量不是空指针nil

    var s []int;

    var s []int
    if s == nil {
        fmt.Println(s, len(s), cap(s))
    }

无论是nil 还是非nil, 它们的len/cap都是0

    var s []int
    s=[]int(nil)
    fmt.Println(s, len(s), cap(s))

nil slice 是可以append的

    // ok
    s := append([]int(nil), 1)

### init slice:

    s := []int{1,2,3,8:100} //len=9,cap=9
### init nil slice:

    []string(nil)

    //或者
    type struct A{
       names []string 
    }
    A{}.names == nil

### make slice:

    s2 := make([]int, 6, 8)
    fmt.Println(s2, len(s2), cap(s2))   //len=6,cap=8
    s3 := make([]int, 6)
    fmt.Println(s3, len(s3), cap(s3))   //len=6=cap

make 不能生成nil slice

    make([]int) //error

### slice structs:

    s := []struct {
        i int
        b bool
    }{
        {2, true},
        {3, false},
        {5, true},
        {7, true},
        {11, false},
        {13, true},
    }

### slice literals is reference
Array is not reference:

	var a = [6]int{1,2,3}
	b := a
	b[0] = 100
	fmt.Println(a,b);   // [1 2 3] [100 2 3]

Slice is reference:

	var a = []int{1,2,3}
	b := a
	b[0] = 100
	fmt.Println(a,b);# [100 2 3] [100 2 3]


## reslice
len 限制了slice 读写，用reslice 创建新的slice 以便在cap 范围内读写：

    s1 := []int{0,1,2,3,4,5,6,7,8,9}
    s2 := s1[2:3:5]     //len=1,cap=3: {2}
                        //s2[1] 是index out of range
    s3 := s2[1:]        //len=0,cap=2: {} 
    s3 := s2[1:2:3]        //len=1,cap=2: {3}
    s3 := s2[1:3:3]        //len=2,cap=2: {3,4}

> reslice 不能超出cap 大小

## join slice

    :import strings
    s := [2]string{"hello", "world"}
    strings.Join(s[:], ",")

## copy
slice 和 array 类型不同, slice是按引用传值, 需要转一下slice[:] (go array是按值传值)

### reference copy
slice/array 本身value是指针(按引用传值)

    a := []int{1,2,3}
    b := make([]int,2) 
    fmt.Printf("%p,%p\n", b,a)  //not same
    b = a
    fmt.Printf("%p,%p\n", b,a)  //same

### copy slice
len(src)>len(dst) 会被golang 截断

    //func copy(dst, src []T) int
    t := make([]byte, len(s))
    copy(t, s)
    copy(arr[:], someSlice[0:4])

### copy via append

    s := append([]int{}, someSlice[0:2]...)
    s := append([]int(nil), []int{1,4}...)    //type(nil) 转为空slice

### copy generic via reflect

    func CopySlice(s interface{}) interface{} {
        t, v := reflect.TypeOf(s), reflect.ValueOf(s)
        c := reflect.MakeSlice(t, v.Len(), v.Len())
        reflect.Copy(c, v)
        return c.Interface()
    }
    a := []int{4, 2}
    b := CopySlice(a).([]int)


## append slice

    func append(s []T, x...T) []T

新分配空间 append 会copy 并扩容

    s2 = append(s,1,2) //s!=s2 (如果是新分配空间，则是完全不同的内存区域)

如果不分配空间就用:

    copy(slice[len(s):], data)

### concat merge slice
merge a and b:

    x := []int{}
    x = append(a,b...)

### append cap allocate
If the backing array of `s` is too small to fit all the given values, a bigger array will be allocated(double cap).

The returned slice will point to the newly allocated array.

    var a = [3]int{1,2,3}
    b := a[:];  # cap(b)=3
    b = append(b,4,5);  # newcap(b)= 2cap(b) = 6 

## range loop slice and array
The `range` form the `for loop iterates` over a `array, slice, string or map`, or values received on a channel.

    for i, v := range [2]int{1,2} {
		fmt.Printf("index=%d, %d\n", i, v)
	}

注意range is not reference! range 会复制对象. 除非使用指针

    // go-lib/array/range-copy-pointer.go
    roles := Roles{&Role{[]string{"ahui"}}}
    for _, role:= range roles{
        fmt.Printf("%p,%p\n", role,roles[0])
    }

### skip range index
You can skip the index or value by assigning to _.

    for _, v := range [2]int{1,2} {
        fmt.Printf("2**%d = %d\n", _, v)
    }

skip value:

    for index := range [2]int{1,2} {
        println(index)
    }

## Memory
Since a slice doesn't make a copy of the underlying array. To decrease memory  memory, release the reference for array.

    func copy(bigarray []int) []byte{
        b = bigarray[2:3]
        c := make([]byte, len(b))
        copy(c, b)
        return c
    }

# operation
## push and pop
## delete
via copy Truncate

    a := []string{"A", "B", "C", "D", "E"}
    i := 2

    a[i] = a[len(a)-1] // Copy last element to index i.
                // copy(a[i:], a[i+1:]) // slow
    a[len(a)-1] = ""   // Erase last element (write zero value).
    a = a[:len(a)-1]   // Truncate slice.

via append: 

    func remove(items []string, item string) []string {
        newitems := []string{}

        for _, v := range items {
            if v != item {
                newitems = append(newitems, v)
            }
        }
        return newitems
    }

### remove by index

    s = append(s[:index], s[index+1:]...)

# copy and deepcopy
https://flaviocopes.com/go-copying-structs/

## 浅copy
见go-lib/struct/copy-*.go

### slice 浅copy
slice copy：

    copy(s_dst, s_src)

e.g:

    type Cat struct {
        age     int
        name    string
        friends []string
    }

    func main() {
        wilson := []Cat{{7, "Wilson", []string{"Tom", "Tabata", "Willie"}}}
        nikita := []Cat{{}}        
        copy(nikita, wilson)            //Cat是浅复制
        nikita[0].age=6
        nikita[0].friends[0]="newuser"  //friends 同时改变

        fmt.Println(wilson)             //[{7 Wilson [newuser Tabata Willie]}]
        fmt.Println(nikita)             //[{6 Wilson [newuser Tabata Willie]}]
    }

### assign 浅copy
    s_dst := s_src[:]
    s_dst := s_src

与copy slice 一样的结果

    wilson := Cat{7, "Wilson", []string{"Tom", "Tabata", "Willie"}}
    nikita := wilson        //浅copy Cat
    nikita.age = 6
    nikita.friends[0]= "newuser"

## append 浅copy

    cat:= Cat{7, "Wilson", []string{"Tom", "Tabata", "Willie"}}
    s := append([]Cat{}, cat)
    s[0].age=6
    s[0].friends[0]="newuser"
    fmt.Println(s)      //[{6 Wilson [newuser Tabata Willie]}]


## deepcopy
深复制的方法：利用copier+新对象

### copier+new Class

    // "github.com/jinzhu/copier"
    wilson := Cat{7, "Wilson", []string{"Tom", "Tabata", "Willie"}}
    nikita := Cat{}
    copier.Copy(&nikita, &wilson)

### copier+make
    nikita.friends = make([]string, len(wilson.friends))  //指针替换