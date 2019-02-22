# https://github.com/Anorov/PySocks
import socks
s = socks.socksocket() 
s.set_proxy(socks.SOCKS5, "localhost", 8888)

s.connect(("baidu.com", 80))
s.sendall("GET / HTTP/1.1 /r/n/r/n")
print(s.recv(4096))
