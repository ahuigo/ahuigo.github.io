# fmt

- Println : with newline
- Print : without newline
- Printf : format

## Printf

		fmt.Printf("%t\n", 1==2)
    fmt.Printf("二进制：%b\n", 255)
    fmt.Printf("八进制：%o\n", 255)
    fmt.Printf("十六进制：%X\n", 255)
    fmt.Printf("十进制：%d\n", 255)
    fmt.Printf("浮点数：%f\n", math.Pi)
    fmt.Printf("字符串：%s\n", "hello world")

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
  	escape printed char with plus flag(%+q). see: go-str
  %x	base 16, with lower-case letters for a-f
  %X	base 16, with upper-case letters for A-F
  %U	Unicode format: U+1234; same as "U+%04X"

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

## Scanf, parse format
## Scanln

	//让主进程停住，不然主进程退了，goroutine也就退了
	 var input string
	 fmt.Scanln(&input)
	 fmt.Println("done")

## Sprintf, format

  var i byte = 1
  fmt.Print(fmt.Sprintf("%d",i))
