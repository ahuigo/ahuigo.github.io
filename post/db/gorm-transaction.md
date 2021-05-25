---
title: gorm transaction
date: 2019-08-17
---
# gorm 事务

	db := db1.Begin()
    db.Rollback()
    db.Commit()

GORM 默认会将单个的 create, update, delete操作封装在事务内进行处理，以确保数据的完整性。

    tx := db.Begin()
    tx.Create(...)

    // do sth....

    tx.Rollback()
    //or
    tx.Commit()

一个具体的例子

    func CreateAnimals(db *gorm.DB) error {
        // Note the use of tx as the database handle once you are within a transaction
        tx := db.Begin()
        defer func() {
            if r := recover(); r != nil {
            tx.Rollback()
            }
        }()

        if err := tx.Error; err != nil {
            return err
        }

        if err := tx.Create(&Animal{Name: "Giraffe"}).Error; err != nil {
            tx.Rollback()
            return err
        }

        if err := tx.Create(&Animal{Name: "Lion"}).Error; err != nil {
            tx.Rollback()
            return err
        }

        return tx.Commit().Error
    }