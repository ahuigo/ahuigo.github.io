import socket
import sys
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

if len(sys.argv)>1 and sys.argv[1] == 'client':
    for data in [b'dog']:
        s.sendto(data, ('127.0.0.1', 8888))
        print(s.recv(1024))
    s.close()
    exit()

s.bind(('127.0.0.1', 9999))
print('Bind UDP on 9999...')
while True:
    # 接收数据:
    data, addr = s.recvfrom(1024)
    print('Received from %s:%s.' % addr)
    s.sendto(b'Hello, %s!' % data, addr)

