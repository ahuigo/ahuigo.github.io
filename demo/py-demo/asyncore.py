import sys,os,time;
import asyncore,socket;


class HTTPClient(asyncore.dispatcher):
    def __init__(self, host, port, path):
        asyncore.dispatcher.__init__(self);
        self.create_socket(socket.AF_INET, socket.SOCK_STREAM);
        self.connect((host, int(port)));
        self.buffer = 'GET %s HTTP/1.1\r\nHost: %s\r\n\r\n'%(path, host);
        self.buffer = self.buffer.encode()
    def handle_connect(self):
        pass;
    def handle_close(self):
        self.close();
    def handle_read(self):
        print("[handle_read] event loop start to read.");
        print(self.recv(8192))
    def writable(self):
        return len(self.buffer) > 0;
    def handle_write(self):
        sent = self.send(self.buffer);
        self.buffer = self.buffer[sent:];

class EchoServer(asyncore.dispatcher):
    def __init__(self, host, port):
        asyncore.dispatcher.__init__(self);
        self.create_socket(socket.AF_INET, socket.SOCK_STREAM);
        self.set_reuse_addr();
        self.bind((host, int(port)));
        self.listen(10);
    def handle_accept(self):
        pair = self.accept();
        if pair is None:
            return;
        (sock, addr) = pair;
        print("incoming client: %s"%(repr(addr)));
        handler = EchoHandler(sock);

class EchoHandler(asyncore.dispatcher_with_send):
    def handle_read(self):
        data = self.recv(8192);
        if data is None:
            return;
        self.send(b"winlin");
        time.sleep(3);
        self.send(data);

check_mode = lambda : len(sys.argv) <= 1;
check_mode_value = lambda: sys.argv[1] not in ("server", "client");
check_mode_argc = lambda mode,argc: sys.argv[1] == mode and len(sys.argv) != 2+argc;
if check_mode() or check_mode_value() or check_mode_argc("client", 3) or check_mode_argc("server", 2):
    print("Usage: %s <mode>\n"
        "mode: the mode, server or client.\n"
        "if mode is client, must specifies: <host> <port> <path>\n"
        "    host: the server ip or hostname. ie. dev\n"
        "    port: the port to connect to. ie. 80\n"
        "    path: the path to get. ie. /api/mine\n"
        "if mode is server, must specifies: <host> <port>\n"
        "    host: the server ip or hostname. ie. dev\n"
        "    port: the port to listen. ie. 80"%(sys.argv[0]));
    sys.exit(1);

mode = sys.argv[1];
if mode == "client":
    (host, port, path) = sys.argv[2:];
    client = HTTPClient(host, port, path);
    #asyncore.loop();
    asyncore.loop(timeout=0.5, count=6);
else:
    (host, port) = sys.argv[2:];
    server = EchoServer(host, port);
    asyncore.loop();
    print('end')
