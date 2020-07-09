---
title: golang string
date: 2018-09-27
private:
---
# rune vs byte

    type byte uint8
    type rune int32 //'a','中'

    // is slice of read only bytes
    type string []byte 
    // is byte 
    str[0]

## rune
单引号字符常量表  Unicode Code Point, 持 `\uFFFF、\U7FFFFFFF、\xFF` 格式。 对应 rune 类型,UCS-4。

    var c1, c2 rune = '\u6211', '们'
    println(c1 == '我', string(c2) == "\xe4\xbb\xac")
    '⌘' // is 0x2318.

单引号其实就是: rune int32:

    rune('a') == 'a' == int32('a') == 97

## byte(chr/ord)
byte 其实是int8

    fmt.Printf("%T,%T", byte('a'),'a', "abc"[0])
    // uint8, int32, uint8

byte array:

    src:=[]byte{'a',0,'b'}
    src:=[]byte("abc")

### string index
go 的string 本身存储就是bytes

    "中"[0] === []byte("中")[0]

### bytes2str

    > string([]byte{1,2,3})
        "\x01\x02\x03"

    > string([]byte{0xe4, 0xb8, 0xad}) == "中" == "\xe4\xb8\xad"

### str2bytes:
method 1

    []byte(s)

method 2

    import "strings"

    b := make([]byte, 8);//buffer
    r := strings.NewReader("0123")
    n, err := r.Read(b) 
        //if err == io.EOF 
    println(b[:n]) 
        //"0123" byte is uint8

### chr ord

    //chr
    string(49) //"1"
    //ord
    "1"[0]

### bytes to hex
1. Encode(dst, src): `[]byte:"12"` to `[]byte:"3132"`:
2. Decode: `[]byte:"3132"` to `[]byte("12")`:

byte to hex-string
1. EncodeToString: `[]byte("12")` to `"3132"`:
2. DecodeString: `"3132"` to `[]byte("12")`:

encode/decode bytes example

    package main

    import (
        "encoding/hex"
        "fmt"
        "log"
    )

    func main() {
        decoded, err := hex.DecodeString("3132")
        fmt.Printf("%s\n", decoded)
        hex.EncodeToString([]byte("12"))=="3132"
    }

# string

## inner pointer(内存结构)
    + |pointer|len=5|       s="hello" 
          |         |
        + |h|e|l|l|o|       [5]byte
            |   |
        + |pointer|len=2|   s[1:3]

string 本身为指针（值不可修改），

    var s2 string
    s1:="h1llo"
    s2="hello" // "hello" 其实是指针(指向头部)
    s2=s1

    // 查看的是字符指针的地址(不同)
    fmt.Printf("%p,%p\n", &s1, &s2)

    // 查看的是字符指针(相同): %!p(string=h1llo),%!p(string=h1llo)
    fmt.Printf("%p,%p\n", s1, s2)

## define

    "12"
    "12\x00\u2318"
    "中" == "\xe4\xb8\xad"

### here doc str

    str := `\n\r\b\\` //literal

### str format
see go-str-html.md

## loop string
### range rune

    const nihongo = "日本語"
    for index, runeValue := range nihongo {
        fmt.Printf("%#U starts at byte position %d\n", runeValue, index)
        fmt.Printf("%U starts at byte position %d\n", runeValue, index)
    }

output:

    U+65E5 '日' starts at byte position 0
    U+65E5 starts at byte position 0
    U+672C '本' starts at byte position 3
    U+672C starts at byte position 3
    U+8A9E '語' starts at byte position 6
    U+8A9E starts at byte position 6

ignore index

    for _, runeValue := range nihongo{}
    for range nihongo{}

### range byte

    for i:0;i<len(s);i++{
        s[i]
    }

## change str and convert str
不可以修改字符串:

    //error
    s:="123"
    s[0]=2

可以替换字符串(地址不变)：

    var s string
    s = "bbb"
    printf("%p\n",&s)
    s = "ssss"
    printf("%p\n",&s)


要修改字符串,可先将其转换成 []rune 或 []byte 再修改,完成后再转换为 string。 论哪种转 换,都会重新分配内存,并复制字节数组。

    s := "abcd"
    bs := []byte(s)
    bs[1] = 'B'
    println(string(bs))

    u := "电脑"
    us := []rune(u)
    us[1] = '话'
    println(string(us))

## concat string

    s := "Hello, " +
        "World!"

# Fields

## explode/split, str to slice
If no content, reurn `empty slice`

    import strings
    fmt.Printf("Fields are: %q", strings.Fields("  foo bar  baz   "))

    fmt.Printf("Fields are: %q", strings.Split("foo,bar,baz",","))

## join

  strings.Join([]string{"a","b"}, ",")

# strconv

## convert bool
    b, err := strconv.ParseBool("true") //true
    b, err := strconv.ParseBool("1") //true
    b, err := strconv.ParseBool("0") //false
    b, err := strconv.ParseBool("") //false
    b, err := strconv.ParseBool("abc") //false

## convert expr

    fmt.Sprintf("%v", v)
   
## io.Copy Reader

		io.Copy(os.Stdout, &r)
			实际调用r.Read(buf []byte)

example:

	import (
		"io"
		"os"
		"strings"
	)

	type rot13Reader struct {
		r io.Reader
	}
	func (r *rot13Reader) Read(b []byte) (int, error){
			n, err:= (*r).r.Read(b)
			return n, err
	}


	func main() {
		s := strings.NewReader("Lbh penpxrq gur pbqr!")
		r := rot13Reader{s}
		io.Copy(os.Stdout, &r)
	}

# String function
## trim
trim 字符集

    strings.Trim(str2, "@$") 
    strings.TrimLeft(str2, "@$") 
    strings.TrimRight(str2, "@$") 
    strings.TrimSpace("abc\n")

trim 字符串

    strings.TrimSuffix("abc,", "ing")
    strings.TrimPrefix("abc,", "pre")
## slice
    s[:5]
## copy string
赋值时它不像slice 引用, 而是传值

    # 等价
    s1:=s
    s1:=s[:]

 Copy returns the number of elements copied, which will be the minimum of len(src) and len(dst).

    func copy(dst, src []Type) int

    src:=[]byte{'a',0,'b'}
    p:= make([]byte, 10)
    p[4]='c'
    copy(p,src)
    fmt.Println((p), len(p))

## in stirng, contain
    import "strings"
    strings.Contains("something", "some") // true



