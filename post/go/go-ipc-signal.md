---
title: Go Signal
date: 2019-09-21
---
# Go Signal

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
	// kill -9 is syscall. SIGKILL but can"t be catch, so don't need add it
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutdown Server ...")