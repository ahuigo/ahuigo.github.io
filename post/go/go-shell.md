---
title: 系统调用
date: 2018-09-27
---
# 系统调用
Go语言主要是通过两个包完成的。一个是os包，一个是syscall包

1. syscall 里提供了什么Chroot/Chmod/Chmod/Chdir…，Getenv/Getgid/Getpid/Getgroups/Getpid/Getppid…，还有很多如Inotify/Ptrace/Epoll/Socket/…的系统调用。
2. os包里提供的东西不多，主要是一个跨平台的调用。它有三个子包，Exec（运行别的命令）, Signal（捕捉信号）和User（通过uid查name之类的）

# linux

## os.env 环境变量
 包括:

    os.Setenv(k, v)
    os.Getenv(k) string
    range os.Environ()

    _, isExist := os.LookupEnv(key)

例子

    import "os"
    import "strings"

    func main() {
        os.Setenv("WEB", "http://coolshell.cn") //设置环境变量
        println(os.Getenv("WEB")) //读出来

        for _, env := range os.Environ() { //穷举环境变量
            e := strings.Split(env, "=")
            println(e[0], "=", e[1])
        }
    }

## shell args

    args := os.Args
    fmt.Println(args) //带执行文件的
    fmt.Println(args[1:]) //不带执行文件的

### flag(parse args)
import flag:

    //第一个参数是“参数名”，第二个是“默认值”，第三个是“说明”。返回的是指针
    host := flag.String("host", "coolshell.cn", "a host name ")
    port := flag.Int("port", 80, "a port number")
    debug := flag.Bool("d", false, "enable/disable debug mode")

    //正式开始Parse命令行参数
    flag.Parse()

    fmt.Println("host:", *host)
    fmt.Println("port:", *port)
    fmt.Println("debug:", *debug)

# exec shell, 执行命令行
下面是一个比较简单的示例

  package main
  import "os/exec"
  import "fmt"

    cmd := exec.Command("ping", "127.0.0.1")
    out, err := cmd.Output() //不含stderr

    if err!=nil {
        println("Command Error!", err.Error())
        return
    }
    fmt.Println(string(out))

cmd *exec.Cmd:

    var cmd *exec.Cmd = exec.Command("cat", args...)

## build multiple commands
    cmd := exec.Command("/bin/sh", "-c", "command1; command2; command3; ...")

### change current working directory

    cmd := exec.Command("myCommand", "arg1", "arg2")
    cmd.Dir = "/path/to/work/dir"

## exec command
阻塞

    out, err := cmd.Output()
    err := cmd.Run()

非阻塞

    err := cmd.Start()
	err = cmd.Wait()

### kill cmd 进程管理
它有很多方法: go doc os/exec Cmd

kill cmd

	pid int:= cmd.Process.Pid
    err := cmd.Process.Kill();

通过 -pid (pgid) kill 孙子进程：go-lib/process/kill-grandchild

    err = syscall.Kill(-pid, syscall.SIGINT)
	err = syscall.Kill(-pid, syscall.SIGKILL)

wait cmd

    // Wait releases any resources
	state, _ = cmd.Process.Wait()
    // cmd封装了上面的Wait
    err = cmd.Wait()

kill if timeout: https://stackoverflow.com/questions/11886531/terminating-a-process-started-with-os-exec-in-golang

    ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
    defer cancel()

    if err := exec.CommandContext(ctx, "sleep", "5").Run(); err != nil {
        // This will fail after 100 milliseconds. The 5 second sleep
        // will be interrupted.
    }
    err := ctx.Err()    // err = DeadLineExceeded{} 

## set cmd attr
setsid:

	cmd.SysProcAttr = &syscall.SysProcAttr{}
	cmd.SysProcAttr.Setsid = true

## stdout vs stderr
### stdout to null
    stdout := os.Stdout
    defer func() { os.Stdout = stdout }()
    os.Stdout = os.NewFile(0, os.DevNull)

### stdout vs stderr

    func Shellout() (error, string, string) {
        var stdout bytes.Buffer
        var stderr bytes.Buffer
        cmd := exec.Command("sh", "-c", "cmd-not-existed||echo ok")
        cmd.Stdout = &stdout
        cmd.Stderr = &stderr
        err := cmd.Run()    //Run 是阻塞的
        return err, stdout.String(), stderr.String()
    }

### pipe
    package main

    import (
        "bytes"
        "io"
        "os"
        "os/exec"
    )

    func main() {
        c1 := exec.Command("ls")
        c2 := exec.Command("wc", "-l")

        r, w := io.Pipe() 
        c1.Stdout = w
        c2.Stdin = r

        var b2 bytes.Buffer
        c2.Stdout = &b2

        c1.Start()
        c2.Start()
        c1.Wait()
        w.Close()
        c2.Wait()
        io.Copy(os.Stdout, &b2)
    }

## exec with pipe
in-out:

    cmd := exec.Command("cat", args...)
    cmd.Stdin = strings.NewReader("some input")
    out, err := cmd.Output()

正规一点的用来处理标准输入和输出的示例如下：

  import (
      "strings"
      "bytes"
      "fmt"
      "log"
      "os/exec"
  )

  func main() {
      cmd := exec.Command("tr", "a-z", "A-Z")
      cmd.Stdin = strings.NewReader("some input")
      var out bytes.Buffer
      cmd.Stdout = &out
      err := cmd.Run()
      if err != nil {
          log.Fatal(err)
      }
      fmt.Printf("in all caps: %q\n", out.String())
  }

## pty pipe
pty is pseudo-terminals, 它是基于cmd.Stdin/Stdout的封装

现在是f.Write, f.Read(stdout) 的例子

    //go-lib/shell/pipe-pty.go
    import (
        "github.com/creack/pty"
        "io"
        "os"
        "os/exec"
    )

    func main() {
        c := exec.Command("grep", "--color=auto", "bar")
        f, err := pty.Start(c)
        if err != nil {
            panic(err)
        }

        go func() {
            f.Write([]byte("foo\n"))
            f.Write([]byte("bar\n"))
            f.Write([]byte("baz\n"))
            f.Write([]byte{4}) // EOT
        }()
        io.Copy(os.Stdout, f)
    }

pty 启动bash的例子: go-lib/shell/bash.go

	go func() { 
        //阻塞
        _, _ = io.Copy(f, os.Stdin) 
    }()
	go func() { 
        _, _ = io.Copy(os.Stdout, f)
        _, _ = io.Copy(os.Stderr, f)
    }()

pty的开关

    f, err := pty.Start(c)
    f.Close()

# runtime

  import runtime