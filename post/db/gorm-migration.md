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
## 表名
表名默认就是结构体名称的复数，例如：

    type User struct {} // 默认表名是 `users`
    type UserDomain struct {} // 默认表名是 `user_domains`
    // 禁用默认表名的复数形式，如果置为 true，则 `User` 的默认表名是 `user`
    db.SingularTable(true)

更改默认表名称（table name）

    gorm.DefaultTableNameHandler = func (db *gorm.DB, defaultTableName string) string  {
        return "prefix_" + defaultTableName;
    }

将 User 的表名设置为 `profiles`

    func (User) TableName() string {
        return "profiles"
    }

    func (u User) TableName() string {
        if u.Role == "admin" {
            return "admin_users"
        } else {
            return "users"
        }
    }

指定表名称

    // 使用User结构体创建名为`deleted_users`的表
    db.Table("deleted_users").CreateTable(&User{})

    db.Table("deleted_users").Where("name = ?", "jinzhu").Delete()
    //// DELETE FROM deleted_users WHERE name = 'jinzhu';


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
### primary key
默认ID 是primary

    type User struct {
        ID   string // field named `ID` will be used as primary field by default
        Name string
    }

    // Set field `AnimalID` as primary field
    type Animal struct {
        AnimalID int64 `gorm:"primary_key"`
        Name     string
        Age      int64
    }

自增

    Num          int     `gorm:"AUTO_INCREMENT"` // set num to auto incrementable

### 列名
下划线分割命名（Snake Case）的列名

    type User struct {
      ID        uint      // column name is `id`
      Name      string    // column name is `name`
      Birthday  time.Time // column name is `birthday`
      CreatedAt time.Time // column name is `created_at`
    }

    // Overriding Column Name
    type Animal struct {
      AnimalId    int64     `gorm:"column:beast_id"`         // set column name to `beast_id`
      Birthday    time.Time `gorm:"column:day_of_the_beast"` // set column name to `day_of_the_beast`
      Age         int64     `gorm:"column:age_of_the_beast"` // set column name to `age_of_the_beast`
    }

### 列注解
	Domains  []string `gorm:"not null" json:"domains"`
    Password string `gorm:"not null" json:"-"`  //json 不保留
	UUID     string `gorm:"not null;unique" json:"uuid"`
	Domain string `gorm:"primary_key" json:"domain"`

### 修改列
修改列的类型为给定值

    // 修改模型`User`的description列的数据类型为`text`
    db.Model(&User{}).ModifyColumn("description", "text")

### 删除列
    // 删除模型`User`的description列
    db.Model(&User{}).DropColumn("description")

# 索引

## AddIndex

    // 为`name`列添加索引`idx_user_name`
    db.Model(&User{}).AddIndex("idx_user_name", "name")

    // 为`name`, `age`列添加索引`idx_user_name_age`
    db.Model(&User{}).AddIndex("idx_user_name_age", "name", "age")

或者声明普通索引

    Address      string  `gorm:"index:addr"` // create index with name `addr` for address
    Country      string  `gorm:"index:addr"` // create index with name `addr` for address

## AddUniqueIndex

    // 添加唯一索引
    db.Model(&User{}).AddUniqueIndex("idx_name", "name")

    // 为多列添加唯一索引
    db.Model(&User{}).AddUniqueIndex("idx_name_age", "name", "age")

声明索引, 相同的`idx_name_code` 就是联合索引

    Name string `gorm:"unique_index:idx_name_code"` // Create index with name, and will create combined index if find other fields defined same name
    Code string `gorm:"unique_index:idx_name_code"` // `unique_index` also works

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