---
title: py-server-wsgi
date: 2018-10-04
---
# Preface
Flask based on Werkezug 还是有点复杂. 
wsgiref 实现WSGI标准提供了一个参考，只用于测试

# wsgiref

    from wsgiref.simple_server import make_server
                
    def app(env, start_response):
        for k in env.items():
            print(k)
        start_response('200 OK', [('Content-Type', 'text/html')])
        return [b'<h1>Hello, web!</h1>']

    if __name__ == '__main__':
        httpd = make_server('', 9999, app)
        sa = httpd.socket.getsockname()
        print(f"Serving HTTP on http://{sa[0]}:{sa[1]}...")
        httpd.serve_forever()