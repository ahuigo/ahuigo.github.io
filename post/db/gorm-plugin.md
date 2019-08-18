---
title: Gorm plugin
date: 2019-08-17
---
# Gorm plugin
GORM本身由Callbacks提供支持，因此您可以根据需要完全自定义GORM, 基于Scope
跟hooks 不同，它不绑定Model

## 注册新的callback
注册新的callback到callbacks中

    func updateCreated(scope *Scope) {
        if scope.HasColumn("Created") {
            scope.SetColumn("Created", "Created by ahuigo")
        }
    }

影响db 和product:

    db.Callback().Create().Before("gorm:create").Register("update_created_at", updateCreated)
    product:=Product{Code: "L1214", Created:"",Price: 18}
    db.Create(&product)
    fmt.Println(product)

只改写product:

    db.Callback().Create().After("gorm:create").Register("update_created_at", updateCreated)
    product:=Product{Code: "L1214", Created:"",Price: 18}
    db.Create(&product)
    fmt.Println(product)

## 删除现有的callback
从callbacks中删除callback

    db.Callback().Create().Remove("gorm:create")
    // 从Create回调中删除`gorm:create`回调

## 替换现有的callback
替换同名callback

    db.Callback().Create().Replace("gorm:create", newCreateFunction)
    // 使用新函数`newCreateFunction`替换回调`gorm:create`用于创建过程

## 注册callback顺序
注册 callback 顺序

    db.Callback().Create().Before("gorm:create").Register("update_created_at", updateCreated)
    db.Callback().Create().After("gorm:create").Register("update_created_at", updateCreated)
    db.Callback().Query().After("gorm:query").Register("my_plugin:after_query", afterQuery)
    db.Callback().Delete().After("gorm:delete").Register("my_plugin:after_delete", afterDelete)
    db.Callback().Update().Before("gorm:update").Register("my_plugin:before_update", beforeUpdate)
    db.Callback().Create().Before("gorm:create").After("gorm:before_create").Register("my_plugin:before_create", beforeCreate)

## 预定义回调
GORM定义了回调以执行其CRUD操作，在开始编写插件之前检查它们。

1. Create callbacks
1. Update callbacks
1. Query callbacks
1. Delete callbacks
1. Row Query callbacks - 没有默认注册的 callback

Row Query callbacks 在运行 Row 或 Rows 时被调用，默认情况下它没有注册的回调，你可以注册一个新的回调：

    func updateTableName(scope *gorm.Scope) {
        scope.Search.Table(scope.TableName() + "_draft") // 追加 `_draft` 到表名后
    }

    db.Callback().RowQuery().Before('gorm:row_query').Register("publish:update_table_name", updateTableName)

Test:

    rows, err := db.Table("products").Select("Code").Rows()
    for rows.Next() {
        var name string
        if err := rows.Scan(&name); err != nil {
        }
    }


# Scope

## Table

    scope.Search.Table(scope.TableName() + "_draft") // 追加 `_draft` 到表名后

## Column

    if scope.HasColumn("Created"){
        scope.SetColumn("Created", "Created by ahuigo")
    }