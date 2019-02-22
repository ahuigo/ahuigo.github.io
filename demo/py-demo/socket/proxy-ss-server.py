# Refer:
# https://github.com/facert/socket-example/blob/master/ss-server.py
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

class ThreadingTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True


class Socks5Server(socketserver.StreamRequestHandler):
    def handle_tcp(self, sock, remote):
        try:
            fdset = [sock, remote]
            flag = True
            while True:
                logging.info('select .....')
                r, w, e = select.select(fdset, [], [], 5)
                if flag and 0:
                    logging.info([self.rfile.read(2),'ahui.......'])
                    logging.info([sock.recv(2),'ahui2.......'])
                logging.info('select changed ')
                if sock in r or flag:
                    flag = False
                    #print('read data from sock... ', self.rfile.read(10))
                    data = sock.recv(4096)
                    print('read data from sock: ', data)
                    if len(data) <= 0:
                        break
                    result = send_all(remote, self.decrypt(data))
                    if result < len(data):
                        raise Exception('failed to send all data')
                if remote in r:
                    data = remote.recv(4096)
                    print('read data from remote: ', data)
                    if len(data) <= 0:
                        break
                    result = send_all(sock, self.encrypt(data))
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

    def handle(self):
        try:
            sock = self.connection
            addrtype = ord(self.decrypt(sock.recv(1)))      # receive addr type
            if addrtype == 1:
                addr = socket.inet_ntoa(self.decrypt(sock.recv(4)))   # get dst addr
            elif addrtype == 3:
                addr = self.decrypt(
                    sock.recv(ord(self.decrypt(sock.recv(1)))))       # read 1 byte of len, then get 'len' bytes name
            else:
                # not support
                logging.warning('addr_type not support')
                return
            port = struct.unpack('>H', self.decrypt(sock.recv(2)))    # get dst port into small endian
            try:
                logging.info('connecting %s:%d' % (addr, port[0]))
                logging.info(addrtype)
                remote = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                remote.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
                remote.connect((addr, port[0]))         # connect to dst
                logging.info('connecting success')
            except socket.error as e:
                # Connection refused
                logging.warning(e)
                return
            self.handle_tcp(sock, remote)
        except socket.error as e:
            logging.warning(e)

if __name__ == '__main__':
    os.chdir(os.path.dirname(__file__) or '.')

    print('shadowsocks v0.9')

    with open('ss.json', 'rb') as f:
        config = json.load(f)

    SERVER = config['server']
    PORT = config['server_port']
    KEY = config['password']

    optlist, args = getopt.getopt(sys.argv[1:], 'p:k:')
    for key, value in optlist:
        if key == '-p':
            PORT = int(value)
        elif key == '-k':
            KEY = value

    logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(levelname)-8s %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S', filemode='a+')

    enc_table, dec_table = get_table(KEY)

    if '-6' in sys.argv[1:]:
        ThreadingTCPServer.address_family = socket.AF_INET6
    try:
        server = ThreadingTCPServer(('', PORT), Socks5Server)
        logging.info("starting server at port %d ..." % PORT)
        server.serve_forever()
    except socket.error as e:
        logging.error(e)
