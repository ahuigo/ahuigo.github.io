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

## 构建reader 
### string reader

    strings.NewReader(s)

### bytes reader
    var stderr bytes.Buffer
    cmd := exec.Command("cat")

    cmd.Stdin = bytes.NewBuffer([]byte("hi"))
    cmd.Stdout = os.Stdout
	cmd.Stderr = &stderr
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

### NopCloser
为reader 添加close 方法支持

	buf := &bytes.Buffer{}
	readerCloser := ioutil.NopCloser(buf)


gonic 的例子

    c.Request.Body:= ioutil.NopCloser(bytes.NewBuffer(buf))

## 读reader
bytes reader

    func readBody(reader io.Reader) string {
        buf := new(bytes.Buffer)
        buf.ReadFrom(reader)

        s := buf.String()
        return s
    }