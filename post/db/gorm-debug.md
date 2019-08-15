---
title: Gorm
date: 2019-04-04
private:
---
# Gorm Model
## Model tableName
TableName 是根据ModelName 自动生成的, 并且通过下列代码将表名复数化

    //go/pkg/mod/github.com/jinzhu/gorm@v1.9.1/utils.go
    //go/pkg/mod/github.com/jinzhu/gorm@v1.9.1/model_struct.go
         60: tableName = inflection.Plural(tableName)

# log
输出日志：

    db.LogMode(true)
    // Debug a single operation, show detailed log for this operation
    db.Debug().Where("name = ?", "jinzhu").First(&User{})
