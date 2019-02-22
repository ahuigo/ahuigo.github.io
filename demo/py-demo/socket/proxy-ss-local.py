# Refer:
# https://zhuanlan.zhihu.com/p/28798090
# example:
#   curl -x socks5h://localhost:8000 'baidu.com'
import sys
import socket
import select
import socketserver
import struct
import os
import json
import logging
import getopt
import hashlib

from functools import cmp_to_key
def get_table(KEY):
    m = hashlib.md5()
    m.update(KEY.encode())
    s = m.digest()
    (a, b) = struct.unpack('<QQ', s)
    table = list(range(0, 0x100))
    for i in range(1, 1024):
        table.sort(key=cmp_to_key(lambda x, y: a%(x+i) - a%(y+i) ))
    enc_table = bytes(table)
    dec_table = bytes.maketrans(enc_table, bytes(range(0, 0x100)))
    return enc_table, dec_table

def send_all(sock, data):
    bytes_sent = 0
    while True:
        r = sock.send(data[bytes_sent:])
        if r < 0:
            return r
        bytes_sent += r
        if bytes_sent == len(data):
            return bytes_sent

class ThreadingTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):   # Multiple inheritance
    allow_reuse_address = True

class Socks5Server(socketserver.StreamRequestHandler):
    ''' RequesHandlerClass Definition '''
    def handle_tcp(self, sock, remote):
        try:
            fdset = [sock, remote]
            while True:
                r, w, e = select.select(fdset, [], [])      # use select I/O multiplexing model
                if sock in r:                               # if local socket is ready for reading
                    data = sock.recv(4096)
                    print('read data from sock: ', data)
                    if len(data) <= 0:                      # received all data
                        break
                    result = send_all(remote, self.encrypt(data))   # send data after encrypting
                    print('send data to remote: ', (result), remote)
                    if result < len(data):
                        raise Exception('failed to send all data')

                if remote in r:                             # remote socket(proxy) ready for reading
                    data = remote.recv(4096)
                    print('read data from remote: ', data)
                    if len(data) <= 0:
                        break
                    result = send_all(sock, self.decrypt(data))     # send to local socket(application)
                    if result < len(data):
                        raise Exception('failed to send all data')
        finally:
            sock.close()
            remote.close()


    def encrypt(self, data):
        return data
        return data.translate(enc_table)

    def decrypt(self, data):
        return data
        return data.translate(dec_table)

    def send_encrypt(self, sock, data):
        sock.send(self.encrypt(data))

    def handle(self):
        try:
            sock = self.connection        # local socket [127.1:port]
            sock.recv(262)                # Sock5 Verification packet
            sock.send("\x05\x00".encode())         # Sock5 Response: '0x05' Version 5; '0x00' NO AUTHENTICATION REQUIRED
            # After Authentication negotiation
            data = self.rfile.read(4)     # Forward request format: VER CMD RSV ATYP (4 bytes)
            mode = (data[1])           # CMD == 0x01 (connect)
            if mode != 1:
                logging.warning('mode != 1')
                return
            addrtype = (data[3])       # indicate destination address type
            addr_to_send = data[3:4]
            print('local addrtype', addrtype)
            if addrtype == 1:             # IPv4
                addr_ip = self.rfile.read(4)            # 4 bytes IPv4 address (big endian)
                addr = socket.inet_ntoa(addr_ip)
                addr_to_send += addr_ip
            elif addrtype == 3:           # FQDN (Fully Qualified Domain Name)
                addr_len = self.rfile.read(1)           # Domain name's Length
                addr = self.rfile.read(ord(addr_len))   # Followed by domain name(e.g. www.google.com)
                addr_to_send += addr_len + addr
            else:
                logging.warning('addr_type not support')
                # not support
                return
            addr_port = self.rfile.read(2)
            addr_to_send += addr_port                   # addr_to_send = ATYP + [Length] + dst addr/domain name + port
            port = struct.unpack('>H', addr_port)       # prase the big endian port number. Note: The result is a tuple even if it contains exactly one item.
            try:
                reply = b"\x05\x00\x00\x01"              # VER REP RSV ATYP
                reply += socket.inet_aton('0.0.0.0') + struct.pack(">H", 2222)  # listening on 2222 on all addresses of the machine, including the loopback(127.0.0.1)
                self.wfile.write(reply)                 # response packet
                # reply immediately
                if '-6' in sys.argv[1:]:                # IPv6 support
                    remote = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
                else:
                    remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                #remote.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)       # turn off Nagling
                remote.connect((SERVER, REMOTE_PORT))
                logging.info('connecting ss server %s:%d' % (SERVER, REMOTE_PORT))
                self.send_encrypt(remote, addr_to_send)      # encrypted
                logging.info('connecting %s:%d' % (addr, port[0]))
            except socket.error as e:
                logging.warning(e)
                return
            self.handle_tcp(sock, remote)
        except socket.error as e:
            logging.warning(e)

if __name__ == '__main__':
    os.chdir(os.path.dirname(__file__) or '.')
    print('shadowsocks v0.9')
    '''
        config = {
            "server": "127.0.0.1",
            "server_port": 8888,
            "password": "123",
            "local_port": 8000
        }
    '''
    with open('ss.json', 'rb') as f:
        config = json.load(f)

    SERVER = config['server']
    REMOTE_PORT = config['server_port']
    PORT = config['local_port']
    KEY = config['password']

    optlist, args = getopt.getopt(sys.argv[1:], 's:p:k:l:')
    for key, value in optlist:
        if key == '-p':
            REMOTE_PORT = int(value)
        elif key == '-k':
            KEY = value
        elif key == '-l':
            PORT = int(value)
        elif key == '-s':
            SERVER = value

    logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(levelname)-8s %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S', filemode='a+')

    enc_table, dec_table = get_table(KEY)


    try:
        server = ThreadingTCPServer(('', PORT), Socks5Server)   # s.bind(('', 80)) specifies that the socket is reachable by any address the machine happens to have.
        logging.info("starting server at port %d ..." % PORT)
        server.serve_forever()
    except socket.error as e:
        logging.error(e)
