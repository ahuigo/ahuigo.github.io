---
title: go str html
date: 2020-03-31
private: true
---
# print tool
- fmt.Println : space, with newline
- fmt.Print : without newline
- fmt.Printf : format

另外还有，内置的标准错误输出(print to stderr):
1. print      prints all arguments; formatting of arguments is implementation-specific
2. println    like print but prints spaces between arguments and a newline at the end

## println, print
stderr

    # no need import fmt
    println(xyz, a2)
    print(123)

## fmt.Println
any type:

    fmt.Println(a1,b2)

## fmt.Printf

    var i int
	var f float64
	var b bool
	var s string
	fmt.Printf("%v %v %v %q\n", i, f, b, s)
        0 0 false ""

# fmt print

## fmt format
https://gobyexample.com/string-formatting

### Print raw,type

    %T type
    %q double-quote strings
    %#v Go syntax representation
    %+v variant will include the struct’s field names. or error trace

### print number
for number 

    space    prefix non-negative number with a space
    +    prefix non-negative number with a plus sign
    -    left-justify within the field
    0    use zeros, not spaces, to right-justify
    #    puts the leading 0 for any octal, prefix non-zero hexadecimal with 0x or 0X, prefix non-zero binary with 0b

### print address

    var i = 0
    fmt.Printf("%p", &i)
    var slice=[]int{0}
    fmt.Printf("%p", slice)


## Print string
> see go-fmt
1. `printf` is equivalent to writing `fprintf(stdout, ...)` and writes formatted text to `standard output stream`
2. `sprintf` writes formatted text to an `array of char`, as opposed to a stream.

A string is in effect a read-only slice of bytes.

    "3132" == fmt.Sprintf("%x", "12")
    "3132" == fmt.Sprintf("%x", 0x3132)

quoted string as go syntax

    fmt.Printf("%q\n", "中\x00sample")
    // "中\x00sample"
    fmt.Printf("%+q\n", "中\x00sample")
    //"\u4e2d\x00sample"


## Printf

    fmt.Printf("Bool:%t\n", 1==2)
    fmt.Printf("二进制：%b\n", 255)
    fmt.Printf("八进制：%o\n", 255)
    fmt.Printf("十六进制：%X\n", 255)
    fmt.Printf("十进制：%d\n", 255)
    fmt.Printf("浮点数：%f\n", math.Pi)
    fmt.Printf("字符串：%s\n", "hello world")
    pf:=fmt.Printf
    pf("字符串：%s\n", "hello world")

General:

  %v	the value in a default format
  	when printing structs, the plus flag (%+v) adds field names
  %#v	a Go-syntax representation of the value
  %T	a Go-syntax representation of the type of the value
  %%	a literal percent sign; consumes no value

Integer:

  %b	base 2
  %c	the character represented by the corresponding Unicode code point
  %d	base 10
  %o	base 8
  %q	a single-quoted character literal safely escaped with Go syntax.
  	%+q   Escaped Unicode char(%+q). see: go-str print: 
  %x	base 16, with lower-case letters for a-f
  %X	base 16, with upper-case letters for A-F
  %U	Unicode format: U+1234; same as "U+%04X"

### Padding
left:

    fmt.Sprintf("%10v", v)

right:

    fmt.Sprintf("%-10v", v)

### pointer
Pointer:

	%p	base 16 notation, with leading 0x

The default format for %v is:

	bool:                    %t
	int, int8 etc.:          %d
	uint, uint8 etc.:        %d, %x if printed with %#v
	float32, complex64, etc: %g
	string:                  %s
	chan:                    %p
	pointer:                 %p

### other flag
Other flags:

	+	always print a sign for numeric values;
		guarantee ASCII-only output for %q (%+q)
	-	pad with spaces on the right rather than the left (left-justify the field)
	#	alternate format: add leading 0 for octal (%#o), 0x for hex (%#x);
		0X for hex (%#X); suppress 0x for %p (%#p);
		for %q, print a raw (backquoted, grave accent) string
		print after if the character is printable for %U (%#U). see:go-str
	' '	(space) leave a space for elided sign in numbers (% d);
		put spaces between bytes printing strings or slices in hex (% x, % X)
	0	pad with leading zeros rather than spaces;(e.g. '003')
		for numbers, this moves the padding after the sign

# fmt Scan
## .Sprint any type
    i := 23
    s := fmt.Sprint("[age:", i, "]") 
        // s will be "[age:23]"

    s := fmt.Sprint("[age:",true, i,[]int{4,5},  "]") 
        [age:true 23 [4 5]]

## Scanf, parse format
## Scanln

	//让主进程停住，不然主进程退了，goroutine也就退了
	 var input string
	 fmt.Scanln(&input)
	 fmt.Println("done")

## Sprintf, format

  var i byte = 1
  var s:= fmt.Sprintf("%d",i)
  fmt.Print(s)

# String format
##  text/template and html/template. 
html/template is for generating HTML output safe against code injection. 

template + data:

    const emailTmpl = `Hi {{.Name}}!
        Your account is ready, your user name is: {{.UserName}}
        You have the following roles assigned:
        {{range $i, $r := .Roles}}{{if $i}}, {{end}}{{.}}{{end}}
    `

    data := map[string]interface{}{
        "Name":     "Bob",
        "UserName": "bob92",
        "Roles":    []string{"dbteam", "uiteam", "tester"},
    }

 Executing the template and getting the result as string:

    t := template.Must(template.New("email").Parse(emailTmpl))
    buf := &bytes.Buffer{}
    if err := t.Execute(buf, data); err != nil {
        panic(err)
    }
    s := buf.String()

write to `os.Stdout`

    t := template.Must(template.New("email").Parse(emailTmpl))
    if err := t.Execute(os.Stdout, data); err != nil {
        panic(err)
    }

full example: go-lib/str/format.go
