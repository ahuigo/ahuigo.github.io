import socket,os,sys
if 'client' in sys.argv:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('127.0.0.1', 8888))
    print(s.recv(1024))

    for data in [b'dog']:
        s.send(data)
        print(s.recv(1024))
    s.close()
    exit()

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

server.bind(('0', 8888))
server.listen()
try:
    while True:
        sock, addr = server.accept()
        pid = os.fork()
        if pid == 0:
            data = sock.recv(1024)
            sock.send(data.upper())
            sock.close()
        else:
            sock.close()
except KeyboardInterrupt:
    sock.close()
