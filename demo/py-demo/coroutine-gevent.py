import gevent
import random
def task(pid):
    gevent.sleep(random.randint(0,2)*.001)
    print('Task %s done' % pid)
def synchronous():
    for i in range(10):
        task(i)
def asynchronous():
    threads = [gevent.spawn(task, i) for i in range(10)]
    gevent.joinall(threads)

print('sync')
synchronous()
print('async')
asynchronous()

# monekey patching(使得普通的IO函数暂停???)
from gevent import monkey;
monkey.patch_all()
import gevent,urllib2
def url(url)
    resp = urllib2.urlopen(url)
    data.resp.read()
    print('%d bytes received from %s' % (len(data), url))

gevent.joinall([gevent.spawn(f, 'http://baidu.com'), ])
