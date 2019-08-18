---
title: Gorm chain and hooks
date: 2019-08
private:
---
# Gorm Chain
## Method Chaining
Gorm implements method chaining interface:

    db, err := gorm.Open("postgres", "user=gorm dbname=gorm sslmode=disable")

    // create a new relation
    tx := db.Where("name = ?", "jinzhu")

    // add more filter
    if someCondition {
        tx = tx.Where("age = ?", 20)
    } else {
        tx = tx.Where("age = ?", 30)
    }

    if yetAnotherCondition {
        tx = tx.Where("active = ?", 1)
    }

Query won’t be generated until a immediate method, which could be useful in some cases.

## Immediate Methods
Immediate methods are those methods that will generate SQL query and send it to database

    Create, First, Find, Take, Save, UpdateXXX, Delete, Scan, Row, Rows…

Here is an immediate methods example based on above chain:

    tx.Find(&user)
    //Generates
    SELECT * FROM users where name = 'jinzhu' AND age = 30 AND active = 1;

### Multiple Immediate Methods
When using multiple immediate methods with GORM, later immediate method will reuse before immediate methods’s query conditions (excluding inline conditions)

    db.Where("name LIKE ?", "jinzhu%").Find(&users, "id IN (?)", []int{1, 2, 3}).Count(&count)
        //1. SELECT * FROM users WHERE name LIKE 'jinzhu%' AND id IN (1, 2, 3)
        //2. SELECT count(*) FROM users WHERE name LIKE 'jinzhu%'


## Scopes chains
Scope is build based on the method chaining theory.
With it, you could extract some generic logics, to write more reusable libraries.

    func AmountGreaterThan1000(db *gorm.DB) *gorm.DB {
        return db.Where("amount > ?", 1000)
    }

    func PaidWithCreditCard(db *gorm.DB) *gorm.DB {
        return db.Where("pay_mode_sign = ?", "C")
    }

    func PaidWithCod(db *gorm.DB) *gorm.DB {
        return db.Where("pay_mode_sign = ?", "C")
    }

    func OrderStatus(status []string) func (db *gorm.DB) *gorm.DB {
        return func (db *gorm.DB) *gorm.DB {
            return db.Scopes(AmountGreaterThan1000).Where("status IN (?)", status)
        }
    }

    db.Scopes(AmountGreaterThan1000, PaidWithCreditCard).Find(&orders)
    // Find all credit card orders and amount greater than 1000

    db.Scopes(AmountGreaterThan1000, PaidWithCod).Find(&orders)
    // Find all COD orders and amount greater than 1000

    db.Scopes(AmountGreaterThan1000, OrderStatus([]string{"paid", "shipped"})).Find(&orders)
    // Find all paid, shipped orders that amount greater than 1000

# Model
    func (s *DB) Model(value interface{}) *DB

Model specify the model you would like to run db operations

    // update all users's name to `hello`
    db.Model(&User{}).Update("name", "hello")
    // if user's primary key is non-blank, will use it as condition, then will only update the user's name to `hello`
    db.Model(&user).Update("name", "hello")

# Hooks
hooks 绑定了(User/Product..)等model, 而plugin 是全局的

## Creating an object
Available hooks for creating

    // begin transaction
    BeforeSave
    BeforeCreate
    // save before associations
    // update timestamp `CreatedAt`, `UpdatedAt`
    // save self
    // reload fields that have default value and its value is blank
    // save after associations
    AfterCreate
    AfterSave
    // commit or rollback transaction

Code Example:

    func (u *User) BeforeSave() (err error) {
        if u.IsValid() {
            err = errors.New("can't save invalid data")
        }
        return
    }

    func (u *User) AfterCreate(scope *gorm.Scope) (err error) {
        if u.ID == 1 {
        scope.DB().Model(u).Update("role", "admin")
    }
        return
    }

NOTE Save/Delete operations in GORM are running in transactions by default, so changes made in that transaction are not visible until it is commited. If you would like access those changes in your hooks, you could accept current transaction as argument in your hooks, for example:

    func (u *User) AfterCreate(tx *gorm.DB) (err error) {
        tx.Model(u).Update("role", "admin")
        return
    }

## Updating an object
Available hooks for updating

    // begin transaction
    BeforeSave
    BeforeUpdate
    // save before associations
    // update timestamp `UpdatedAt`
    // save self
    // save after associations
    AfterUpdate
    AfterSave
    // commit or rollback transaction

Code Example:

    func (u *User) BeforeUpdate() (err error) {
        if u.readonly() {
            err = errors.New("read only user")
        }
        return
    }

    // Updating data in same transaction
    func (u *User) AfterUpdate(tx *gorm.DB) (err error) {
        if u.Confirmed {
            tx.Model(&Address{}).Where("user_id = ?", u.ID).Update("verfied", true)
        }
        return
    }

## Deleting an object
Available hooks for deleting

    // begin transaction
    BeforeDelete
    // delete self
    AfterDelete
    // commit or rollback transaction

Code Example:

    // Updating data in same transaction
    func (u *User) AfterDelete(tx *gorm.DB) (err error) {
        if u.Confirmed {
            tx.Model(&Address{}).Where("user_id = ?", u.ID).Update("invalid", false)
        }
        return
    }

## Querying an object
Available hooks for querying

    // load data from database
    // Preloading (eager loading)
    AfterFind

Code Example:

    func (u *User) AfterFind() (err error) {
        if u.MemberShip == "" {
            u.MemberShip = "user"
        }
        return
    }

# Plugin
1. 跟hooks 不同，plugin 不绑定Model, plugin是全局的
2. GORM本身由Callbacks提供支持，plugin也是(基于Scope )

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


# Scope function

## Table

    scope.Search.Table(scope.TableName() + "_draft") // 追加 `_draft` 到表名后

## Column

    if scope.HasColumn("Created"){
        scope.SetColumn("Created", "Created by ahuigo")
    }