---
title: Gorm ddl 操作
date: 2019-07-07
private:
---
# connect
    db.DB().SetMaxIdleConns(30)
    db.DB().SetMaxOpenConns(60)
    defer db.Close()

## ping

    // Ping
    db.DB().Ping()

# Gorm Migrate
## define table
    type User struct {
        gorm.Model
        Name         string
        Age          sql.NullInt64
        Birthday     *time.Time
        Email        string  `gorm:"type:varchar(100);unique_index"`
        Role         string  `gorm:"size:255"` // set field size to 255
        MemberNumber *string `gorm:"unique;not null"` // set member number to unique and not null
        Num          int     `gorm:"AUTO_INCREMENT"` // set num to auto incrementable
        Address      string  `gorm:"index:addr"` // create index with name `addr` for address
        IgnoreMe     int     `gorm:"-"` // ignore this field
    }

go 读取 null column时，默认：

    string ""
    int     0
    ....

multiple key:

    Name string `gorm:"unique_index:idx_name_code"` // Create index with name, and will create combined index 
                                                    // if find other fields defined same name
    Code string `gorm:"unique_index:idx_name_code"` // `unique_index` also works

    db.Model(&User{}).AddUniqueIndex("idx_user_name_age", "name", "code") 

## Migrate
自动迁移仅仅会创建表，缺少列和索引，并且不会改变现有列的类型或删除未使用的列以保护数据。

    db.AutoMigrate(&User{})

    db.AutoMigrate(&User{}, &Product{}, &Order{})

    // 创建表时添加表后缀
    db.Set("gorm:table_options", "ENGINE=InnoDB").AutoMigrate(&User{})

# Table
## hasTable 检查表是否存在
    // 检查模型`User`表是否存在
    db.HasTable(&User{})
    db.HasTable("users")

## 1.2.3. 创建表
    // 为模型`User`创建表
    db.CreateTable(&User{})
    // 创建表`users'时将“ENGINE = InnoDB”附加到SQL语句
    db.Set("gorm:table_options", "ENGINE=InnoDB").CreateTable(&User{})

## 1.2.4. 删除表
    // 删除模型`User`的表
    db.DropTable(&User{})

    // 删除表`users`
    db.DropTable("users", "profiles")

    // 删除模型`User`的表和表`products`
    db.DropTableIfExists(&User{}, "products")

## 列
### 修改列
修改列的类型为给定值

    // 修改模型`User`的description列的数据类型为`text`
    db.Model(&User{}).ModifyColumn("description", "text")

### 1.2.6. 删除列
    // 删除模型`User`的description列
    db.Model(&User{}).DropColumn("description")


# 索引

## AddIndex

    // 为`name`列添加索引`idx_user_name`
    db.Model(&User{}).AddIndex("idx_user_name", "name")

    // 为`name`, `age`列添加索引`idx_user_name_age`
    db.Model(&User{}).AddIndex("idx_user_name_age", "name", "age")

## AddUniqueIndex

    // 添加唯一索引
    db.Model(&User{}).AddUniqueIndex("idx_user_name", "name")

    // 为多列添加唯一索引
    db.Model(&User{}).AddUniqueIndex("idx_user_name_age", "name", "age")

## RemoveIndex

    // 删除索引
    db.Model(&User{}).RemoveIndex("idx_user_name")

## 外键
### 添加外键
    // 添加主键
    // 1st param : 外键字段
    // 2nd param : 外键表(字段)
    // 3rd param : ONDELETE
    // 4th param : ONUPDATE
    db.Model(&User{}).AddForeignKey("city_id", "cities(id)", "RESTRICT", "RESTRICT")
### Remove ForeignKey
    db.Model(&User{}).RemoveForeignKey("city_id", "cities(id)")