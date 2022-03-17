---
title: Golang notes: argv
date: 2019-03-25
---
# Golang notes: argv

    os.Args []string返回命令⾏行参数，
    os.Exit 终⽌止进程。 
    filepath.Abs(exec.LookPath(os.Args[0]))。

# Golang flag
必须放在parse 后

    package main
    import "flag"
    import "fmt"
    func main() {
        wordPtr := flag.String("word", "foo", "a string")
        numbPtr := flag.Int("numb", 42, "an int")
        boolPtr := flag.Bool("fork", false, "a bool")
        var svar string
        flag.StringVar(&svar, "svar", "bar", "a string var")

        flag.Parse()
        fmt.Println("word:", *wordPtr)
        fmt.Println("numb:", *numbPtr)
        fmt.Println("fork:", *boolPtr)
        fmt.Println("svar:", svar)

        fmt.Println("tail:", flag.Args())
    }

shell:

    $ go run cli.go --word word1 -numb 41 -fork -svar bar1 arg1 arg2
    word: word1
    numb: 41
    fork: true
    svar: bar1
    tail: [arg1 arg2]

## custom args
    func Parse() {
        // Ignore errors; CommandLine is set for ExitOnError.
        CommandLine.Parse(os.Args[1:])
    }
