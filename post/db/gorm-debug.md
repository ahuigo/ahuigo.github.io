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


## 自定义 Logger
参考GORM的默认记录器如何自定义它 https://github.com/jinzhu/gorm/blob/master/logger.go

    //例如，使用Revel的Logger作为GORM的输出
    db.SetLogger(gorm.Logger{revel.TRACE})

    //使用 os.Stdout 作为输出
    db.SetLogger(log.New(os.Stdout, "\r\n", 0))

# error

## 错误处理
如果发生任何错误，GORM将设置* gorm.DB的错误字段，可以这样检查：

    if err := db.Where("name = ?", "jinzhu").First(&user).Error; err != nil {
        // error handling...
    }
    Or
    if result := db.Where("name = ?", "jinzhu").First(&user); result.Error != nil {
        // error handling...
    }

## 错误List
处理数据时，通常会发生多个错误。 GORM提供了一个API来将所有错误作为切片返回：

    // If there are more than one error happened, `GetErrors` returns them as `[]error`
    errors := db.First(&user).Limit(10).Find(&users).GetErrors()

    fmt.Println(len(errors))
    for _, err := range errors {
        fmt.Println(err)
    }

## RecordNotFound（紀錄未找到）错误
GORM提供了处理RecordNotFound错误的快捷方式。如果有多个错误，它将检查它们中是否有任何RecordNotFound错误。

    // Check if returns RecordNotFound error
    db.Where("name = ?", "hello world").First(&user).RecordNotFound()
    if db.Model(&user).Related(&credit_card).RecordNotFound() {
        // record not found
    }

    if err := db.Where("name = ?", "jinzhu").First(&user).Error; gorm.IsRecordNotFoundError(err) {
        // record not found
    }
