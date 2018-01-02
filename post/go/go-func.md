---
layout: page
title:
category: blog
description:
---
# Preface
func 是func-value

# Function Closures
A closure is a function value that references variables from outside its body.

	func adder() func(int) int {
		sum := 0
		return func(x int) int {
			sum += x
			return sum
		}
	}

	func main() {
		pos, neg := adder(), adder()
		for i := 0; i < 10; i++ {
			fmt.Println(
				pos(i),
				neg(-2*i),
			)
		}
	}

## number of arguments, 不定参数
	func sum(nums ...int) {
	    fmt.Printf("%T",nums)  //slice = []int{1, 2, 3)
	}
	sum(1, 2, 3)

ignore type

	func Statusln(a ...interface{})
	a := []interface{}{"hello", "world", 42}


## Multiple results
A function can return any number of results.

	func swap(x, y string) (string, string) {
		return y, x
	}
	a, b := swap("hello", "world")

### Named return values
A return statement `without` arguments returns the `named return values`.
This is known as a `"naked"` return.

	func split(sum int) (x, y int) {
		x = sum * 4 / 9
		y = sum - x
		return
	}
	fmt.Println(split(17))

## Short variable declarations
Inside a function, the `:=` short assignment statement can be used in place of `a var declaration` with `implicit type`.
> Outside a function, every statement begins with a `keyword (var, func, and so on)` and so the `:=` construct is not available.

	func main() {
		var i, j int = 1, 2
		k := 3
		c, python, java := true, false, "no!"

		fmt.Println(i, j, k, c, python, java)
	}

# Methods
Go does not have classes. However, you can define methods with a special receiver argument.
The receiver appears in its `own argument list` between the `func keyword` and the `method name`.

	type Vertex struct {
		X, Y float64
	}

	func (v Vertex) Abs() float64 {
		return math.Sqrt(v.X*v.X + v.Y*v.Y)
	}

	func main() {
		v := Vertex{3, 4}
		fmt.Println(v.Abs())
	}

## Mehtond on local-type
Declare a method on non-struct types, such as float64

	type MyFloat float64

	func (f MyFloat) Abs() float64 {
		if f < 0 {
			return float64(-f)
		}
		return float64(f)
	}

	func main() {
		f := MyFloat(-math.Sqrt2)
		fmt.Println(f.Abs())
	}

You can only declare:
1. a method with a receiver whose type is defined in the same package as the method.
2. You cannot declare a method with a receiver whose type is defined in another package (such as the built-in types: int float64).

## methods with pointer receivers.
If you wanna change receivers, use pointer pls.

	type Vertex struct {
		X, Y float64
	}

	func (v Vertex) Abs() float64 {
		return math.Sqrt(v.X*v.X + v.Y*v.Y)
	}

	func (v *Vertex) Scale(f float64) {
		v.X = v.X * f
		v.Y = v.Y * f
	}

	func main() {
		v := Vertex{3, 4}
		v.Scale(10)
		fmt.Println(v.Abs())
	}

### pointer as arg

	func Abs(v )
	Abs(&v)

since the Scale method has a pointer receiver and `v is not pointer`

	var v Vertex
	v.Scale(5)  // OK. as (&v).Scale(5) since the Scale method has a pointer receiver.
	p := &v
	p.Scale(10) // OK

the method call `p.Abs()` is interpreted as `(*p).Abs()`.

	var v Vertex
	fmt.Println(v.Abs()) // OK
	p := &v
	fmt.Println(p.Abs()) // OK interpreted as `(*p).Abs()`.

# Errors
The error type is a built-in interface similar to fmt.Stringer:

	type error interface {
	    Error() string
	}

	nil
	io.EOF

## new error

	:import errors
	// errors.New("this is a new error")
	var err error = errors.New("this is a new error")
	//io.EOF
	var EOF = errors.New("EOF")

## fmt.Errorf

	err := fmt.Errorf("%s", "the error test for fmt.Errorf")
		&errors.errorString{s:"the error ....."}

## custom MyError

	type MyError struct {
		When time.Time
		What string
	}

	func (e *MyError) Error() string {
		return fmt.Sprintf("at %v, %s",
			e.When, e.What)
	}

	func run() (string, error) {
		return "results!!", &MyError{
			time.Now(),
			"it didn't work",
		}
	}

	func main() {
		if ret, err := run(); err != nil {
			fmt.Println(ret,err)
		}
	}

# Panic
相当于 php 的 die, 但是可以通过 defer 被 recovery 捕获:

	func g(i int) {
		 fmt.Println("Panic!")
		 panic(fmt.Sprintf("%v", i))
	}

	func f() {
		 defer func() {
				 if r := recover(); r != nil {
						 fmt.Println("Recovered in f", r)
				 }
		 }()

		i := 10
		fmt.Println("Calling g with ", i)
		g(i)
		fmt.Println("Returned normally from g.")
	}
