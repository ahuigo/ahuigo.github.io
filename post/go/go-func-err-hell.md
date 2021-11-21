---
title: go err hell
date: 2021-11-21
private: true
---
# go err hell
Error Check  Hell
好了，说到 Go 语言的 if err !=nil 的代码了，这样的代码的确是能让人写到吐。那么有没有什么好的方式呢，有的。我们先看如下的一个令人崩溃的代码。

    func parse(r io.Reader) (*Point, error) {
        var p Point
        if err := binary.Read(r, binary.BigEndian, &p.Longitude); err != nil {
            return nil, err
        }
        if err := binary.Read(r, binary.BigEndian, &p.Latitude); err != nil {
            return nil, err
        }
        ...
    }

## 函数式方案
要解决这个事，我们可以用函数式编程的方式，如下代码示例：

func parse(r io.Reader) (*Point, error) {
    var p Point
    var err error
    read := func(data interface{}) {
        if err != nil {
            return
        }
        err = binary.Read(r, binary.BigEndian, data)
    }
    read(&p.Longitude)
    read(&p.Latitude)
    read(&p.Distance)
    read(&p.ElevationGain)
    read(&p.ElevationLoss)
    if err != nil {
        return &p, err
    }
    return &p, nil
}
上面的代码我们可以看到，我们通过使用Closure 的方式把相同的代码给抽出来重新定义一个函数，这样大量的  if err!=nil 处理的很干净了。但是会带来一个问题，那就是有一个 err 变量和一个内部的函数，感觉不是很干净。

## 借鉴bufio.Scanner()
那么，我们还能不能搞得更干净一点呢，我们从Go 语言的 bufio.Scanner()中似乎可以学习到一些东西：

    scanner := bufio.NewScanner(input)
    for scanner.Scan() {
        token := scanner.Text()
        // process token
    }
    if err := scanner.Err(); err != nil {
        // process the error
    }

上面的代码我们可以看到，scanner在操作底层的I/O的时候，那个for-loop中`没有任何的 if err !=nil `的情况，退出循环后有一个 scanner.Err() 的检查。看来使用了结构体的方式。模仿它，我们可以把我们的代码重构成下面这样：

## 
首先，定义一个结构体和一个成员函数

type Reader struct {
    r   io.Reader
    err error
}
func (r *Reader) read(data interface{}) {
    if r.err == nil {
        r.err = binary.Read(r.r, binary.BigEndian, data)
    }
}
然后，我们的代码就可以变成下面这样：

    func parse(input io.Reader) (*Point, error) {
        var p Point
        r := Reader{r: input}
        r.read(&p.Longitude)
        r.read(&p.Latitude)
        r.read(&p.Distance)
        r.read(&p.ElevationGain)
        r.read(&p.ElevationLoss)
        if r.err != nil {
            return nil, r.err
        }
        return &p, nil
    }