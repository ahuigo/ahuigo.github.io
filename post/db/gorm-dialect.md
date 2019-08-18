---
title: Gorm dialect
date: 2019-08-17
---
# Gorm dialect
GORM 官方支持以下几种方言：sqlite, mysql, postgres, mssql.

当你创建一个新方言的时候，你必须实现 the dialect interface 接口。

## 方言的特殊类型
某些 SQL 的方言包含特殊的、非标准的类型，比如 PostgreSQL 中的 jsonb 类型。 GORM 支持其中的几种类型，如下所示。

### PostgreSQL
GORM 支持加载以下 PostgreSQL 特有类型： - jsonb - hstore

Model 定义如下：

    import (
        "encoding/json"
        "github.com/jinzhu/gorm/dialects/postgres"
    )

    type Document struct {
        Metadata postgres.Jsonb
        Secrets  postgres.Hstore
        Body     string
        ID       int
    }

你可以这样使用 model:

    password := "0654857340"
    metadata := json.RawMessage(`{"is_archived": 0}`)
    sampleDoc := Document{
        Body: "This is a test document",
        Metadata: postgres.Jsonb{ metadata },
        Secrets: postgres.Hstore{"password": &password},
    }

    // 插入 sampleDoc 到数据库
    db.Create(&sampleDoc)

    // 取出记录，以确定记录是否正确插入
    resultDoc := Document{}
    db.Where("id = ?", sampleDoc.ID).First(&resultDoc)

    metadataIsEqual := reflect.DeepEqual(resultDoc.Metadata, sampleDoc.Metadata)
    secretsIsEqual := reflect.DeepEqual(resultDoc.Secrets, sampleDoc.Secrets)

    // 应该输出 "true"
    fmt.Println("Inserted fields are as expected:", metadataIsEqual && secretsIsEqual)
