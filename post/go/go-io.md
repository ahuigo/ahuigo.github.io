---
title: go io
date: 2021-02-03
private: true
---
# reader closer

# io.Reader
    type Reader interface {
        Read(p []byte) (n int, err error)
    }

## reader 
### string reader

    strings.NewReader("abc")

### bytes reader
build bytes reader/writer

    b:=make([]byte, 0, 10)
    buf = bytes.NewBuffer([]byte("hi"))

    // reader
    buf.Read(b)
    // writer
    buf.ReadFrom(reader)

e.g2:

    cmd := exec.Command("cat")

    cmd.Stdin = bytes.NewBuffer([]byte("hi"))
    cmd.Stdout = os.Stdout
	cmd.Stderr = &bytes.Buffer{}
    cmd.Run()

### teeReader
teeReader 相当于是shell tee 命令

    package main

    import (
        "io"
        "io/ioutil"
        "os"
        "strings"
    )

    func main() {
        var r io.Reader = strings.NewReader("some io.Reader stream to be read\n")
        r = io.TeeReader(r, os.Stdout)
        str := ioutil.ReadAll(r)
    }

### file reader

    fileReader, err := os.Open("/tmp/dat")
    fileReader.Close()

### NopCloser
为reader 添加close 方法支持

	buf := &bytes.Buffer{}
	readerCloser := ioutil.NopCloser(buf)


gonic 的例子

    c.Request.Body:= ioutil.NopCloser(bytes.NewBuffer(buf))

## 读reader
io.Reader:

    type Reader interface {
        Read(p []byte) (n int, err error)
    }

### read to buffer via reader
buffer reader

    func readBody(reader io.Reader) string {
        buf := new(bytes.Buffer)
        n, err := buf.ReadFrom(reader)  // via reader.Read(buf.buf)

        s := buf.String()
        return s
    }

### read to writer via reader (io.Copy)
    var b *bytes.Buffer = bytes.NewBuffer([]byte("hi"))
    io.Copy(os.Stdout, b) // copy b to stdout

### raw copy: bytes to bytes
read to bytes from bytes

    // go-lib/str/bytes.go
    p := make([]byte, 10)
    copy(p[3:], []byte("hello"))
    copy(p[1:], []byte("0123"))

    // bp:  0123llo   [0 48 49 50 51 108 108 111 0 0]
    fmt.Println("bp:",string(p), p)

## pipe

### pipe buffer to
    var b *bytes.Buffer = bytes.NewBuffer([]byte("hi"))
    io.Copy(os.Stdout, b) // copy b to stdout

### pipe file to

    io.Copy(ctx.Writer, f)