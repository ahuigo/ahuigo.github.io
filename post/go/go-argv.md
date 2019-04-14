---
title: Golang notes: argv
date: 2019-03-25
---
# Golang notes: argv

    os.Args 返回命令⾏行参数，
    os.Exit 终⽌止进程。 
    filepath.Abs(exec.LookPath(os.Args[0]))。

# Golang flag

    package main
    import "flag"
    import "fmt"
    func main() {
        wordPtr := flag.String("word", "foo", "a string")
        numbPtr := flag.Int("numb", 42, "an int")
        boolPtr := flag.Bool("fork", false, "a bool")
        var svar string
        flag.StringVar(&svar, "svar", "bar", "a string var")

        fmt.Println("word:", *wordPtr)
        fmt.Println("numb:", *numbPtr)
        fmt.Println("fork:", *boolPtr)
        fmt.Println("svar:", svar)

        flag.Parse()
        fmt.Println("tail:", flag.Args())
    }
