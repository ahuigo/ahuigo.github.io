# Interfaces
An interface type is defined as `a set of method signatures`.

1. method 没有 public protecte..., 如果要被其它 package 使用, 函数名首字母必须大写!

A value of interface type can hold any value that implements those methods.

  import (
  	"fmt"
  	"math"
  )

  type Abser interface {
  	Abs() float64
  }

  func main() {
  	var a Abser
  	f := MyFloat(-math.Sqrt2)
  	v := Vertex{3, 4}

  	a = f  // a MyFloat implements Abser
  	fmt.Println(a.Abs(), f.Abs())
  	a = &v // a *Vertex implements Abser
  	fmt.Println(a.Abs(), (&v).Abs())

  	// In the following line, v is a Vertex (not *Vertex)
  	// and does NOT implement Abser.
  	a = v

  	fmt.Println(a.Abs(), v.Abs())
  }

  type MyFloat float64

  func (f MyFloat) Abs() float64 {
  	if f < 0 {
  		return float64(-f)
  	}
  	return float64(f)
  }

  type Vertex struct {
  	X, Y float64
  }

  func (v *Vertex) Abs() float64 {
  	return math.Sqrt(v.X*v.X + v.Y*v.Y)
  }

## interface value-type

  type F float64

  func (f F) M() {
  	fmt.Println(f)
  }

  func main() {
  	var i I
  	i = &T{"Hello"}
  	describe(i)
  	i.M()

  	i = F(math.Pi)
  	describe(i)
  	i.M()
  }

  func describe(i I) {
  	fmt.Printf("(%v, %T)\n", i, i)
  }

output:

  (&{Hello}, *main.T)
  (3.141592653589793, main.F)

## Interface values with nil underlying values

  func (t *T) M() {
  	if t == nil {
  		fmt.Println("<nil>")
  		return
  	}
  	fmt.Println(t.S)
  }

	var i I
	var t *T
	i = t
	describe(i)
	i.M()

output:

  (<nil>, *main.T)
  <nil>

## Nil Interface

  var i I
  describe(i)

  func describe(i I) {
  	fmt.Printf("(%v, %T)\n", i, i)
  }

output:

  (<nil>, <nil>)
  runtime-error

## emptye Interface
An empty interface may hold values of any type.

  //like fmt.Print
  func describe(i interface{}) {
  	fmt.Printf("(%v, %T)\n", i, i)
  }

# Type assertions
A type assertion provides access to an interface value's underlying concrete value.

  t := i.(T)
  t, ok := i.(T)

If i does not hold a T, and no ok, the statement will trigger a panic.

  var i interface{} = "hello"

  s, ok := i.(string)
  fmt.Println(s, ok)  //ok = true

  f, ok := i.(float64)
  fmt.Println(f, ok)// f=float64, ok=false

  f = i.(float64) // panic
  fmt.Println(f)

## Type switches
A type switch is a construct that permits several type assertions in series.

In each of the T and S cases, the variable v will be of type `T` or `S` respectively and hold the value held by i:

  func do(i interface{}) {
    switch v := i.(type) {
    case int:
      fmt.Printf("Twice %v is %v\n", v, v*2)
    case string:
      fmt.Printf("%q is %v bytes long\n", v, len(v))
    default:
      fmt.Printf("I don't know about type %T!\n", v)
    }
  }

  func main() {
    do(21)
    do("hello")
    do(true)
  }

assert type via `interface.(Type)`:

  type User struct {
  	id   int
  	name string
  }
  func (self *User) String() string {
  	return fmt.Sprintf("%d, %s", self.id, self.name)
  }
  func main() {
  	var o interface{} = &User{1, "Tom"}
  	if i, ok := o.(fmt.Stringer); ok {
  		fmt.Println(i)
  	}
  	u := o.(*User)
  	// u ,ok:= o.(User) u=User{0}, ok=false
  	// u := o.(User) panic
  	fmt.Println(u)
  }

## Stringers
One of the most ubiquitous interfaces is Stringer defined by the fmt package.

  type Stringer interface {
      String() string
  }

A Stringer is a type that can describe itself as a string. The fmt package (and many others) look for this interface to print values.

  type Person struct {
  	Name string
  	Age  int
  }

  func (p Person) String() string {
  	return fmt.Sprintf("%v (%v years)", p.Name, p.Age); // like Person.protocol.toString() in javascript
  }

  	a := Person{"Arthur Dent", 42}
  	z := Person{"Zaphod Beeblebrox", 9001}
    fmt.Println(a, z)
