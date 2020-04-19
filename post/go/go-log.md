---
title: Go log
date: 2019-09-21
---
# Go log

## log.Println
    import "log"
    log.Println("timeout of 5 seconds.", []string{"abc"})
    //2019/09/21 08:34:19 timeout of 5 seconds.

## logger
new logger

    func New(out io.Writer, prefix string, flag int) *Logger

e.g.

    import (
        "bytes"
        "fmt"
        "log"
    )

    func main() {
        var (
            buf    bytes.Buffer
            logger = log.New(&buf, "logger: ", log.Lshortfile)
        )

        logger.Print("Hello, log file!")

        fmt.Print(&buf)

gonic根据log 定制logger