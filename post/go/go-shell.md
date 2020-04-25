---
title: go shell
date: 2020-04-20
private: true
---
# go shell

## exec
    package main

    import (
        "log"
        "os/exec"
    )

    func main() {
        args := []string{
            "arg1", "arg2"
        }
        cmd := exec.Command("echo", args...)
        out, err := cmd.Output()
        if err != nil {
            log.Fatal(err)
        }
        log.Printf("%s", out)
    }
