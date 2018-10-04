---
title: signal
date: 2018-10-04
---
# signal
help: pydoc signal, c-signal.md

    SIGINT = 2
    SIGQUIT = 3
    SIGSTOP = 17
    SIGTERM = 15
    SIGABRT = 6
    SIGALRM = 14
    SIGHUP = 1
    SIGKILL = 9
    SIGPIPE = 13

## SIGTERM
```
import signal
import time

def handler(sig, frame):
    print('Got signal: ', sig)

signal.signal(signal.SIGTERM, handler)
time.sleep(10)
print('Program Ends.')
```
## SIGCHLD
进程退出，向父进程发出SIGCHLD (chldhandler), 然后要清理子进程在进程表中的信息
```
def chldhandler(signum, stackframe):
    try:
        pid, status=os.waitpid(-1, os.WNOHANG) # -1 则等待第一个子进程退出后清理，
    except OSError:pass

signal.signal(signal.SIGCHLD, chldhandler)
```