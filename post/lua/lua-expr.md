---
title: lua expr
date: 2020-05-04
private: true
---
# lua expr

# comment
单行注释

    --两个减号是单行注释:

多行注释

    --[[
    多行注释
    多行注释
    --]]

# loop/if
## 循环
do while

    repeat
        statements
    until( condition )

while

    while( true )
    do
        print("执行下去")
        break;
    end

for:

    -- step 步长默认1
    for i=10,1,-1 do
        print(i)
    end

## if

    --[ 0 为 true ]
    if(0)
    then
        print("0 为 true")
    elseif(0==3)
    else
    end
