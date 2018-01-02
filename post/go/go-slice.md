# struct

	type Vertex struct {
		X int
		Y int
	}

	v := Vertex{1, 2}
	v.X = 4
	Vertex{1, 2}.X

define+init:

  j:=struct{
    x int
    y int
  }{5,6}
  j.x
  (&j).x

## pointer to structs
struct pointer:

  v := Vertex{1, 2}
	p := &v
	p.X = 1e9

copy:

  p := v

## Struct Literals Pointer
A struct literal denotes a newly allocated struct value by listing the values of its fields

  var (
  	v1 = Vertex{1, 2}  // has type Vertex
  	v2 = Vertex{X: 1}  // Y:0 is implicit
  	v3 = Vertex{}      // X:0 and Y:0
  	p  = &Vertex{1, 2} // has type *Vertex
  )
  fmt.Println(v1, p, v2, v3, x,j,3)

# Arrays
The type `[n]T` is an array of `n` values of type `T`

  var a [10]int
  var a [2]string
	primes := [6]int{2, 3, 5, 7, 11, 13}
	fmt.Println(primes)

## array assign is not reference

  b := a

> slice assign/pass-arguments is Reference, point to original slice but not array

# Slices
An array has fixed size, a slice is a dynamically-sized. `[]T` is a slice with elements of type `T`

## create slice
declare slice

  var s []int;

Create a slice of the array primes:

    primes := [7]int{2, 3, 5, 7, 11, 13, 17}
  	var s []int = primes[4:6]
  	fmt.Println(s); # [11 13]

Create a slice of the init array :

  s := []int{1,2,3}

## Slices are like reference to arrays

  names := [4]string{
		"John",
		"Paul",
		"George",
		"Ringo",
	}

	a := names[0:2]
	b := names[1:3]
  b[0] = 'XXX'
	fmt.Println(a, b)
  [John XXX] [XXX George]

## slice literals
This is an array literal:

  [3]bool{true, true, false}

And this creates the same array as above, then builds a `slice` that `references` it:

  []bool{true, true, false}

slice structs:

  s := []struct {
    i int
    b bool
  }{
    {2, true},
    {3, false},
    {5, true},
    {7, true},
    {11, false},
    {13, true},
  }

### slice literals is reference
Array is not reference:

	var a = [6]int{1,2,3}
	b := a
	b[0] = 100
	fmt.Println(a,b);# [100 2 3] [100 2 3]

Slice is reference:

	var a = []int{1,2,3}
	b := a
	b[0] = 100
	fmt.Println(a,b);# [1 2 3] [100 2 3]

## slice bounds
For array `var a [10]int `, these slice expressions are equivalent:

  a[0:10]
  a[:10]
  a[0:]
  a[:]

  a[start:end:cap_end]

## slice length and capacity
The length and capacity of a slice s can be obtained using the expressions `len(s)` and `cap(s)`.

  len(s)  - The number of elements it contains.
  cap(s)  - The number of elements in the underlying array

You adn extend a slice's length within its capacity:

  func main() {
  	s := []int{2, 3, 5, 7, 11, 13}
  	printSlice(s)

  	// Slice the slice to give it zero length.
  	s = s[:0]
  	printSlice(s)

  	// Extend its length.
  	s = s[:4]
  	printSlice(s)

  	// Drop its first two values.
  	s = s[2:]
  	printSlice(s)
  }

  func printSlice(s []int) {
  	fmt.Printf("len=%d cap=%d %v\n", len(s), cap(s), s)
  }

output:

  len=6 cap=6 [2 3 5 7 11 13]
  len=0 cap=6 []
  len=4 cap=6 [2 3 5 7]
  len=2 cap=4 [5 7]

## Nil slices
A nil slice has a length and capacity of 0 and has `no underlying array`(no pointer):

  var s []int
  fmt.Println(s, len(s), cap(s))
  if s == nil {
    fmt.Println("nil!")
  }

## make slice
This is how you create dynamically-sized arrays.

The make function allocates a zeroed array and returns a slice that refers to that array:

  a := make([]int, 5)  // len(a)=5 a=[0 0 0 0 0]

To specify a capacity, pass a third argument to make:

  b := make([]int, 0, 5) // len(b)=0, cap(b)=5, a=[]

  b = b[:cap(b)] // len(b)=5, cap(b)=5
  b = b[1:]      // len(b)=4, cap(b)=4

## join slice

  :import strings
  s := [2]string{"hello", "world"}
  strings.Join(s[:], ",")

## append slice
The documentation of the built-in package describes append.

  func append(s []T, vs ...T) []T

The first parameter `s` of append is a slice of `type T`, and the rest are T values to append to the slice.

### slice allocate
If the backing array of `s` is too small to fit all the given values, a bigger array will be allocated(double cap).

The returned slice will point to the newly allocated array.

  var a = [3]int{1,2,3}
  b := a[:];  # cap(b)=3
  b = append(b,4,5);  # cap(b)=6, b=[1,2,3,4,5], a=[1,2,3] ; and b will not point to a

Otherwise, slice still points to underlying array

  var a = [3]int{1,2,3}
  b := a[:1];  # cap(b) = 3
  b = append(b,4);   # cap(b)=3, b=[1,4], a=[1,4,3] and b still point to a

## range
The `range` form the `for loop iterates` over a `array, slice, string or map`, or values received on a channel.

  for i, v := range [2]int{1,2} {
		fmt.Printf("2**%d = %d\n", i, v)
	}

> range is not reference!

### skip range index
You can skip the index or value by assigning to _.

  for _, v := range [2]int{1,2} {
		fmt.Printf("2**%d = %d\n", _, v)
	}

skip value:

  for i := range [2]int{1,2} {
