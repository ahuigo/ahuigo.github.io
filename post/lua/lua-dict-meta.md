---
title: lua metatable
date: 2020-05-07
private: true
---

# lua metatable

metatable 实现了table 之间的魔法函数

    setmetatable(table,metatable): 对指定 table 设置元表(metatable)，如果元表(metatable)中存在 __metatable 键值，setmetatable 会失败。
    getmetatable(table): 返回对象的元表(metatable)。

## __index

lua从table中查找一个key时, 如果没有key, 就会在`metatable.__index` 对应的table 中找

    t中是否有k，有则返回，无则第2步
    t是否有metatable，无则返回nil，有则第3步
    t的metatable中是否有__index方法，无则返回nil，有则查找 __index对应的table或者方法

### index(类似js的prototype)

    > other = { foo = 3 }
    > t = setmetatable({}, { __index = other })
    > t.foo
    3
    > t.bar
    nil
    > getmetatable(t).__index.foo
    3
    > getmetatable(t).foo
    nil

setmetatable 是inplace 的

    o= { foo = 3 }
    a = {}
    setmetatable(a, { __index = o})
    a.foo

### `__index`支持回调函数

    mytable = setmetatable({key1 = "value1", k2="v2"}, {
      __index = function(myt, key)
          print('myt:',myt==mytable,key)
        if key == "key2" then
          return "metatablevalue"
        else
          return nil
        end
      end
    })

ipairs 是按key 从1开始迭代的, 1这个key不存在，就调用`__index`

    for k, v in ipairs(mytable) do
        print('kv1:',k,v)
    end
    // 返回
    myt:	true	1

pairs 是按实际的key 开始迭代的, 不会调用`__index`

    for k, v in pairs(mytable) do
        print('kv2:',k,v)
    end
    // 返回
    kv2:	k2	v2
    kv2:	key1	value1

直接访问不存在的key

    print(mytable.key1,mytable.key2)
    //返回
    myt:	true	key2
    value1	metatablevalue

## `__newindex` 元方法

`__newindex` 元方法用来对表更新，`__index`则用来对表访问 。

    mymetatable = {}
    mytable = setmetatable({key1 = "value1"}, { __newindex = mymetatable }) 

    mytable.newkey = "新值2"
    print(mytable.newkey,mymetatable.newkey)

    mytable.key1 = "新值1"
    print(mytable.key1,mymetatable.key1)

以上实例执行输出结果为：

    nil    新值2
    新值1    nil

### newindex 回调

    mytable = setmetatable({key1 = "value1"}, {
        __newindex = function(mytable, key, value)
            rawset(mytable, key, "\""..value.."\"")
        end
    })

    mytable.key1 = "new value"
    mytable.key2 = 4

    print(mytable.key1,mytable.key2)

### 操作符

    __add	对应的运算符 '+'.
    __sub	对应的运算符 '-'.
    __mul	对应的运算符 '*'.
    __div	对应的运算符 '/'.
    __mod	对应的运算符 '%'.
    __unm	对应的运算符 '-'.
    __concat	对应的运算符 '..'.
    __eq	对应的运算符 '=='.
    __lt	对应的运算符 '<'.
    __le	对应的运算符 '<='.

`__add为例`：

    -- 两表相加操作
    mytable = setmetatable({ 1, 2, 3 }, {
        __add = function(mytable, newtable)
            for i = 1, #newtable do
                table.insert(mytable, #mytable+1,newtable[i])
            end
            return mytable
        end
    })

    secondtable = {4,5,6}

    mytable = mytable + secondtable
    for k,v in ipairs(mytable) do
        print(k,v)
    end

## call 元方法

`__call` 元方法在 Lua 调用一个值时调用。

    -- 定义元方法__call
    mytable = setmetatable({10}, {
        __call = function(mytable, newtable)
            sum = 0
            for i = 1, #mytable do
                sum = sum + mytable[i]
            end
            for i = 1, #(newtable) do
                sum = sum + newtable[i]
            end
            return sum
        end
    })
    newtable = {10,20,30}
    print(mytable(newtable))
    //以上实例执行输出结果为： 70

## `__tostring` 元方法

    mytable = setmetatable({ 10, 20, 30 }, {
        __tostring = function(mytable)
            return "表所有元素的个数为 " .. #mytable
        end
    })
    print(mytable)
