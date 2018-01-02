# map

## nil map
The `zero` value of a map is `nil`. A `nil` map has no keys, nor can keys be added.

  var m map[string]int
  fmt.Println(m==nil); //true
  fmt.Println(make(map[string]int)==nil); //false


## make map

    m := make(map[string]int) //使用make创建一个空的map
    b := make(map[int]byte); // map 支持动态 allocate 扩容,而普通的array,slice 则必须指定 len

    m["one"] = 1
    m["two"] = 2
    m["three"] = 3

    fmt.Println(m) //输出 map[three:3 two:2 one:1] (顺序在运行时可能不一样)
    fmt.Println(len(m)) //输出 3

    v := m["two"] //从map里取值
    fmt.Println(v) // 输出 2

init map

    m1 := map[string]int{"one": 1, "two": 2, "three": 3}
    fmt.Println(m1) //输出 map[two:2 three:3 one:1] (顺序在运行时可能不一样)

or:

    var m = map[string]Vertex{
    	"Bell Labs": {40.68433, -74.39967},
    	"Google":    Vertex{37.42202, -122.08408},
    }

## get

  elem = m[key]

## test
If key is not in m, ok is false

  elem, ok := m[key]

## delete

    delete(m, "two")
    fmt.Println(m) //输出 map[three:3 one:1]

## foreach

    for key, val := range m1{
        fmt.Printf("%s => %d \n", key, val)
    }
}
