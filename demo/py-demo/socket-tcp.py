import socket,os
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
#server.bind(('127.0.0.1', 8080))
server.bind(('0', 5000))
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
