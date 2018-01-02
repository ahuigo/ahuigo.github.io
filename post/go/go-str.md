# bytes

  var out bytes.Buffer

## read bytes

  r := strings.NewReader("some input")
  b := make([]byte, 8);//buffer
  r.Read(b)

# string

## here doc str

  str := `ab\bc`

## rune
单引号字符常量表  Unicode Code Point, 持 `\uFFFF、\U7FFFFFFF、\xFF` 格式。 对应 rune 类型,UCS-4。

  var c1, c2 rune = '\u6211', '们'
  println(c1 == '我', string(c2) == "\xe4\xbb\xac")

## change str
要修改字符串,可先将其转换成 []rune 或 []byte,完成后再转换为 string。 论哪种转 换,都会重新分配内存,并复制字节数组。

  s := "abcd"
  bs := []byte(s)
  bs[1] = 'B'
  println(string(bs))

  u := "电脑"
  us := []rune(u)
  us[1] = '话'
  println(string(us))

### rune(code point)
"Code point" is a bit of a mouthful, so Go introduces a shorter term for the concept: `rune`.
The term appears in the libraries and source code, and means exactly the same as "code point", with one interesting addition.

The Go language defines the word rune as an alias for the `type int32`, so programs can be clear when an integer value represents a `code point`.
Moreover, what you might think of as a character constant is called a rune constant in Go. The type and value of the expression

  '⌘'

is rune with integer value 0x2318.

To summarize, here are the salient points:

1. Go source code is always UTF-8.
2. A string holds arbitrary bytes.
3. A string literal, absent byte-level escapes, always holds valid UTF-8 sequences.
4. Those sequences represent Unicode code points, called runes(int32).

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

### range byte

  for i:0;i<len(s);i++{
    s[i]
  }

## Print string
> see go-fmt

A string is in effect a read-only slice of bytes.

  fmt.Sprintf("%x", "\x31\x32"[0])
    31
  fmt.Sprintf("%x", "\x31\x32")
    3132
  fmt.Sprintf("%    x", "12")
    31 32

quoted string as go syntax

  fmt.Sprintf("%q", "12\x00\u2318")
    "12\x00⌘"
  fmt.Sprintf("%+q", "12\x00")
    "\x31\x32\x00\u2318"


# Fields

## explode, str to slice
If no content in reurn `empty slice`

  import strings
  fmt.Printf("Fields are: %q", strings.Fields("  foo bar  baz   "))

## join

  strings.Join([]string{"a","b"}, ",")

# strconv

## .Atoi
str to int, strconv.Atoi

  var t = []string{"1", "2", "3"}
  var t2 = []int{}
  for _, i := range t {
      j, err := strconv.Atoi(i)
      if err != nil {
          panic(err)
      }
      t2 = append(t2, j)
  }
  a_

## .Itoa

  s := strconv.Itoa(-42)

## byte2str

  gore> string([]byte{1,2,3})
  "\x01\x02\x03"
  gore> string(1)
  "\x01"

# trim

  strings.TrimSuffix("abc,", ",")
  func TrimSpace(s string) string
