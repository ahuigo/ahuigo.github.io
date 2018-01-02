# Pointers
支持指针类型 *T,指针的指针 **T,以及包含包名前缀的 *<package>.T。
The type `*T` is a pointer to a T value. Its zero value is `nil`.

  var p *int

The `&` operator generates a pointer to its operand.

  i := 42
  p = &i

  v = &Vertex{3, 4}

The `*` operator denotes the pointer's underlying value.

  fmt.Println(*p) // read i through the pointer p
  *p = 21         // set i through the pointer p
