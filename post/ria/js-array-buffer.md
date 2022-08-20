---
title: js array buffer
date: 2022-07-08
private: true
---
# js array buffer
ArrayBuffer 跟array不一样：
1. new ArrayBuffer(16); // 创建一个长度为 16 的 buffer, 并填充0
2. 长度不可变。

# TypedArray 视图
ArrayBuffer没有数据类型, 要操作它则要转成视图(`TypedArray`或`DataView`). `TypedArray`可分为
1. Uint8Array —— 将 ArrayBuffer 中的每个字节视为 0 到 255 之间的单个数字（每个字节是 8 位，因此只能容纳那么多）。这称为 “8 位无符号整数”。
1. Uint16Array —— 将每 2 个字节视为一个 0 到 65535 之间的整数。这称为 “16 位无符号整数”。
1. Uint32Array —— 将每 4 个字节视为一个 0 到 4294967295 之间的整数。这称为 “32 位无符号整数”。
1. Float64Array —— 将每 8 个字节视为一个 5.0x10-324 到 1.8x10308 之间的浮点数。

## 视图构造
create typedArray point to ArrayBuffer:

    new TypedArray(buffer, [byteOffset], [length]);
        基于ArrayBuffer 创建视图
    new TypedArray(object);
        new Uint8Array([1,2,3,4])
    new TypedArray(typedArray);

create typedArray and auto create ArrayBuffer:

    new TypedArray(length);
    new TypedArray();

example： from buffer

    > let a=new Uint8Array([1,2,3,4])
    > let b=new Uint8Array(a.buffer, 1,2)
    > b
    Uint8Array(2) [ 2, 3 ]
    > b[1]=99
    99
    > a
    Uint8Array(4) [ 1, 2, 99, 4 ]

example: from iterator

    // From an iterable
    const iterable = function*() { yield* [1, 2, 3]; }();
    const uint8FromIterable = new Uint8Array(iterable);
    console.log(uint8FromIterable);
    // Uint8Array [1, 2, 3]

## 视图内存结构
那么在 TypedArray 中有如下的属性：

    arr.buffer —— 引用 ArrayBuffer。
    arr.byteLength —— Array 的总字节长度(视图)
    arr.buffer.byteLength —— 内部ArrayBuffer 的总字节长度
    arr.BYTES_PER_ELEMENT // 每个元素字节长
        Uint16Array的BYTES_PER_ELEMENT是2

e.g:

    let a = new Uint8Array([1,2,3,4]); // 为 4 个整数创建类型化数组
    let b = new Uint8Array(a.buffer, 1,2); // 创建视图 //[2,3]
    b.byteLength    //2
    b.buffer.byteLength    //4

## 视图类型转换
### 视图类型间转换
转换时，可能会丢失数据（越界行为)

    let arr16 = new Uint16Array([-1, 258]); // 无符号数
    let arr8 = new Uint8Array(arr16);
    arr8[0]; //255
    arr8[1]; // 2

### 视图与string
    function bytes2str(bytes:Uint8Array){
        return new TextDecoder().decode(bytes)
    }

    function str2bytes(s){
        return new TextEncoder().encode(s)
    }


## 视图读写

### 视图读
    let buffer = new ArrayBuffer(16); // 创建一个长度为 16 的 buffer
    let view = new Uint32Array(buffer); // 将 buffer 视为一个 32 位整数的序列

    // 让我们写入一个值
    view[0] = 123456;
    // 遍历值
    for(let num of view) {
        console.log(num); // 123456，然后 0，0，0（一共 4 个值）
    }

### 视图写
    view[0] = 123456;
    
注意，直接操作buffer, 其实不是修改的内存数据，而是修改的属性

    > buffer[11]=11
    > buffer[0]=1
    > buffer
    ArrayBuffer { "0": 1, "11": 11 }

### 其它方法
除了支持（iterate），map，slice，find 和 reduce 等
还有两种其他方法：

    arr1 = arr2.slice(0,1)  // 创建新buffer
    arr1 = arr2             // 指向同一buffer
    dst.set(srcArr, [offset]) // 复制：从 dst 的offset（默认为 0）开始，将 fromArr 中的所有元素复制到 arr。
    arr1 = arr.subarray([begin, end]) 创建一个从 begin 到 end（不包括）相同类型的新视图。
        这类似于 slice 方法，但不复制任何内容 —— 只是创建一个新视图，以对给定片段的数据进行操作

### 越界行为

    let arr8 = new Uint8Array(2);
    arr8[0]=257; // 存1
    arr8[2] //undefined
    arr8[2] = 1 //无效，但是不报错

# DataView, 无类型视图
DataView 是在 ArrayBuffer 上的一种特殊的超灵活“未类型化”视图。

    // 与类型化数组不同，DataView 不会自行创建缓冲区（buffer）
    new DataView(buffer, [byteOffset], [byteLength])

通过 DataView，我们可以使用 .getUint8(i) 或 .getUint16(i) 之类的方法访问数据。我们在调用方法时选择格式，而不是在构造的时候。
语法：

例如:

    // 4 个字节的二进制数组，每个都是最大值 255
    let buffer = new Uint8Array([255, 255, 255, 255]).buffer;

    let dataView = new DataView(buffer);

    // 在偏移量为 0 处获取 8 位数字
    alert( dataView.getUint8(0) ); // 255

    // 现在在偏移量为 0 处获取 16 位数字，它由 2 个字节组成，一起解析为 65535
    alert( dataView.getUint16(0) ); // 65535（最大的 16 位无符号整数）

    // 在偏移量为 0 处获取 32 位数字
    alert( dataView.getUint32(0) ); // 4294967295（最大的 32 位无符号整数）

    dataView.setUint32(0, 0); // 将 4 个字节的数字设为 0，即将所有字节都设为 0