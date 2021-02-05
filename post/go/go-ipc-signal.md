---
title: Go Signal
date: 2019-09-21
---
# Go Signal

查看信号

    $ man signal
    No    Name         Default Action       Description
    2     SIGINT       terminate process    interrupt program
    9     SIGKILL      terminate process    kill program
    15    SIGTERM      terminate process    software termination signal
    19    SIGCONT      discard signal       continue after stop
    20    SIGCHLD      discard signal       child status has changed
    28    SIGWINCH     discard signal       Window size change

## signal.Notify
    import (
        "context"
        "log"
        "net/http"
        "os"
        "os/signal"
        "syscall"
        "time"
    }
	quit := make(chan os.Signal)
	// kill (no param) default send syscanll.SIGTERM
	// kill -2 is syscall.SIGINT
	// kill -9 is syscall. SIGKILL but can"t be catch, 
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutdown Server ...")

参考示例：go-lib/process/signal-terminate_test.go

    kill -TERM <pid>