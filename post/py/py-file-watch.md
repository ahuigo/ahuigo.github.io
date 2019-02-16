---
title: python watch file
date: 2019-02-14
---
# python watch file
Some methods: https://stackoverflow.com/questions/182197/how-do-i-watch-a-file-for-changes
- watchdog
- signal

signal method

    import time
    import fcntl
    import os
    import signal

    FNAME = "/HOME/TOTO/FILETOWATCH"

    def handler(signum, frame):
        print "File %s modified" % (FNAME,)

    signal.signal(signal.SIGIO, handler)
    fd = os.open(FNAME,  os.O_RDONLY)
    fcntl.fcntl(fd, fcntl.F_SETSIG, 0)
    fcntl.fcntl(fd, fcntl.F_NOTIFY,
                fcntl.DN_MODIFY | fcntl.DN_CREATE | fcntl.DN_MULTISHOT)

    while True:
        time.sleep(10000)


pbpaste|uncurl 