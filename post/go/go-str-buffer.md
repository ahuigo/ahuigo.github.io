---
title: golang io buffer
date: 2020-03-29
private: true
---
# golang buffer
> go-lib/str/buffer.go

## initial buffer
    func NewBuffer(buf []byte) *Buffer { return &Buffer{buf: buf} }

bytes.Buffer是一个缓冲byte类型的缓冲器. 

    //等价
    buf1 := bytes.NewBufferString("hello")
    buf2 := bytes.NewBuffer([]byte("hello"))
    buf3 := bytes.NewBuffer([]byte{'h','e','l','l','o'})

    fmt.Println(buf1.String(),buf2.String(),buf3.String())

buffer 是slice结构，可以自动扩容，也可以指定始容量

    buf3 := bytes.NewBuffer(make([]byte, 0, 512))

初始化为空：

    // 即可以是结构变量
    var buf bytes.Buffer
    // 也可以是pointer变量
    buf := &bytes.Buffer{}
    buf := new(bytes.Buffer)

## convert buffer to other
    buf.Bytes()
    buf.String()

## write buffer
> write 相当于字符串连接join bytes.buffer 比strings.Join 快一点儿:
write byte slice

    //func (b *Buffer) Write(p []byte) (n int,err error)
    buf3.Write([]byte(" world"))

write one byte/Rune

    var a byte='s'
    buf3.WriteByte(a)

    var s rune='好'
    buf3.WriteByte(s)

write string

    buf3.WriteString(" world")

via Fprintf

    fmt.Fprintf(&buf3, " world!")


### 重置buffer
buf 可以重置，如果buf 是从buffer 池取出来的，就必须重置：[go-pool](/go/go-pool)

    buf := bufPool.Get().(*bytes.Buffer)
    defer bufPool.Put(buf)
    buf.Reset()
    buf.WriteString(name)

### readFromFile

    file, _ := os.Open("hello.txt")
    buf := bytes.NewBufferString("bob ")
    buf.ReadFrom(file)
    fmt.Println(buf.String()) //bob hello world

## read buffer(读出)
也就是取buffer
### read to bytes
read 数量取决于写入bytes的容量

   s3 := make([]byte,3)
   buff.Read(s3)     //把buff的内容读入到s3，s3的容量为3，读了3个过来
   fmt.Println(buff.String()) //lo world
   fmt.Println(string(s3))   //hel
   buff.Read(s3) //继续读入3个，原来的被覆盖

### read 一个byte/rune

    b,_ := buf.ReadByte()   //取出第一个byte，赋值给b
    r,_ := buf.ReadRune()   //取出第一个Rune

### read 2 个bytes
    b := buf.Next(2)  //取前2个

### read 到分隔符停止
e.g.读取一行(包括分隔符)

   line,_ := buf.ReadBytes('\n')  //读到分隔符\n，并返回给line(bytes)
   lineStr,_ := buf.ReadString('\n')  //读到分隔符\n

### read 到文件
   file,_ := os.Create("text.txt")
   buf := bytes.NewBufferString("hello world")
   buf.WriteTo(file)
   //或者使用写入，fmt.Fprintf(file,buf.String())

### read to stdout
参考 go file

    var b bytes.Buffer
    io.Copy(os.Stdout, &b)

# io.Reader interface
除了bytes Buffer, 还有strings reader, 它们都实现了io.Reader interface

    bytes.NewReader(jsonBytes) // *bytes.Reader
    bytes.NewBuffer(jsonBytes) // *bytes.Buffer
    strings.NewReader(json) // *strings.Reader

    var s *strings.Reader = strings.NewReader("username=admin&password=pass"))

## convert map to io.Reader

# todo
Go 中 io 包的使用方法
https://segmentfault.com/a/1190000015591319
