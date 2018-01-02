# for

  sum := 0
	for i := 0; i < 10; i++ {
		sum += i
	}

or

  for ; sum < 1000; {
		sum += sum
	}

## while

  for sum < 1000 {
		sum += sum
	}

## forever
  for {
	}

# if
  if x < 0 {
	}

## pre if
Variables `v` declared by the statement are only in scope until the end of the if.

  if v := math.Pow(x, n); v < 5 {
		return v
	}else{

  }
	fmt.Println(v);undefined: v

# switch

  package main
  import (
  	"fmt"
  	"runtime"
  )

  func main() {
  	fmt.Print("Go runs on ")
  	switch os := runtime.GOOS; os {
  	case "darwin":
  		fmt.Println("OS X.")
  	case "linux":
  		fmt.Println("Linux.")
  	default:
  		// freebsd, openbsd,
  		// plan9, windows...
  		fmt.Printf("%s.", os)
  	}
  }

## short switch

  switch {
	case t.Hour() < 12:
		fmt.Println("Good morning!")
	case t.Hour() < 17:
		fmt.Println("Good afternoon.")
	default:
		fmt.Println("Good evening.")
	}

# defer
  func main() {
  	defer fmt.Println("world")

  	fmt.Println("hello")
  }

# Stacking defers
Deferred function calls are pushed onto a stack.

When a function returns, its deferred calls are executed in last-in-first-out order

  func main() {
  	fmt.Println("counting")

  	for i := 0; i < 10; i++ {
  		defer fmt.Println(i)
  	}

  	fmt.Println("done")
  }
