# socket

# socket demo
http://coolshell.cn/articles/8489.html

## server socket

  package main

  import (
      "net"
      "fmt"
      "io"
  )

  const RECV_BUF_LEN = 1024

  func main() {
      listener, err := net.Listen("tcp", "0.0.0.0:6666")//侦听在6666端口
      if err != nil {
          panic("error listening:"+err.Error())
      }
      fmt.Println("Starting the server")

      for {
          conn, err := listener.Accept() //接受连接
          if err != nil {
              panic("Error accept:"+err.Error())
          }
          fmt.Println("Accepted the Connection :", conn.RemoteAddr())
          go EchoServer(conn)
      }
  }

  func EchoServer(conn net.Conn) {
      buf := make([]byte, RECV_BUF_LEN)
      defer conn.Close()

      for {
          n, err := conn.Read(buf);
          switch err {
              case nil:
                  conn.Write( buf[0:n] )
              case io.EOF:
                  fmt.Printf("Warning: End of data: %s \n", err);
                  return
              default:
                  fmt.Printf("Error: Reading data : %s \n", err);
                  return
          }
       }
  }

## Client端

  package main

  import (
      "fmt"
      "time"
      "net"
  )

  const RECV_BUF_LEN = 1024

  func main() {
      conn,err := net.Dial("tcp", "127.0.0.1:6666")
      if err != nil {
          panic(err.Error())
      }
      defer conn.Close()

      buf := make([]byte, RECV_BUF_LEN)

      for i := 0; i < 5; i++ {
          //准备要发送的字符串
          msg := fmt.Sprintf("Hello World, %03d", i)
          n, err := conn.Write([]byte(msg))
          if err != nil {
              println("Write Buffer Error:", err.Error())
              break
          }
          fmt.Println(msg)

          //从服务器端收字符串
          n, err = conn.Read(buf)
          if err !=nil {
              println("Read Buffer Error:", err.Error())
              break
          }
          fmt.Println(string(buf[0:n]))

          //等一秒钟
          time.Sleep(time.Second)
      }
  }
