---
title: go switch
date: 2022-03-25
private: true
---
# go switch
## No condition
A switch without a condition is the same as switch true.

    switch hour := time.Now().Hour(); { // missing expression means "true"
    case hour < 12:
        fmt.Println("Good morning!")
    case hour < 17:
        fmt.Println("Good afternoon!")
    default:
        fmt.Println("Good evening!")
    }

## Case list
    func WhiteSpace(c rune) bool {
        switch c {
        case ' ', '\t', '\n', '\f', '\r':
            return true
        }
        return false
    }

## Fallthrough
A fallthrough statement transfers control to the next case.

It may be used only as the final statement in a clause.

    switch 2 {
    case 1:
        fmt.Println("1")
        fallthrough
    case 2:
        fmt.Println("2")
        fallthrough
    case 3:
        fmt.Println("3")
    }
    2
    3

## Exit with break
A break statement terminates execution of the innermost for, switch, or select statement.

If you need to break out of a surrounding loop, not the switch, you can put a label on the loop and break to that label. This example shows both uses.

    Loop:
        for _, ch := range "a b\nc" {
            switch ch {
            case ' ': // skip space
                break
            case '\n': // break at newline
                break Loop
            default:
                fmt.Printf("%c\n", ch)
            }
        }
    a
    b

## Execution order
First the switch expression is evaluated once.
Then case expressions are evaluated left-to-right and top-to-bottom:
1. the first one that equals the switch expression triggers execution of the statements of the associated case,
2. the other cases are skipped.

Foo prints and returns n.

    func Foo(n int) int {
        fmt.Println(n)
        return n
    }

    func main() {
        switch Foo(2) {
        case Foo(1), Foo(2), Foo(3):
            fmt.Println("First case")
            fallthrough
        case Foo(4):
            fmt.Println("Second case")
        }
    }
    2
    1
    2
    First case
    Second case