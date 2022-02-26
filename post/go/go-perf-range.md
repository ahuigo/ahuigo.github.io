---
title: go array range 的坑
date: 2020-09-11
private: true
---
# go array range 的坑
## range　会copy 副本
如果不用pointer, range 就会copy values

    //go-lib/struct/range-copy-pointer.go
    type Role struct{
        Users []string
    }
    type Roles []*Role
    func main(){
        roles := Roles{&Role{[]string{"ahui"}}}
        // 如果用非指针，roles就在堆在，role[i]被从堆copy 到栈上(对于大struct 有性能问题)
        for _, role:= range roles{
            role.Users = append(role.Users, "newValue")
            fmt.Println("role:",role)
            fmt.Println("roles[0]:",roles[0])
            fmt.Printf("%p,%p\n", role,roles[0])
        }
    }

除非只迭代下标，就不会copy

        for i:= range roles{

## 不要对range元素取址
对range v取址`&v`, 得到相同的`{chain2, 21}`. 
因为v是栈空间的变量，在整个loop期间会copy　元素`o[i]`到这个变量`v`。

    type P struct {
        Name string
        Age  int
    }
    func main() {
        o := []P{
            P{"chain1", 20},
            P{"chain2", 21},
        }
        oPointer := make([]*P, 0, 2)
        for _, v := range o {
            oPointer = append(oPointer, &v)
        }
        fmt.Println(oPointer)
        for _, v := range oPointer {
            fmt.Println(v)
        }
    }

## range map delete
删除是安全的

    for key := range m {
        if key.expired() {
            delete(m, key)
        }
    }

## range map add
新增不安全，结果可能不一样(有时少)

    data := map[string]string{"1": "A", "2": "B", "3": "C"}
    for k, v := range data {
        data[v] = k
        fmt.Printf("res %v\n", data)
    }

因为go的map是hash桶，是 unordered的. python,php都有这个问题

# 参考
- 神坑range - chainhelen的文章: [golang-range]

[golang-range]: https://zhuanlan.zhihu.com/p/212828864