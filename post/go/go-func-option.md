---
title: go Functional Options
date: 2021-11-21
private: true
---
# Functional Options
如果可选参数太多，可以把它们放到一个可选的`*Config`

## 利用`*conf`
我们把那些非必输的选项都移到一个结构体里，于是 Server 对象变成了：

    type Server struct {
        Addr string
        Port int
        Conf *Config
    }

    type Config struct {
        Protocol string
        Timeout  time.Duration
        Maxconns int
        TLS      *tls.Config
    }

于是，我们只需要一个 NewServer() 的函数了，在使用前需要构造 Config 对象。

    func NewServer(addr string, port int, conf *Config) (*Server, error) {
        //...
    }
    //Using the default configuratrion
    srv1, _ := NewServer("localhost", 9000, nil) 
    conf := ServerConfig{Protocol:"tcp", Timeout: 60*time.Duration}
    srv2, _ := NewServer("locahost", 9000, &conf)

## Builder with option
不需要额外的Config类

    //使用一个builder类来做包装
    type ServerBuilder struct {
      Server
    }
    func (sb *ServerBuilder) Create(addr string, port int) *ServerBuilder {
      sb.Server.Addr = addr
      sb.Server.Port = port
      //其它代码设置其它成员的默认值
      return sb
    }
    func (sb *ServerBuilder) WithProtocol(protocol string) *ServerBuilder {
      sb.Server.Protocol = protocol 
      return sb
    }
    func (sb *ServerBuilder) Build() (Server) {
      return  sb.Server
    }

server build

    sb := ServerBuilder{}
    server, err := sb.Create("127.0.0.1", 8080).
        WithProtocol("udp").
        Build()

## Functional Options
Rest Parameters/Optional Parameters/Variadic Functions in Go


For example:

    func Protocol(p string) Option {
    return func(s *Server) {
        s.Protocol = p
    }
    }
    func Timeout(timeout time.Duration) Option {
        return func(s *Server) {
            s.Timeout = timeout
        }
    }

    func NewServer(addr string, port int, options ...func(*Server)) (*Server, error) {
      srv := Server{
        Addr:     addr,
        Port:     port,
        Protocol: "tcp",
        Timeout:  30 * time.Second,
        MaxConns: 1000,
        TLS:      nil,
      }
      for _, option := range options {
        option(&srv)
      }
      //...
      return &srv, nil
    }

于是，我们在创建 Server 对象的时候，我们就可以这样来了。

    s1, _ := NewServer("localhost", 1024)
    s2, _ := NewServer("localhost", 2048, Protocol("udp"))
    s3, _ := NewServer("0.0.0.0", 8080, Timeout(300*time.Second), MaxConns(1000

