---
layout: page
title:
category: blog
description:
---
# Preface

# install

	brew install go

# hello

## 1.set workspace

	export GOPATH=$HOME/www/go
	# 默认的
	GOROOT=/usr/local/Cellar/go/1.6.2/libexec/

## hello
cat www/go/src/A/hello/hello.go

	package main

	import "fmt"

	func main() {
		fmt.Printf("hello, world\n")
	}


## compile:
会默认去$GOROOT/$GOPATH 找`src/A/hello/hello.go`

	$ go install A/hello

得到目录树

	.
	├── pkg			编译生成的包文件
	├── bin 		生成的可执行文件
	│   └── hello
	└── src
		└── A
			└── hello
				└── hello.go

# run

	run         compile and run Go program
	build       compile packages and dependencies(test, This won't produce an output file)
	get         download and install packages and dependencies
	install     compile and install packages and dependencies

可以直接run (compile and excute) 不产生bin

	$ go run a.go

或者

	$ go build a.go;# gen binary excute file ./a

## Your first library
see go/hello

  mkdir -p $GOPATH/src/github.com/user/stringutil
  vim reverse.go

in that directory with the following contents.

  // Package stringutil contains utility functions for working with strings.
  package stringutil

  // Reverse returns its argument string reversed rune-wise left to right.
  func Reverse(s string) string {
  	r := []rune(s)
  	for i, j := 0, len(r)-1; i < len(r)/2; i, j = i+1, j-1 {
  		r[i], r[j] = r[j], r[i]
  	}
  	return string(r)
  }

Now, test that the package compiles with go build:

  $ go build github.com/user/stringutil

Or, if you are working in the package's source directory, just:

  $ go build

This won't produce an output file. To do that, you must use go install, which places the package object inside the pkg directory of the workspace.

edit $GOPATH/src/github.com/user/hello/hello.go

  package main

  import (
  	"fmt"

  	"github.com/user/stringutil"
  )

  func main() {
  	fmt.Printf(stringutil.Reverse("!oG ,olleH"))
  }

Whenever the go tool installs a package or binary, it also installs whatever dependencies it has. So when you install the hello program

  $ go install github.com/user/hello

the stringutil package will be installed as well, automatically.

Running the new version of the program, you should see a new, reversed message:

  $ hello
  Hello, Go!

After the steps above, your workspace should look like this:

  bin/
      hello                 # command executable
  pkg/
      linux_amd64/          # this will reflect your OS and architecture
          github.com/user/
              stringutil.a  # package object
  src/
      github.com/user/
          hello/
              hello.go      # command source
          stringutil/
              reverse.go    # package source

Note that go install placed the `stringutil.a` object in a directory inside `pkg/linux_amd64` that mirrors its source directory.

# Remote Package
An import path can describe how to obtain the package source code using a revision control system such as Git or Mercurial. 

	$ go get github.com/golang/example/hello
	$ $GOPATH/bin/hello
	Hello, Go examples!
