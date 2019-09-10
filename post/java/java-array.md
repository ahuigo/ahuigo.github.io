---
title: Java Array
date: 2019-09-09
---
# Map

## put

    Map<String,String> m = new HashMap<String,String> ();
    m.put(key, value)

## key

    map.containsKey(key)
    map.get(key)!=null

# array

## define:

    String[] logs;
    String[] logs = msg.split("\n");
    int[] nums = new int[100];
    int[] ns = new int[] { 68, 79, 91, 85, 62 };

简写：

    int[] ns = { 68, 79, 91, 85, 62 };


Java的数组有几个特点：

1. 数组所有元素初始化为默认值，整型都是0，浮点型是0.0，布尔型是false；
2. 数组一旦创建后，大小就不可改变。

## string 是不可变的引用
Refer: https://www.liaoxuefeng.com/wiki/1252599548343744/1255941599809248

    String[] names = {"ABC", "XYZ", "zoo"};
    String s = names[1];    //s 指向“ABC”
    names[1] = "cat";       //s 还是指向“ABC”

## loop:

    // Fill it with numbers using a for-loop
    for (int i = 0; i < nums.length; i++)
        nums[i] = i + 1;  // +1 since we want 1-100 and not 0-99


## split explode

    String partsColl = "A,B,C";
    String[] partsCollArr;
    String delimiter = ",";
    partsCollArr = partsColl.split(delimiter);