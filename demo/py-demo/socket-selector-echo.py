# IO复用：没有用多进程/协程，而是select轮询, 当有收到数据时(哪怕是b''空数据)，才会recv, 避免了recv()自己 block)
from socket import socket, AF_INET, SOCK_STREAM, SOL_SOCKET, SO_REUSEADDR
from selectors import DefaultSelector, EVENT_READ

selector = DefaultSelector()
pool = {}

def request(client_socket, addr):
    client_socket, addr = client_socket, addr
    def handle_request(key, mask): # client 每次发数据，这个handle_request就会被调用一次
        print('wait client:')
        data = client_socket.recv(500) # curl客户端主动断开，才会收到空字符
        print('data:',data)
        if not data:
            client_socket.close()
            selector.unregister(client_socket)
            del pool[addr]
        else:
            client_socket.send(data)
    return handle_request

def recv_client(key, mask):
    sock = key.fileobj
    client_socket, addr = sock.accept()
    req = request(client_socket, addr)
    pool[addr] = req
    selector.register(client_socket, EVENT_READ, req) # key.data == req, key.fileobj == client_socket. req(key, mask)

def echo_server(address):
    sock = socket(AF_INET, SOCK_STREAM)
    sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    sock.bind(address)
    sock.listen(5)
    selector.register(sock, EVENT_READ, recv_client) # key.data == recv_client, key.fileobj == sock. recv_client(key, mask)
    try:
        while True:
            events = selector.select()
            for key, mask in events:
                callback = key.data
                callback(key, mask)
    except KeyboardInterrupt:
        sock.close()

if __name__ == '__main__':
    echo_server(('',8081))

