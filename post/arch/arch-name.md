---
title: 命名规范
date: 2020-06-08
private: true
---
# 命名规范
参考：编写可维护的前端代码
https://github.com/olivewind/blog/issues/8

## 文件命名 kebab-case
除了 model 中的数据模型用大驼峰(PascalCase)，都使用kebab-case(小写短横线)命名

    import SearchFilter from 'components/common/search-filter';

## 变量/方法 camelCase

    taskList
    getTaskList

## 类型/Class PascalCase
    interface Map {

    }

有的语言建议加上前缀I, 或者泛型T

    IMap

## CSS
    .nav-main