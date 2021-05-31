---
title: go context
date: 2021-05-27
private: true
---
# go context

## error type
Canceled is the error returned by Context.Err when the context is canceled.

    var Canceled = errors.New("context canceled")

DeadlineExceeded is the error returned by Context.Err when the context's deadline passes.

    var DeadlineExceeded error = deadlineExceededError{}


## func
go-lib/process/ctx/withValue.go

### withValue
    package main

    import (
        "context"
        "fmt"
    )

    func main() {
        type favContextKey string

        f := func(ctx context.Context, k favContextKey) {
            if v := ctx.Value(k); v != nil {
                fmt.Println("found value:", v)
                return
            }
            fmt.Println("key not found:", k)
        }

        k := favContextKey("language")
        ctx := context.WithValue(context.Background(), k, "Go")

        f(ctx, k)
        f(ctx, favContextKey("color"))

    }