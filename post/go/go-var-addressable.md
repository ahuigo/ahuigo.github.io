---
title: addressable value
date: 2022-02-09
private: true
---
# addressable value
refer1: https://go101.org/article/unofficial-faq.html#unaddressable-values
refer2: https://colobu.com/2018/02/27/go-addressable/

    func main(){
        m:=map[string]string{
            "k1":"val1",
        }
        s:=[2]int{1,2}
        fmt.Println(&s[0]) // ok
        fmt.Println(&m["k1"]) // can't addressable
    }

## addressable
The `&v` operand must be addressable, either:

    &v: 
        a variable, 
    &*p: 
        pointer indirection, (pointer dereference operations)
    &s[0]: 
        slice indexing operation; 
        elements of any slices (whether the slices are addressable or not)
    &struct{A int}{1}: 
        fields of addressable structs
    &arr[0]
        elements of addressable arrays
## not addressable
We can't take the address of the following values:

    bytes in strings
    map elements
        &m["key"]
    dynamic values of interface values (exposed by type assertions)
        &inferaceA.(int)
    constant values (including named constants and literals)
        &2
    package level functions
        &afunc //func afunc()
    methods (used as function values)
        &t.method()
    intermediate values(中间值)
        function calls
            &afunc()
            &afunc().field
            &afunc()[0]
        explicit value conversions
            &(a+b+c)
        all sorts of operations, excluding pointer dereference operations, but including:
            channel receive operations
            sub-string operations
                &str[:3]
            sub-slice operations
            addition, subtraction, multiplication, and division, etc.

## Why unaddressable?
1. Why are map elements unaddressable?
empty elements could has zero value
