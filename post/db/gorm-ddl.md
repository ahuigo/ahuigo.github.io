---
title: Gorm ddl 操作
date: 2019-07-07
private:
---
# Gorm Migrate
自动迁移仅仅会创建表，缺少列和索引，并且不会改变现有列的类型或删除未使用的列以保护数据。

    db.AutoMigrate(&User{})

    db.AutoMigrate(&User{}, &Product{}, &Order{})

    // 创建表时添加表后缀
    db.Set("gorm:table_options", "ENGINE=InnoDB").AutoMigrate(&User{})

# Table
1.2.2. 检查表是否存在
// 检查模型`User`表是否存在
db.HasTable(&User{})

// 检查表`users`是否存在
db.HasTable("users")
1.2.3. 创建表
// 为模型`User`创建表
db.CreateTable(&User{})

// 创建表`users'时将“ENGINE = InnoDB”附加到SQL语句
db.Set("gorm:table_options", "ENGINE=InnoDB").CreateTable(&User{})
1.2.4. 删除表
// 删除模型`User`的表
db.DropTable(&User{})

// 删除表`users`
db.DropTable("users")

// 删除模型`User`的表和表`products`
db.DropTableIfExists(&User{}, "products")
1.2.5. 修改列
修改列的类型为给定值

// 修改模型`User`的description列的数据类型为`text`
db.Model(&User{}).ModifyColumn("description", "text")
1.2.6. 删除列
// 删除模型`User`的description列
db.Model(&User{}).DropColumn("description")
1.2.7. 添加外键
// 添加主键
// 1st param : 外键字段
// 2nd param : 外键表(字段)
// 3rd param : ONDELETE
// 4th param : ONUPDATE
db.Model(&User{}).AddForeignKey("city_id", "cities(id)", "RESTRICT", "RESTRICT")

1.2.8. 索引
// 为`name`列添加索引`idx_user_name`
db.Model(&User{}).AddIndex("idx_user_name", "name")

// 为`name`, `age`列添加索引`idx_user_name_age`
db.Model(&User{}).AddIndex("idx_user_name_age", "name", "age")

// 添加唯一索引
db.Model(&User{}).AddUniqueIndex("idx_user_name", "name")

// 为多列添加唯一索引
db.Model(&User{}).AddUniqueIndex("idx_user_name_age", "name", "age")

// 删除索引
db.Model(&User{}).RemoveIndex("idx_user_name")

