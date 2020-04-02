---
title: go str
date: 2019-05-06
---
# go json

## encode marshal bytes

    import "encoding/json"
    type response2 struct {
        Page   int      `json:"page"` //json 是可选的, 用于转名字
        Fruits []string `json:"fruits"`
    }
    //等价
    bytes1 := json.Marshal(response2{})
    bytes1 := json.Marshal(&response2{})

map

    bytes1 := json.Marshal(map[string]interface{}{
        "a":1,
        "k2":"b",
    })

### encode stdout
    enc := json.NewEncoder(os.Stdout)
    d := map[string]int{"apple": 5, "lettuce": 7}
    enc.Encode(d)

## Unmarshal
### str to struct
https://gobyexample.com/json

    type Resp struct {
        Name            string              `json:"name"`
        Description     string              `json:"description"`
        Fruits []string `json:"fruits"`

    }
    res := Resp{}
    json.Unmarshal([]byte(str), &res)

### str to map 
由于nil map 其实不能被赋值，所以go 利用reflect 动态生成的新map

    byt := []byte(`{"num":6.13,"strs":["a","b"]}`)
    var dat map[string]interface{}
    if err := json.Unmarshal(byt, &dat); err != nil { }
    fmt.Println(dat)    
        //map[num:6.13 strs:[a b]]
    strs := dat["strs"].([]interface{})
        // ["a","b"]

### map to struct
    //import "github.com/mitchellh/mapstructure"
	err := mapstructure.Decode(mapinput, &result)
	err := mapstructure.Decode(&mapinput, &result)

其实是利用反射：[go-lib/str/map2struct.go]
