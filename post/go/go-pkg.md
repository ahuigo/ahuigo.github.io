---
layout: page
title:
category: blog
description:
---
# Preface

# package
Go Programs start running in package main.


	package main

	import (
		"fmt"
		"math/rand"
	)

	func main() {
		fmt.Println("My favorite number is", rand.Intn(10))
	}

# import
This code groups the imports into a parenthesized, `"factored"` import statement.

You can also write multiple import statements, like:

	```
	import "fmt"
	import "math"
	```

还可以这样

	```
	package main

	import (
		"fmt"
		"math"
	)

	func main() {
		fmt.Printf("Now you have %g problems.", math.Sqrt(7))
	}
	```
## Exported names
In Go, a name is exported if it begins with a capital letter. 

For example, Pi is an exported name

	math.Pi

Any "unexported" names are not accessible from outside the package.

	math.pi
