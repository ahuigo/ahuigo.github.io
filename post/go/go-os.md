# 系统调用
Go语言主要是通过两个包完成的。一个是os包，一个是syscall包

1. syscall里提供了什么Chroot/Chmod/Chmod/Chdir…，Getenv/Getgid/Getpid/Getgroups/Getpid/Getppid…，还有很多如Inotify/Ptrace/Epoll/Socket/…的系统调用。
2. os包里提供的东西不多，主要是一个跨平台的调用。它有三个子包，Exec（运行别的命令）, Signal（捕捉信号）和User（通过uid查name之类的）

# linux

## os.env 环境变量
 包括:

  os.Setenv(k, v)
  os.Getenv(k)
  range os.Environ()

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
  a_

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

## exec, 执行命令行
下面是一个比较简单的示例

  package main
  import "os/exec"
  import "fmt"

    cmd := exec.Command("ping", "127.0.0.1")
    out, err := cmd.Output()

    if err!=nil {
        println("Command Error!", err.Error())
        return
    }
    fmt.Println(string(out))

### exec with pipe
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

# runtime

  import runtime
