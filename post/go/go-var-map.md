---
title: map
date: 2018-09-27
---
# map

## define map
键必须是⽀支持相等运算符 (==、!=) 类型，⽐比如 number、string、 pointer、array、struct，以及对应的 interface。值可以是任意类型，没有限制。

    map[KEY]VALUE

### make map

    m := make(map[string]int) //使用make创建一个空的map
    b := make(map[int]byte); // map 支持动态 allocate 扩容,而普通的slice 则必须指定 len

    m["one"] = 1
    m["two"] = 2
    m["three"] = 3

    fmt.Println(m) //输出 map[three:3 two:2 one:1] (顺序在运行时可能不一样)
    fmt.Println(len(m)) //输出 3

    v := m["two"] //从map里取值
    fmt.Println(v) // 输出 2

### init map(可以扩容)
key:int

    m1 := map[string]int{"one": 1, "two": 2, "three": 3}
    fmt.Println(m1) //输出 map[two:2 three:3 one:1] (顺序在运行时可能不一样)

key:interface

    map[string]interface{}{
        "a":1,
        "k2":"b",
    }

struct map:

    var m = map[string]Vertex{
    	"Bell Labs": {40.68433, -74.39967},
    	"Google":    Vertex{37.42202, -122.08408},
    }

init with variable key:

    type T string
    const (
       A T = "key1"
       B T = "key2"
    )
    var m = map[T]int{
        A:2,
        B:3,
    }
    fmt.Printf("%#v\n", m)  //Speak

## nil map(不能扩容)
The `zero` value of a map is `nil`. A `nil` map has no keys, nor can keys be added.

  var m map[string]int
  fmt.Println(m==nil);      //true
  fmt.Printf("%#v\n", m)    //map[string]int(nil)

  m=make(map[string]int)
  fmt.Println(m==nil);      //false
  fmt.Printf("%#v\n", m)    // map[string]int{}

## map index address
map 只用于：`regular addressable value`类型
https://stackoverflow.com/questions/32751537/why-do-i-get-a-cannot-assign-error-when-setting-value-to-a-struct-as-a-value-i

cannot assign to struct field p["HM"].age in map

    //go-lib/map/map-index-address.go
    package main

    import "fmt"
    type Person struct {
        name string
        age int
    }

    type People map[string]Person

    func main() {
        p := make(People)
        p["HM"] = Person{"Hank McNamara", 39}

        // cannot assign to field p["HM"].age in map
        p["HM"].age = p["HM"].age + 1
        // 可以用: p["HM"] = p["HM"].incrementAge()
        fmt.Printf("age: %d\n", p["HM"].age)
    }

go `=`赋值只能用于addressable, 很可惜`p["HM"] is not addressable`.

    Each left-hand side operand must be addressable, a map index expression

方法是用index address:
1. 用：`map[string]*MyStruct`参与赋值
2. `p["HM"] = p["HM"].incrementAge()`

## add
    m["new_key"] = 1

## get

    elem := m[key] //key 不存在，默认是0

### test

  if elem, exists := m[key]; exists{

  }

## delete
允许删除不存在的key 不报错

    delete(m, "two")
    fmt.Println(m) //输出 map[three:3 one:1]

## foreach

    for key := range m1{
        fmt.Printf("%s \n", key)
    }
    for key, val := range m1{
        fmt.Printf("%s => %d \n", key, val)
    }
}

可以在迭代时安全删除键值。但如果期间有新增操作，那么就不知道会有什么意外了。

        m := map[int]string{
            0:  "a", 1:  "a", 2:  "a", 3:  "a", 4:  "a",
            5:  "a", 6:  "a", 7:  "a", 8:  "a", 9:  "a",
        }
        for k := range m {
            m[k+k] = "x"
            delete(m, k)
        }
        //output: map[12:x 16:x 20:x 28:x 36:x]

## update
get的value 是临时复制的，应该

    u := m[1]       //copy value
    u.name = "Tom"  
    m[1] = u        // 替换 value。

或者用指针直接修改

    m2 := map[int]*user{
        1: &user{"user1"},
    }
    m2[1].name = "Jack"

# 参考
- 雨痕的golang 笔记第四版